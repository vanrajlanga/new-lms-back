
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using System.Data;
using System.IO;
using System.Threading.Tasks;
using System.Collections.Generic;
using System;
using LMS.Models;

namespace LMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ContentController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly IWebHostEnvironment _env;

        public ContentController(IConfiguration configuration, IWebHostEnvironment env)
        {
            _configuration = configuration;
            _env = env;
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

        [HttpPost("UploadFile")]
        public async Task<IActionResult> UploadFile(
       [FromForm] IFormFile file,
       [FromForm] int courseId,
       [FromForm] string title,
       [FromForm] string description,
       [FromForm] string contentType)
        {
            if (file == null || file.Length == 0)
                return BadRequest("File is empty.");

            var uploadsPath = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "uploads", "course-content");
            Directory.CreateDirectory(uploadsPath);

            var originalFileName = Path.GetFileName(file.FileName); // Keep exact original name
            var filePath = Path.Combine(uploadsPath, originalFileName);
            var fileUrl = $"/uploads/course-content/{originalFileName}";

            try
            {
                using var stream = new FileStream(filePath, FileMode.Create); // Overwrites if exists
                await file.CopyToAsync(stream);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "File save failed: " + ex.Message);
            }

            int newId = 0;
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_CourseContent_UploadFile", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@CourseId", courseId);
            cmd.Parameters.AddWithValue("@Title", title ?? "");
            cmd.Parameters.AddWithValue("@Description", description ?? "");
            cmd.Parameters.AddWithValue("@FileUrl", fileUrl);
            cmd.Parameters.AddWithValue("@ContentType", contentType ?? "");
            cmd.Parameters.AddWithValue("@UploadedAt", DateTime.UtcNow);

            await conn.OpenAsync();
            var result = await cmd.ExecuteScalarAsync();
            newId = Convert.ToInt32(result);

            return Ok(new
            {
                id = newId,
                courseId,
                title,
                description,
                fileUrl,
                contentType,
                uploadedAt = DateTime.UtcNow
            });
        }



        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_CourseContent_GetById", conn)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@Id", id);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return Ok(ReadRow(reader));

            return NotFound();
        }

        [HttpGet("Course/{courseId}")]
        public async Task<IActionResult> GetByCourse(int courseId)
        {
            var result = new List<Dictionary<string, object>>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_CourseContent_GetByCourse", conn)
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

        [HttpPut("Update/{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CourseContent updated)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_CourseContent_Update", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@Title", updated.Title ?? "");
            cmd.Parameters.AddWithValue("@Description", updated.Description ?? "");
            cmd.Parameters.AddWithValue("@FileUrl", updated.FileUrl ?? "");
            cmd.Parameters.AddWithValue("@ContentType", updated.ContentType ?? "");
            cmd.Parameters.AddWithValue("@UploadedAt", DateTime.UtcNow);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();

            return NoContent();
        }

        [HttpGet("stats/{courseId}")]
        public async Task<IActionResult> GetContentStatsByCourse(int courseId)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_CourseContent_GetStatsByCourse", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@CourseId", courseId);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                int pdfCount = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                int videoCount = reader.IsDBNull(1) ? 0 : reader.GetInt32(1);

                return Ok(new
                {
                    pdfCount,
                    videoCount
                });
            }

            return Ok(new { pdfCount = 0, videoCount = 0 });
        }

        [HttpDelete("Delete/{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            string fileUrl = null;

            using (var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection")))
            {
                var getCmd = new SqlCommand("sp_CourseContent_GetById", conn)
                {
                    CommandType = CommandType.StoredProcedure
                };
                getCmd.Parameters.AddWithValue("@Id", id);
                await conn.OpenAsync();
                using var reader = await getCmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                    fileUrl = reader["FileUrl"].ToString();
                else
                    return NotFound();
            }

            if (!string.IsNullOrWhiteSpace(fileUrl))
            {
                var fullPath = Path.Combine(_env.WebRootPath, fileUrl.TrimStart('/'));
                if (System.IO.File.Exists(fullPath))
                    System.IO.File.Delete(fullPath);
            }

            using var conn2 = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_CourseContent_Delete", conn2)
            {
                CommandType = CommandType.StoredProcedure
            };
            cmd.Parameters.AddWithValue("@Id", id);
            await conn2.OpenAsync();
            await cmd.ExecuteNonQueryAsync();

            return NoContent();
        }
    }

  
}
