-- ✅ GetTasks
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TaskBoard_GetTasks]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_TaskBoard_GetTasks]
AS
BEGIN
    SELECT t.Id, t.Title, t.Description, t.Status, t.AssignedToUserId, 
           u.FirstName + '' '' + u.LastName AS AssignedToFullName,
           t.CreatedAt, t.UpdatedAt
    FROM TaskItems t
    LEFT JOIN Users u ON t.AssignedToUserId = u.UserId;
END
')
END

-- ✅ CreateTask
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TaskBoard_CreateTask]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_TaskBoard_CreateTask]
    @Title NVARCHAR(MAX),
    @Description NVARCHAR(MAX) = NULL,
    @Status NVARCHAR(50),
    @AssignedToUserId INT = NULL
AS
BEGIN
    INSERT INTO TaskItems (Title, Description, Status, AssignedToUserId, CreatedAt)
    VALUES (@Title, @Description, @Status, @AssignedToUserId, GETUTCDATE());

    SELECT * FROM TaskItems WHERE Id = SCOPE_IDENTITY();
END
')
END

-- ✅ UpdateTask
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TaskBoard_UpdateTask]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_TaskBoard_UpdateTask]
    @Id INT,
    @Title NVARCHAR(MAX),
    @Description NVARCHAR(MAX) = NULL,
    @Status NVARCHAR(50),
    @AssignedToUserId INT = NULL
AS
BEGIN
    UPDATE TaskItems
    SET Title = @Title,
        Description = @Description,
        Status = @Status,
        AssignedToUserId = @AssignedToUserId,
        UpdatedAt = GETUTCDATE()
    WHERE Id = @Id;

    SELECT * FROM TaskItems WHERE Id = @Id;
END
')
END

-- ✅ DeleteTask
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TaskBoard_DeleteTask]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_TaskBoard_DeleteTask]
    @Id INT
AS
BEGIN
    DELETE FROM TaskItems WHERE Id = @Id;
END
')
END
