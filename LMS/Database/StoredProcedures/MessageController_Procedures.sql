-- File: MessageController_Procedures.sql

-- ✅ sp_Message_SendMessage
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Message_SendMessage]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Message_SendMessage]
    @SenderId INT,
    @ReceiverId INT,
    @Subject NVARCHAR(255),
    @Content NVARCHAR(MAX),
    @SentAt DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Messages (SenderId, ReceiverId, Subject, Content, SentAt, IsRead)
    VALUES (@SenderId, @ReceiverId, @Subject, @Content, @SentAt, 0);

    SELECT * FROM Messages WHERE Id = SCOPE_IDENTITY();
END
')
END

-- ✅ sp_Message_GetInbox
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Message_GetInbox]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Message_GetInbox]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Id, m.SenderId, m.ReceiverId, 
           s.Username AS SenderName, 
           r.Username AS ReceiverName, 
           m.Subject, m.Content, m.IsRead, m.SentAt
    FROM Messages m
    JOIN Users s ON m.SenderId = s.UserId
    JOIN Users r ON m.ReceiverId = r.UserId
    WHERE m.ReceiverId = @UserId
    ORDER BY m.SentAt DESC;
END
')
END

-- ✅ sp_Message_GetSentMessages
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Message_GetSentMessages]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Message_GetSentMessages]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Id, m.SenderId, m.ReceiverId, 
           s.Username AS SenderName, 
           r.Username AS ReceiverName, 
           m.Subject, m.Content, m.IsRead, m.SentAt
    FROM Messages m
    JOIN Users s ON m.SenderId = s.UserId
    JOIN Users r ON m.ReceiverId = r.UserId
    WHERE m.SenderId = @UserId
    ORDER BY m.SentAt DESC;
END
')
END

-- ✅ sp_Message_MarkAsRead
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Message_MarkAsRead]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Message_MarkAsRead]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Messages SET IsRead = 1 WHERE Id = @Id;
END
')
END
