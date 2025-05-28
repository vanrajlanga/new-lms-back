-- File: InstructorController_Procedures.sql

-- ✅ Procedure: sp_Instructor_Register
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_Register]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_Register]
  @Username NVARCHAR(100),
  @PasswordHash NVARCHAR(MAX),
  @Email NVARCHAR(100),
  @FirstName NVARCHAR(100),
  @LastName NVARCHAR(100),
  @PhoneNumber NVARCHAR(50),
  @ProfilePhotoUrl NVARCHAR(255),
  @OfficeLocation NVARCHAR(255),
  @EmployeeStatus NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
  BEGIN
    RAISERROR(''Username already exists.'', 16, 1);
    RETURN;
  END

  INSERT INTO Users
  (Username, PasswordHash, Role, Email, FirstName, LastName, PhoneNumber, ProfilePhotoUrl, Address, Status)
  VALUES
  (@Username, @PasswordHash, ''Instructor'', @Email, @FirstName, @LastName, @PhoneNumber, @ProfilePhotoUrl, @OfficeLocation, @EmployeeStatus);

  SELECT ''Instructor registered successfully'' AS Message;
END
')
END

-- ✅ Procedure: sp_Instructor_GetDetails
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_GetDetails]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_GetDetails]
  @UserId INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT * FROM Users WHERE UserId = @UserId AND Role = ''Instructor'';

  SELECT * FROM ProfessionalInfos WHERE UserId = @UserId;
  SELECT * FROM EducationInfos WHERE UserId = @UserId;
  SELECT * FROM Professors WHERE UserId = @UserId;
END
')
END

-- ✅ Procedure: sp_Instructor_GetById
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_GetById]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_GetById]
  @UserId INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT u.UserId, u.FirstName, u.LastName, u.Email, u.PhoneNumber,
         u.ProfilePhotoUrl, u.Status, u.Role,
         p.Department, p.Bio, p.OfficeLocation, p.OfficeHours,
         p.SocialMediaLinks, p.EducationalBackground, p.ResearchInterests, p.TeachingRating
  FROM Users u
  LEFT JOIN Professors p ON u.UserId = p.UserId
  WHERE u.UserId = @UserId AND u.Role = ''Instructor'';
END
')
END

-- ✅ Procedure: sp_Instructor_GetProfessional
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_GetProfessional]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_GetProfessional]
  @UserId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT * FROM ProfessionalInfos WHERE UserId = @UserId;
END
')
END

-- ✅ Procedure: sp_Instructor_AddProfessional
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_AddProfessional]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_AddProfessional]
  @UserId INT,
  @Title NVARCHAR(255),
  @Company NVARCHAR(255),
  @Location NVARCHAR(255),
  @Experience NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO ProfessionalInfos (UserId, Title, Company, Location, Experience)
  VALUES (@UserId, @Title, @Company, @Location, @Experience);

  SELECT * FROM ProfessionalInfos WHERE Id = SCOPE_IDENTITY();
END
')
END

-- ✅ Procedure: sp_Instructor_UpdateProfessional
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_UpdateProfessional]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_UpdateProfessional]
  @Id INT,
  @UserId INT,
  @Title NVARCHAR(255),
  @Company NVARCHAR(255),
  @Location NVARCHAR(255),
  @Experience NVARCHAR(255)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM ProfessionalInfos WHERE Id = @Id AND UserId = @UserId)
  BEGIN
    RAISERROR(''Professional info not found.'', 16, 1);
    RETURN;
  END

  UPDATE ProfessionalInfos
  SET Title = @Title, Company = @Company, Location = @Location, Experience = @Experience
  WHERE Id = @Id;

  SELECT * FROM ProfessionalInfos WHERE Id = @Id;
END
')
END

-- ✅ Procedure: sp_Instructor_DeleteProfessional
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_DeleteProfessional]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_DeleteProfessional]
  @Id INT,
  @UserId INT
AS
BEGIN
  SET NOCOUNT ON;

  DELETE FROM ProfessionalInfos WHERE Id = @Id AND UserId = @UserId;
END
')
END

-- ✅ Procedure: sp_Instructor_GetEducation
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_GetEducation]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_GetEducation]
  @UserId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT * FROM EducationInfos WHERE UserId = @UserId;
END
')
END

-- ✅ Procedure: sp_Instructor_AddEducation
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_AddEducation]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_AddEducation]
  @UserId INT,
  @Degree NVARCHAR(100),
  @Institute NVARCHAR(255),
  @Year NVARCHAR(50),
  @Grade NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO EducationInfos (UserId, Degree, Institute, Year, Grade)
  VALUES (@UserId, @Degree, @Institute, @Year, @Grade);

  SELECT * FROM EducationInfos WHERE Id = SCOPE_IDENTITY();
END
')
END

-- ✅ Procedure: sp_Instructor_UpdateEducation
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_UpdateEducation]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_UpdateEducation]
  @Id INT,
  @UserId INT,
  @Degree NVARCHAR(100),
  @Institute NVARCHAR(255),
  @Year NVARCHAR(50),
  @Grade NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM EducationInfos WHERE Id = @Id AND UserId = @UserId)
  BEGIN
    RAISERROR(''Education record not found.'', 16, 1);
    RETURN;
  END

  UPDATE EducationInfos
  SET Degree = @Degree, Institute = @Institute, Year = @Year, Grade = @Grade
  WHERE Id = @Id;

  SELECT * FROM EducationInfos WHERE Id = @Id;
END
')
END

-- ✅ Procedure: sp_Instructor_DeleteEducation
IF NOT EXISTS (
  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instructor_DeleteEducation]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Instructor_DeleteEducation]
  @Id INT,
  @UserId INT
AS
BEGIN
  SET NOCOUNT ON;

  DELETE FROM EducationInfos WHERE Id = @Id AND UserId = @UserId;
END
')
END

