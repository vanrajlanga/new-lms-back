-- File: InstructorSummaryController_Procedures.sql

-- ✅ Procedure: sp_InstructorSummary_GetDashboard
IF NOT EXISTS (
  SELECT * FROM sys.objects 
  WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorSummary_GetDashboard]') 
    AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorSummary_GetDashboard]
  @InstructorId INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @CourseCount INT = (SELECT COUNT(*) FROM InstructorCourses WHERE InstructorId = @InstructorId);
  DECLARE @AssignmentCount INT = (SELECT COUNT(*) FROM Assignments WHERE CreatedBy = @InstructorId);
  DECLARE @LiveClassCount INT = (SELECT COUNT(*) FROM LiveClasses WHERE InstructorId = @InstructorId);
  DECLARE @ExamCount INT = (
    SELECT COUNT(*) FROM Examinations e
    WHERE EXISTS (
      SELECT 1 FROM InstructorCourses ic
      WHERE ic.InstructorId = @InstructorId AND ic.CourseId = e.CourseId
    )
  );
  DECLARE @TestCount INT = (SELECT COUNT(*) FROM Exams WHERE CreatedBy = @InstructorId);
  DECLARE @TaskCount INT = (SELECT COUNT(*) FROM TaskItems WHERE AssignedToUserId = @InstructorId);
  DECLARE @LeaveCount INT = (SELECT COUNT(*) FROM LeaveRequests WHERE UserId = @InstructorId);
  DECLARE @NotificationCount INT = (SELECT COUNT(*) FROM Notifications WHERE UserId = @InstructorId);
  DECLARE @StudentCount INT = (
    SELECT COUNT(DISTINCT sc.UserId)
    FROM StudentCourses sc
    JOIN InstructorCourses ic ON sc.CourseId = ic.CourseId
    WHERE ic.InstructorId = @InstructorId
  );

  SELECT
    @CourseCount AS Courses,
    @AssignmentCount AS Assignments,
    @LiveClassCount AS LiveClasses,
    @ExamCount AS Exams,
    @TestCount AS Tests,
    @TaskCount AS Tasks,
    @LeaveCount AS Leaves,
    @NotificationCount AS Notifications,
    @StudentCount AS Students;
END
')
END
