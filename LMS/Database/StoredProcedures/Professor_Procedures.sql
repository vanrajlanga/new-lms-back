-- ================================================
-- File: Professor_Procedures.sql
-- Description: Stored Procedures for ProfessorController
-- ================================================

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_GetProfessors]') 
    AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_GetProfessors]
AS
BEGIN
    SET NOCOUNT ON;

    -- First result set: list of professors
    SELECT 
        u.UserId,
        CONCAT(ISNULL(u.FirstName, ''''), '' '', ISNULL(u.LastName, '''')) AS FullName,
        u.Email,
        u.PhoneNumber,
        u.Programme AS Department,
        p.Bio,
        u.ProfilePhotoUrl AS ProfilePictureUrl,
        p.OfficeLocation,
        p.OfficeHours,
        u.Status AS EmployeeStatus,
        GETUTCDATE() AS AccountCreated,   -- Placeholder if actual CreatedAt not stored
        NULL AS LastLogin,                -- Placeholder if not implemented
        CASE WHEN u.Status = ''Active'' THEN 1 ELSE 0 END AS IsActive,
        u.Role,
        p.SocialMediaLinks,
        p.EducationalBackground,
        p.ResearchInterests,
        p.TeachingRating
    FROM Users u
    INNER JOIN Professors p ON u.UserId = p.UserId
    WHERE u.Role = ''Instructor'';

    -- Second result set: assigned courses
    SELECT 
        ic.InstructorId AS ProfessorId,
        c.CourseId,
        c.Name,
        c.CourseCode,
        c.Credits,
        c.CourseDescription,
        c.Semester,
        c.Programme
    FROM InstructorCourses ic
    INNER JOIN Courses c ON c.CourseId = ic.CourseId;
END
')
END

-- ================================================
-- File: Professor_Procedures.sql
-- Description: Stored Procedures for ProfessorController
-- ================================================

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_GetProfessors]') 
    AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_GetProfessors]
AS
BEGIN
    SET NOCOUNT ON;

    -- First result set: list of professors
    SELECT 
        u.UserId,
        CONCAT(ISNULL(u.FirstName, ''''), '' '', ISNULL(u.LastName, '''')) AS FullName,
        u.Email,
        u.PhoneNumber,
        u.Programme AS Department,
        p.Bio,
        u.ProfilePhotoUrl AS ProfilePictureUrl,
        p.OfficeLocation,
        p.OfficeHours,
        u.Status AS EmployeeStatus,
        GETUTCDATE() AS AccountCreated,   -- Placeholder if actual CreatedAt not stored
        NULL AS LastLogin,                -- Placeholder if not implemented
        CASE WHEN u.Status = ''Active'' THEN 1 ELSE 0 END AS IsActive,
        u.Role,
        p.SocialMediaLinks,
        p.EducationalBackground,
        p.ResearchInterests,
        p.TeachingRating
    FROM Users u
    INNER JOIN Professors p ON u.UserId = p.UserId
    WHERE u.Role = ''Instructor'';

    -- Second result set: assigned courses
    SELECT 
        ic.InstructorId AS ProfessorId,
        c.CourseId,
        c.Name,
        c.CourseCode,
        c.Credits,
        c.CourseDescription,
        c.Semester,
        c.Programme
    FROM InstructorCourses ic
    INNER JOIN Courses c ON c.CourseId = ic.CourseId;
END
')
END
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_GetAssignedCoursesForProfessor]') 
    AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_GetAssignedCoursesForProfessor]
    @ProfessorId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CourseId,
        c.Name,
        c.CourseCode,
        c.Credits,
        c.CourseDescription,
        c.Semester,
        c.Programme
    FROM InstructorCourses ic
    INNER JOIN Courses c ON c.CourseId = ic.CourseId
    WHERE ic.InstructorId = @ProfessorId;
END
')
END


-- ✅ Get Professor By ID
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_GetProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_GetProfessor]
    @UserId INT
AS
BEGIN
    SELECT 
        u.UserId,
        CONCAT(u.FirstName, '' '', u.LastName) AS FullName,
        u.Email,
        u.PhoneNumber,
        p.Department,
        p.Bio,
        u.ProfilePhotoUrl AS ProfilePictureUrl,
        p.OfficeLocation,
        p.OfficeHours,
        u.Status AS EmployeeStatus,
        GETUTCDATE() AS AccountCreated,
        NULL AS LastLogin,
        CASE WHEN u.Status = ''Active'' THEN 1 ELSE 0 END AS IsActive,
        u.Role,
        p.SocialMediaLinks,
        p.EducationalBackground,
        p.ResearchInterests,
        p.TeachingRating
    FROM Users u
    INNER JOIN Professors p ON u.UserId = p.UserId
    WHERE u.UserId = @UserId AND u.Role = ''Instructor'';
END
')
END

-- ✅ Create Professor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_PostProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_PostProfessor]
    @Username NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @Email NVARCHAR(255),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @PhoneNumber NVARCHAR(50),
    @ProfilePictureUrl NVARCHAR(MAX),
    @OfficeLocation NVARCHAR(255),
    @EmployeeStatus NVARCHAR(50),
    @Department NVARCHAR(255),
    @Bio NVARCHAR(MAX),
    @OfficeHours NVARCHAR(255),
    @SocialMediaLinks NVARCHAR(MAX),
    @EducationalBackground NVARCHAR(MAX),
    @ResearchInterests NVARCHAR(MAX),
    @TeachingRating FLOAT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        RAISERROR (''Username already exists.'', 16, 1);
        RETURN;
    END

    INSERT INTO Users (Username, PasswordHash, Role, Email, FirstName, LastName, PhoneNumber, ProfilePhotoUrl, Address, Status)
    VALUES (@Username, @PasswordHash, ''Instructor'', @Email, @FirstName, @LastName, @PhoneNumber, @ProfilePictureUrl, @OfficeLocation, @EmployeeStatus);

    DECLARE @NewUserId INT = SCOPE_IDENTITY();

    INSERT INTO Professors (UserId, Department, Bio, OfficeLocation, OfficeHours, SocialMediaLinks, EducationalBackground, ResearchInterests, TeachingRating)
    VALUES (@NewUserId, @Department, @Bio, @OfficeLocation, @OfficeHours, @SocialMediaLinks, @EducationalBackground, @ResearchInterests, @TeachingRating);
END
')
END

-- ✅ Update Professor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_UpdateProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_UpdateProfessor]
    @UserId INT,
    @Email NVARCHAR(255),
    @FullName NVARCHAR(255),
    @PhoneNumber NVARCHAR(50),
    @ProfilePictureUrl NVARCHAR(MAX),
    @OfficeLocation NVARCHAR(255),
    @EmployeeStatus NVARCHAR(50),
    @Role NVARCHAR(50),
    @Department NVARCHAR(255),
    @Bio NVARCHAR(MAX),
    @OfficeHours NVARCHAR(255),
    @SocialMediaLinks NVARCHAR(MAX),
    @EducationalBackground NVARCHAR(MAX),
    @ResearchInterests NVARCHAR(MAX),
    @TeachingRating FLOAT
AS
BEGIN
    DECLARE @FirstName NVARCHAR(100), @LastName NVARCHAR(100);
    SET @FirstName = LEFT(@FullName, CHARINDEX('' '', @FullName + '' '') - 1);
    SET @LastName = LTRIM(RIGHT(@FullName, LEN(@FullName) - LEN(@FirstName)));

    UPDATE Users
    SET Email = @Email,
        FirstName = @FirstName,
        LastName = @LastName,
        PhoneNumber = @PhoneNumber,
        ProfilePhotoUrl = @ProfilePictureUrl,
        Address = @OfficeLocation,
        Status = @EmployeeStatus,
        Role = @Role
    WHERE UserId = @UserId AND Role = ''Instructor'';

    UPDATE Professors
    SET Department = @Department,
        Bio = @Bio,
        OfficeLocation = @OfficeLocation,
        OfficeHours = @OfficeHours,
        SocialMediaLinks = @SocialMediaLinks,
        EducationalBackground = @EducationalBackground,
        ResearchInterests = @ResearchInterests,
        TeachingRating = @TeachingRating
    WHERE UserId = @UserId;
END
')
END

-- ✅ Assign Courses to Professor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_AssignCoursesToProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_AssignCoursesToProfessor]
    @ProfessorId INT,
    @CourseId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @ProfessorId AND Role = ''Instructor'')
    BEGIN
        RAISERROR (''Professor not found.'', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Courses WHERE CourseId = @CourseId)
    BEGIN
        RAISERROR (''Course not found.'', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM InstructorCourses WHERE InstructorId = @ProfessorId AND CourseId = @CourseId)
    BEGIN
        INSERT INTO InstructorCourses (InstructorId, CourseId)
        VALUES (@ProfessorId, @CourseId);
    END
END
')
END




IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_GetAssignedCoursesForProfessor]') 
    AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_GetAssignedCoursesForProfessor]
    @ProfessorId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CourseId,
        c.Name,
        c.CourseCode,
        c.Credits,
        c.CourseDescription,
        c.Semester,
        c.Programme
    FROM InstructorCourses ic
    INNER JOIN Courses c ON c.CourseId = ic.CourseId
    WHERE ic.InstructorId = @ProfessorId;
END
')
END


-- ✅ Get Professor By ID
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_GetProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_GetProfessor]
    @UserId INT
AS
BEGIN
    SELECT 
        u.UserId,
        CONCAT(u.FirstName, '' '', u.LastName) AS FullName,
        u.Email,
        u.PhoneNumber,
        p.Department,
        p.Bio,
        u.ProfilePhotoUrl AS ProfilePictureUrl,
        p.OfficeLocation,
        p.OfficeHours,
        u.Status AS EmployeeStatus,
        GETUTCDATE() AS AccountCreated,
        NULL AS LastLogin,
        CASE WHEN u.Status = ''Active'' THEN 1 ELSE 0 END AS IsActive,
        u.Role,
        p.SocialMediaLinks,
        p.EducationalBackground,
        p.ResearchInterests,
        p.TeachingRating
    FROM Users u
    INNER JOIN Professors p ON u.UserId = p.UserId
    WHERE u.UserId = @UserId AND u.Role = ''Instructor'';
END
')
END

-- ✅ Create Professor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_PostProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_PostProfessor]
    @Username NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @Email NVARCHAR(255),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @PhoneNumber NVARCHAR(50),
    @ProfilePictureUrl NVARCHAR(MAX),
    @OfficeLocation NVARCHAR(255),
    @EmployeeStatus NVARCHAR(50),
    @Department NVARCHAR(255),
    @Bio NVARCHAR(MAX),
    @OfficeHours NVARCHAR(255),
    @SocialMediaLinks NVARCHAR(MAX),
    @EducationalBackground NVARCHAR(MAX),
    @ResearchInterests NVARCHAR(MAX),
    @TeachingRating FLOAT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        RAISERROR (''Username already exists.'', 16, 1);
        RETURN;
    END

    INSERT INTO Users (Username, PasswordHash, Role, Email, FirstName, LastName, PhoneNumber, ProfilePhotoUrl, Address, Status)
    VALUES (@Username, @PasswordHash, ''Instructor'', @Email, @FirstName, @LastName, @PhoneNumber, @ProfilePictureUrl, @OfficeLocation, @EmployeeStatus);

    DECLARE @NewUserId INT = SCOPE_IDENTITY();

    INSERT INTO Professors (UserId, Department, Bio, OfficeLocation, OfficeHours, SocialMediaLinks, EducationalBackground, ResearchInterests, TeachingRating)
    VALUES (@NewUserId, @Department, @Bio, @OfficeLocation, @OfficeHours, @SocialMediaLinks, @EducationalBackground, @ResearchInterests, @TeachingRating);
END
')
END

-- ✅ Update Professor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_UpdateProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_UpdateProfessor]
    @UserId INT,
    @Email NVARCHAR(255),
    @FullName NVARCHAR(255),
    @PhoneNumber NVARCHAR(50),
    @ProfilePictureUrl NVARCHAR(MAX),
    @OfficeLocation NVARCHAR(255),
    @EmployeeStatus NVARCHAR(50),
    @Role NVARCHAR(50),
    @Department NVARCHAR(255),
    @Bio NVARCHAR(MAX),
    @OfficeHours NVARCHAR(255),
    @SocialMediaLinks NVARCHAR(MAX),
    @EducationalBackground NVARCHAR(MAX),
    @ResearchInterests NVARCHAR(MAX),
    @TeachingRating FLOAT
AS
BEGIN
    DECLARE @FirstName NVARCHAR(100), @LastName NVARCHAR(100);
    SET @FirstName = LEFT(@FullName, CHARINDEX('' '', @FullName + '' '') - 1);
    SET @LastName = LTRIM(RIGHT(@FullName, LEN(@FullName) - LEN(@FirstName)));

    UPDATE Users
    SET Email = @Email,
        FirstName = @FirstName,
        LastName = @LastName,
        PhoneNumber = @PhoneNumber,
        ProfilePhotoUrl = @ProfilePictureUrl,
        Address = @OfficeLocation,
        Status = @EmployeeStatus,
        Role = @Role
    WHERE UserId = @UserId AND Role = ''Instructor'';

    UPDATE Professors
    SET Department = @Department,
        Bio = @Bio,
        OfficeLocation = @OfficeLocation,
        OfficeHours = @OfficeHours,
        SocialMediaLinks = @SocialMediaLinks,
        EducationalBackground = @EducationalBackground,
        ResearchInterests = @ResearchInterests,
        TeachingRating = @TeachingRating
    WHERE UserId = @UserId;
END
')
END

-- ✅ sp_Professor_DeleteProfessorByUserId
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_DeleteProfessorByUserId]') 
    AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_DeleteProfessorByUserId]
    @UserId INT
AS
BEGIN
    -- Delete any course assignments for this professor
    DELETE FROM InstructorCourses WHERE InstructorId = @UserId;

    -- Delete professor details
    DELETE FROM Professors WHERE UserId = @UserId;

    -- Delete user account if role is Instructor
    DELETE FROM Users WHERE UserId = @UserId AND Role = ''Instructor'';
END
')
END

-- ✅ Assign Courses to Professor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Professor_AssignCoursesToProfessor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Professor_AssignCoursesToProfessor]
    @ProfessorId INT,
    @CourseId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @ProfessorId AND Role = ''Instructor'')
    BEGIN
        RAISERROR (''Professor not found.'', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Courses WHERE CourseId = @CourseId)
    BEGIN
        RAISERROR (''Course not found.'', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM InstructorCourses WHERE InstructorId = @ProfessorId AND CourseId = @CourseId)
    BEGIN
        INSERT INTO InstructorCourses (InstructorId, CourseId)
        VALUES (@ProfessorId, @CourseId);
    END
END
')
END
