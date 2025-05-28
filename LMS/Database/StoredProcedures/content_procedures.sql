
-- ===========================================
-- Stored Procedures for ContentController (CourseContents)
-- Model: CourseContent
-- ===========================================

-- 1. Upload (Insert) Course Content
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CourseContent_UploadFile]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CourseContent_UploadFile
        @CourseId INT,
        @Title NVARCHAR(255),
        @Description NVARCHAR(MAX),
        @FileUrl NVARCHAR(500),
        @ContentType NVARCHAR(50),
        @UploadedAt DATETIME
    AS
    BEGIN
        INSERT INTO CourseContents (CourseId, Title, Description, FileUrl, ContentType, UploadedAt)
        VALUES (@CourseId, @Title, @Description, @FileUrl, @ContentType, @UploadedAt);

        SELECT SCOPE_IDENTITY() AS Id;
    END
    ')
END

-- 2. Get CourseContent by Id
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CourseContent_GetById]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CourseContent_GetById
        @Id INT
    AS
    BEGIN
        SELECT * FROM CourseContents WHERE Id = @Id;
    END
    ')
END

-- 3. Get CourseContent by CourseId
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CourseContent_GetByCourse]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CourseContent_GetByCourse
        @CourseId INT
    AS
    BEGIN
        SELECT * FROM CourseContents WHERE CourseId = @CourseId ORDER BY UploadedAt DESC;
    END
    ')
END

-- 4. Update CourseContent
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CourseContent_Update]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CourseContent_Update
        @Id INT,
        @Title NVARCHAR(255),
        @Description NVARCHAR(MAX),
        @FileUrl NVARCHAR(500),
        @ContentType NVARCHAR(50),
        @UploadedAt DATETIME
    AS
    BEGIN
        UPDATE CourseContents
        SET Title = @Title,
            Description = @Description,
            FileUrl = @FileUrl,
            ContentType = @ContentType,
            UploadedAt = @UploadedAt
        WHERE Id = @Id;
    END
    ')
END

-- 5. Stats for CourseContent by CourseId
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CourseContent_GetStatsByCourse]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CourseContent_GetStatsByCourse
        @CourseId INT
    AS
    BEGIN
        SELECT 
            SUM(CASE WHEN LOWER(ContentType) = ''pdf'' THEN 1 ELSE 0 END) AS PdfCount,
            SUM(CASE WHEN LOWER(ContentType) = ''video'' THEN 1 ELSE 0 END) AS VideoCount
        FROM CourseContents
        WHERE CourseId = @CourseId;
    END
    ')
END

-- 6. Delete CourseContent
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CourseContent_Delete]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_CourseContent_Delete
        @Id INT
    AS
    BEGIN
        DELETE FROM CourseContents WHERE Id = @Id;
    END
    ')
END
