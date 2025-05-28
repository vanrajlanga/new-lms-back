-- File: MeetingController_Procedures.sql

-- ✅ sp_Meeting_GetAll
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Meeting_GetAll]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Meeting_GetAll]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Meetings ORDER BY ScheduledAt DESC;
END
')
END

-- ✅ sp_Meeting_GetById
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Meeting_GetById]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Meeting_GetById]
    @MeetingId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Meetings WHERE MeetingId = @MeetingId;
END
')
END

-- ✅ sp_Meeting_Create
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Meeting_Create]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Meeting_Create]
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @ScheduledAt DATETIME,
    @MeetingType NVARCHAR(50),
    @MeetingLink NVARCHAR(500),
    @MeetingLocation NVARCHAR(255),
    @TargetProgramme NVARCHAR(50),
    @TargetSemester NVARCHAR(50),
    @TargetCourse NVARCHAR(100),
    @CreatedAt DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Meetings (Title, Description, ScheduledAt, MeetingType, MeetingLink, MeetingLocation, TargetProgramme, TargetSemester, TargetCourse, CreatedAt)
    VALUES (@Title, @Description, @ScheduledAt, @MeetingType, @MeetingLink, @MeetingLocation, @TargetProgramme, @TargetSemester, @TargetCourse, @CreatedAt);

    SELECT * FROM Meetings WHERE MeetingId = SCOPE_IDENTITY();
END
')
END

-- ✅ sp_Meeting_Update
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Meeting_Update]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Meeting_Update]
    @MeetingId INT,
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @ScheduledAt DATETIME,
    @MeetingType NVARCHAR(50),
    @MeetingLink NVARCHAR(500),
    @MeetingLocation NVARCHAR(255),
    @TargetProgramme NVARCHAR(50),
    @TargetSemester NVARCHAR(50),
    @TargetCourse NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Meetings
    SET Title = @Title,
        Description = @Description,
        ScheduledAt = @ScheduledAt,
        MeetingType = @MeetingType,
        MeetingLink = @MeetingLink,
        MeetingLocation = @MeetingLocation,
        TargetProgramme = @TargetProgramme,
        TargetSemester = @TargetSemester,
        TargetCourse = @TargetCourse
    WHERE MeetingId = @MeetingId;

    SELECT * FROM Meetings WHERE MeetingId = @MeetingId;
END
')
END

-- ✅ sp_Meeting_Delete
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Meeting_Delete]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Meeting_Delete]
    @MeetingId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Meetings WHERE MeetingId = @MeetingId;
END
')
END

-- ✅ sp_Meeting_GetRelevant

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Meeting_GetRelevant]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
ALTER PROCEDURE [dbo].[sp_Meeting_GetRelevant]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Department NVARCHAR(100);
    DECLARE @Courses TABLE (CourseName NVARCHAR(100));

    SELECT @Department = Department FROM Professors WHERE UserId = @UserId;

    INSERT INTO @Courses (CourseName)
    SELECT c.Name FROM InstructorCourses ic
    JOIN Courses c ON ic.CourseId = c.CourseId
    WHERE ic.InstructorId = @UserId;

    SELECT * FROM Meetings
    WHERE
        (TargetProgramme IS NULL AND TargetCourse IS NULL)
        OR (TargetProgramme = @Department AND TargetCourse IS NULL)
        OR (TargetProgramme = @Department AND TargetCourse IN (SELECT CourseName FROM @Courses))
    ORDER BY ScheduledAt;
END
')
END
