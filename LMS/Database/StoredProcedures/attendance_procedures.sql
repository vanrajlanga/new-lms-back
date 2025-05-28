
-- ===========================================
-- LMS: Stored Procedures for AttendanceController
-- ===========================================
-- Aligned with models:
-- - Attendance (table: Attendances)
-- - User       (table: Users)
-- - Course     (table: Courses)
-- - LiveClass  (table: LiveClasses)
-- All fields and datatypes strictly matched.
-- ===========================================


-- 1. Mark a single attendance entry (raw insert)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_Mark]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_Mark
        @StudentId INT,
        @CourseId INT,
        @Date DATE,
        @Status NVARCHAR(50),
        @LiveClassId INT = NULL
    AS
    BEGIN
        INSERT INTO Attendances (StudentId, CourseId, Date, Status, LiveClassId)
        VALUES (@StudentId, @CourseId, @Date, @Status, @LiveClassId);
    END
    ')
END


-- 2. Mark or update a batch record
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_MarkBatch]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_MarkBatch
        @StudentId INT,
        @CourseId INT,
        @Date DATE,
        @Status NVARCHAR(50),
        @LiveClassId INT = NULL
    AS
    BEGIN
        IF EXISTS (
            SELECT 1 FROM Attendances
            WHERE StudentId = @StudentId AND CourseId = @CourseId AND
                  ((LiveClassId IS NULL AND @LiveClassId IS NULL) OR LiveClassId = @LiveClassId)
        )
        BEGIN
            UPDATE Attendances
            SET Date = @Date,
                Status = @Status
            WHERE StudentId = @StudentId AND CourseId = @CourseId AND
                  ((LiveClassId IS NULL AND @LiveClassId IS NULL) OR LiveClassId = @LiveClassId);
        END
        ELSE
        BEGIN
            INSERT INTO Attendances (StudentId, CourseId, Date, Status, LiveClassId)
            VALUES (@StudentId, @CourseId, @Date, @Status, @LiveClassId);
        END
    END
    ')
END


-- 3. Get all attendance records for a course
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_GetByCourse]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_GetByCourse
        @CourseId INT
    AS
    BEGIN
        SELECT a.AttendanceId, a.StudentId, a.CourseId, a.Date, a.Status, a.LiveClassId, u.Username
        FROM Attendances a
        JOIN Users u ON u.UserId = a.StudentId
        WHERE a.CourseId = @CourseId
        ORDER BY a.Date;
    END
    ')
END


-- 4. Get all attendance records for a student with course & live class info
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_GetByStudent]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_GetByStudent
        @StudentId INT
    AS
    BEGIN
        SELECT 
            a.AttendanceId,
            a.Date,
            c.Name AS CourseName,
            lc.ClassName AS LiveClassName,
            a.Status
        FROM Attendances a
        LEFT JOIN Courses c ON c.CourseId = a.CourseId
        LEFT JOIN LiveClasses lc ON lc.LiveClassId = a.LiveClassId
        WHERE a.StudentId = @StudentId;
    END
    ')
END


-- 5. Get all attendance records for a live class
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_GetByLiveClass]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_GetByLiveClass
        @LiveClassId INT
    AS
    BEGIN
        SELECT 
            a.AttendanceId,
            a.StudentId,
            a.CourseId,
            a.Date,
            a.Status,
            a.LiveClassId,
            u.Username AS StudentName,
            c.Name AS CourseName
        FROM Attendances a
        JOIN Users u ON u.UserId = a.StudentId
        JOIN Courses c ON c.CourseId = a.CourseId
        WHERE a.LiveClassId = @LiveClassId
        ORDER BY u.Username;
    END
    ')
END


-- 6. Update attendance record by ID
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_Update]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_Update
        @AttendanceId INT,
        @Date DATE,
        @Status NVARCHAR(50),
        @LiveClassId INT = NULL
    AS
    BEGIN
        UPDATE Attendances
        SET Date = @Date,
            Status = @Status,
            LiveClassId = @LiveClassId
        WHERE AttendanceId = @AttendanceId;
    END
    ')
END


-- 7. Delete attendance record by ID
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Attendance_Delete]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Attendance_Delete
        @AttendanceId INT
    AS
    BEGIN
        DELETE FROM Attendances WHERE AttendanceId = @AttendanceId;
    END
    ')
END
