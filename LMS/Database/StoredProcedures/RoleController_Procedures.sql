-- RoleController_Procedures.sql

-- ✅ sp_Role_AssignRole
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Role_AssignRole]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Role_AssignRole]
        @UserId INT,
        @RoleId INT
    AS
    BEGIN
        DECLARE @RoleName NVARCHAR(100);
        SELECT @RoleName = RoleName FROM Roles WHERE RoleId = @RoleId;

        IF @RoleName IS NULL
        BEGIN
            RAISERROR (''Role not found.'', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            RAISERROR (''User not found.'', 16, 1);
            RETURN;
        END

        UPDATE Users SET Role = @RoleName WHERE UserId = @UserId;
    END
    ')
END

-- ✅ sp_Role_GetUsersByRole
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Role_GetUsersByRole]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Role_GetUsersByRole]
        @RoleName NVARCHAR(100)
    AS
    BEGIN
        SELECT * FROM Users WHERE Role = @RoleName;
    END
    ')
END

-- ✅ sp_Role_UpdateRole
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Role_UpdateRole]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Role_UpdateRole]
        @UserId INT,
        @RoleId INT
    AS
    BEGIN
        DECLARE @RoleName NVARCHAR(100);
        SELECT @RoleName = RoleName FROM Roles WHERE RoleId = @RoleId;

        IF @RoleName IS NULL
        BEGIN
            RAISERROR (''Role not found.'', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            RAISERROR (''User not found.'', 16, 1);
            RETURN;
        END

        UPDATE Users SET Role = @RoleName WHERE UserId = @UserId;
    END
    ')
END

-- ✅ sp_Role_RemoveRole
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Role_RemoveRole]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_Role_RemoveRole]
        @UserId INT
    AS
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            RAISERROR (''User not found.'', 16, 1);
            RETURN;
        END

        UPDATE Users SET Role = NULL WHERE UserId = @UserId;
    END
    ')
END
