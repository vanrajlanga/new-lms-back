
-- 1. Create Assignment and Notify Students
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_Create]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_Create]
        @CourseId INT,
        @Title NVARCHAR(MAX),
        @Description NVARCHAR(MAX),
        @DueDate DATETIME,
        @MaxGrade INT,
        @AssignmentType NVARCHAR(100),
        @FileUrl NVARCHAR(MAX),
        @CreatedBy INT,
        @CreatedDate DATETIME,
        @Semester NVARCHAR(50),
        @Programme NVARCHAR(100)
    AS
    BEGIN
        INSERT INTO Assignments (CourseId, Title, Description, DueDate, MaxGrade, AssignmentType, FileUrl, CreatedBy, CreatedDate, Semester, Programme)
        VALUES (@CourseId, @Title, @Description, @DueDate, @MaxGrade, @AssignmentType, @FileUrl, @CreatedBy, @CreatedDate, @Semester, @Programme);

        DECLARE @AssignmentId INT = SCOPE_IDENTITY();

        INSERT INTO Notifications (UserId, NotificationType, Message, CreatedAt, DateSent, IsRead)
        SELECT sc.UserId, ''Assignment'', ''Due: '' + CONVERT(VARCHAR, @DueDate, 106), GETUTCDATE(), GETUTCDATE(), 0
        FROM StudentCourses sc
        WHERE sc.CourseId = @CourseId;

        SELECT * FROM Assignments WHERE AssignmentId = @AssignmentId;
    END
    ')
END

-- 2. Get Assignment by ID
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_GetById]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_GetById]
        @AssignmentId INT
    AS
    BEGIN
        SELECT * FROM Assignments WHERE AssignmentId = @AssignmentId;
    END
    ')
END

-- 3. Get Assignments by Instructor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_GetByInstructor]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_GetByInstructor]
        @InstructorId INT
    AS
    BEGIN
        SELECT * FROM Assignments WHERE CreatedBy = @InstructorId;
    END
    ')
END

-- 4. Update Assignment
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_Update]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_Update]
        @AssignmentId INT,
        @Title NVARCHAR(MAX),
        @Description NVARCHAR(MAX),
        @DueDate DATETIME,
        @MaxGrade INT,
        @AssignmentType NVARCHAR(100),
        @CourseId INT,
        @UpdatedDate DATETIME
    AS
    BEGIN
        UPDATE Assignments
        SET Title = @Title,
            Description = @Description,
            DueDate = @DueDate,
            MaxGrade = @MaxGrade,
            AssignmentType = @AssignmentType,
            CourseId = @CourseId,
            UpdatedDate = @UpdatedDate
        WHERE AssignmentId = @AssignmentId;
    END
    ')
END

-- 5. Get All Assignments
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_GetAll]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_GetAll]
    AS
    BEGIN
        SELECT * FROM Assignments;
    END
    ')
END

-- 6. Delete Assignment
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_Delete]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_Delete]
        @AssignmentId INT
    AS
    BEGIN
        DELETE FROM Assignments WHERE AssignmentId = @AssignmentId;
    END
    ')
END

-- 7. Get Assignments by Course
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_GetByCourse]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_GetByCourse]
        @CourseId INT
    AS
    BEGIN
        SELECT * FROM Assignments WHERE CourseId = @CourseId;
    END
    ')
END

-- 8. Get Assignments by Student (via enrolled courses)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_GetByStudent]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_GetByStudent]
        @StudentId INT
    AS
    BEGIN
        SELECT a.*
        FROM Assignments a
        WHERE a.CourseId IN (
            SELECT CourseId FROM StudentCourses WHERE UserId = @StudentId
        );
    END
    ')
END

-- 9. Count Assignments by Course
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Assignment_CountByCourse]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Assignment_CountByCourse]
        @CourseId INT
    AS
    BEGIN
        SELECT COUNT(*) AS Total FROM Assignments WHERE CourseId = @CourseId;
    END
    ')
END
