-- SearchController_Procedures.sql

-- ✅ sp_Search_SearchUsers
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Search_SearchUsers]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Search_SearchUsers]
        @Query NVARCHAR(100)
    AS
    BEGIN
        SELECT * FROM Users
        WHERE Username LIKE ''%'' + @Query + ''%''
           OR Email LIKE ''%'' + @Query + ''%''
           OR Role LIKE ''%'' + @Query + ''%'';
    END
    ')
END

-- ✅ sp_Search_SearchCourses
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Search_SearchCourses]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Search_SearchCourses]
        @Query NVARCHAR(100)
    AS
    BEGIN
        SELECT * FROM Courses
        WHERE Name LIKE ''%'' + @Query + ''%''
           OR CourseCode LIKE ''%'' + @Query + ''%''
           OR CourseDescription LIKE ''%'' + @Query + ''%'';
    END
    ')
END
