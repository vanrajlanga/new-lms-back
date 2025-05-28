-- QuizController_Procedures.sql

-- ✅ sp_Quiz_CreateQuiz
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Quiz_CreateQuiz]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Quiz_CreateQuiz]
        @Title NVARCHAR(255),
        @CourseId INT,
        @Status NVARCHAR(50),
        @StartTime DATETIME = NULL,
        @DurationMinutes INT = NULL
    AS
    BEGIN
        INSERT INTO Quizzes (Title, CourseId, Status, StartTime, DurationMinutes)
        VALUES (@Title, @CourseId, @Status, @StartTime, @DurationMinutes);

        SELECT * FROM Quizzes WHERE QuizId = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ sp_Quiz_GetQuiz
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Quiz_GetQuiz]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Quiz_GetQuiz]
        @QuizId INT
    AS
    BEGIN
        SELECT * FROM Quizzes WHERE QuizId = @QuizId;

        SELECT * FROM QuizQuestions WHERE QuizId = @QuizId;
    END
    ')
END

-- ✅ sp_Quiz_GetQuizzesByCourse
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Quiz_GetQuizzesByCourse]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Quiz_GetQuizzesByCourse]
        @CourseId INT
    AS
    BEGIN
        SELECT * FROM Quizzes WHERE CourseId = @CourseId;

        SELECT * FROM QuizQuestions WHERE QuizId IN (SELECT QuizId FROM Quizzes WHERE CourseId = @CourseId);
    END
    ')
END

-- ✅ sp_Quiz_SubmitQuiz
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Quiz_SubmitQuiz]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Quiz_SubmitQuiz]
        @QuizId INT,
        @StudentId INT,
        @StartedAt DATETIME,
        @SubmittedAt DATETIME,
        @Score INT
    AS
    BEGIN
        INSERT INTO QuizSubmissions (QuizId, StudentId, StartedAt, SubmittedAt, Score)
        VALUES (@QuizId, @StudentId, @StartedAt, @SubmittedAt, @Score);

        SELECT SCOPE_IDENTITY() AS QuizSubmissionId;
    END
    ')
END

-- ✅ sp_Quiz_GetStudentResults
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Quiz_GetStudentResults]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Quiz_GetStudentResults]
        @StudentId INT
    AS
    BEGIN
        SELECT * FROM QuizSubmissions WHERE StudentId = @StudentId;

        SELECT * FROM Quizzes WHERE QuizId IN (SELECT QuizId FROM QuizSubmissions WHERE StudentId = @StudentId);

        SELECT * FROM QuizAnswers WHERE QuizSubmissionId IN (SELECT QuizSubmissionId FROM QuizSubmissions WHERE StudentId = @StudentId);

        SELECT * FROM QuizQuestions WHERE QuizId IN (SELECT QuizId FROM QuizSubmissions WHERE StudentId = @StudentId);
    END
    ')
END
