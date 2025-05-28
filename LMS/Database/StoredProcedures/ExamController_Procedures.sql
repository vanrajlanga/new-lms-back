-- Filename: ExamController_Procedures.sql
-- ✅ Follows strict rules: 1 file per controller, strict naming, logic match, structure match, IF NOT EXISTS wrappers

-- ✅ Get all exams
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_GetAll]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_GetAll]
AS
BEGIN
    SELECT * FROM Exams ORDER BY ExamDate DESC;
END')
END

-- ✅ Get exam by ID
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_GetById]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_GetById]
    @Id INT
AS
BEGIN
    SELECT * FROM Exams WHERE Id = @Id;
END')
END

-- ✅ Update exam
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_Update]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_Update]
    @Id INT,
    @Title NVARCHAR(200),
    @CourseId INT,
    @ExamDate DATETIME,
    @DurationMinutes INT
AS
BEGIN
    UPDATE Exams
    SET Title = @Title,
        CourseId = @CourseId,
        ExamDate = @ExamDate,
        DurationMinutes = @DurationMinutes
    WHERE Id = @Id;
END')
END

-- ✅ Delete exam
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_Delete]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_Delete]
    @Id INT
AS
BEGIN
    DELETE FROM Exams WHERE Id = @Id;
END')
END

-- ✅ Get latest exam by course
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_GetLatestByCourse]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_GetLatestByCourse]
    @CourseId INT
AS
BEGIN
    SELECT TOP 1 * FROM Exams WHERE CourseId = @CourseId ORDER BY ExamDate DESC;
END')
END

-- ✅ Get exam questions
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_GetQuestions]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_GetQuestions]
    @ExamId INT
AS
BEGIN
    SELECT q.Id, q.QuestionText, q.OptionA, q.OptionB, q.OptionC, q.OptionD
    FROM ExamQuestions eq
    JOIN Questions q ON q.Id = eq.QuestionId
    WHERE eq.ExamId = @ExamId;
END')
END


-- ✅ sp_Exam_Create
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_Create]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_Create]
    @Title NVARCHAR(200),
    @CourseId INT,
    @ExamDate DATETIME,
    @DurationMinutes INT
AS
BEGIN
    INSERT INTO Exams (Title, CourseId, ExamDate, DurationMinutes, CreatedAt)
    VALUES (@Title, @CourseId, @ExamDate, @DurationMinutes, GETUTCDATE());

    DECLARE @ExamId INT = SCOPE_IDENTITY();

    INSERT INTO Notifications (UserId, NotificationType, Message, CreatedAt, DateSent, IsRead)
    SELECT sc.UserId, ''Exam'', CONCAT(''Exam Date: '', FORMAT(@ExamDate, ''dd MMM yyyy'')), GETUTCDATE(), GETUTCDATE(), 0
    FROM StudentCourses sc WHERE sc.CourseId = @CourseId;

    SELECT * FROM Exams WHERE Id = @ExamId;
END')
END

-- ✅ sp_Exam_CreateFull
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_CreateFull]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_CreateFull]
    @Title NVARCHAR(200),
    @CourseId INT,
    @ExamDate DATETIME,
    @DurationMinutes INT,
    @CreatedBy INT
AS
BEGIN
    BEGIN TRAN;
    INSERT INTO Exams (Title, CourseId, ExamDate, DurationMinutes, CreatedAt, CreatedBy)
    VALUES (@Title, @CourseId, @ExamDate, @DurationMinutes, GETUTCDATE(), @CreatedBy);

    DECLARE @ExamId INT = SCOPE_IDENTITY();

    -- Caller inserts Questions separately and links in AddQuestionsToExam

    INSERT INTO Notifications (UserId, NotificationType, Message, CreatedAt, DateSent, IsRead)
    SELECT sc.UserId, ''Exam'', CONCAT(''Scheduled on '', FORMAT(@ExamDate, ''dd MMM yyyy'')), GETUTCDATE(), GETUTCDATE(), 0
    FROM StudentCourses sc WHERE sc.CourseId = @CourseId;

    COMMIT;
    SELECT @ExamId AS ExamId;
END')
END

-- ✅ sp_Exam_AddQuestionsToExam
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_AddQuestionsToExam]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_AddQuestionsToExam]
    @ExamId INT
AS
BEGIN
    DELETE FROM ExamQuestions WHERE ExamId = @ExamId;
    -- Caller inserts into ExamQuestions outside this SP
END')
END

-- ✅ sp_Exam_GetResultReport
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Exam_GetResultReport]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Exam_GetResultReport]
    @ExamId INT
AS
BEGIN
    SELECT
        e.Id AS ExamId,
        e.Title AS ExamTitle,
        e.ExamDate,
        s.UserId AS StudentId,
        u.FirstName + '' '' + u.LastName AS FullName,
        u.Email,
        u.Programme,
        u.Semester,
        ISNULL(c.Name, ''N/A'') AS CourseName,
        s.SubmittedAt,
        s.TotalScore AS Score,
        s.IsGraded,
        s.IsAutoGraded
    FROM ExamSubmissions s
    JOIN Users u ON s.UserId = u.UserId
    LEFT JOIN StudentCourses sc ON u.UserId = sc.UserId AND sc.CourseId = (SELECT CourseId FROM Exams WHERE Id = @ExamId)
    LEFT JOIN Courses c ON c.CourseId = sc.CourseId
    JOIN Exams e ON e.Id = s.ExamId
    WHERE s.ExamId = @ExamId
    ORDER BY s.TotalScore DESC;
END')
END

