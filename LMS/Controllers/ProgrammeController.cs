//// ================================================
//// File: ProgrammeController.cs (SP-backed version)
//// ================================================

//using Microsoft.AspNetCore.Mvc;
//using Microsoft.Data.SqlClient;
//using Microsoft.EntityFrameworkCore;
//using Microsoft.Extensions.Logging;
//using LMS.Data;
//using LMS.Models;
//using System.Data;

//namespace LMS.Controllers
//{
//    [Route("api/[controller]")]
//    [ApiController]
//    public class ProgrammeController : ControllerBase
//    {
//        private readonly AppDbContext _context;
//        private readonly ILogger<ProgrammeController> _logger;
//        private readonly string _connection;

//        public ProgrammeController(AppDbContext context, ILogger<ProgrammeController> logger)
//        {
//            _context = context;
//            _logger = logger;
//            _connection = _context.Database.GetConnectionString();
//        }

//        [HttpGet("All")]
//        public async Task<ActionResult<IEnumerable<Programme>>> GetAllProgrammes()
//        {
//            var result = new List<Programme>();
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_GetAllProgrammes", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            await conn.OpenAsync();
//            using var reader = await cmd.ExecuteReaderAsync();
//            while (await reader.ReadAsync())
//            {
//                result.Add(new Programme
//                {
//                    ProgrammeId = (int)reader["ProgrammeId"],
//                    ProgrammeName = reader["ProgrammeName"].ToString(),
//                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
//                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
//                    Fee = (decimal)reader["Fee"],
//                    CreatedDate = (DateTime)reader["CreatedDate"],
//                    UpdatedDate = (DateTime)reader["UpdatedDate"]
//                });
//            }
//            return Ok(result);
//        }

//        [HttpGet("ProgrammesWithSemesters")]
//        public async Task<IActionResult> GetProgrammesWithSemesters()
//        {
//            var result = new List<object>();
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_GetProgrammesWithSemesters", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            await conn.OpenAsync();
//            using var reader = await cmd.ExecuteReaderAsync();
//            while (await reader.ReadAsync())
//            {
//                result.Add(new
//                {
//                    ProgrammeName = reader["ProgrammeName"].ToString(),
//                    Semester = reader["Semester"].ToString(),
//                    CourseId = Convert.ToInt32(reader["CourseId"]),
//                    Name = reader["Name"].ToString(),
//                    CourseCode = reader["CourseCode"].ToString(),
//                    Credits = Convert.ToInt32(reader["Credits"]),
//                    CourseDescription = reader["CourseDescription"].ToString()
//                });
//            }
//            return Ok(result);
//        }

//        [HttpGet("WithCourses/{programmeCode}")]
//        public async Task<IActionResult> GetProgrammeWithCourses(string programmeCode)
//        {
//            var courses = new List<object>();
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_GetProgrammeWithCourses", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            cmd.Parameters.AddWithValue("@ProgrammeCode", programmeCode);
//            await conn.OpenAsync();
//            using var reader = await cmd.ExecuteReaderAsync();
//            while (await reader.ReadAsync())
//            {
//                courses.Add(new
//                {
//                    CourseId = (int)reader["CourseId"],
//                    Name = reader["Name"].ToString(),
//                    CourseCode = reader["CourseCode"].ToString(),
//                    Credits = (int)reader["Credits"],
//                    CourseDescription = reader["CourseDescription"].ToString(),
//                    Semester = reader["Semester"].ToString()
//                });
//            }
//            return courses.Count == 0 ? NotFound("No courses found for this programme.") : Ok(new { programmeCode, courses });
//        }

//        [HttpGet("ByCode/{code}")]
//        public async Task<IActionResult> GetProgrammeByCode(string code)
//        {
//            Programme programme = null;
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_GetProgrammeByCode", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            cmd.Parameters.AddWithValue("@ProgrammeCode", code);
//            await conn.OpenAsync();
//            using var reader = await cmd.ExecuteReaderAsync();
//            if (await reader.ReadAsync())
//            {
//                programme = new Programme
//                {
//                    ProgrammeId = (int)reader["ProgrammeId"],
//                    ProgrammeName = reader["ProgrammeName"].ToString(),
//                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
//                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
//                    Fee = (decimal)reader["Fee"],
//                    CreatedDate = (DateTime)reader["CreatedDate"],
//                    UpdatedDate = (DateTime)reader["UpdatedDate"]
//                };
//            }
//            return programme == null ? NotFound("Programme not found.") : Ok(programme);
//        }

//        [HttpGet("{id:int}")]
//        public async Task<ActionResult<Programme>> GetProgramme(int id)
//        {
//            Programme programme = null;
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_GetProgramme", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            cmd.Parameters.AddWithValue("@ProgrammeId", id);
//            await conn.OpenAsync();
//            using var reader = await cmd.ExecuteReaderAsync();
//            if (await reader.ReadAsync())
//            {
//                programme = new Programme
//                {
//                    ProgrammeId = (int)reader["ProgrammeId"],
//                    ProgrammeName = reader["ProgrammeName"].ToString(),
//                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
//                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
//                    Fee = (decimal)reader["Fee"],
//                    CreatedDate = (DateTime)reader["CreatedDate"],
//                    UpdatedDate = (DateTime)reader["UpdatedDate"]
//                };
//            }
//            return programme == null ? NotFound() : Ok(programme);
//        }

//        [HttpPost]
//        public async Task<ActionResult<Programme>> CreateProgramme([FromBody] Programme programme)
//        {
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_CreateProgramme", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            cmd.Parameters.AddWithValue("@ProgrammeName", programme.ProgrammeName);
//            cmd.Parameters.AddWithValue("@ProgrammeCode", programme.ProgrammeCode);
//            cmd.Parameters.AddWithValue("@NumberOfSemesters", programme.NumberOfSemesters);
//            cmd.Parameters.AddWithValue("@Fee", programme.Fee);
//            await conn.OpenAsync();
//            using var reader = await cmd.ExecuteReaderAsync();
//            Programme created = null;
//            if (await reader.ReadAsync())
//            {
//                created = new Programme
//                {
//                    ProgrammeId = (int)reader["ProgrammeId"],
//                    ProgrammeName = reader["ProgrammeName"].ToString(),
//                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
//                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
//                    Fee = (decimal)reader["Fee"],
//                    CreatedDate = (DateTime)reader["CreatedDate"],
//                    UpdatedDate = (DateTime)reader["UpdatedDate"]
//                };
//            }
//            return CreatedAtAction(nameof(GetProgramme), new { id = created.ProgrammeId }, created);
//        }

//        [HttpPut("Update/{id}")]
//        public async Task<IActionResult> UpdateProgramme(int id, [FromBody] Programme updated)
//        {
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_UpdateProgramme", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            cmd.Parameters.AddWithValue("@ProgrammeId", id);
//            cmd.Parameters.AddWithValue("@ProgrammeName", updated.ProgrammeName);
//            cmd.Parameters.AddWithValue("@ProgrammeCode", updated.ProgrammeCode);
//            cmd.Parameters.AddWithValue("@NumberOfSemesters", updated.NumberOfSemesters);
//            cmd.Parameters.AddWithValue("@Fee", updated.Fee);
//            await conn.OpenAsync();
//            await cmd.ExecuteNonQueryAsync();
//            return NoContent();
//        }

//        [HttpDelete("{id}")]
//        public async Task<IActionResult> DeleteProgramme(int id)
//        {
//            using var conn = new SqlConnection(_connection);
//            using var cmd = new SqlCommand("sp_Programme_DeleteProgramme", conn);
//            cmd.CommandType = CommandType.StoredProcedure;
//            cmd.Parameters.AddWithValue("@ProgrammeId", id);
//            await conn.OpenAsync();
//            await cmd.ExecuteNonQueryAsync();
//            return NoContent();
//        }
//    }
//}
// ================================================
// File: ProgrammeController.cs (SP-backed version)
// ================================================

using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using LMS.Data;
using LMS.Models;
using System.Data;

namespace LMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProgrammeController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ILogger<ProgrammeController> _logger;
        private readonly string _connection;

        public ProgrammeController(AppDbContext context, ILogger<ProgrammeController> logger)
        {
            _context = context;
            _logger = logger;
            _connection = _context.Database.GetConnectionString();
        }

        [HttpGet("All")]
        public async Task<ActionResult<IEnumerable<Programme>>> GetAllProgrammes()
        {
            var result = new List<Programme>();
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_GetAllProgrammes", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                result.Add(new Programme
                {
                    ProgrammeId = (int)reader["ProgrammeId"],
                    ProgrammeName = reader["ProgrammeName"].ToString(),
                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
                    Fee = (decimal)reader["Fee"],
                    BatchName = reader["BatchName"].ToString(),
                    CreatedDate = (DateTime)reader["CreatedDate"],
                    UpdatedDate = (DateTime)reader["UpdatedDate"]
                });
            }
            return Ok(result);
        }

        [HttpGet("ProgrammesWithSemesters")]
        public async Task<IActionResult> GetProgrammesWithSemesters()
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_GetProgrammesWithSemesters", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                result.Add(new
                {
                    ProgrammeName = reader["ProgrammeName"].ToString(),
                    Semester = reader["Semester"].ToString(),
                    CourseId = Convert.ToInt32(reader["CourseId"]),
                    Name = reader["Name"].ToString(),
                    CourseCode = reader["CourseCode"].ToString(),
                    Credits = Convert.ToInt32(reader["Credits"]),
                    CourseDescription = reader["CourseDescription"].ToString()
                });
            }
            return Ok(result);
        }

        [HttpGet("WithCourses/{programmeCode}")]
        public async Task<IActionResult> GetProgrammeWithCourses(string programmeCode)
        {
            var courses = new List<object>();
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_GetProgrammeWithCourses", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProgrammeCode", programmeCode);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                courses.Add(new
                {
                    CourseId = (int)reader["CourseId"],
                    Name = reader["Name"].ToString(),
                    CourseCode = reader["CourseCode"].ToString(),
                    Credits = (int)reader["Credits"],
                    CourseDescription = reader["CourseDescription"].ToString(),
                    Semester = reader["Semester"].ToString()
                });
            }
            return courses.Count == 0 ? NotFound("No courses found for this programme.") : Ok(new { programmeCode, courses });
        }

        [HttpGet("ByCode/{code}")]
        public async Task<IActionResult> GetProgrammeByCode(string code)
        {
            Programme programme = null;
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_GetProgrammeByCode", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProgrammeCode", code);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                programme = new Programme
                {
                    ProgrammeId = (int)reader["ProgrammeId"],
                    ProgrammeName = reader["ProgrammeName"].ToString(),
                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
                    Fee = (decimal)reader["Fee"],
                    BatchName = reader["BatchName"].ToString(),
                    CreatedDate = (DateTime)reader["CreatedDate"],
                    UpdatedDate = (DateTime)reader["UpdatedDate"]
                };
            }
            return programme == null ? NotFound("Programme not found.") : Ok(programme);
        }

        [HttpGet("{id:int}")]
        public async Task<ActionResult<Programme>> GetProgramme(int id)
        {
            Programme programme = null;
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_GetProgramme", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProgrammeId", id);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                programme = new Programme
                {
                    ProgrammeId = (int)reader["ProgrammeId"],
                    ProgrammeName = reader["ProgrammeName"].ToString(),
                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
                    Fee = (decimal)reader["Fee"],
                    BatchName = reader["BatchName"].ToString(),
                    CreatedDate = (DateTime)reader["CreatedDate"],
                    UpdatedDate = (DateTime)reader["UpdatedDate"]
                };
            }
            return programme == null ? NotFound() : Ok(programme);
        }

        [HttpPost]
        public async Task<ActionResult<Programme>> CreateProgramme([FromBody] Programme programme)
        {
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_CreateProgramme", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProgrammeName", programme.ProgrammeName);
            cmd.Parameters.AddWithValue("@ProgrammeCode", programme.ProgrammeCode);
            cmd.Parameters.AddWithValue("@NumberOfSemesters", programme.NumberOfSemesters);
            cmd.Parameters.AddWithValue("@Fee", programme.Fee);
            cmd.Parameters.AddWithValue("@BatchName", programme.BatchName);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            Programme created = null;
            if (await reader.ReadAsync())
            {
                created = new Programme
                {
                    ProgrammeId = (int)reader["ProgrammeId"],
                    ProgrammeName = reader["ProgrammeName"].ToString(),
                    ProgrammeCode = reader["ProgrammeCode"].ToString(),
                    NumberOfSemesters = (int)reader["NumberOfSemesters"],
                    Fee = (decimal)reader["Fee"],
                    BatchName = reader["BatchName"].ToString(),
                    CreatedDate = (DateTime)reader["CreatedDate"],
                    UpdatedDate = (DateTime)reader["UpdatedDate"]
                };
            }
            return CreatedAtAction(nameof(GetProgramme), new { id = created.ProgrammeId }, created);
        }

        [HttpPut("Update/{id}")]
        public async Task<IActionResult> UpdateProgramme(int id, [FromBody] Programme updated)
        {
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_UpdateProgramme", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProgrammeId", id);
            cmd.Parameters.AddWithValue("@ProgrammeName", updated.ProgrammeName);
            cmd.Parameters.AddWithValue("@ProgrammeCode", updated.ProgrammeCode);
            cmd.Parameters.AddWithValue("@NumberOfSemesters", updated.NumberOfSemesters);
            cmd.Parameters.AddWithValue("@Fee", updated.Fee);
            cmd.Parameters.AddWithValue("@BatchName", updated.BatchName);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProgramme(int id)
        {
            using var conn = new SqlConnection(_connection);
            using var cmd = new SqlCommand("sp_Programme_DeleteProgramme", conn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ProgrammeId", id);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return NoContent();
        }
    }
}

