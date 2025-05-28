//// File: Controllers/ExamController.cs (Fully Patched ADO.NET with EF-like behavior)
//using LMS.Models;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.Data.SqlClient;
//using Microsoft.Extensions.Configuration;
//using System.Data;
//using System.Collections.Generic;
//using System.Linq;
//using System.Threading.Tasks;

//[Route("api/[controller]")]
//[ApiController]
//public class ExamController : ControllerBase
//{
//    private readonly IConfiguration _configuration;

//    public ExamController(IConfiguration configuration)
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

//    [HttpPost("CreateFull")]
//    public async Task<IActionResult> CreateExamWithQuestions([FromBody] ExamCreateRequest request)
//    {
//        using var conn = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
//        await conn.OpenAsync();

//        int newExamId;
//        using (var cmd = new SqlCommand("sp_Exam_CreateFull", conn) { CommandType = CommandType.StoredProcedure })
//        {
//            cmd.Parameters.AddWithValue("@Title", request.Title);
//            cmd.Parameters.AddWithValue("@CourseId", request.CourseId);
//            cmd.Parameters.AddWithValue("@ExamDate", request.ExamDate);
//            cmd.Parameters.AddWithValue("@DurationMinutes", request.DurationMinutes);
//            cmd.Parameters.AddWithValue("@CreatedBy", request.CreatedBy);
//            var result = await cmd.ExecuteScalarAsync();
//            newExamId = Convert.ToInt32(result);
//        }

//        if (request.Questions != null && request.Questions.Any())
//        {
//            foreach (var q in request.Questions)
//            {
//                using var qCmd = new SqlCommand(@"
//                    INSERT INTO Questions (QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption, Topic, Subject, DifficultyLevel)
//                    OUTPUT INSERTED.Id
//                    VALUES (@text, @a, @b, @c, @d, @correct, @topic, @subject, @difficulty)", conn);

//                qCmd.Parameters.AddWithValue("@text", q.QuestionText ?? (object)DBNull.Value);
//                qCmd.Parameters.AddWithValue("@a", q.OptionA ?? (object)DBNull.Value);
//                qCmd.Parameters.AddWithValue("@b", q.OptionB ?? (object)DBNull.Value);
//                qCmd.Parameters.AddWithValue("@c", q.OptionC ?? (object)DBNull.Value);
//                qCmd.Parameters.AddWithValue("@d", q.OptionD ?? (object)DBNull.Value);
//                qCmd.Parameters.AddWithValue("@correct", q.CorrectOption ?? (object)DBNull.Value);
//                qCmd.Parameters.AddWithValue("@topic", string.IsNullOrWhiteSpace(q.Topic) ? "General" : q.Topic);
//                qCmd.Parameters.AddWithValue("@subject", "General");
//                qCmd.Parameters.AddWithValue("@difficulty", "Medium");

//                var questionId = (int)await qCmd.ExecuteScalarAsync();

//                using var linkCmd = new SqlCommand("INSERT INTO ExamQuestions (ExamId, QuestionId) VALUES (@eid, @qid)", conn);
//                linkCmd.Parameters.AddWithValue("@eid", newExamId);
//                linkCmd.Parameters.AddWithValue("@qid", questionId);
//                await linkCmd.ExecuteNonQueryAsync();
//            }
//        }

//        using (var studentCmd = new SqlCommand("SELECT UserId FROM StudentCourses WHERE CourseId = @cid", conn))
//        {
//            studentCmd.Parameters.AddWithValue("@cid", request.CourseId);
//            using var reader = await studentCmd.ExecuteReaderAsync();
//            var notifications = new List<(int UserId, string Message)>();
//            while (await reader.ReadAsync())
//            {
//                int uid = reader.GetInt32(0);
//                string message = $"Scheduled on {request.ExamDate:dd MMM yyyy}";
//                notifications.Add((uid, message));
//            }
//            reader.Close();

//            foreach (var note in notifications)
//            {
//                using var notifyCmd = new SqlCommand("INSERT INTO Notifications (UserId, NotificationType, Message, CreatedAt, DateSent, IsRead) VALUES (@uid, 'Exam', @msg, GETUTCDATE(), GETUTCDATE(), 0)", conn);
//                notifyCmd.Parameters.AddWithValue("@uid", note.UserId);
//                notifyCmd.Parameters.AddWithValue("@msg", note.Message);
//                await notifyCmd.ExecuteNonQueryAsync();
//            }
//        }

//        return Ok(new { message = "Exam created successfully", examId = newExamId });
//    }

//    public class ExamCreateRequest
//    {
//        public string Title { get; set; }
//        public int CourseId { get; set; }
//        public DateTime ExamDate { get; set; }
//        public int DurationMinutes { get; set; }
//        public int CreatedBy { get; set; }
//        public List<ExamQuestionRequest> Questions { get; set; }
//    }

//    public class ExamQuestionRequest
//    {
//        public string QuestionText { get; set; }
//        public string OptionA { get; set; }
//        public string OptionB { get; set; }
//        public string OptionC { get; set; }
//        public string OptionD { get; set; }
//        public string CorrectOption { get; set; }
//        public string Topic { get; set; }
//    }
//}
// ✅ Enhanced ExamController with Notifications like AssignmentController
using LMS.Data;
using LMS.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

[Route("api/[controller]")]
[ApiController]
public class ExamController : ControllerBase
{
    private readonly AppDbContext _context;

    public ExamController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var exams = await _context.Exams.OrderByDescending(e => e.ExamDate).ToListAsync();
        return Ok(exams);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var exam = await _context.Exams.FindAsync(id);
        return exam == null ? NotFound() : Ok(exam);
    }

    [HttpPost("Create")]
    public async Task<ActionResult> CreateExam([FromBody] Exam exam)
    {
        if (exam == null) return BadRequest("Invalid exam data.");

        var course = await _context.Courses.FindAsync(exam.CourseId);
        if (course == null) return BadRequest("Invalid Course.");

        _context.Exams.Add(exam);
        await _context.SaveChangesAsync();

        if (exam.ExamQuestions != null && exam.ExamQuestions.Any())
        {
            foreach (var examQuestion in exam.ExamQuestions)
            {
                var question = await _context.Questions.FindAsync(examQuestion.QuestionId);
                if (question != null)
                {
                    _context.ExamQuestions.Add(new ExamQuestion
                    {
                        ExamId = exam.Id,
                        QuestionId = question.Id
                    });
                }
                else
                {
                    return BadRequest($"Question with ID {examQuestion.QuestionId} not found.");
                }
            }
            await _context.SaveChangesAsync();
        }

        var studentIds = await _context.StudentCourses
            .Where(sc => sc.CourseId == exam.CourseId)
            .Select(sc => sc.UserId)
            .ToListAsync();

        var notifications = studentIds.Select(sid => new Notification
        {
            UserId = sid,
            NotificationType = "Exam",
            //Title = $"New Exam Scheduled: {exam.Title}",
            Message = $"Exam Date: {exam.ExamDate:dd MMM yyyy}",
            CreatedAt = DateTime.UtcNow,
            DateSent = DateTime.UtcNow,
            IsRead = false
        }).ToList();

        _context.Notifications.AddRange(notifications);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Exam created successfully", exam });
    }

    [HttpPost("CreateFull")]
    public async Task<IActionResult> CreateExamWithQuestions([FromBody] ExamCreateRequest request)
    {
        if (request == null || request.Questions == null || request.Questions.Count == 0)
            return BadRequest("Invalid exam data or no questions.");

        var course = await _context.Courses.FindAsync(request.CourseId);
        if (course == null) return BadRequest("Invalid Course.");

        var exam = new Exam
        {
            Title = request.Title,
            CourseId = request.CourseId,
            ExamDate = request.ExamDate,
            DurationMinutes = request.DurationMinutes,
            CreatedAt = DateTime.UtcNow,
            CreatedBy = request.CreatedBy
        };

        _context.Exams.Add(exam);
        await _context.SaveChangesAsync();

        var examQuestions = request.Questions.Select(q => new Question
        {
            QuestionText = q.QuestionText,
            OptionA = q.OptionA,
            OptionB = q.OptionB,
            OptionC = q.OptionC,
            OptionD = q.OptionD,
            CorrectOption = q.CorrectOption,
            DifficultyLevel = "Medium",
            Topic = "General",
            Subject = "General"
        }).ToList();

        _context.Questions.AddRange(examQuestions);
        await _context.SaveChangesAsync();

        var examQuestionsLinks = examQuestions.Select(q => new ExamQuestion
        {
            ExamId = exam.Id,
            QuestionId = q.Id
        }).ToList();

        _context.ExamQuestions.AddRange(examQuestionsLinks);
        await _context.SaveChangesAsync();

        var studentIds = await _context.StudentCourses
            .Where(sc => sc.CourseId == exam.CourseId)
            .Select(sc => sc.UserId)
            .ToListAsync();

        var notifications = studentIds.Select(sid => new Notification
        {
            UserId = sid,
            NotificationType = "Exam",
            //Title = $"New Exam: {exam.Title}",
            Message = $"Scheduled on {exam.ExamDate:dd MMM yyyy}",
            CreatedAt = DateTime.UtcNow,
            DateSent = DateTime.UtcNow,
            IsRead = false
        }).ToList();

        _context.Notifications.AddRange(notifications);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Exam created successfully", examId = exam.Id });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] Exam exam)
    {
        if (id != exam.Id) return BadRequest();

        var existing = await _context.Exams.FindAsync(id);
        if (existing == null) return NotFound();

        existing.Title = exam.Title;
        existing.CourseId = exam.CourseId;
        existing.ExamDate = exam.ExamDate;
        existing.DurationMinutes = exam.DurationMinutes;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var exam = await _context.Exams.FindAsync(id);
        if (exam == null) return NotFound();

        _context.Exams.Remove(exam);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{examId}/AddQuestions")]
    public async Task<IActionResult> AddQuestionsToExam(int examId, [FromBody] List<int> questionIds)
    {
        var exam = await _context.Exams.FindAsync(examId);
        if (exam == null) return NotFound();

        var existingLinks = _context.ExamQuestions.Where(eq => eq.ExamId == examId);
        _context.ExamQuestions.RemoveRange(existingLinks);

        var newLinks = questionIds.Select(qid => new ExamQuestion
        {
            ExamId = examId,
            QuestionId = qid
        });

        await _context.ExamQuestions.AddRangeAsync(newLinks);
        await _context.SaveChangesAsync();

        return Ok("Questions linked to exam successfully.");
    }

    [HttpGet("latest-by-course/{courseId}")]
    public async Task<IActionResult> GetLatestExamByCourse(int courseId)
    {
        if (courseId <= 0) return BadRequest("Invalid course ID.");

        var latestExam = await _context.Exams
            .Where(e => e.CourseId == courseId)
            .OrderByDescending(e => e.ExamDate)
            .FirstOrDefaultAsync();

        if (latestExam == null)
        {
            return Ok(new { hasNewAssessment = false, message = "No New Assessment Updated" });
        }

        return Ok(new
        {
            hasNewAssessment = true,
            message = $"Latest exam: {(string.IsNullOrWhiteSpace(latestExam.Title) ? "Untitled" : latestExam.Title)} on {latestExam.ExamDate:MMMM dd, yyyy}"
        });
    }

    [HttpGet("{examId}/ResultReport")]
    public async Task<IActionResult> GetExamResultReport(int examId)
    {
        var exam = await _context.Exams.FindAsync(examId);
        if (exam == null)
            return NotFound("Exam not found.");

        var submissions = await _context.ExamSubmissions
            .Where(es => es.ExamId == examId)
            .Include(es => es.User)
            .Include(es => es.User.StudentCourses)
                .ThenInclude(sc => sc.Course)
            .OrderByDescending(es => es.TotalScore)
            .ToListAsync();

        var report = submissions.Select(sub => new
        {
            StudentId = sub.UserId,
            FullName = $"{sub.User.FirstName} {sub.User.LastName}",
            Email = sub.User.Email,
            Programme = sub.User.Programme,
            Semester = sub.User.Semester,
            CourseName = sub.User.StudentCourses.FirstOrDefault(sc => sc.CourseId == exam.CourseId)?.Course?.Name ?? "N/A",
            SubmittedAt = sub.SubmittedAt,
            Score = sub.TotalScore,
            IsGraded = sub.IsGraded,
            IsAutoGraded = sub.IsAutoGraded
        }).ToList();

        return Ok(new
        {
            ExamId = exam.Id,
            ExamTitle = exam.Title,
            ExamDate = exam.ExamDate,
            TotalSubmissions = report.Count,
            Results = report
        });
    }

    /* FRONTEND: Update button to navigate instead of alert */


    [HttpGet("{id}/Questions")]
    public async Task<IActionResult> GetExamQuestions(int id)
    {
        var questionIds = await _context.ExamQuestions
            .Where(eq => eq.ExamId == id)
            .Select(eq => eq.QuestionId)
            .ToListAsync();

        if (!questionIds.Any()) return NotFound("No questions found for this exam.");

        var questions = await _context.Questions
            .Where(q => questionIds.Contains(q.Id))
            .Select(q => new
            {
                q.Id,
                q.QuestionText,
                q.OptionA,
                q.OptionB,
                q.OptionC,
                q.OptionD
            })
            .ToListAsync();

        return questions.Any() ? Ok(questions) : NotFound("No questions available.");
    }

    public class ExamCreateRequest
    {
        public string Title { get; set; }
        public int CourseId { get; set; }
        public DateTime ExamDate { get; set; }
        public int DurationMinutes { get; set; }
        public int CreatedBy { get; set; } // ✅ Add this
        public List<ExamQuestionRequest> Questions { get; set; }
    }

    public class ExamQuestionRequest
    {
        public string QuestionText { get; set; }
        public string OptionA { get; set; }
        public string OptionB { get; set; }
        public string OptionC { get; set; }
        public string OptionD { get; set; }
        public string CorrectOption { get; set; }
    }
}
