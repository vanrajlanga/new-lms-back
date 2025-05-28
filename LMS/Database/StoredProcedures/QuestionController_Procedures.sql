-- QuestionController_Procedures.sql

-- ✅ sp_Question_GetAll
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Question_GetAll]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Question_GetAll]
    AS
    BEGIN
        SELECT * FROM Questions;
    END
    ')
END

-- ✅ sp_Question_GetById
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Question_GetById]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Question_GetById]
        @Id INT
    AS
    BEGIN
        SELECT * FROM Questions WHERE Id = @Id;
    END
    ')
END

-- ✅ sp_Question_Create
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Question_Create]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Question_Create]
        @Subject NVARCHAR(100),
        @Topic NVARCHAR(100),
        @QuestionText NVARCHAR(MAX),
        @OptionA NVARCHAR(100),
        @OptionB NVARCHAR(100),
        @OptionC NVARCHAR(100),
        @OptionD NVARCHAR(100),
        @CorrectOption NVARCHAR(10),
        @DifficultyLevel NVARCHAR(50)
    AS
    BEGIN
        INSERT INTO Questions (Subject, Topic, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption, DifficultyLevel)
        VALUES (@Subject, @Topic, @QuestionText, @OptionA, @OptionB, @OptionC, @OptionD, @CorrectOption, @DifficultyLevel);

        SELECT * FROM Questions WHERE Id = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ sp_Question_Update
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Question_Update]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Question_Update]
        @Id INT,
        @Subject NVARCHAR(100),
        @Topic NVARCHAR(100),
        @QuestionText NVARCHAR(MAX),
        @OptionA NVARCHAR(100),
        @OptionB NVARCHAR(100),
        @OptionC NVARCHAR(100),
        @OptionD NVARCHAR(100),
        @CorrectOption NVARCHAR(10),
        @DifficultyLevel NVARCHAR(50)
    AS
    BEGIN
        UPDATE Questions
        SET Subject = @Subject,
            Topic = @Topic,
            QuestionText = @QuestionText,
            OptionA = @OptionA,
            OptionB = @OptionB,
            OptionC = @OptionC,
            OptionD = @OptionD,
            CorrectOption = @CorrectOption,
            DifficultyLevel = @DifficultyLevel
        WHERE Id = @Id;
    END
    ')
END

-- ✅ sp_Question_Delete
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Question_Delete]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Question_Delete]
        @Id INT
    AS
    BEGIN
        DELETE FROM Questions WHERE Id = @Id;
    END
    ')
END
