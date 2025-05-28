-- StudentCoursesController_Procedures.sql

-- ✅ sp_StudentCourses_AssignCourses
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_StudentCourses_AssignCourses]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_StudentCourses_AssignCourses]
        @UserId INT,
        @CourseIdList NVARCHAR(MAX)
    AS
    BEGIN
        DELETE FROM StudentCourses WHERE UserId = @UserId;

        DECLARE @CourseIds TABLE (CourseId INT);
        INSERT INTO @CourseIds (CourseId)
        SELECT CAST(value AS INT)
        FROM STRING_SPLIT(@CourseIdList, '','');

        INSERT INTO StudentCourses (UserId, CourseId)
        SELECT @UserId, CourseId FROM @CourseIds;
    END
    ')
END
