-- ✅ GetAllStudents
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_GetAllStudents]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_GetAllStudents]
    AS
    BEGIN
        SELECT s.Id AS StudentId, s.UserId, s.FirstName, s.LastName, s.Email, s.PhoneNumber,
               s.DateOfBirth, s.Gender, s.Address, s.City, s.State, s.Country, s.ZipCode,
               s.ProfilePhotoUrl, s.CourseId, c.Name AS CourseName, s.Semester, s.Programme,
               s.IsActive, s.CreatedAt
        FROM Students s
        LEFT JOIN Courses c ON s.CourseId = c.CourseId;
    END
    ')
END

-- ✅ GetStudentDetails
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_GetStudentDetails]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_GetStudentDetails]
        @UserId INT
    AS
    BEGIN
        SELECT TOP 1 u.UserId, u.Username, u.Email, u.Status, u.FirstName, u.LastName,
                     u.PhoneNumber, u.Gender, u.DateOfBirth, u.ProfilePhotoUrl,
                     u.Address, u.City, u.State, u.Country, u.ZipCode, u.Programme
        FROM Users u
        WHERE u.UserId = @UserId;

        SELECT DISTINCT c.Semester
        FROM StudentCourses sc
        INNER JOIN Courses c ON sc.CourseId = c.CourseId
        WHERE sc.UserId = @UserId;

        SELECT DISTINCT c.Name AS Course
        FROM StudentCourses sc
        INNER JOIN Courses c ON sc.CourseId = c.CourseId
        WHERE sc.UserId = @UserId;

        SELECT a.AssignmentId, a.Title, s.Status, s.SubmissionDate
        FROM AssignmentSubmissions s
        JOIN Assignments a ON s.AssignmentId = a.AssignmentId
        WHERE s.StudentId = @UserId;

        SELECT c.Name AS Subject, sr.ReportDate AS ExamDate,
               sr.TotalMarks, 0 AS ObtainedMarks
        FROM ScoreReports sr
        JOIN Courses c ON sr.CourseId = c.CourseId
        WHERE sr.StudentId = @UserId;

        SELECT TOP 1 FORMAT(c.CreatedDate, ''MMM-yyyy'') AS Intake
        FROM StudentCourses sc
        JOIN Courses c ON sc.CourseId = c.CourseId
        WHERE sc.UserId = @UserId
        ORDER BY c.CreatedDate ASC;
    END
    ')
END

-- ✅ GetProfessionalInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_GetProfessionalInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_GetProfessionalInfo]
        @UserId INT
    AS
    BEGIN
        SELECT Id, Title, Company, Location, Experience
        FROM ProfessionalInfos
        WHERE UserId = @UserId;
    END
    ')
END

-- ✅ AddProfessionalInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_AddProfessionalInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_AddProfessionalInfo]
        @UserId INT,
        @Title NVARCHAR(255),
        @Company NVARCHAR(255),
        @Location NVARCHAR(255),
        @Experience NVARCHAR(MAX)
    AS
    BEGIN
        INSERT INTO ProfessionalInfos (UserId, Title, Company, Location, Experience)
        VALUES (@UserId, @Title, @Company, @Location, @Experience);

        SELECT * FROM ProfessionalInfos WHERE Id = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ UpdateProfessionalInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_UpdateProfessionalInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_UpdateProfessionalInfo]
        @Id INT,
        @UserId INT,
        @Title NVARCHAR(255),
        @Company NVARCHAR(255),
        @Location NVARCHAR(255),
        @Experience NVARCHAR(MAX)
    AS
    BEGIN
        UPDATE ProfessionalInfos
        SET Title = @Title,
            Company = @Company,
            Location = @Location,
            Experience = @Experience
        WHERE Id = @Id AND UserId = @UserId;

        SELECT * FROM ProfessionalInfos WHERE Id = @Id;
    END
    ')
END

-- ✅ DeleteProfessionalInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_DeleteProfessionalInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_DeleteProfessionalInfo]
        @Id INT,
        @UserId INT
    AS
    BEGIN
        DELETE FROM ProfessionalInfos WHERE Id = @Id AND UserId = @UserId;
    END
    ')
END

-- ✅ GetEducationInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_GetEducationInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_GetEducationInfo]
        @UserId INT
    AS
    BEGIN
        SELECT Id, Degree, Institute, Year, Grade
        FROM EducationInfos
        WHERE UserId = @UserId;
    END
    ')
END

-- ✅ AddEducationInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_AddEducationInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_AddEducationInfo]
        @UserId INT,
        @Degree NVARCHAR(255),
        @Institute NVARCHAR(255),
        @Year NVARCHAR(50),
        @Grade NVARCHAR(50)
    AS
    BEGIN
        INSERT INTO EducationInfos (UserId, Degree, Institute, Year, Grade)
        VALUES (@UserId, @Degree, @Institute, @Year, @Grade);

        SELECT * FROM EducationInfos WHERE Id = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ UpdateEducationInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_UpdateEducationInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_UpdateEducationInfo]
        @Id INT,
        @UserId INT,
        @Degree NVARCHAR(255),
        @Institute NVARCHAR(255),
        @Year NVARCHAR(50),
        @Grade NVARCHAR(50)
    AS
    BEGIN
        UPDATE EducationInfos
        SET Degree = @Degree,
            Institute = @Institute,
            Year = @Year,
            Grade = @Grade
        WHERE Id = @Id AND UserId = @UserId;

        SELECT * FROM EducationInfos WHERE Id = @Id;
    END
    ')
END

IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_DeleteStudentCascade]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_DeleteStudentCascade]
        @StudentId INT
    AS
    BEGIN
        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM Students WHERE Id = @StudentId;

        IF @UserId IS NOT NULL
        BEGIN
            DELETE FROM Notifications WHERE UserId = @UserId;
            DELETE FROM Attendances WHERE StudentId = @UserId;
            DELETE FROM AssignmentSubmissions WHERE StudentId = @UserId;
            DELETE FROM ScoreReports WHERE StudentId = @UserId;
            DELETE FROM StudentProgresses WHERE StudentId = @UserId;
            DELETE FROM LiveClassAttendances WHERE StudentId = @UserId;
            DELETE FROM StudentCourses WHERE UserId = @UserId;
            DELETE FROM RoleAssignments WHERE UserId = @UserId;
            DELETE FROM ProfessionalInfos WHERE UserId = @UserId;
            DELETE FROM EducationInfos WHERE UserId = @UserId;

            DELETE FROM Users WHERE UserId = @UserId;
        END

        DELETE FROM Students WHERE Id = @StudentId;
    END
    ')
END

-- ✅ DeleteEducationInfo
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Students_DeleteEducationInfo]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Students_DeleteEducationInfo]
        @Id INT,
        @UserId INT
    AS
    BEGIN
        DELETE FROM EducationInfos WHERE Id = @Id AND UserId = @UserId;
    END
    ')
END