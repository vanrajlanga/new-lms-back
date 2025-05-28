-- File: LeaveController_Procedures.sql

-- ✅ sp_Leave_GetAll
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Leave_GetAll]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Leave_GetAll]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT l.LeaveRequestId,
           CONCAT(u.FirstName, '' '', u.LastName) AS Name,
           u.ProfilePhotoUrl,
           u.Username AS UserCode,
           l.Reason,
           l.StartDate,
           l.EndDate,
           l.Status
    FROM LeaveRequests l
    JOIN Users u ON l.UserId = u.UserId;
END
')
END

-- ✅ sp_Leave_GetByUser
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Leave_GetByUser]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Leave_GetByUser]
  @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT l.LeaveRequestId,
           CONCAT(u.FirstName, '' '', u.LastName) AS Name,
           u.ProfilePhotoUrl,
           u.Username AS UserCode,
           l.Reason,
           l.StartDate,
           l.EndDate,
           l.Status
    FROM LeaveRequests l
    JOIN Users u ON l.UserId = u.UserId
    WHERE l.UserId = @UserId;
END
')
END

-- ✅ sp_Leave_Submit
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Leave_Submit]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Leave_Submit]
  @UserId INT,
  @StartDate DATETIME,
  @EndDate DATETIME,
  @Reason NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO LeaveRequests (UserId, StartDate, EndDate, Reason, Status, CreatedAt)
    VALUES (@UserId, @StartDate, @EndDate, @Reason, ''Pending'', GETUTCDATE());
END
')
END

-- ✅ sp_Leave_Approve
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Leave_Approve]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Leave_Approve]
  @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE LeaveRequests SET Status = ''Approved'' WHERE LeaveRequestId = @Id;
END
')
END

-- ✅ sp_Leave_Reject
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Leave_Reject]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Leave_Reject]
  @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE LeaveRequests SET Status = ''Rejected'' WHERE LeaveRequestId = @Id;
END
')
END

-- ✅ sp_Leave_Delete
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Leave_Delete]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Leave_Delete]
  @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM LeaveRequests WHERE LeaveRequestId = @Id;
END
')
END
