// File: Controllers/ExamSubmissionsController.cs
using LMS.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class ExamSubmissionsController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public ExamSubmissionsController(IConfiguration configuration)
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
    public async Task<IActionResult> GetAllSubmissions()
    {
        var result = new List<object>();
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_ExamSubmissions_GetAll", conn) { CommandType = CommandType.StoredProcedure };

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            result.Add(ReadRow(reader));

        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSubmissionById(int id)
    {
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_ExamSubmissions_GetById", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.AddWithValue("@Id", id);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        if (!await reader.ReadAsync()) return NotFound();

        var submission = ReadRow(reader);

        var answers = new List<object>();
        if (await reader.NextResultAsync())
        {
            while (await reader.ReadAsync())
                answers.Add(ReadRow(reader));
        }

        submission["answers"] = answers;
        return Ok(submission);
    }
}