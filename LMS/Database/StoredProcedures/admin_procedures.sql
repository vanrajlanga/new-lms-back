-- ✅ Create sp_Admin_GetAllStudents if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Admin_GetAllStudents]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Admin_GetAllStudents]
    AS
    BEGIN
        SELECT UserId, Username, Email , FirstName , LastName
        FROM Users
        WHERE Role = ''Student'';
    END
    ')
END

-- ✅ Create sp_Admin_GetStudentOverview if not exists
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Admin_GetStudentOverview]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Admin_GetStudentOverview]
        @UserId INT
    AS
    BEGIN
        SELECT TOP 1 u.UserId, u.Username AS Name, u.Email
        INTO #BasicInfo
        FROM Users u
        WHERE u.UserId = @UserId AND u.Role = ''Student'';

        SELECT a.Title AS AssignmentTitle, s.Grade, a.MaxGrade,
               CASE WHEN s.SubmittedAt > a.DueDate THEN 1 ELSE 0 END AS IsLate
        INTO #Grades
        FROM AssignmentSubmissions s
        JOIN Assignments a ON s.AssignmentId = a.AssignmentId
        WHERE s.StudentId = @UserId;

        SELECT a.Title AS AssignmentTitle, s.SubmittedAt,
               CASE WHEN s.SubmittedAt IS NOT NULL THEN 1 ELSE 0 END AS IsSubmitted
        INTO #Submissions
        FROM AssignmentSubmissions s
        JOIN Assignments a ON s.AssignmentId = a.AssignmentId
        WHERE s.StudentId = @UserId;

        SELECT e.PaperName, e.PaperCode, c.Name AS Course,
               m.InternalMarks, m.TheoryMarks, m.TotalMarks
        INTO #Marks
        FROM StudentMarks m
        JOIN Examinations e ON m.ExaminationId = e.ExaminationId
        JOIN Courses c ON e.CourseId = c.CourseId
        WHERE m.StudentId = @UserId;

        DECLARE @Total INT = (SELECT COUNT(*) FROM Attendances WHERE StudentId = @UserId);
        DECLARE @Present INT = (SELECT COUNT(*) FROM Attendances WHERE StudentId = @UserId AND Status = ''Present'');
        DECLARE @AttendancePercentage FLOAT = CASE WHEN @Total > 0 THEN CAST(@Present AS FLOAT) / @Total * 100 ELSE 0 END;

        SELECT TOP 1 c.Programme, c.Semester
        INTO #CourseInfo
        FROM CourseUsers cu
        JOIN Courses c ON cu.CourseId = c.CourseId
        WHERE cu.UserId = @UserId;

        SELECT * FROM #BasicInfo;
        SELECT * FROM #Grades;
        SELECT * FROM #Submissions;
        SELECT * FROM #Marks;
        SELECT * FROM #CourseInfo;
        SELECT @AttendancePercentage AS AttendancePercentage;

        DROP TABLE #BasicInfo, #Grades, #Submissions, #Marks, #CourseInfo;
    END
    ')
END
