
-- 1. Submit assignment with file
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AssignmentSubmission_Submit]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_AssignmentSubmission_Submit]
        @AssignmentId INT,
        @StudentId INT,
        @SubmissionDate DATETIME,
        @FilePath NVARCHAR(MAX),
        @Status INT,
        @Feedback NVARCHAR(MAX)
    AS
    BEGIN
        IF EXISTS (
            SELECT 1 FROM AssignmentSubmissions 
            WHERE AssignmentId = @AssignmentId AND StudentId = @StudentId
        )
        BEGIN
            RAISERROR(''Already submitted.'', 16, 1);
            RETURN;
        END

        INSERT INTO AssignmentSubmissions (AssignmentId, StudentId, SubmissionDate, FilePath, Status, Feedback)
        VALUES (@AssignmentId, @StudentId, @SubmissionDate, @FilePath, @Status, @Feedback);

        SELECT SCOPE_IDENTITY() AS SubmissionId;
    END
    ')
END

-- 2. Grade assignment
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AssignmentSubmission_Grade]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_AssignmentSubmission_Grade]
        @SubmissionId INT,
        @Grade INT,
        @Feedback NVARCHAR(MAX)
    AS
    BEGIN
        UPDATE AssignmentSubmissions
        SET Grade = @Grade,
            Feedback = @Feedback,
            Status = 1 -- Graded
        WHERE AssignmentSubmissionId = @SubmissionId;
    END
    ')
END

-- 3. Get assignments not submitted by student
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AssignmentSubmission_NotSubmittedByStudent]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_AssignmentSubmission_NotSubmittedByStudent]
        @StudentId INT
    AS
    BEGIN
        SELECT a.*
        FROM Assignments a
        WHERE a.AssignmentId NOT IN (
            SELECT AssignmentId 
            FROM AssignmentSubmissions 
            WHERE StudentId = @StudentId
        );
    END
    ')
END

-- 4. Get submissions by student
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AssignmentSubmission_GetByStudent]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_AssignmentSubmission_GetByStudent]
        @StudentId INT
    AS
    BEGIN
        SELECT s.*, a.Title AS AssignmentTitle
        FROM AssignmentSubmissions s
        JOIN Assignments a ON s.AssignmentId = a.AssignmentId
        WHERE s.StudentId = @StudentId;
    END
    ')
END

-- 5. Get all submissions by instructor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_AssignmentSubmission_GetAllByInstructor]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_AssignmentSubmission_GetAllByInstructor]
        @InstructorId INT
    AS
    BEGIN
        SELECT 
            s.AssignmentSubmissionId,
            s.SubmissionDate,
            s.Grade,
            s.Feedback,
            s.Status,
            s.FilePath,
            u.UserId AS StudentId,
            a.AssignmentId,
            a.Title AS AssignmentTitle
        FROM AssignmentSubmissions s
        JOIN Assignments a ON s.AssignmentId = a.AssignmentId
        JOIN Users u ON s.StudentId = u.UserId
        WHERE a.CreatedBy = @InstructorId;
    END
    ')
END
