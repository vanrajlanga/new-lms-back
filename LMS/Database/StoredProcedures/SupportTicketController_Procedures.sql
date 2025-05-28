-- SupportTicketController_Procedures.sql

-- ✅ sp_SupportTicket_CreateTicket
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SupportTicket_CreateTicket]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SupportTicket_CreateTicket]
        @StudentId INT,
        @Subject NVARCHAR(200),
        @Description NVARCHAR(MAX),
        @Type NVARCHAR(50),
        @SubType NVARCHAR(50)
    AS
    BEGIN
        INSERT INTO SupportTickets (StudentId, Subject, Description, Type, SubType, Status, StartDate)
        VALUES (@StudentId, @Subject, @Description, @Type, @SubType, ''Open'', GETUTCDATE());

        SELECT * FROM SupportTickets WHERE Id = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ sp_SupportTicket_GetStudentTickets
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SupportTicket_GetStudentTickets]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SupportTicket_GetStudentTickets]
        @StudentId INT
    AS
    BEGIN
        SELECT *
        FROM SupportTickets
        WHERE StudentId = @StudentId
        ORDER BY StartDate DESC;
    END
    ')
END

-- ✅ sp_SupportTicket_GetAllTickets
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SupportTicket_GetAllTickets]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SupportTicket_GetAllTickets]
    AS
    BEGIN
        SELECT s.Id, s.StudentId, u.Username AS StudentName,
               s.Subject, s.Description, s.Type, s.SubType, s.Status,
               s.StartDate, s.DueDate
        FROM SupportTickets s
        JOIN Users u ON s.StudentId = u.UserId
        ORDER BY s.StartDate DESC;
    END
    ')
END

-- ✅ sp_SupportTicket_UpdateTicket
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SupportTicket_UpdateTicket]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SupportTicket_UpdateTicket]
        @Id INT,
        @Status NVARCHAR(50) = NULL,
        @AdminComment NVARCHAR(MAX) = NULL
    AS
    BEGIN
        UPDATE SupportTickets
        SET Status = ISNULL(@Status, Status),
            AdminComment = ISNULL(@AdminComment, AdminComment)
        WHERE Id = @Id;

        SELECT * FROM SupportTickets WHERE Id = @Id;
    END
    ')
END
