-- StudentSummaryController_Procedures.sql

-- ✅ sp_StudentSummary_GetDashboard
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_StudentSummary_GetDashboard]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_StudentSummary_GetDashboard]
        @StudentId INT
    AS
    BEGIN
        DECLARE @CourseCount INT = (SELECT COUNT(*) FROM StudentCourses WHERE UserId = @StudentId);
        DECLARE @AssignmentCount INT = (SELECT COUNT(*) FROM Assignments WHERE CourseId IN (SELECT CourseId FROM StudentCourses WHERE UserId = @StudentId));
        DECLARE @ExamCount INT = (SELECT COUNT(*) FROM Examinations WHERE CourseId IN (SELECT CourseId FROM StudentCourses WHERE UserId = @StudentId));
        DECLARE @TestCount INT = (SELECT COUNT(*) FROM Exams WHERE CourseId IN (SELECT CourseId FROM StudentCourses WHERE UserId = @StudentId));
        DECLARE @AttendanceCount INT = (SELECT COUNT(*) FROM Attendances WHERE StudentId = @StudentId);
        DECLARE @LiveClassCount INT = (SELECT COUNT(*) FROM LiveClasses WHERE CourseId IN (SELECT CourseId FROM StudentCourses WHERE UserId = @StudentId));
        DECLARE @FeeCount INT = (SELECT COUNT(*) FROM Fees WHERE StudentId = @StudentId);
        DECLARE @SupportTicketCount INT = (SELECT COUNT(*) FROM SupportTickets WHERE StudentId = @StudentId);

        SELECT @CourseCount AS Courses,
               @AssignmentCount AS Assignments,
               @ExamCount AS Exams,
               @TestCount AS Tests,
               @AttendanceCount AS Attendance,
               @LiveClassCount AS LiveClasses,
               @FeeCount AS Fees,
               @SupportTicketCount AS SupportTickets;

        SELECT TOP 10 *
        FROM Notifications
        WHERE UserId = @StudentId
        ORDER BY DateSent DESC;
    END
    ')
END
