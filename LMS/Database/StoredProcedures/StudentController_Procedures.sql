-- File: StudentController_Procedures.sql
IF EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Student_GetStudents]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    DROP PROCEDURE [dbo].[sp_Student_GetStudents];
    ');
END;

EXEC('
CREATE PROCEDURE [dbo].[sp_Student_GetStudents]
AS
BEGIN
    SELECT 
        u.UserId,
        u.Username,
        u.FirstName,
        u.LastName,
        u.Email,
        u.PhoneNumber,
        u.ProfilePhotoUrl,
        u.Status,
        u.Role,
        c.CourseId,
        c.Name AS CourseName,
        c.Programme,
        c.Semester
    FROM Users u
    LEFT JOIN Courses c 
        ON u.Programme = c.Programme 
       AND TRY_CAST(REPLACE(u.Semester, ''Semester '', '''') AS INT) = c.Semester
    WHERE u.Role = ''Student''
END
');



-- ✅ sp_Student_DeleteStudent
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Student_DeleteStudent]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Student_DeleteStudent]
    @UserId INT
AS
BEGIN
    DELETE FROM StudentCourses WHERE UserId = @UserId;
    DELETE FROM Fees WHERE StudentId = @UserId;
    DELETE FROM Users WHERE UserId = @UserId AND Role = ''Student'';
END
')
END

-- ✅ sp_Student_GetStudentDetails
-- ✅ sp_Student_GetStudentDetails
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Student_GetStudentDetails]') 
      AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Student_GetStudentDetails]
    @UserId INT
AS
BEGIN
    SELECT TOP 1
        u.UserId,
        u.Username,
        u.FirstName,
        u.LastName,
        u.Email,
        u.PhoneNumber,
        u.DateOfBirth,
        u.Gender,
        u.Address,
        u.City,
        u.State,
        u.Country,
        u.ZipCode,
        u.ProfilePhotoUrl,
        u.Programme,
        u.Semester,
        ISNULL(sc.CourseId, 0) AS CourseId
    FROM Users u
    LEFT JOIN StudentCourses sc ON u.UserId = sc.UserId
    WHERE u.UserId = @UserId AND u.Role = ''Student'';
END
')
END

-- ✅ sp_Student_GetStudentProfile
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Student_GetStudentProfile]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Student_GetStudentProfile]
    @UserId INT
AS
BEGIN
    SELECT TOP 1
        u.UserId,
        u.Username,
        u.FirstName,
        u.LastName,
        u.Email,
        u.PhoneNumber,
        u.DateOfBirth,
        u.Gender,
        u.Address,
        u.City,
        u.State,
        u.Country,
        u.ZipCode,
        u.ProfilePhotoUrl,
        ISNULL(c.Programme, u.Programme) AS Programme,
        ISNULL(c.Semester, ''NA'') AS Semester,
        ISNULL(sc.CourseId, 0) AS CourseId
    FROM Users u
    LEFT JOIN StudentCourses sc ON u.UserId = sc.UserId
    LEFT JOIN Courses c ON sc.CourseId = c.CourseId
    WHERE u.UserId = @UserId AND u.Role = ''Student'';
END
')
END
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Student_Register]') 
    AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Student_Register]
        @Email NVARCHAR(255),
        @PasswordHash NVARCHAR(255),
        @FirstName NVARCHAR(255),
        @LastName NVARCHAR(255),
        @PhoneNumber NVARCHAR(255),
        @Gender NVARCHAR(50),
        @DateOfBirth DATETIME,
        @ProfilePhotoUrl NVARCHAR(500),
        @Address NVARCHAR(255),
        @City NVARCHAR(255),
        @State NVARCHAR(255),
        @Country NVARCHAR(255),
        @ZipCode NVARCHAR(50),
        @Programme NVARCHAR(255),
        @Semester NVARCHAR(50),
        @Username NVARCHAR(7) OUTPUT
    )
    AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
            DECLARE @UserId INT;
            DECLARE @NextId INT;
            SET @NextId = IDENT_CURRENT(''Users'') + IDENT_INCR(''Users'');

            SET @Username = RIGHT(''0000000'' + CAST(@NextId AS VARCHAR), 7);

            INSERT INTO Users (
                Username, PasswordHash, Email, Role, Status,
                FirstName, LastName, PhoneNumber, Gender, DateOfBirth,
                ProfilePhotoUrl, Address, City, State, Country, ZipCode,
                Programme, Semester
            )
            VALUES (
                @Username, @PasswordHash, @Email, ''Student'', ''Active'',
                @FirstName, @LastName, @PhoneNumber, @Gender, @DateOfBirth,
                @ProfilePhotoUrl, @Address, @City, @State, @Country, @ZipCode,
                @Programme, @Semester
            );

            SET @UserId = SCOPE_IDENTITY();

            INSERT INTO StudentCourses (UserId, CourseId, CompletionStatus, Grade, DateAssigned)
            SELECT @UserId, CourseId, ''NotStarted'', ''N/A'', GETUTCDATE()
            FROM Courses
            WHERE LOWER(RTRIM(LTRIM(Programme))) = LOWER(RTRIM(LTRIM(@Programme)))
              AND PATINDEX(''%[0-9]%'', Semester) = PATINDEX(''%[0-9]%'', @Semester);

            -- ✅ FEE LOGIC
            IF NOT EXISTS (
                SELECT 1 FROM Fees WHERE StudentId = @UserId AND Semester = @Semester
            )
            BEGIN
                DECLARE @AmountDue DECIMAL(10, 2);

                SELECT @AmountDue = AmountDue
                FROM SemesterFeeTemplate
                WHERE Programme = @Programme AND Semester = @Semester;

                IF @AmountDue IS NOT NULL
                BEGIN
                    INSERT INTO Fees (
                        StudentId, Semester, Programme, AmountDue, AmountPaid, FeeStatus,
                        DueDate, CreatedAt, PaymentMethod, TransactionId
                    )
                    VALUES (
                        @UserId, @Semester, @Programme, @AmountDue, 0, ''Pending'',
                        DATEADD(MONTH, 1, GETUTCDATE()), GETUTCDATE(), ''NA'', NEWID()
                    );
                END
            END

            SELECT @UserId AS UserId, @Username AS Username, ''Student registered successfully'' AS Message;
        END TRY
        BEGIN CATCH
            DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg, 16, 1);
        END CATCH
    END
    ')
END



-- ✅ sp_Student_UpdateStudent-- ✅ sp_Student_UpdateStudent
-- ✅ sp_Student_UpdateStudent
IF EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[dbo].[sp_Student_UpdateStudent]') 
      AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Student_UpdateStudent];

EXEC('
CREATE PROCEDURE [dbo].[sp_Student_UpdateStudent]
    @UserId INT,
    @Email NVARCHAR(255),
    @FirstName NVARCHAR(255),
    @LastName NVARCHAR(255),
    @PhoneNumber NVARCHAR(255),
    @DateOfBirth DATETIME,
    @Gender NVARCHAR(50),
    @Address NVARCHAR(255),
    @City NVARCHAR(255),
    @State NVARCHAR(255),
    @Country NVARCHAR(255),
    @ZipCode NVARCHAR(50),
    @ProfilePhotoUrl NVARCHAR(500),
    @Programme NVARCHAR(255),
    @Semester NVARCHAR(50)
AS
BEGIN
    UPDATE Users
    SET Email = @Email,
        FirstName = @FirstName,
        LastName = @LastName,
        PhoneNumber = @PhoneNumber,
        DateOfBirth = @DateOfBirth,
        Gender = @Gender,
        Address = @Address,
        City = @City,
        State = @State,
        Country = @Country,
        ZipCode = @ZipCode,
        ProfilePhotoUrl = @ProfilePhotoUrl,
        Programme = @Programme,
        Semester = @Semester
    WHERE UserId = @UserId AND Role = ''Student'';

    DELETE FROM StudentCourses WHERE UserId = @UserId;

    INSERT INTO StudentCourses (UserId, CourseId, CompletionStatus, Grade, DateAssigned)
    SELECT @UserId, CourseId, ''NotStarted'', ''N/A'', GETUTCDATE()
    FROM Courses
    WHERE LOWER(RTRIM(LTRIM(Programme))) = LOWER(RTRIM(LTRIM(@Programme)))
      AND CAST(Semester AS NVARCHAR) = REPLACE(LOWER(RTRIM(LTRIM(@Semester))), ''semester '', '''');

    SELECT ''Student updated successfully'' AS Message;
END
')
