-- ✅ Procedure: sp_Examination_Create
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_Create]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_Create]
        @CourseId INT,
        @GroupId INT,
        @Semester INT,
        @PaperCode NVARCHAR(50),
        @PaperName NVARCHAR(100),
        @IsElective BIT,
        @PaperType NVARCHAR(MAX),
        @Credits INT,
        @InternalMarks1 INT,
        @InternalMarks2 INT,
        @TotalInternalMarks INT,
        @TotalMarks INT
    AS
    BEGIN
        SET NOCOUNT ON;

        IF EXISTS (
            SELECT 1 FROM Examinations 
            WHERE PaperCode = @PaperCode AND CourseId = @CourseId AND GroupId = @GroupId AND Semester = @Semester
        )
        BEGIN
            RAISERROR(''Duplicate Paper Code not allowed in same course-group-semester.'', 16, 1);
            RETURN;
        END

        INSERT INTO Examinations
        (
            CourseId, GroupId, Semester, PaperCode, PaperName, IsElective, PaperType, Credits,
            InternalMarks1, InternalMarks2, TotalInternalMarks, TotalMarks,
            CreatedDate, UpdatedDate
        )
        VALUES
        (
            @CourseId, @GroupId, @Semester, @PaperCode, @PaperName, @IsElective, @PaperType, @Credits,
            @InternalMarks1, @InternalMarks2, @TotalInternalMarks, @TotalMarks,
            GETUTCDATE(), GETUTCDATE()
        );

        DECLARE @NewId INT = SCOPE_IDENTITY();
        SELECT * FROM Examinations WHERE ExaminationId = @NewId;
    END
    ')
END

-- ✅ Procedure: sp_Examination_GetAll
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_GetAll]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_GetAll]
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT e.*, c.Name AS CourseName, g.GroupName AS GroupTitle
        FROM Examinations e
        LEFT JOIN Courses c ON e.CourseId = c.CourseId
        LEFT JOIN Groups g ON e.GroupId = g.GroupId;
    END
    ')
END

-- ✅ Procedure: sp_Examination_GetById
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_GetById]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_GetById]
        @Id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT e.*, c.Name AS CourseName, g.GroupName AS GroupTitle
        FROM Examinations e
        LEFT JOIN Courses c ON e.CourseId = c.CourseId
        LEFT JOIN Groups g ON e.GroupId = g.GroupId
        WHERE e.ExaminationId = @Id;
    END
    ')
END

-- ✅ Procedure: sp_Examination_Update
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_Update]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_Update]
        @ExaminationId INT,
        @CourseId INT,
        @GroupId INT,
        @Semester INT,
        @PaperCode NVARCHAR(50),
        @PaperName NVARCHAR(100),
        @IsElective BIT,
        @PaperType NVARCHAR(MAX),
        @Credits INT,
        @InternalMarks1 INT,
        @InternalMarks2 INT,
        @TotalInternalMarks INT,
        @TotalMarks INT
    AS
    BEGIN
        SET NOCOUNT ON;

        UPDATE Examinations
        SET CourseId = @CourseId,
            GroupId = @GroupId,
            Semester = @Semester,
            PaperCode = @PaperCode,
            PaperName = @PaperName,
            IsElective = @IsElective,
            PaperType = @PaperType,
            Credits = @Credits,
            InternalMarks1 = @InternalMarks1,
            InternalMarks2 = @InternalMarks2,
            TotalInternalMarks = @TotalInternalMarks,
            TotalMarks = @TotalMarks,
            UpdatedDate = GETUTCDATE()
        WHERE ExaminationId = @ExaminationId;
    END
    ')
END

-- ✅ Procedure: sp_Examination_Delete
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_Delete]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_Delete]
        @Id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        DELETE FROM Examinations WHERE ExaminationId = @Id;
    END
    ')
END

-- ✅ Procedure: sp_Examination_GetByStudent
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_GetByStudent]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_GetByStudent]
        @StudentId INT
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT e.*, c.Name AS CourseName, g.GroupName AS GroupTitle
        FROM StudentCourses sc
        JOIN Examinations e ON sc.CourseId = e.CourseId
        LEFT JOIN Courses c ON e.CourseId = c.CourseId
        LEFT JOIN Groups g ON e.GroupId = g.GroupId
        WHERE sc.UserId = @StudentId;
    END
    ')
END

-- ✅ Procedure: sp_Examination_GetByInstructor
IF NOT EXISTS (
    SELECT * FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Examination_GetByInstructor]')
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Examination_GetByInstructor]
        @InstructorId INT
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM InstructorCourses WHERE InstructorId = @InstructorId)
        BEGIN
            RAISERROR(''No courses found for the instructor.'', 16, 1);
            RETURN;
        END

        SELECT e.*, c.Name AS CourseName, g.GroupName AS GroupTitle
        FROM InstructorCourses ic
        JOIN Examinations e ON ic.CourseId = e.CourseId
        LEFT JOIN Courses c ON e.CourseId = c.CourseId
        LEFT JOIN Groups g ON e.GroupId = g.GroupId
        WHERE ic.InstructorId = @InstructorId;
    END
    ')
END
