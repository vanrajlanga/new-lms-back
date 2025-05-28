// File: Controllers/ExaminationController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Text.Json;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class ExaminationController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public ExaminationController(IConfiguration configuration)
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

    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] JsonElement model)
    {
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_Examination_Create", conn) { CommandType = CommandType.StoredProcedure };

        cmd.Parameters.AddWithValue("@CourseId", model.GetProperty("courseId").GetInt32());
        cmd.Parameters.AddWithValue("@GroupId", model.GetProperty("groupId").GetInt32());
        cmd.Parameters.AddWithValue("@Semester", model.GetProperty("semester").GetInt32());
        cmd.Parameters.AddWithValue("@PaperCode", model.GetProperty("paperCode").GetString());
        cmd.Parameters.AddWithValue("@PaperName", model.GetProperty("paperName").GetString());
        cmd.Parameters.AddWithValue("@IsElective", model.GetProperty("isElective").GetBoolean());
        cmd.Parameters.AddWithValue("@PaperType", model.GetProperty("paperType").GetString());
        cmd.Parameters.AddWithValue("@Credits", model.GetProperty("credits").GetInt32());
        cmd.Parameters.AddWithValue("@InternalMarks1", model.GetProperty("internalMarks1").GetInt32());
        cmd.Parameters.AddWithValue("@InternalMarks2", model.GetProperty("internalMarks2").GetInt32());
        cmd.Parameters.AddWithValue("@TotalInternalMarks", model.GetProperty("totalInternalMarks").GetInt32());
        cmd.Parameters.AddWithValue("@TotalMarks", model.GetProperty("totalMarks").GetInt32());

        await conn.OpenAsync();
        await cmd.ExecuteNonQueryAsync();

        return Ok(new { message = "Examination created successfully" });
    }

    [HttpPut("Update/{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] JsonElement model)
    {
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_Examination_Update", conn) { CommandType = CommandType.StoredProcedure };

        cmd.Parameters.AddWithValue("@ExaminationId", id);
        cmd.Parameters.AddWithValue("@CourseId", model.GetProperty("courseId").GetInt32());
        cmd.Parameters.AddWithValue("@GroupId", model.GetProperty("groupId").GetInt32());
        cmd.Parameters.AddWithValue("@Semester", model.GetProperty("semester").GetInt32());
        cmd.Parameters.AddWithValue("@PaperCode", model.GetProperty("paperCode").GetString());
        cmd.Parameters.AddWithValue("@PaperName", model.GetProperty("paperName").GetString());
        cmd.Parameters.AddWithValue("@IsElective", model.GetProperty("isElective").GetBoolean());
        cmd.Parameters.AddWithValue("@PaperType", model.GetProperty("paperType").GetString());
        cmd.Parameters.AddWithValue("@Credits", model.GetProperty("credits").GetInt32());
        cmd.Parameters.AddWithValue("@InternalMarks1", model.GetProperty("internalMarks1").GetInt32());
        cmd.Parameters.AddWithValue("@InternalMarks2", model.GetProperty("internalMarks2").GetInt32());
        cmd.Parameters.AddWithValue("@TotalInternalMarks", model.GetProperty("totalInternalMarks").GetInt32());
        cmd.Parameters.AddWithValue("@TotalMarks", model.GetProperty("totalMarks").GetInt32());

        await conn.OpenAsync();
        await cmd.ExecuteNonQueryAsync();
        return NoContent();
    }

    [HttpGet("All")]
    public async Task<IActionResult> GetAll()
    {
        var result = new List<object>();
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_Examination_GetAll", conn) { CommandType = CommandType.StoredProcedure };

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
        using var cmd = new SqlCommand("sp_Examination_GetById", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.AddWithValue("@Id", id);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();
        if (await reader.ReadAsync())
            return Ok(ReadRow(reader));

        return NotFound();
    }

    [HttpDelete("Delete/{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_Examination_Delete", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.AddWithValue("@Id", id);

        await conn.OpenAsync();
        await cmd.ExecuteNonQueryAsync();
        return NoContent();
    }

    [HttpGet("ByStudent/{studentId}")]
    public async Task<IActionResult> GetExamsByStudent(int studentId)
    {
        var result = new List<object>();
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_Examination_GetByStudent", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.AddWithValue("@StudentId", studentId);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
            result.Add(ReadRow(reader));

        return Ok(result);
    }

    [HttpGet("ByInstructor/{instructorId}")]
    public async Task<IActionResult> GetByInstructor(int instructorId)
    {
        var result = new List<object>();
        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        using var cmd = new SqlCommand("sp_Examination_GetByInstructor", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.AddWithValue("@InstructorId", instructorId);

        await conn.OpenAsync();
        try
        {
            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                result.Add(ReadRow(reader));
        }
        catch (SqlException ex) when (ex.Message.Contains("No courses found"))
        {
            return NotFound("No courses found for the instructor.");
        }

        return Ok(result);
    }
}
