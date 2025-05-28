
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.Data.SqlClient;
//using Microsoft.Extensions.Configuration;
//using System.Collections.Generic;
//using System.Data;
//using System.Threading.Tasks;

//[Route("api/[controller]")]
//[ApiController]
//public class FeeController : ControllerBase
//{
//    private readonly IConfiguration _configuration;

//    public FeeController(IConfiguration configuration)
//    {
//        _configuration = configuration;
//    }

//    private Dictionary<string, object> ReadRow(SqlDataReader reader)
//    {
//        var row = new Dictionary<string, object>();
//        for (int i = 0; i < reader.FieldCount; i++)
//        {
//            var name = reader.GetName(i);
//            var camel = char.ToLowerInvariant(name[0]) + name.Substring(1);
//            row[camel] = reader.IsDBNull(i) ? null : reader.GetValue(i);
//        }
//        return row;
//    }

//    [HttpGet("Student/{studentId}")]
//    public async Task<IActionResult> GetStudentFees(int studentId)
//    {
//        var result = new List<object>();
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetStudentFees", conn) { CommandType = CommandType.StoredProcedure };
//        cmd.Parameters.AddWithValue("@StudentId", studentId);

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        while (await reader.ReadAsync())
//            result.Add(ReadRow(reader));

//        return result.Count > 0 ? Ok(result) : NotFound("No fee records found.");
//    }

//    [HttpGet("Student/{studentId}/Pending")]
//    public async Task<IActionResult> GetPendingFeesForStudent(int studentId)
//    {
//        var result = new List<object>();
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetPendingByStudent", conn) { CommandType = CommandType.StoredProcedure };
//        cmd.Parameters.AddWithValue("@StudentId", studentId);

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        while (await reader.ReadAsync())
//            result.Add(ReadRow(reader));

//        return result.Count > 0 ? Ok(result) : NotFound("No pending fee records found.");
//    }

//    [HttpGet("Student/{studentId}/Semester/{semesterName}")]
//    public async Task<IActionResult> GetStudentFeesBySemester(int studentId, string semesterName)
//    {
//        var result = new List<object>();
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetBySemester", conn) { CommandType = CommandType.StoredProcedure };
//        cmd.Parameters.AddWithValue("@StudentId", studentId);
//        cmd.Parameters.AddWithValue("@Semester", semesterName);

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        while (await reader.ReadAsync())
//            result.Add(ReadRow(reader));

//        return result.Count > 0 ? Ok(result) : NotFound("No fee records found for this semester.");
//    }

//    [HttpGet("Unpaid")]
//    public async Task<IActionResult> GetUnpaidStudents()
//    {
//        var result = new List<object>();
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetUnpaid", conn) { CommandType = CommandType.StoredProcedure };

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        while (await reader.ReadAsync())
//            result.Add(ReadRow(reader));

//        return Ok(result);
//    }

//    [HttpGet("Unpaid/Semester/{semesterName}")]
//    public async Task<IActionResult> GetUnpaidFeesBySemester(string semesterName)
//    {
//        var result = new List<object>();
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetUnpaidBySemester", conn) { CommandType = CommandType.StoredProcedure };
//        cmd.Parameters.AddWithValue("@Semester", semesterName);

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        while (await reader.ReadAsync())
//            result.Add(ReadRow(reader));

//        return Ok(result);
//    }

//    [HttpPost("Add")]
//    public async Task<IActionResult> AddFee([FromBody] dynamic request)
//    {
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_AddFee", conn) { CommandType = CommandType.StoredProcedure };

//        cmd.Parameters.AddWithValue("@StudentId", (int)request.studentId);
//        cmd.Parameters.AddWithValue("@Semester", (string)request.semester);
//        cmd.Parameters.AddWithValue("@Programme", (string)request.programme);
//        cmd.Parameters.AddWithValue("@AmountDue", (decimal)request.amountDue);
//        cmd.Parameters.AddWithValue("@AmountPaid", (decimal)request.amountPaid);
//        cmd.Parameters.AddWithValue("@DueDate", (DateTime)request.dueDate);
//        cmd.Parameters.AddWithValue("@FeeStatus", (string)request.feeStatus);
//        cmd.Parameters.AddWithValue("@PaymentDate", (DateTime?)request.paymentDate ?? (object)DBNull.Value);
//        cmd.Parameters.AddWithValue("@PaymentMethod", (string?)request.paymentMethod ?? (object)DBNull.Value);
//        cmd.Parameters.AddWithValue("@TransactionId", (string?)request.transactionId ?? (object)DBNull.Value);

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        if (await reader.ReadAsync())
//            return CreatedAtAction(nameof(GetStudentFees), new { studentId = request.studentId }, ReadRow(reader));

//        return BadRequest();
//    }

//    [HttpPut("Update/{id}")]
//    public async Task<IActionResult> UpdateFee(int id, [FromBody] dynamic request)
//    {
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_UpdateFee", conn) { CommandType = CommandType.StoredProcedure };

//        cmd.Parameters.AddWithValue("@FeeId", id);
//        cmd.Parameters.AddWithValue("@AmountPaid", (decimal)request.amountPaid);
//        cmd.Parameters.AddWithValue("@FeeStatus", (string)request.feeStatus);
//        cmd.Parameters.AddWithValue("@PaymentDate", (DateTime?)request.paymentDate ?? (object)DBNull.Value);
//        cmd.Parameters.AddWithValue("@PaymentMethod", (string?)request.paymentMethod ?? (object)DBNull.Value);
//        cmd.Parameters.AddWithValue("@TransactionId", (string?)request.transactionId ?? (object)DBNull.Value);

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        if (await reader.ReadAsync())
//            return Ok(ReadRow(reader));

//        return BadRequest("Fee update failed.");
//    }

//    [HttpDelete("Delete/{id}")]
//    public async Task<IActionResult> DeleteFee(int id)
//    {
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_Delete", conn) { CommandType = CommandType.StoredProcedure };
//        cmd.Parameters.AddWithValue("@Id", id);

//        await conn.OpenAsync();
//        await cmd.ExecuteNonQueryAsync();
//        return NoContent();
//    }

//    [HttpGet("All")]
//    public async Task<IActionResult> GetAllFees()
//    {
//        var result = new List<object>();
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetAll", conn) { CommandType = CommandType.StoredProcedure };

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        while (await reader.ReadAsync())
//            result.Add(ReadRow(reader));

//        return Ok(result);
//    }

//    [HttpGet("SemesterFeeTemplate")]
//    public async Task<IActionResult> GetSemesterFeeTemplate([FromQuery] string programme, [FromQuery] int semester)
//    {
//        if (string.IsNullOrWhiteSpace(programme) || semester <= 0)
//            return BadRequest("Programme and semester required.");

//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        using var cmd = new SqlCommand("sp_Fee_GetSemesterFeeTemplate", conn) { CommandType = CommandType.StoredProcedure };
//        cmd.Parameters.AddWithValue("@Programme", programme);
//        cmd.Parameters.AddWithValue("@Semester", semester.ToString());

//        await conn.OpenAsync();
//        using var reader = await cmd.ExecuteReaderAsync();
//        if (await reader.ReadAsync())
//            return Ok(ReadRow(reader));

//        return NotFound("Fee template not found.");
//    }
//}

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using LMS.Data;
using LMS.Models;
using LMS.Models.DTOs;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;
using LMS.DTOs;

namespace LMS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FeeController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FeeController(AppDbContext context)
        {
            _context = context;
        }

        private static CourseDto MapCourse(Course course)
        {
            return new CourseDto
            {
                CourseId = course.CourseId,
                Name = course.Name,
                CourseCode = course.CourseCode,
                Credits = course.Credits,
                CourseDescription = course.CourseDescription,
                Semester = course.Semester,
                Programme = course.Programme
            };
        }

        private static FeeSummaryDto MapFee(Fee f)
        {
            return new FeeSummaryDto
            {
                FeeId = f.FeeId,
                StudentId = f.StudentId,
                StudentName = f.Student.FirstName + " " + f.Student.LastName,
                Semester = f.Semester ?? "Unknown",
                Programme = f.Programme ?? "Unknown",
                AmountDue = f.AmountDue,
                AmountPaid = f.AmountPaid,
                FeeStatus = f.FeeStatus,
                DueDate = f.DueDate,
                PaymentDate = f.PaymentDate
            };
        }

        [HttpGet("Student/{studentId}")]
        public async Task<ActionResult<IEnumerable<FeeSummaryDto>>> GetStudentFees(int studentId)
        {
            var fees = await _context.Fees
                .Include(f => f.Student)
                .ToListAsync();

            return fees.Any() ? Ok(fees.Select(MapFee)) : NotFound("No fee records found.");
        }

        [HttpGet("Student/{studentId}/Pending")]
        public async Task<ActionResult<IEnumerable<FeeSummaryDto>>> GetPendingFeesForStudent(int studentId)
        {
            var fees = await _context.Fees
               .Include(f => f.Student)
                .Where(f => f.StudentId == studentId && (f.FeeStatus != "Paid" || f.AmountPaid < f.AmountDue))
                .ToListAsync();

            return fees.Any() ? Ok(fees.Select(MapFee)) : NotFound("No pending fee records found.");
        }

        [HttpGet("Student/{studentId}/Semester/{semesterName}")]
        public async Task<IActionResult> GetStudentFeesBySemester(int studentId, string semesterName)
        {
            var fees = await _context.Fees
                .Include(f => f.Student)
                .Where(f => f.StudentId == studentId && f.Semester == semesterName)
                .ToListAsync();

            return fees.Any() ? Ok(fees.Select(MapFee)) : NotFound("No fee records found for this semester.");
        }

        [HttpGet("Unpaid")]
        public async Task<IActionResult> GetUnpaidStudents()
        {
            var unpaidFees = await _context.Fees
                .Include(f => f.Student)
                .Where(f => f.FeeStatus != "Paid" || f.AmountPaid < f.AmountDue)
                .GroupBy(f => f.Student)
                .Select(g => new
                {
                    StudentId = g.Key.UserId,
                    Name = g.Key.Username,
                    TotalDue = g.Sum(f => f.AmountDue - f.AmountPaid),
                    OutstandingFees = g.Select(f => new
                    {
                        f.FeeId,
                        Semester = f.Semester ?? "Unknown",
                        f.AmountDue,
                        f.AmountPaid,
                        f.FeeStatus,
                        f.PaymentDate
                    })
                })
                .ToListAsync();

            return Ok(unpaidFees);
        }
        [HttpPost("Pay")]
        public async Task<IActionResult> PayFee([FromBody] PayFeeDto dto)
        {
            if (dto.FeeId <= 0 || dto.Amount <= 0)
                return BadRequest("Invalid fee ID or amount.");

            var fee = await _context.Fees.FindAsync(dto.FeeId);
            if (fee == null)
                return NotFound("Fee record not found.");

            var remaining = fee.AmountDue - fee.AmountPaid;
            if (dto.Amount > remaining)
                return BadRequest($"Payment exceeds due amount. Remaining: ₹{remaining}");

            fee.AmountPaid += dto.Amount;
            fee.PaymentDate = DateTime.UtcNow;
            fee.PaymentMethod = dto.PaymentMethod;
            fee.TransactionId = dto.TransactionId;
            fee.UpdatedAt = DateTime.UtcNow;

            if (fee.AmountPaid >= fee.AmountDue)
                fee.FeeStatus = "Paid";
            else if (fee.AmountPaid > 0)
                fee.FeeStatus = "Partial";

            await _context.SaveChangesAsync();

            var notification = new Notification
            {
                UserId = fee.StudentId,
                NotificationType = "Fee",
                Message = $"Payment received: ₹{dto.Amount} on {DateTime.UtcNow:dd MMM yyyy}. Status: {fee.FeeStatus}",
                CreatedAt = DateTime.UtcNow,
                DateSent = DateTime.UtcNow,
                IsRead = false
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return Ok("Payment successful.");
        }


        [HttpGet("Unpaid/Semester/{semesterName}")]
        public async Task<IActionResult> GetUnpaidFeesBySemester(string semesterName)
        {
            var unpaid = await _context.Fees
                .Include(f => f.Student)
                .Where(f => f.Semester == semesterName && (f.FeeStatus != "Paid" || f.AmountPaid < f.AmountDue))
                .ToListAsync();

            return Ok(unpaid.Select(MapFee));
        }

        [HttpPost("Add")]
        public async Task<ActionResult<Fee>> AddFee([FromBody] Fee request)
        {
            if (request.StudentId <= 0) return BadRequest("Invalid StudentId");

            var student = await _context.Users.FindAsync(request.StudentId);
            if (student == null || student.Role != "Student") return NotFound("Invalid student.");

            _context.Fees.Add(request);
            await _context.SaveChangesAsync();

            var notification = new Notification
            {
                UserId = request.StudentId,
                NotificationType = "Fee",
                Message = $"Due: {request.DueDate:dd MMM yyyy}, Amount: ₹{request.AmountDue}",
                CreatedAt = DateTime.UtcNow,
                DateSent = DateTime.UtcNow,
                IsRead = false
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetStudentFees), new { studentId = request.StudentId }, request);
        }

        public class FeeUpdateDto
        {
            public decimal AmountPaid { get; set; }
            public string FeeStatus { get; set; }
            public DateTime? PaymentDate { get; set; }
            public string PaymentMethod { get; set; }
            public string TransactionId { get; set; }
        }

        [HttpPut("Update/{id}")]
        public async Task<IActionResult> UpdateFee(int id, [FromBody] FeeUpdateDto request)
        {
            if (request == null) return BadRequest("Invalid data");

            var fee = await _context.Fees.FindAsync(id);
            if (fee == null) return NotFound("Fee not found.");

            fee.AmountPaid = request.AmountPaid;
            fee.FeeStatus = request.FeeStatus ?? fee.FeeStatus;
            fee.PaymentDate = request.PaymentDate ?? DateTime.UtcNow;
            fee.PaymentMethod = request.PaymentMethod ?? fee.PaymentMethod;
            fee.TransactionId = request.TransactionId ?? fee.TransactionId;
            fee.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var notification = new Notification
            {
                UserId = fee.StudentId,
                NotificationType = "Fee",
                Message = $"Paid ₹{fee.AmountPaid} on {fee.PaymentDate:dd MMM yyyy} (Status: {fee.FeeStatus})",
                CreatedAt = DateTime.UtcNow,
                DateSent = DateTime.UtcNow,
                IsRead = false
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return Ok("Fee updated successfully.");
        }

        [HttpDelete("Delete/{id}")]
        public async Task<IActionResult> DeleteFee(int id)
        {
            var fee = await _context.Fees.FindAsync(id);
            if (fee == null) return NotFound();

            _context.Fees.Remove(fee);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("All")]
        public async Task<ActionResult<IEnumerable<FeeSummaryDto>>> GetAllFees()
        {
            var fees = await _context.Fees
                .Include(f => f.Student)
                .ToListAsync();

            return Ok(fees.Select(MapFee));
        }

        [HttpGet("SemesterFeeTemplate")]
        public async Task<IActionResult> GetSemesterFeeTemplate([FromQuery] string programme, [FromQuery] int semester)
        {
            if (string.IsNullOrWhiteSpace(programme) || semester <= 0)
                return BadRequest("Programme and semester required.");

            var template = await _context.SemesterFeeTemplate
                .FirstOrDefaultAsync(t => t.Programme == programme && t.Semester == semester.ToString());


            if (template == null)
                return NotFound("Fee template not found.");

            return Ok(new
            {
                programme = template.Programme,
                semester = template.Semester,
                amountDue = template.AmountDue
            });
        }
    }
}

