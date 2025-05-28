-- File: ExamGradingController_Procedures.sql

-- ✅ Procedure: sp_ExamGrading_AutoGrade
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_ExamGrading_AutoGrade]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_ExamGrading_AutoGrade]
        @SubmissionId INT
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @TotalScore FLOAT = 0;

        IF NOT EXISTS (SELECT 1 FROM ExamSubmissions WHERE Id = @SubmissionId)
        BEGIN
            RAISERROR(''Submission not found.'', 16, 1);
            RETURN;
        END

        -- Cursor to iterate answers
        DECLARE AnswerCursor CURSOR FOR
        SELECT Id, QuestionId, StudentAnswer
        FROM AnswerSubmissions
        WHERE ExamSubmissionId = @SubmissionId;

        DECLARE @AnswerId INT;
        DECLARE @QuestionId INT;
        DECLARE @StudentAnswer NVARCHAR(MAX);
        DECLARE @CorrectOption NVARCHAR(MAX);
        DECLARE @Score FLOAT;

        OPEN AnswerCursor;
        FETCH NEXT FROM AnswerCursor INTO @AnswerId, @QuestionId, @StudentAnswer;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @CorrectOption = CorrectOption
            FROM Questions
            WHERE Id = @QuestionId;

            IF @CorrectOption IS NOT NULL AND
               LTRIM(RTRIM(UPPER(@CorrectOption))) = LTRIM(RTRIM(UPPER(@StudentAnswer)))
            BEGIN
                SET @Score = 1;
                SET @TotalScore += 1;
            END
            ELSE
            BEGIN
                SET @Score = 0;
            END

            UPDATE AnswerSubmissions
            SET ScoreAwarded = @Score
            WHERE Id = @AnswerId;

            FETCH NEXT FROM AnswerCursor INTO @AnswerId, @QuestionId, @StudentAnswer;
        END

        CLOSE AnswerCursor;
        DEALLOCATE AnswerCursor;

        UPDATE ExamSubmissions
        SET TotalScore = @TotalScore,
            IsGraded = 1,
            IsAutoGraded = 1
        WHERE Id = @SubmissionId;

        SELECT ''Auto-graded successfully'' AS Message, @TotalScore AS TotalScore;
    END
    ')
END


-- ✅ Procedure: sp_ExamGrading_ManualGrade
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_ExamGrading_ManualGrade]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_ExamGrading_ManualGrade]
        @AnswerId INT,
        @Score FLOAT
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM AnswerSubmissions WHERE Id = @AnswerId)
        BEGIN
            RAISERROR(''Answer not found.'', 16, 1);
            RETURN;
        END

        UPDATE AnswerSubmissions
        SET ScoreAwarded = @Score
        WHERE Id = @AnswerId;

        SELECT ''Manual grading updated.'' AS Message;
    END
    ')
END
