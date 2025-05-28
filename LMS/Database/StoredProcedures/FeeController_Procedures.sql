-- File: FeeController_Procedures.sql

-- ✅ Procedure: sp_Fee_GetStudentFees
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetStudentFees]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetStudentFees]
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.FeeId, f.StudentId, u.FirstName + '' '' + u.LastName AS StudentName,
           ISNULL(f.Semester, ''Unknown'') AS Semester, ISNULL(f.Programme, ''Unknown'') AS Programme,
           f.AmountDue, f.AmountPaid, f.FeeStatus, f.DueDate, f.PaymentDate
    FROM Fees f
    JOIN Users u ON f.StudentId = u.UserId
    WHERE f.StudentId = @StudentId;
END
')
END

-- ✅ Procedure: sp_Fee_GetPendingByStudent
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetPendingByStudent]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetPendingByStudent]
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.FeeId, f.StudentId, u.FirstName + '' '' + u.LastName AS StudentName,
           ISNULL(f.Semester, ''Unknown'') AS Semester, ISNULL(f.Programme, ''Unknown'') AS Programme,
           f.AmountDue, f.AmountPaid, f.FeeStatus, f.DueDate, f.PaymentDate
    FROM Fees f
    JOIN Users u ON f.StudentId = u.UserId
    WHERE f.StudentId = @StudentId
      AND (f.FeeStatus != ''Paid'' OR f.AmountPaid < f.AmountDue);
END
')
END

-- ✅ Procedure: sp_Fee_GetBySemester
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetBySemester]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetBySemester]
    @StudentId INT,
    @Semester NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.FeeId, f.StudentId, u.FirstName + '' '' + u.LastName AS StudentName,
           ISNULL(f.Semester, ''Unknown'') AS Semester, ISNULL(f.Programme, ''Unknown'') AS Programme,
           f.AmountDue, f.AmountPaid, f.FeeStatus, f.DueDate, f.PaymentDate
    FROM Fees f
    JOIN Users u ON f.StudentId = u.UserId
    WHERE f.StudentId = @StudentId AND f.Semester = @Semester;
END
')
END

-- ✅ Procedure: sp_Fee_GetUnpaid
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetUnpaid]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetUnpaid]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.StudentId, u.Username AS Name,
           SUM(f.AmountDue - f.AmountPaid) AS TotalDue,
           f.FeeId, ISNULL(f.Semester, ''Unknown'') AS Semester,
           f.AmountDue, f.AmountPaid, f.FeeStatus, f.PaymentDate
    FROM Fees f
    JOIN Users u ON f.StudentId = u.UserId
    WHERE f.FeeStatus != ''Paid'' OR f.AmountPaid < f.AmountDue
    GROUP BY f.StudentId, u.Username, f.FeeId, f.Semester, f.AmountDue, f.AmountPaid, f.FeeStatus, f.PaymentDate;
END
')
END

-- ✅ Procedure: sp_Fee_GetUnpaidBySemester
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetUnpaidBySemester]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetUnpaidBySemester]
    @Semester NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.FeeId, f.StudentId, u.FirstName + '' '' + u.LastName AS StudentName,
           ISNULL(f.Semester, ''Unknown'') AS Semester, ISNULL(f.Programme, ''Unknown'') AS Programme,
           f.AmountDue, f.AmountPaid, f.FeeStatus, f.DueDate, f.PaymentDate
    FROM Fees f
    JOIN Users u ON f.StudentId = u.UserId
    WHERE f.Semester = @Semester AND (f.FeeStatus != ''Paid'' OR f.AmountPaid < f.AmountDue);
END
')
END

-- ✅ Procedure: sp_Fee_GetAll
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetAll]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT f.FeeId, f.StudentId, u.FirstName + '' '' + u.LastName AS StudentName,
           ISNULL(f.Semester, ''Unknown'') AS Semester, ISNULL(f.Programme, ''Unknown'') AS Programme,
           f.AmountDue, f.AmountPaid, f.FeeStatus, f.DueDate, f.PaymentDate
    FROM Fees f
    JOIN Users u ON f.StudentId = u.UserId;
END
')
END

-- ✅ Procedure: sp_Fee_GetSemesterFeeTemplate
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_GetSemesterFeeTemplate]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_GetSemesterFeeTemplate]
    @Programme NVARCHAR(100),
    @Semester NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Programme, Semester, AmountDue
    FROM SemesterFeeTemplate
    WHERE Programme = @Programme AND Semester = @Semester;
END
')
END
-- File: FeeController_Procedures.sql

-- [Previous procedures remain unchanged above...]

-- ✅ Procedure: sp_Fee_AddFee
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_AddFee]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_AddFee]
    @StudentId INT,
    @Semester NVARCHAR(50),
    @Programme NVARCHAR(100),
    @AmountDue DECIMAL(18,2),
    @AmountPaid DECIMAL(18,2),
    @DueDate DATETIME,
    @FeeStatus NVARCHAR(50),
    @PaymentDate DATETIME = NULL,
    @PaymentMethod NVARCHAR(100) = NULL,
    @TransactionId NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @StudentId AND Role = ''Student'')
    BEGIN
        RAISERROR(''Invalid student.'', 16, 1);
        RETURN;
    END

    INSERT INTO Fees
    (
        StudentId, Semester, Programme, AmountDue, AmountPaid,
        DueDate, FeeStatus, PaymentDate, PaymentMethod, TransactionId,
        CreatedAt, DateSent
    )
    VALUES
    (
        @StudentId, @Semester, @Programme, @AmountDue, @AmountPaid,
        @DueDate, @FeeStatus, @PaymentDate, @PaymentMethod, @TransactionId,
        GETUTCDATE(), GETUTCDATE()
    );

    DECLARE @FeeId INT = SCOPE_IDENTITY();

    INSERT INTO Notifications
    (
        UserId, NotificationType, Message, CreatedAt, DateSent, IsRead
    )
    VALUES
    (
        @StudentId, ''Fee'',
        ''Due: '' + CONVERT(NVARCHAR, @DueDate, 106) + '', Amount: ₹'' + CAST(@AmountDue AS NVARCHAR),
        GETUTCDATE(), GETUTCDATE(), 0
    );

    SELECT * FROM Fees WHERE FeeId = @FeeId;
END
')
END

-- ✅ Procedure: sp_Fee_UpdateFee
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_UpdateFee]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_UpdateFee]
    @FeeId INT,
    @AmountPaid DECIMAL(18,2),
    @FeeStatus NVARCHAR(50),
    @PaymentDate DATETIME = NULL,
    @PaymentMethod NVARCHAR(100) = NULL,
    @TransactionId NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Fees WHERE FeeId = @FeeId)
    BEGIN
        RAISERROR(''Fee not found.'', 16, 1);
        RETURN;
    END

    UPDATE Fees
    SET AmountPaid = @AmountPaid,
        FeeStatus = @FeeStatus,
        PaymentDate = ISNULL(@PaymentDate, GETUTCDATE()),
        PaymentMethod = ISNULL(@PaymentMethod, PaymentMethod),
        TransactionId = ISNULL(@TransactionId, TransactionId),
        UpdatedAt = GETUTCDATE()
    WHERE FeeId = @FeeId;

    DECLARE @StudentId INT = (SELECT StudentId FROM Fees WHERE FeeId = @FeeId);

    INSERT INTO Notifications
    (
        UserId, NotificationType, Message, CreatedAt, DateSent, IsRead
    )
    VALUES
    (
        @StudentId, ''Fee'',
        ''Paid ₹'' + CAST(@AmountPaid AS NVARCHAR) + '' on '' + CONVERT(NVARCHAR, ISNULL(@PaymentDate, GETUTCDATE()), 106) + '' (Status: '' + @FeeStatus + '')'',
        GETUTCDATE(), GETUTCDATE(), 0
    );

    SELECT ''Fee updated successfully.'' AS Message;
END
')
END

-- ✅ Procedure: sp_Fee_Delete
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Fee_Delete]') AND type IN (N'P', N'PC')
)
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Fee_Delete]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Fees WHERE FeeId = @Id;
END
')
END

