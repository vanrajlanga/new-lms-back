-- StudentExamController_Procedures.sql

-- ✅ sp_StudentExam_GetAvailableExams
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_StudentExam_GetAvailableExams]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_StudentExam_GetAvailableExams]
        @UserId INT
    AS
    BEGIN
        SELECT Id, Title, CourseId AS Course, ExamDate, DurationMinutes
        FROM Exams
        ORDER BY ExamDate DESC;
    END
    ')
END

-- ✅ sp_StudentExam_SubmitExam
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_StudentExam_SubmitExam]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_StudentExam_SubmitExam]
        @UserId INT,
        @ExamId INT
    AS
    BEGIN
        INSERT INTO ExamSubmissions (UserId, ExamId, SubmittedAt, IsGraded, IsAutoGraded)
        VALUES (@UserId, @ExamId, GETUTCDATE(), 0, 0);

        SELECT SCOPE_IDENTITY() AS SubmissionId;
    END
    ')
END

-- ✅ sp_StudentExam_GetStudentSubmissions
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_StudentExam_GetStudentSubmissions]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_StudentExam_GetStudentSubmissions]
        @UserId INT
    AS
    BEGIN
        SELECT e.Title AS ExamTitle, s.SubmittedAt AS ExamDate, s.TotalScore AS Score, s.IsGraded
        FROM ExamSubmissions s
        JOIN Exams e ON s.ExamId = e.Id
        WHERE s.UserId = @UserId;
    END
    ')
END

-- ✅ sp_StudentExam_GetExamQuestions
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_StudentExam_GetExamQuestions]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_StudentExam_GetExamQuestions]
        @ExamId INT
    AS
    BEGIN
        SELECT q.Id, q.QuestionText, q.OptionA, q.OptionB, q.OptionC, q.OptionD
        FROM ExamQuestions eq
        JOIN Questions q ON eq.QuestionId = q.Id
        WHERE eq.ExamId = @ExamId;
    END
    ')
END
