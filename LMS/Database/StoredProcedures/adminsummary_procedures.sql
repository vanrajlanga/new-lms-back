IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_AdminSummary_GetDashboard]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_AdminSummary_GetDashboard]
    AS
    BEGIN
        SELECT 
            (SELECT COUNT(*) FROM Students) AS StudentCount,
            (SELECT COUNT(*) FROM Professors) AS ProfessorCount,
            (SELECT COUNT(*) FROM Programmes) AS ProgrammeCount,
            (SELECT COUNT(*) FROM Books) AS BookCount,
            (SELECT COUNT(*) FROM Examinations) AS ExamCount,
            (SELECT COUNT(*) FROM LiveClasses) AS LiveClassCount,
            (SELECT COUNT(*) FROM TaskItems) AS TaskCount,
            (SELECT COUNT(*) FROM LeaveRequests) AS LeaveCount
    END
    ')
END
