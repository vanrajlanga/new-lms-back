-- File: LiveClassController_Procedures.sql

-- ✅ sp_LiveClass_GetAll
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_GetAll]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_GetAll]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT l.LiveClassId, l.ClassName, u.Username AS InstructorName, c.Name AS CourseName,
           l.Semester, l.Programme, l.StartTime, l.EndTime, l.DurationMinutes,
           l.MeetingLink, l.Status, l.CreatedAt, l.UpdatedAt
    FROM LiveClasses l
    JOIN Users u ON l.InstructorId = u.UserId
    JOIN Courses c ON l.CourseId = c.CourseId
    ORDER BY l.StartTime DESC;
END
')
END

-- ✅ sp_LiveClass_GetById
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_GetById]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_GetById]
  @LiveClassId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM LiveClasses WHERE LiveClassId = @LiveClassId;
END
')
END

-- ✅ sp_LiveClass_Create
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_Create]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_Create]
  @ClassName NVARCHAR(255),
  @InstructorId INT,
  @CourseId INT,
  @Semester NVARCHAR(50),
  @Programme NVARCHAR(50),
  @StartTime DATETIME,
  @EndTime DATETIME,
  @DurationMinutes INT,
  @MeetingLink NVARCHAR(MAX),
  @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO LiveClasses (ClassName, InstructorId, CourseId, Semester, Programme,
        StartTime, EndTime, DurationMinutes, MeetingLink, Status, CreatedAt)
    VALUES (@ClassName, @InstructorId, @CourseId, @Semester, @Programme,
        @StartTime, @EndTime, @DurationMinutes, @MeetingLink, @Status, GETUTCDATE());

    SELECT * FROM LiveClasses WHERE LiveClassId = SCOPE_IDENTITY();
END
')
END

-- ✅ sp_LiveClass_GetByInstructor
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_GetByInstructor]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_GetByInstructor]
  @InstructorId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM LiveClasses
    WHERE InstructorId = @InstructorId
    ORDER BY StartTime DESC;
END
')
END

-- ✅ sp_LiveClass_GetByStudent
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_GetByStudent]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_GetByStudent]
  @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM LiveClasses
    WHERE CourseId IN (SELECT CourseId FROM StudentCourses WHERE UserId = @StudentId)
    ORDER BY StartTime;
END
')
END

-- ✅ sp_LiveClass_Update
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_Update]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_Update]
  @LiveClassId INT,
  @ClassName NVARCHAR(255),
  @InstructorId INT,
  @CourseId INT,
  @Semester NVARCHAR(50),
  @Programme NVARCHAR(50),
  @StartTime DATETIME,
  @EndTime DATETIME,
  @DurationMinutes INT,
  @MeetingLink NVARCHAR(MAX),
  @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE LiveClasses SET
        ClassName = @ClassName,
        InstructorId = @InstructorId,
        CourseId = @CourseId,
        Semester = @Semester,
        Programme = @Programme,
        StartTime = @StartTime,
        EndTime = @EndTime,
        DurationMinutes = @DurationMinutes,
        MeetingLink = @MeetingLink,
        Status = @Status,
        UpdatedAt = GETUTCDATE()
    WHERE LiveClassId = @LiveClassId;

    SELECT * FROM LiveClasses WHERE LiveClassId = @LiveClassId;
END
')
END

-- ✅ sp_LiveClass_Delete
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_Delete]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_Delete]
  @LiveClassId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM LiveClasses WHERE LiveClassId = @LiveClassId;
END
')
END

-- ✅ sp_LiveClass_GetUpcomingByCourse
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LiveClass_GetUpcomingByCourse]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_LiveClass_GetUpcomingByCourse]
  @CourseId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETUTCDATE();
    DECLARE @NextWeek DATETIME = DATEADD(DAY, 7, @Now);

    SELECT TOP 1 * FROM LiveClasses
    WHERE CourseId = @CourseId AND StartTime >= @Now AND StartTime <= @NextWeek
    ORDER BY StartTime;
END
')
END
