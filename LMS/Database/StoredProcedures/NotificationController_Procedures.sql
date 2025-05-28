-- File: NotificationController_Procedures.sql

-- ✅ CreateNotification
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_CreateNotification]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_CreateNotification]
    @Message NVARCHAR(MAX),
    @NotificationType NVARCHAR(50),
    @UserId INT,
    @DateSent DATETIME
AS
BEGIN
    INSERT INTO Notifications (Message, NotificationType, DateSent, IsRead, UserId, CreatedAt)
    VALUES (@Message, @NotificationType, @DateSent, 0, @UserId, GETDATE());

    SELECT * FROM Notifications WHERE NotificationId = SCOPE_IDENTITY();
END
')
END

-- ✅ GetNotification
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_GetNotification]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_GetNotification]
    @Id INT
AS
BEGIN
    SELECT * FROM Notifications WHERE NotificationId = @Id;
END
')
END

-- ✅ GetAllNotifications
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_GetAllNotifications]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_GetAllNotifications]
AS
BEGIN
    SELECT * FROM Notifications ORDER BY DateSent DESC;
END
')
END

-- ✅ GetByUser
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_GetByUser]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_GetByUser]
    @UserId INT
AS
BEGIN
    SELECT * FROM Notifications WHERE UserId = @UserId ORDER BY DateSent DESC;
END
')
END

-- ✅ GetNotificationsByUser
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_GetNotificationsByUser]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_GetNotificationsByUser]
    @UserId INT
AS
BEGIN
    SELECT * FROM Notifications WHERE UserId = @UserId ORDER BY CreatedAt DESC;
END
')
END

-- ✅ MarkAsRead
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_MarkAsRead]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_MarkAsRead]
    @Id INT
AS
BEGIN
    UPDATE Notifications SET IsRead = 1 WHERE NotificationId = @Id;
END
')
END

-- ✅ DeleteNotification
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_DeleteNotification]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_DeleteNotification]
    @Id INT
AS
BEGIN
    DELETE FROM Notifications WHERE NotificationId = @Id;
END
')
END

-- ✅ Broadcast
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Notification_Broadcast]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Notification_Broadcast]
    @Message NVARCHAR(MAX),
    @NotificationType NVARCHAR(50),
    @DateSent DATETIME
AS
BEGIN
    INSERT INTO Notifications (UserId, Message, NotificationType, DateSent, IsRead, CreatedAt)
    SELECT UserId, @Message, @NotificationType, @DateSent, 0, GETDATE()
    FROM Users WHERE Role = @NotificationType;
END
')
END
