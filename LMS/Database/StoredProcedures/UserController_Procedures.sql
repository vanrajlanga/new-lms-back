-- UserController_Procedures.sql

-- ✅ sp_User_GetAllUsers
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_GetAllUsers]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_GetAllUsers]
    AS
    BEGIN
        SELECT * FROM Users;
    END
    ')
END

-- ✅ sp_User_GetUser
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_GetUser]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_GetUser]
        @UserId INT
    AS
    BEGIN
        SELECT * FROM Users WHERE UserId = @UserId;
    END
    ')
END

-- ✅ sp_User_CreateUser
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_CreateUser]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_CreateUser]
        @Username NVARCHAR(100),
        @PasswordHash NVARCHAR(MAX),
        @Role NVARCHAR(50),
        @Email NVARCHAR(100)
    AS
    BEGIN
        INSERT INTO Users (Username, PasswordHash, Role, Email, Status)
        VALUES (@Username, @PasswordHash, @Role, @Email, ''Active'');

        SELECT * FROM Users WHERE UserId = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ sp_User_UpdateUser
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_UpdateUser]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_UpdateUser]
        @UserId INT,
        @Role NVARCHAR(50),
        @Status NVARCHAR(50)
    AS
    BEGIN
        UPDATE Users
        SET Role = @Role, Status = @Status
        WHERE UserId = @UserId;
    END
    ')
END

-- ✅ sp_User_DeleteUser
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_DeleteUser]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_DeleteUser]
        @UserId INT
    AS
    BEGIN
        DELETE FROM Users WHERE UserId = @UserId;
    END
    ')
END

-- ✅ sp_User_AssignRole
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_AssignRole]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_AssignRole]
        @UserId INT,
        @Role NVARCHAR(50)
    AS
    BEGIN
        UPDATE Users SET Role = @Role WHERE UserId = @UserId;
    END
    ')
END

-- ✅ sp_User_VerifyFeePayment
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_User_VerifyFeePayment]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_User_VerifyFeePayment]
        @StudentId INT
    AS
    BEGIN
        IF EXISTS (SELECT 1 FROM Users WHERE UserId = @StudentId AND Role = ''Student'')
        BEGIN
            IF EXISTS (SELECT 1 FROM Fees WHERE StudentId = @StudentId AND FeeStatus = ''Paid'')
            BEGIN
                SELECT ''Fee is paid. Access granted.'' AS Message;
            END
            ELSE
            BEGIN
                RAISERROR(''Fee not paid. Access denied.'', 16, 1);
            END
        END
        ELSE
        BEGIN
            RAISERROR(''Student not found or invalid role.'', 16, 1);
        END
    END
    ')
END