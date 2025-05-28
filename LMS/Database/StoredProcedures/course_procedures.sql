
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_GetByProgrammeAndSemester]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_GetByProgrammeAndSemester
    @Programme NVARCHAR(100),
    @Semester NVARCHAR(50)
AS
BEGIN
    SELECT CourseId, Name, CourseCode, Credits, CourseDescription, Semester AS SemesterName, Programme
    FROM Courses
    WHERE Programme = @Programme AND Semester = @Semester;
END
')
END

-- ✅ Procedure: sp_Course_GetByInstructor
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_GetByInstructor]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_GetByInstructor
    @InstructorId INT
AS
BEGIN
    SELECT c.*
    FROM InstructorCourses ic
    INNER JOIN Courses c ON ic.CourseId = c.CourseId
    WHERE ic.InstructorId = @InstructorId;
END
')
END

-- ✅ Procedure: sp_Course_Create
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_Create]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_Create
    @Name NVARCHAR(255),
    @CourseCode NVARCHAR(100),
    @Credits INT,
    @CourseDescription NVARCHAR(MAX),
    @Programme NVARCHAR(100),
    @Semester NVARCHAR(50),
    @CreatedDate DATETIME,
    @UpdatedDate DATETIME
AS
BEGIN
    INSERT INTO Courses (Name, CourseCode, Credits, CourseDescription, Programme, Semester, CreatedDate, UpdatedDate)
    VALUES (@Name, @CourseCode, @Credits, @CourseDescription, @Programme, @Semester, @CreatedDate, @UpdatedDate);

    SELECT SCOPE_IDENTITY() AS CourseId;
END
')
END

-- ✅ Procedure: sp_Course_GetById
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_GetById]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_GetById
    @CourseId INT
AS
BEGIN
    SELECT * FROM Courses WHERE CourseId = @CourseId;
END
')
END

-- ✅ Procedure: sp_Course_GetAll
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_GetAll]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_GetAll
AS
BEGIN
    SELECT CourseId, Name, CourseCode, Credits, CourseDescription, Semester AS SemesterName, Programme
    FROM Courses;
END
')
END

-- ✅ Procedure: sp_Course_Update
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_Update]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_Update
    @CourseId INT,
    @Name NVARCHAR(255),
    @CourseCode NVARCHAR(100),
    @Credits INT,
    @CourseDescription NVARCHAR(MAX),
    @Programme NVARCHAR(100),
    @Semester NVARCHAR(50),
    @UpdatedDate DATETIME
AS
BEGIN
    UPDATE Courses
    SET Name = @Name,
        CourseCode = @CourseCode,
        Credits = @Credits,
        CourseDescription = @CourseDescription,
        Programme = @Programme,
        Semester = @Semester,
        UpdatedDate = @UpdatedDate
    WHERE CourseId = @CourseId;
END
')
END

-- ✅ Procedure: sp_Course_Delete
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_Delete]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_Delete
    @CourseId INT
AS
BEGIN
    DELETE FROM Courses WHERE CourseId = @CourseId;
END
')
END

-- ✅ Procedure: sp_Course_GetEnrolledStudents
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_GetEnrolledStudents]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_GetEnrolledStudents
    @CourseId INT
AS
BEGIN
    SELECT u.UserId AS StudentId, u.Username AS Name, u.Email, sc.CourseId, ''Present'' AS Status
    FROM StudentCourses sc
    INNER JOIN Users u ON sc.UserId = u.UserId
    WHERE sc.CourseId = @CourseId AND u.Role = ''Student'';
END
')
END

-- ✅ Procedure: sp_Course_GetByStudent
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Course_GetByStudent]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Course_GetByStudent
    @UserId INT
AS
BEGIN
    DECLARE @Programme NVARCHAR(100), @Semester NVARCHAR(50);

    SELECT TOP 1 @Programme = c.Programme, @Semester = c.Semester
    FROM StudentCourses sc
    INNER JOIN Courses c ON sc.CourseId = c.CourseId
    WHERE sc.UserId = @UserId;

    SELECT DISTINCT c.CourseId, c.Name, c.CourseCode, c.Credits, c.CourseDescription, c.Programme, c.Semester
    FROM StudentCourses sc
    INNER JOIN Courses c ON sc.CourseId = c.CourseId
    WHERE sc.UserId = @UserId AND c.Programme = @Programme AND c.Semester = @Semester;
END
')
END

-- ✅ Procedure: sp_Department_GetWithCourses
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Department_GetWithCourses]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE sp_Department_GetWithCourses
AS
BEGIN
    SELECT d.*, c.CourseId, c.Name AS CourseName, c.CourseCode, c.Credits, c.CourseDescription, c.Programme, c.Semester
    FROM Departments d
    LEFT JOIN Courses c ON d.Name = c.Programme
    ORDER BY d.Name, c.Semester;
END
')
END
