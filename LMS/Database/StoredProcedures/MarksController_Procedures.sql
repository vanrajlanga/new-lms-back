-- File: MarksController_Procedures.sql

-- ✅ sp_Marks_GetAllWithDetails
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Marks_GetAllWithDetails]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Marks_GetAllWithDetails]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Username AS StudentName, u.Email AS StudentEmail,
           e.PaperCode, e.PaperName, e.PaperType,
           c.Name AS Course, g.GroupCode AS [Group],
           e.Semester,
           m.InternalMarks, m.TheoryMarks, m.TotalMarks
    FROM StudentMarks m
    JOIN Users u ON m.StudentId = u.UserId
    JOIN Examinations e ON m.ExaminationId = e.ExaminationId
    JOIN Courses c ON e.CourseId = c.CourseId
    JOIN Groups g ON e.GroupId = g.GroupId;
END
')
END

-- ✅ sp_Marks_EnterMarks
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Marks_EnterMarks]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Marks_EnterMarks]
  @ExaminationId INT,
  @StudentId INT,
  @InternalMarks INT,
  @TheoryMarks INT,
  @TotalMarks INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM StudentMarks WHERE ExaminationId = @ExaminationId AND StudentId = @StudentId)
    BEGIN
        UPDATE StudentMarks
        SET InternalMarks = @InternalMarks,
            TheoryMarks = @TheoryMarks,
            TotalMarks = @TotalMarks,
            UpdatedDate = GETUTCDATE()
        WHERE ExaminationId = @ExaminationId AND StudentId = @StudentId;
    END
    ELSE
    BEGIN
        INSERT INTO StudentMarks (ExaminationId, StudentId, InternalMarks, TheoryMarks, TotalMarks, CreatedDate, UpdatedDate)
        VALUES (@ExaminationId, @StudentId, @InternalMarks, @TheoryMarks, @TotalMarks, GETUTCDATE(), GETUTCDATE());
    END
END
')
END

-- ✅ sp_Marks_GetMarksForStudent
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Marks_GetMarksForStudent]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Marks_GetMarksForStudent]
  @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.ExaminationId, e.PaperName, e.PaperCode,
           c.Name AS Course,
           m.InternalMarks, m.TheoryMarks, m.TotalMarks
    FROM StudentMarks m
    JOIN Examinations e ON m.ExaminationId = e.ExaminationId
    JOIN Courses c ON e.CourseId = c.CourseId
    WHERE m.StudentId = @StudentId;
END
')
END
