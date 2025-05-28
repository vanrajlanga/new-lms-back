-- File: DepartmentController_Procedures.sql

-- ✅ Procedure: sp_Department_GetAll
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Department_GetAll]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Department_GetAll]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        Id, Name, Code, Description,
        HeadOfDepartment, FacultyCount, EstablishedYear,
        Location, ContactEmail, ContactPhone, WebsiteUrl
    FROM Departments;
END
')
END

-- ✅ Procedure: sp_Department_GetById
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Department_GetById]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Department_GetById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        Id, Name, Code, Description,
        HeadOfDepartment, FacultyCount, EstablishedYear,
        Location, ContactEmail, ContactPhone, WebsiteUrl
    FROM Departments
    WHERE Id = @Id;
END
')
END

-- ✅ PATCHED Procedure: sp_Department_Create
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Department_Create]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Department_Create]
GO

EXEC('
CREATE PROCEDURE [dbo].[sp_Department_Create]
    @Name NVARCHAR(255),
    @Code NVARCHAR(50),
    @Description NVARCHAR(500),
    @HeadOfDepartment NVARCHAR(255),
    @FacultyCount INT,
    @EstablishedYear INT,
    @Location NVARCHAR(255),
    @ContactEmail NVARCHAR(255),
    @ContactPhone NVARCHAR(50),
    @WebsiteUrl NVARCHAR(255),
    @CoursesOffered NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Departments (
        Name, Code, Description, HeadOfDepartment,
        FacultyCount, EstablishedYear, Location,
        ContactEmail, ContactPhone, WebsiteUrl,
        CoursesOffered, CreatedAt, UpdatedAt
    )
    VALUES (
        @Name, @Code, @Description, @HeadOfDepartment,
        @FacultyCount, @EstablishedYear, @Location,
        @ContactEmail, @ContactPhone, @WebsiteUrl,
        @CoursesOffered, GETUTCDATE(), GETUTCDATE()
    );

    SELECT SCOPE_IDENTITY() AS Id;
END
')

-- ✅ Procedure: sp_Department_Update
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Department_Update]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Department_Update]
    @Id INT,
    @Name NVARCHAR(255),
    @Code NVARCHAR(50),
    @Description NVARCHAR(500),
    @HeadOfDepartment NVARCHAR(255),
    @FacultyCount INT,
    @EstablishedYear INT,
    @Location NVARCHAR(255),
    @ContactEmail NVARCHAR(255),
    @ContactPhone NVARCHAR(50),
    @WebsiteUrl NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Departments
    SET
        Name = @Name,
        Code = @Code,
        Description = @Description,
        HeadOfDepartment = @HeadOfDepartment,
        FacultyCount = @FacultyCount,
        EstablishedYear = @EstablishedYear,
        Location = @Location,
        ContactEmail = @ContactEmail,
        ContactPhone = @ContactPhone,
        WebsiteUrl = @WebsiteUrl,
        UpdatedAt = GETUTCDATE()
    WHERE Id = @Id;
END
')
END

-- ✅ Procedure: sp_Department_Delete
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Department_Delete]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Department_Delete]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Departments WHERE Id = @Id;
END
')
END
