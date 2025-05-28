-- File: ExamSubmissionsController_Procedures.sql

-- ✅ Procedure: sp_ExamSubmissions_GetAll
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_ExamSubmissions_GetAll]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_ExamSubmissions_GetAll]
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            s.Id AS SubmissionId,
            u.UserId AS StudentId,
            u.Username AS StudentName,
            e.Id AS ExamId,
            e.Title AS ExamTitle,
            s.TotalScore,
            s.SubmittedAt
        FROM ExamSubmissions s
        JOIN Users u ON s.UserId = u.UserId
        JOIN Exams e ON s.ExamId = e.Id
        ORDER BY s.SubmittedAt DESC;
    END
    ')
END

-- ✅ Procedure: sp_ExamSubmissions_GetById
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_ExamSubmissions_GetById]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_ExamSubmissions_GetById]
        @Id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            s.Id,
            s.UserId,
            s.ExamId,
            s.TotalScore,
            s.SubmittedAt
        FROM ExamSubmissions s
        WHERE s.Id = @Id;

        SELECT 
            a.Id,
            a.QuestionId,
            a.StudentAnswer,
            a.ScoreAwarded,
            a.InstructorFeedback,
            q.QuestionText
        FROM AnswerSubmissions a
        JOIN Questions q ON a.QuestionId = q.Id
        WHERE a.ExamSubmissionId = @Id;
    END
    ')
END
