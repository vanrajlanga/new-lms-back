-- ================================================
-- File: Programme_Procedures.sql
-- Description: Stored Procedures for ProgrammeController (updated with BatchName)
-- ================================================

-- ✅ Create sp_Programme_GetAllProgrammes if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_GetAllProgrammes]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_GetAllProgrammes]
    AS
    BEGIN
        SELECT * FROM Programmes;
    END
    ')
END

-- ✅ Create sp_Programme_GetProgramme if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_GetProgramme]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_GetProgramme]
        @ProgrammeId INT
    AS
    BEGIN
        SELECT * FROM Programmes WHERE ProgrammeId = @ProgrammeId;
    END
    ')
END

-- ✅ Create sp_Programme_GetProgrammeByCode if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_GetProgrammeByCode]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_GetProgrammeByCode]
        @ProgrammeCode NVARCHAR(50)
    AS
    BEGIN
        SELECT * FROM Programmes WHERE ProgrammeCode = @ProgrammeCode;
    END
    ')
END

-- ✅ Create sp_Programme_GetProgrammesWithSemesters if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_GetProgrammesWithSemesters]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_GetProgrammesWithSemesters]
    AS
    BEGIN
        SELECT 
            Programme AS ProgrammeName,
            Semester,
            CourseId,
            Name,
            CourseCode,
            Credits,
            CourseDescription
        FROM Courses
        WHERE Programme IS NOT NULL AND Semester IS NOT NULL;
    END
    ')
END

-- ✅ Create sp_Programme_GetProgrammeWithCourses if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_GetProgrammeWithCourses]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_GetProgrammeWithCourses]
        @ProgrammeCode NVARCHAR(50)
    AS
    BEGIN
        SELECT 
            CourseId,
            Name,
            CourseCode,
            Credits,
            CourseDescription,
            Semester
        FROM Courses
        WHERE Programme = @ProgrammeCode;
    END
    ')
END

-- ✅ Create sp_Programme_CreateProgramme if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_CreateProgramme]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_CreateProgramme]
        @ProgrammeName NVARCHAR(255),
        @ProgrammeCode NVARCHAR(50),
        @NumberOfSemesters INT,
        @Fee DECIMAL(18,2),
        @BatchName NVARCHAR(20)
    AS
    BEGIN
        DECLARE @CreatedDate DATETIME = GETUTCDATE();

        INSERT INTO Programmes (ProgrammeName, ProgrammeCode, NumberOfSemesters, Fee, BatchName, CreatedDate, UpdatedDate)
        VALUES (@ProgrammeName, @ProgrammeCode, @NumberOfSemesters, @Fee, @BatchName, @CreatedDate, @CreatedDate);

        DECLARE @ProgrammeId INT = SCOPE_IDENTITY();

        DECLARE @i INT = 1;
        WHILE @i <= @NumberOfSemesters
        BEGIN
            INSERT INTO SemesterFeeTemplates (Programme, Semester, AmountDue)
            VALUES (@ProgrammeName, ''Semester '' + CAST(@i AS NVARCHAR), @Fee);
            SET @i += 1;
        END

        SELECT * FROM Programmes WHERE ProgrammeId = @ProgrammeId;
    END
    ')
END

-- ✅ Create sp_Programme_UpdateProgramme if not exists-- ✅ Replace sp_Programme_UpdateProgramme with BatchName included
IF OBJECT_ID(N'dbo.sp_Programme_UpdateProgramme', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Programme_UpdateProgramme;
GO

EXEC('
CREATE PROCEDURE [dbo].[sp_Programme_UpdateProgramme]
    @ProgrammeId INT,
    @ProgrammeName NVARCHAR(255),
    @ProgrammeCode NVARCHAR(50),
    @NumberOfSemesters INT,
    @Fee DECIMAL(18,2),
    @BatchName NVARCHAR(20)
AS
BEGIN
    UPDATE Programmes
    SET ProgrammeName = @ProgrammeName,
        ProgrammeCode = @ProgrammeCode,
        NumberOfSemesters = @NumberOfSemesters,
        Fee = @Fee,
        BatchName = @BatchName,
        UpdatedDate = GETUTCDATE()
    WHERE ProgrammeId = @ProgrammeId;
END
');


-- ✅ Create sp_Programme_DeleteProgramme if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Programme_DeleteProgramme]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Programme_DeleteProgramme]
        @ProgrammeId INT
    AS
    BEGIN
        DELETE FROM Programmes WHERE ProgrammeId = @ProgrammeId;
    END
    ')
END
