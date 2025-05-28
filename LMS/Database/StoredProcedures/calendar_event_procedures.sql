
-- ===========================================
-- Stored Procedures for CalendarEventController
-- Table: CalendarEvents (from CalendarEvent model)
-- ===========================================

-- 1. Create a new calendar event
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CalendarEvent_Create]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CalendarEvent_Create
        @CourseId INT,
        @EventTitle NVARCHAR(255),
        @EventDescription NVARCHAR(MAX),
        @StartDate DATETIME,
        @EndDate DATETIME,
        @EventType NVARCHAR(100)
    AS
    BEGIN
        INSERT INTO CalendarEvents (CourseId, EventTitle, EventDescription, StartDate, EndDate, EventType)
        VALUES (@CourseId, @EventTitle, @EventDescription, @StartDate, @EndDate, @EventType);

        SELECT SCOPE_IDENTITY() AS EventId;
    END
    ')
END


-- 2. Get events by CourseId
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CalendarEvent_GetByCourse]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CalendarEvent_GetByCourse
        @CourseId INT
    AS
    BEGIN
        SELECT * FROM CalendarEvents
        WHERE CourseId = @CourseId
        ORDER BY StartDate;
    END
    ')
END


-- 3. Update calendar event
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CalendarEvent_Update]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CalendarEvent_Update
        @EventId INT,
        @EventTitle NVARCHAR(255),
        @EventDescription NVARCHAR(MAX),
        @StartDate DATETIME,
        @EndDate DATETIME,
        @EventType NVARCHAR(100)
    AS
    BEGIN
        UPDATE CalendarEvents
        SET EventTitle = @EventTitle,
            EventDescription = @EventDescription,
            StartDate = @StartDate,
            EndDate = @EndDate,
            EventType = @EventType
        WHERE EventId = @EventId;
    END
    ')
END


-- 4. Delete calendar event
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CalendarEvent_Delete]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CalendarEvent_Delete
        @EventId INT
    AS
    BEGIN
        DELETE FROM CalendarEvents
        WHERE EventId = @EventId;
    END
    ')
END
