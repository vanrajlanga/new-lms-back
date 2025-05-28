-- ✅ Procedure: sp_Group_GetAll
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Group_GetAll]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Group_GetAll];
GO
EXEC('
CREATE PROCEDURE [dbo].[sp_Group_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GroupId, g.GroupCode, g.GroupName, g.NumberOfSemesters, g.ProgrammeId,
           g.ProgrammeName, g.BatchName, g.Fee, g.SelectedSemesters,
           p.ProgrammeName AS ProgrammeNameFromFK, p.ProgrammeCode,
           g.CreatedDate, g.UpdatedDate
    FROM Groups g
    LEFT JOIN Programmes p ON g.ProgrammeId = p.ProgrammeId;
END
')
GO

-- ✅ Procedure: sp_Group_GetByProgramme
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Group_GetByProgramme]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Group_GetByProgramme];
GO
EXEC('
CREATE PROCEDURE [dbo].[sp_Group_GetByProgramme]
    @ProgrammeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GroupId, g.GroupCode, g.GroupName, g.NumberOfSemesters, g.ProgrammeId,
           g.ProgrammeName, g.BatchName, g.Fee, g.SelectedSemesters,
           p.ProgrammeName AS ProgrammeNameFromFK, p.ProgrammeCode,
           g.CreatedDate, g.UpdatedDate
    FROM Groups g
    LEFT JOIN Programmes p ON g.ProgrammeId = p.ProgrammeId
    WHERE g.ProgrammeId = @ProgrammeId;
END
')
GO

-- ✅ Procedure: sp_Group_GetById
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Group_GetById]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Group_GetById];
GO
EXEC('
CREATE PROCEDURE [dbo].[sp_Group_GetById]
    @GroupId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GroupId, g.GroupCode, g.GroupName, g.NumberOfSemesters, g.ProgrammeId,
           g.ProgrammeName, g.BatchName, g.Fee, g.SelectedSemesters,
           p.ProgrammeName AS ProgrammeNameFromFK, p.ProgrammeCode,
           g.CreatedDate, g.UpdatedDate
    FROM Groups g
    LEFT JOIN Programmes p ON g.ProgrammeId = p.ProgrammeId
    WHERE g.GroupId = @GroupId;
END
')
GO

-- ✅ Procedure: sp_Group_Create
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Group_Create]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Group_Create];
GO
EXEC('
CREATE PROCEDURE [dbo].[sp_Group_Create]
    @GroupCode NVARCHAR(100),
    @GroupName NVARCHAR(100),
    @NumberOfSemesters INT,
    @ProgrammeName NVARCHAR(100),
    @BatchName NVARCHAR(100),
    @Fee DECIMAL(18, 2),
    @SelectedSemesters NVARCHAR(MAX),
    @ProgrammeId INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Groups
    (GroupCode, GroupName, NumberOfSemesters, ProgrammeName, BatchName, Fee, SelectedSemesters, ProgrammeId, CreatedDate, UpdatedDate)
    VALUES
    (@GroupCode, @GroupName, @NumberOfSemesters, @ProgrammeName, @BatchName, @Fee, @SelectedSemesters, @ProgrammeId, GETUTCDATE(), GETUTCDATE());

    DECLARE @NewId INT = SCOPE_IDENTITY();
    SELECT * FROM Groups WHERE GroupId = @NewId;
END
')
GO

-- ✅ Procedure: sp_Group_Update
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Group_Update]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Group_Update];
GO
EXEC('
CREATE PROCEDURE [dbo].[sp_Group_Update]
    @GroupId INT,
    @GroupCode NVARCHAR(100),
    @GroupName NVARCHAR(100),
    @NumberOfSemesters INT,
    @ProgrammeName NVARCHAR(100),
    @BatchName NVARCHAR(100),
    @Fee DECIMAL(18, 2),
    @SelectedSemesters NVARCHAR(MAX),
    @ProgrammeId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Groups
    SET GroupCode = @GroupCode,
        GroupName = @GroupName,
        NumberOfSemesters = @NumberOfSemesters,
        ProgrammeName = @ProgrammeName,
        BatchName = @BatchName,
        Fee = @Fee,
        SelectedSemesters = @SelectedSemesters,
        ProgrammeId = @ProgrammeId,
        UpdatedDate = GETUTCDATE()
    WHERE GroupId = @GroupId;
END
')
GO

-- ✅ Procedure: sp_Group_Delete
IF EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Group_Delete]') AND type IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[sp_Group_Delete];
GO
EXEC('
CREATE PROCEDURE [dbo].[sp_Group_Delete]
    @GroupId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Groups WHERE GroupId = @GroupId;
END
')
GO
