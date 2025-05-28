// File: Controllers/LibraryController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Text.Json;
using System.Threading.Tasks;

namespace LMS.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LibraryController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public LibraryController(IConfiguration configuration)
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

        [HttpGet("books")]
        public async Task<IActionResult> GetBooks()
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Library_GetBooks", conn) { CommandType = CommandType.StoredProcedure };
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));
            return Ok(result);
        }

        [HttpGet("books/{id}")]
        public async Task<IActionResult> GetBook(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Library_GetBookById", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@BookId", id);
            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Ok(ReadRow(reader)) : NotFound();
        }

        [HttpPost("books")]
        public async Task<IActionResult> AddBook([FromBody] JsonElement book)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Library_AddBook", conn) { CommandType = CommandType.StoredProcedure };

            cmd.Parameters.AddWithValue("@Title", book.GetProperty("title").GetString());
            cmd.Parameters.AddWithValue("@Author", book.GetProperty("author").GetString());
            cmd.Parameters.AddWithValue("@ISBN", book.GetProperty("isbn").GetString());
            cmd.Parameters.AddWithValue("@Category", book.GetProperty("category").GetString());
            cmd.Parameters.AddWithValue("@TotalCopies", book.GetProperty("totalCopies").GetInt32());
            cmd.Parameters.AddWithValue("@AvailableCopies", book.GetProperty("availableCopies").GetInt32());

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Ok(ReadRow(reader)) : BadRequest();
        }


        [HttpPut("books/{id}")]
        public async Task<IActionResult> UpdateBook(int id, [FromBody] dynamic book)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Library_UpdateBook", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@BookId", id);
            cmd.Parameters.AddWithValue("@Title", (string)book.title);
            cmd.Parameters.AddWithValue("@Author", (string)book.author);
            cmd.Parameters.AddWithValue("@ISBN", (string)book.isbn);
            cmd.Parameters.AddWithValue("@Category", (string)book.category);
            cmd.Parameters.AddWithValue("@TotalCopies", (int)book.totalCopies);
            cmd.Parameters.AddWithValue("@AvailableCopies", (int)book.availableCopies);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Ok(ReadRow(reader)) : NotFound();
        }

        [HttpDelete("books/{id}")]
        public async Task<IActionResult> DeleteBook(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Library_DeleteBook", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@BookId", id);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return NoContent();
        }
    }
}
