
using LMS.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using LMS.DTOs;

namespace LMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourseController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public CourseController(IConfiguration configuration)
        {
            _configuration = configuration;
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

        [HttpGet("ByProgrammeAndSemester")]
        public async Task<IActionResult> GetCoursesByProgrammeAndSemester(string programme, int semester)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_GetByProgrammeAndSemester", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@Programme", programme);
            cmd.Parameters.AddWithValue("@Semester", semester.ToString());

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }

        [HttpGet("by-instructor/{instructorId}")]
        public async Task<IActionResult> GetCoursesByInstructor(int instructorId)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_GetByInstructor", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@InstructorId", instructorId);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }

        [HttpPost("Create")]
        public async Task<IActionResult> CreateCourse([FromBody] CourseCreateRequest course)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_Create", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Name", course.Name);
            cmd.Parameters.AddWithValue("@CourseCode", course.CourseCode);
            cmd.Parameters.AddWithValue("@Credits", course.Credits);
            cmd.Parameters.AddWithValue("@CourseDescription", course.CourseDescription);
            cmd.Parameters.AddWithValue("@Programme", course.Programme);
            cmd.Parameters.AddWithValue("@Semester", course.Semester);
            cmd.Parameters.AddWithValue("@CreatedDate", DateTime.UtcNow);
            cmd.Parameters.AddWithValue("@UpdatedDate", DateTime.UtcNow);

            await conn.OpenAsync();
            var insertedId = Convert.ToInt32(await cmd.ExecuteScalarAsync());

            return Ok(new { courseId = insertedId });
        }


        [HttpGet("{id}")]
        public async Task<IActionResult> GetCourse(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_GetById", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@CourseId", id);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return Ok(ReadRow(reader));

            return NotFound();
        }

        [HttpGet("All")]
        public async Task<IActionResult> GetAllCourses()
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_GetAll", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }

        [HttpPut("Update/{id}")]
        public async Task<IActionResult> UpdateCourse(int id, [FromBody] CourseUpdateDto dto)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_Update", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@CourseId", id);
            cmd.Parameters.AddWithValue("@Name", dto.Name ?? string.Empty);
            cmd.Parameters.AddWithValue("@CourseCode", dto.CourseCode ?? string.Empty);
            cmd.Parameters.AddWithValue("@Credits", dto.Credits);
            cmd.Parameters.AddWithValue("@CourseDescription", dto.CourseDescription ?? string.Empty);
            cmd.Parameters.AddWithValue("@Programme", dto.Programme ?? string.Empty);
            cmd.Parameters.AddWithValue("@Semester", dto.Semester ?? string.Empty);
            cmd.Parameters.AddWithValue("@UpdatedDate", DateTime.UtcNow);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();

            return NoContent();
        }
        [HttpDelete("Delete/{id}")]
        public async Task<IActionResult> DeleteCourse(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_Delete", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@CourseId", id);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();

            return NoContent();
        }

        [HttpGet("{courseId}/students")]
        public async Task<IActionResult> GetStudentsForCourse(int courseId)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_GetEnrolledStudents", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@CourseId", courseId);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }

        [HttpGet("CoursesForStudent/{userId}")]
        public async Task<IActionResult> GetCoursesForStudent(int userId)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Course_GetByStudent", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@UserId", userId);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }
        [HttpPost("AssignCourseGroup")]
        public async Task<IActionResult> AssignCourseGroup([FromBody] CourseGroupAssignmentDto dto)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));

            // Step 1: Get existing course
            using var getCmd = new SqlCommand("sp_Course_GetById", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            getCmd.Parameters.AddWithValue("@CourseId", dto.CourseId);

            await conn.OpenAsync();
            CourseUpdateDto existing = null;

            using (var reader = await getCmd.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    existing = new CourseUpdateDto
                    {
                        Name = reader["Name"]?.ToString(),
                        CourseCode = reader["CourseCode"]?.ToString(),
                        Credits = Convert.ToInt32(reader["Credits"]),
                        CourseDescription = reader["CourseDescription"]?.ToString(),
                        Programme = dto.ProgrammeId.ToString(),
                        Semester = dto.Semester.ToString()
                    };
                }
            }

            if (existing == null)
                return NotFound("Course not found");

            // Step 2: Update with new Programme + Group + Semester
            using var updateCmd = new SqlCommand("sp_Course_Update", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            updateCmd.Parameters.AddWithValue("@CourseId", dto.CourseId);
            updateCmd.Parameters.AddWithValue("@Name", existing.Name);
            updateCmd.Parameters.AddWithValue("@CourseCode", existing.CourseCode);
            updateCmd.Parameters.AddWithValue("@Credits", existing.Credits);
            updateCmd.Parameters.AddWithValue("@CourseDescription", existing.CourseDescription);
            updateCmd.Parameters.AddWithValue("@Programme", dto.ProgrammeId.ToString());
            updateCmd.Parameters.AddWithValue("@Semester", dto.Semester.ToString());
            updateCmd.Parameters.AddWithValue("@UpdatedDate", DateTime.UtcNow);

            await updateCmd.ExecuteNonQueryAsync();

            return Ok(new { message = "Course assignment updated successfully" });
        }



        [HttpGet("WithCourses")]
        public async Task<IActionResult> GetDepartmentsWithCourses()
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Department_GetWithCourses", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }
    }
}
