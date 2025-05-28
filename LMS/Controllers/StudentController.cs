// File: Controllers/StudentController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using LMS.DTOs;
using System;
using LMS.Services;

namespace LMS.Controllers
{
    [Route("api/student")]
    [ApiController]
    public class StudentController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly IFeeService _feeService;

        public StudentController(IConfiguration configuration, IFeeService feeService)
        {
            _configuration = configuration;
            _feeService = feeService;
        }

        private Dictionary<string, object> ReadRow(SqlDataReader reader)
        {
            var row = new Dictionary<string, object>();
            for (int i = 0; i < reader.FieldCount; i++)
            {
                var name = reader.GetName(i);
                var camel = char.ToLowerInvariant(name[0]) + name.Substring(1);
                row[camel] = reader.IsDBNull(i) ? null : reader.GetValue(i);
            }
            return row;
        }

        [HttpGet("students")]
        public async Task<ActionResult<IEnumerable<object>>> GetStudents()
        {
            var list = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Student_GetStudents", conn) { CommandType = CommandType.StoredProcedure };
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                list.Add(ReadRow(reader));
            return Ok(list);
        }
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] StudentRegisterDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));

                // Step 1: Call SP to create user and get username
                using var cmd = new SqlCommand("sp_Student_Register", conn) { CommandType = CommandType.StoredProcedure };

                var usernameParam = new SqlParameter("@Username", SqlDbType.VarChar, 7)
                {
                    Direction = ParameterDirection.Output
                };

                cmd.Parameters.AddWithValue("@Email", request.Email);
                cmd.Parameters.AddWithValue("@PasswordHash", "TEMP");
                cmd.Parameters.AddWithValue("@FirstName", request.FirstName);
                cmd.Parameters.AddWithValue("@LastName", request.LastName);
                cmd.Parameters.AddWithValue("@PhoneNumber", request.PhoneNumber);
                cmd.Parameters.AddWithValue("@Gender", request.Gender);
                cmd.Parameters.AddWithValue("@DateOfBirth", request.DateOfBirth);
                cmd.Parameters.AddWithValue("@ProfilePhotoUrl", request.ProfilePhotoUrl);
                cmd.Parameters.AddWithValue("@Address", request.Address);
                cmd.Parameters.AddWithValue("@City", request.City);
                cmd.Parameters.AddWithValue("@State", request.State);
                cmd.Parameters.AddWithValue("@Country", request.Country);
                cmd.Parameters.AddWithValue("@ZipCode", request.ZipCode);
                cmd.Parameters.AddWithValue("@Programme", request.Programme);
                cmd.Parameters.AddWithValue("@Semester", request.Semester);
                cmd.Parameters.Add(usernameParam);

                await conn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();

                var generatedUsername = usernameParam.Value?.ToString();
                if (string.IsNullOrEmpty(generatedUsername))
                    return StatusCode(500, "Username generation failed.");

                // Step 2: Use username as password
                var rawPassword = generatedUsername;
                var hashedPassword = BCrypt.Net.BCrypt.HashPassword(rawPassword);

                // Step 3: Update password
                using var updateCmd = new SqlCommand("UPDATE Users SET PasswordHash = @PasswordHash WHERE Username = @Username", conn);
                updateCmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
                updateCmd.Parameters.AddWithValue("@Username", generatedUsername);
                await updateCmd.ExecuteNonQueryAsync();

                // Step 4: Get newly created UserId
                using var userIdCmd = new SqlCommand("SELECT UserId FROM Users WHERE Username = @Username", conn);
                userIdCmd.Parameters.AddWithValue("@Username", generatedUsername);
                var userIdObj = await userIdCmd.ExecuteScalarAsync();
                if (userIdObj == null)
                    return StatusCode(500, "Failed to retrieve UserId.");
                int userId = Convert.ToInt32(userIdObj);

                // Step 5: Auto-assign courses based on Programme and Semester
                using var courseCmd = new SqlCommand("SELECT CourseId, Semester FROM Courses WHERE LOWER(RTRIM(Programme)) = LOWER(RTRIM(@Programme))", conn);
                courseCmd.Parameters.AddWithValue("@Programme", request.Programme);
                using var reader = await courseCmd.ExecuteReaderAsync();

                var semesterDigits = new string(request.Semester.Where(char.IsDigit).ToArray());
                var matchedCourseIds = new List<int>();

                while (await reader.ReadAsync())
                {
                    var courseSemester = reader["Semester"]?.ToString() ?? "";
                    var courseDigits = new string(courseSemester.Where(char.IsDigit).ToArray());
                    if (courseDigits == semesterDigits && int.TryParse(reader["CourseId"].ToString(), out int cid))
                        matchedCourseIds.Add(cid);
                }
                reader.Close();

                foreach (var courseId in matchedCourseIds)
                {
                    using var assignCmd = new SqlCommand(@"INSERT INTO StudentCourses (UserId, CourseId, CompletionStatus, Grade, DateAssigned)
                                                   VALUES (@UserId, @CourseId, 'NotStarted', 'N/A', @Now)", conn);
                    assignCmd.Parameters.AddWithValue("@UserId", userId);
                    assignCmd.Parameters.AddWithValue("@CourseId", courseId);
                    assignCmd.Parameters.AddWithValue("@Now", DateTime.UtcNow);
                    await assignCmd.ExecuteNonQueryAsync();
                }

                // Step 6: Generate semester fee
                await _feeService.GenerateSemesterFeeForCurrentSemester(userId, request.Semester);

                return Ok(new
                {
                    Username = generatedUsername,
                    Password = rawPassword,
                    Message = "Student registered successfully"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> DeleteStudent(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Student_DeleteStudent", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@StudentId", id); // ✅ Fixed here
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return Ok(new { message = "Student deleted successfully." });
        }


        [HttpGet("details/{id}")]
        public async Task<ActionResult<object>> GetStudentDetails(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Student_GetStudentDetails", conn) { CommandType = CommandType.StoredProcedure };

            cmd.Parameters.AddWithValue("@UserId", id); // ✅ Correct parameter name

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return Ok(ReadRow(reader));

            return NotFound("Student not found.");
        }



        [HttpGet("profile")]
        public async Task<ActionResult<object>> GetStudentProfile()
        {
            var userIdClaim = User.FindFirst("UserId");
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
                return Unauthorized(new { error = "Token missing UserId" });

            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Student_GetStudentProfile", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@UserId", userId);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return Ok(ReadRow(reader));
            return NotFound("Student not found");
        }

        [HttpPut("update/{studentId}")]
        public async Task<IActionResult> UpdateStudent(int studentId, [FromBody] StudentCreateUpdateDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
                await conn.OpenAsync();

                using (var cmd = new SqlCommand("sp_Student_UpdateStudent", conn) { CommandType = CommandType.StoredProcedure })
                {
                    cmd.Parameters.AddWithValue("@UserId", studentId);
                    cmd.Parameters.AddWithValue("@Email", request.Email);
                    cmd.Parameters.AddWithValue("@FirstName", request.FirstName);
                    cmd.Parameters.AddWithValue("@LastName", request.LastName);
                    cmd.Parameters.AddWithValue("@PhoneNumber", request.PhoneNumber);
                    cmd.Parameters.AddWithValue("@DateOfBirth", request.DateOfBirth);
                    cmd.Parameters.AddWithValue("@Gender", request.Gender);
                    cmd.Parameters.AddWithValue("@Address", request.Address);
                    cmd.Parameters.AddWithValue("@City", request.City);
                    cmd.Parameters.AddWithValue("@State", request.State);
                    cmd.Parameters.AddWithValue("@Country", request.Country);
                    cmd.Parameters.AddWithValue("@ZipCode", request.ZipCode);
                    cmd.Parameters.AddWithValue("@ProfilePhotoUrl", request.ProfilePhotoUrl);
                    cmd.Parameters.AddWithValue("@Programme", request.Programme);
                    cmd.Parameters.AddWithValue("@Semester", request.Semester);

                    await cmd.ExecuteNonQueryAsync();
                }

                using var fetchCmd = new SqlCommand("sp_Student_GetStudentDetails", conn) { CommandType = CommandType.StoredProcedure };
                fetchCmd.Parameters.AddWithValue("@UserId", studentId);

                using var reader = await fetchCmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    return Ok(new
                    {
                        Message = "Student updated successfully",
                        Student = ReadRow(reader)
                    });
                }

                return StatusCode(500, "Update succeeded but student could not be reloaded.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

    }
}
