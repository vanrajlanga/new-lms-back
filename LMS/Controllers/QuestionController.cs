// File: Controllers/QuestionController.cs (Patched for ADO.NET)
using LMS.Models.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using LMS.DTOs;


namespace LMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class QuestionController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public QuestionController(IConfiguration configuration)
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

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = new List<object>();
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Question_GetAll", conn) { CommandType = CommandType.StoredProcedure };

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));

            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Question_GetById", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@Id", id);

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return Ok(ReadRow(reader));

            return NotFound();
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] object q)
        {
            var json = (System.Text.Json.JsonElement)q;

            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Question_Create", conn) { CommandType = CommandType.StoredProcedure };

            cmd.Parameters.AddWithValue("@Subject", json.GetProperty("subject").GetString());
            cmd.Parameters.AddWithValue("@Topic", json.GetProperty("topic").GetString());
            cmd.Parameters.AddWithValue("@QuestionText", json.GetProperty("questionText").GetString());
            cmd.Parameters.AddWithValue("@OptionA", json.GetProperty("optionA").GetString());
            cmd.Parameters.AddWithValue("@OptionB", json.GetProperty("optionB").GetString());
            cmd.Parameters.AddWithValue("@OptionC", json.GetProperty("optionC").GetString());
            cmd.Parameters.AddWithValue("@OptionD", json.GetProperty("optionD").GetString());
            cmd.Parameters.AddWithValue("@CorrectOption", json.GetProperty("correctOption").GetString());
            cmd.Parameters.AddWithValue("@DifficultyLevel", json.GetProperty("difficultyLevel").GetString());

            await conn.OpenAsync();
            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
                return Ok(ReadRow(reader));

            return BadRequest("Insert failed");
        }


        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] QuestionDto q)

        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Question_Update", conn) { CommandType = CommandType.StoredProcedure };

            cmd.Parameters.AddWithValue("@Id", id);
            cmd.Parameters.AddWithValue("@Subject", q.Subject);
            cmd.Parameters.AddWithValue("@Topic", q.Topic);
            cmd.Parameters.AddWithValue("@QuestionText", q.QuestionText);
            cmd.Parameters.AddWithValue("@OptionA", q.OptionA);
            cmd.Parameters.AddWithValue("@OptionB", q.OptionB);
            cmd.Parameters.AddWithValue("@OptionC", q.OptionC);
            cmd.Parameters.AddWithValue("@OptionD", q.OptionD);
            cmd.Parameters.AddWithValue("@CorrectOption", q.CorrectOption);
            cmd.Parameters.AddWithValue("@DifficultyLevel", q.DifficultyLevel);


            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
            using var cmd = new SqlCommand("sp_Question_Delete", conn) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@Id", id);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
            return NoContent();
        }
    }
}
