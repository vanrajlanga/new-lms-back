
using LMS.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using LMS.DTOs;
using LMS.Models;

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
        [HttpGet("Groups")]
        public async Task<IActionResult> GetGroups(string programmeName, string batchName)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand(@"
        SELECT GroupName
        FROM Groups
        WHERE ProgrammeName = @ProgrammeName AND BatchName = @BatchName
    ", conn);

            cmd.Parameters.AddWithValue("@ProgrammeName", programmeName);
            cmd.Parameters.AddWithValue("@BatchName", batchName);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                result.Add(reader["GroupName"].ToString());
            }

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
        // ? Extending existing CourseController safely without modifying models

        [HttpPost("AssignSubjects")]
        public async Task<IActionResult> AssignSubjects([FromBody] SubjectAssignmentRequest request)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            await conn.OpenAsync();

            // Step 1: Delete existing assignment for combination
            var deleteCmd = new SqlCommand(@"
        DELETE FROM CourseAssignments
        WHERE ProgrammeName = @Programme AND BatchName = @Batch AND GroupName = @Group AND Semester = @Semester", conn);

            deleteCmd.Parameters.AddWithValue("@Programme", request.Programme);
            deleteCmd.Parameters.AddWithValue("@Batch", request.Batch);
            deleteCmd.Parameters.AddWithValue("@Group", request.Group);
            deleteCmd.Parameters.AddWithValue("@Semester", request.Semester);

            await deleteCmd.ExecuteNonQueryAsync();

            // Step 2: Insert new order
            for (int i = 0; i < request.SubjectIds.Count; i++)
            {
                var insertCmd = new SqlCommand(@"
            INSERT INTO CourseAssignments (ProgrammeName, BatchName, GroupName, Semester, CourseId, DisplayOrder)
            VALUES (@Programme, @Batch, @Group, @Semester, @CourseId, @DisplayOrder)", conn);

                insertCmd.Parameters.AddWithValue("@Programme", request.Programme);
                insertCmd.Parameters.AddWithValue("@Batch", request.Batch);
                insertCmd.Parameters.AddWithValue("@Group", request.Group);
                insertCmd.Parameters.AddWithValue("@Semester", request.Semester);
                insertCmd.Parameters.AddWithValue("@CourseId", request.SubjectIds[i]);
                insertCmd.Parameters.AddWithValue("@DisplayOrder", i + 1);

                await insertCmd.ExecuteNonQueryAsync();
            }

            return Ok(new { message = "Subjects assigned successfully." });
        }

        [HttpGet("AssignedSubjects")]
        public async Task<IActionResult> GetAssignedSubjects(string programme, string batch, string group, int semester)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            var cmd = new SqlCommand(@"
        SELECT c.*
        FROM CourseAssignments ca
        JOIN Courses c ON ca.CourseId = c.CourseId
        WHERE ca.ProgrammeName = @Programme AND ca.BatchName = @Batch AND ca.GroupName = @Group AND ca.Semester = @Semester
        ORDER BY ca.DisplayOrder", conn);

            cmd.Parameters.AddWithValue("@Programme", programme);
            cmd.Parameters.AddWithValue("@Batch", batch);
            cmd.Parameters.AddWithValue("@Group", group);
            cmd.Parameters.AddWithValue("@Semester", semester);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }
        [HttpPost("AssignSubjectsById")]
        public async Task<IActionResult> AssignSubjectsById([FromBody] SubjectAssignmentByIdRequest request)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            await conn.OpenAsync();

            // Step 1: Delete previous subject assignments for the same combination
            var deleteCmd = new SqlCommand(@"
        DELETE FROM SubjectAssignments
        WHERE ProgrammeId = @ProgrammeId AND BatchId = @BatchId AND GroupId = @GroupId AND Semester = @Semester", conn);

            deleteCmd.Parameters.AddWithValue("@ProgrammeId", request.ProgrammeId);
            deleteCmd.Parameters.AddWithValue("@BatchId", request.BatchId);
            deleteCmd.Parameters.AddWithValue("@GroupId", request.GroupId);
            deleteCmd.Parameters.AddWithValue("@Semester", request.Semester);

            await deleteCmd.ExecuteNonQueryAsync();

            // Step 2: Insert new subject assignments
            for (int i = 0; i < request.SubjectIds.Count; i++)
            {
                var insertCmd = new SqlCommand(@"
            INSERT INTO SubjectAssignments (ProgrammeId, BatchId, GroupId, Semester, CourseId, DisplayOrder)
            VALUES (@ProgrammeId, @BatchId, @GroupId, @Semester, @CourseId, @DisplayOrder)", conn);

                insertCmd.Parameters.AddWithValue("@ProgrammeId", request.ProgrammeId);
                insertCmd.Parameters.AddWithValue("@BatchId", request.BatchId);
                insertCmd.Parameters.AddWithValue("@GroupId", request.GroupId);
                insertCmd.Parameters.AddWithValue("@Semester", request.Semester);
                insertCmd.Parameters.AddWithValue("@CourseId", request.SubjectIds[i]);
                insertCmd.Parameters.AddWithValue("@DisplayOrder", i + 1);

                await insertCmd.ExecuteNonQueryAsync();
            }

            return Ok(new { message = "Subjects assigned successfully to SubjectAssignments table." });
        }


        public class SubjectAssignmentRequest
        {
            public string Programme { get; set; }
            public string Batch { get; set; }
            public string Group { get; set; }
            public int Semester { get; set; }
            public List<int> SubjectIds { get; set; }
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
