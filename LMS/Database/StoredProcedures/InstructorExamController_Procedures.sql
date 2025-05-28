-- File: InstructorExamController_Procedures.sql

-- ✅ sp_InstructorExam_Create
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_Create]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_Create]
  @Title NVARCHAR(255),
  @CourseId INT,
  @ExamDate DATETIME,
  @DurationMinutes INT,
  @CreatedBy INT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO Exams (Title, CourseId, ExamDate, DurationMinutes, CreatedAt, CreatedBy)
  VALUES (@Title, @CourseId, @ExamDate, @DurationMinutes, GETUTCDATE(), @CreatedBy);

  SELECT * FROM Exams WHERE Id = SCOPE_IDENTITY();
END
')
END

-- ✅ sp_InstructorExam_GetById
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_GetById]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_GetById]
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT * FROM Exams WHERE Id = @Id;
END
')
END

-- ✅ sp_InstructorExam_Update
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_Update]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_Update]
  @Id INT,
  @Title NVARCHAR(255),
  @CourseId INT,
  @ExamDate DATETIME,
  @DurationMinutes INT
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE Exams
  SET Title = @Title,
      CourseId = @CourseId,
      ExamDate = @ExamDate,
      DurationMinutes = @DurationMinutes
  WHERE Id = @Id;
END
')
END

-- ✅ sp_InstructorExam_AddQuestions
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_AddQuestions]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_AddQuestions]
  @ExamId INT
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM ExamQuestions WHERE ExamId = @ExamId;
END
')
END

-- ✅ sp_InstructorExam_InsertExamQuestion
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_InsertExamQuestion]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_InsertExamQuestion]
  @ExamId INT,
  @QuestionId INT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO ExamQuestions (ExamId, QuestionId) VALUES (@ExamId, @QuestionId);
END
')
END

-- ✅ sp_InstructorExam_GetUngradedSubmissions
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_GetUngradedSubmissions]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_GetUngradedSubmissions]
AS
BEGIN
  SET NOCOUNT ON;
  SELECT s.Id AS SubmissionId, u.Username AS StudentName, e.Title AS ExamTitle, s.SubmittedAt
  FROM ExamSubmissions s
  INNER JOIN Exams e ON s.ExamId = e.Id
  INNER JOIN Users u ON s.UserId = u.UserId
  WHERE s.IsGraded = 0;
END
')
END

-- ✅ sp_InstructorExam_GetSubmissionDetails
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_GetSubmissionDetails]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_GetSubmissionDetails]
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT e.Title AS ExamTitle, s.SubmittedAt
  FROM ExamSubmissions s
  JOIN Exams e ON s.ExamId = e.Id
  WHERE s.Id = @Id;

  SELECT a.Id AS AnswerId, q.QuestionText, q.CorrectOption, a.StudentAnswer, a.InstructorFeedback, a.ScoreAwarded
  FROM AnswerSubmissions a
  JOIN Questions q ON a.QuestionId = q.Id
  WHERE a.ExamSubmissionId = @Id;
END
')
END

-- ✅ sp_InstructorExam_UpdateAnswerScore
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_UpdateAnswerScore]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_UpdateAnswerScore]
  @AnswerId INT,
  @Score FLOAT,
  @Feedback NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE AnswerSubmissions
  SET ScoreAwarded = @Score, InstructorFeedback = @Feedback
  WHERE Id = @AnswerId;
END
')
END

-- ✅ sp_InstructorExam_GradeSubmission
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_GradeSubmission]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_GradeSubmission]
  @SubmissionId INT
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE ExamSubmissions
  SET IsGraded = 1,
      TotalScore = (SELECT SUM(ScoreAwarded) FROM AnswerSubmissions WHERE ExamSubmissionId = @SubmissionId)
  WHERE Id = @SubmissionId;
END
')
END

-- ✅ sp_InstructorExam_GetByInstructor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_GetByInstructor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_GetByInstructor]
  @InstructorId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT * FROM Exams WHERE CreatedBy = @InstructorId ORDER BY ExamDate DESC;
END
')
END

-- ✅ sp_InstructorExam_GetGradingSummary
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_InstructorExam_GetGradingSummary]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_InstructorExam_GetGradingSummary]
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    COUNT(*) AS Total,
    SUM(CASE WHEN IsGraded = 1 THEN 1 ELSE 0 END) AS Graded,
    SUM(CASE WHEN IsGraded = 0 THEN 1 ELSE 0 END) AS Pending,
    AVG(CASE WHEN IsGraded = 1 THEN TotalScore ELSE NULL END) AS AverageScore
  FROM ExamSubmissions;
END
')
END