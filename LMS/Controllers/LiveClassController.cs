// File: Controllers/LiveClassController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using System;
using System.Text.Json;

namespace LMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LiveClassController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public LiveClassController(IConfiguration configuration)
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

        [HttpGet("All")]
        public async Task<IActionResult> GetLiveClasses()
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_GetAll", conn) { CommandType = CommandType.StoredProcedure };
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetLiveClass(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_GetById", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@LiveClassId", id);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Ok(ReadRow(reader)) : NotFound();
        }

        [HttpPost("Create")]
        public async Task<IActionResult> CreateLiveClass([FromBody] JsonElement liveClass)
        {
            if (!liveClass.TryGetProperty("startTime", out var startProp) ||
                !liveClass.TryGetProperty("endTime", out var endProp))
            {
                return BadRequest("Missing startTime or endTime.");
            }

            DateTime startTime = startProp.GetDateTime();
            DateTime endTime = endProp.GetDateTime();
            int duration = (int)(endTime - startTime).TotalMinutes;

            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_Create", conn) { CommandType = CommandType.StoredProcedure };

            cmd.Parameters.AddWithValue("@ClassName", liveClass.GetProperty("className").GetString());
            cmd.Parameters.AddWithValue("@InstructorId", liveClass.GetProperty("instructorId").GetInt32());
            cmd.Parameters.AddWithValue("@CourseId", liveClass.GetProperty("courseId").GetInt32());
            cmd.Parameters.AddWithValue("@Semester", liveClass.GetProperty("semester").GetString());
            cmd.Parameters.AddWithValue("@Programme", liveClass.GetProperty("programme").GetString());
            cmd.Parameters.AddWithValue("@StartTime", startTime);
            cmd.Parameters.AddWithValue("@EndTime", endTime);
            cmd.Parameters.AddWithValue("@DurationMinutes", duration);
            cmd.Parameters.AddWithValue("@MeetingLink", liveClass.GetProperty("meetingLink").GetString());
            cmd.Parameters.AddWithValue("@Status", "Upcoming");

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Ok(ReadRow(reader)) : BadRequest();
        }

        [HttpGet("Instructor/{instructorId}")]
        public async Task<IActionResult> GetInstructorLiveClasses(int instructorId)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_GetByInstructor", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@InstructorId", instructorId);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));
            return Ok(result);
        }

        [HttpGet("Student/{studentId}")]
        public async Task<IActionResult> GetStudentLiveClasses(int studentId)
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_GetByStudent", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@StudentId", studentId);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));
            return Ok(result);
        }

        [HttpPut("Update/{id}")]
        public async Task<IActionResult> UpdateLiveClass(int id, [FromBody] JsonElement request)
        {
            try
            {
                var startTime = request.GetProperty("startTime").GetDateTime();
                var endTime = request.GetProperty("endTime").GetDateTime();
                var duration = (int)(endTime - startTime).TotalMinutes;

                using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
                using var cmd = new SqlCommand("sp_LiveClass_Update", conn) { CommandType = CommandType.StoredProcedure };

                cmd.Parameters.AddWithValue("@LiveClassId", id);
                cmd.Parameters.AddWithValue("@ClassName", request.GetProperty("className").GetString());
                cmd.Parameters.AddWithValue("@InstructorId", request.GetProperty("instructorId").GetInt32());
                cmd.Parameters.AddWithValue("@CourseId", request.GetProperty("courseId").GetInt32());
                cmd.Parameters.AddWithValue("@Semester", request.GetProperty("semester").GetString());
                cmd.Parameters.AddWithValue("@Programme", request.GetProperty("programme").GetString());
                cmd.Parameters.AddWithValue("@StartTime", startTime);
                cmd.Parameters.AddWithValue("@EndTime", endTime);
                cmd.Parameters.AddWithValue("@DurationMinutes", duration);
                cmd.Parameters.AddWithValue("@MeetingLink", request.GetProperty("meetingLink").GetString());
                cmd.Parameters.AddWithValue("@Status", request.GetProperty("status").GetString());

                await conn.OpenAsync();
                using var reader = await cmd.ExecuteReaderAsync();
                return await reader.ReadAsync() ? Ok(ReadRow(reader)) : NotFound("Live Class not found.");
            }
            catch (KeyNotFoundException)
            {
                return BadRequest("Missing one or more required fields.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal error: {ex.Message}");
            }
        }


        [HttpDelete("Delete/{id}")]
        public async Task<IActionResult> DeleteLiveClass(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_Delete", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@LiveClassId", id);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return NoContent();
        }

        [HttpGet("Upcoming/{courseId}")]
        public async Task<IActionResult> GetUpcomingLiveClassByCourse(int courseId)
        {
            if (courseId <= 0) return BadRequest("Invalid course ID.");

            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_LiveClass_GetUpcomingByCourse", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                var upcoming = ReadRow(reader);
                var start = Convert.ToDateTime(upcoming["startTime"]);
                return Ok(new
                {
                    hasUpcoming = true,
                    message = $"Live class on {start:dddd, MMM dd @ h:mm tt}"
                });
            }

            return Ok(new
            {
                hasUpcoming = false,
                message = "No Live Class Scheduled For Upcoming Week"
            });
        }
    }
}
