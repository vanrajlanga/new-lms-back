-- File: LibraryController_Procedures.sql

-- ✅ sp_Library_GetBooks
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Library_GetBooks]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Library_GetBooks]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Books;
END
')
END

-- ✅ sp_Library_GetBookById
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Library_GetBookById]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Library_GetBookById]
  @BookId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Books WHERE BookId = @BookId;
END
')
END

-- ✅ sp_Library_AddBook
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Library_AddBook]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Library_AddBook]
  @Title NVARCHAR(255),
  @Author NVARCHAR(255),
  @ISBN NVARCHAR(100),
  @Category NVARCHAR(100),
  @TotalCopies INT,
  @AvailableCopies INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Books (Title, Author, ISBN, Category, TotalCopies, AvailableCopies)
    VALUES (@Title, @Author, @ISBN, @Category, @TotalCopies, @AvailableCopies);

    SELECT * FROM Books WHERE BookId = SCOPE_IDENTITY();
END
')
END

-- ✅ sp_Library_UpdateBook
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Library_UpdateBook]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Library_UpdateBook]
  @BookId INT,
  @Title NVARCHAR(255),
  @Author NVARCHAR(255),
  @ISBN NVARCHAR(100),
  @Category NVARCHAR(100),
  @TotalCopies INT,
  @AvailableCopies INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Books
    SET Title = @Title,
        Author = @Author,
        ISBN = @ISBN,
        Category = @Category,
        TotalCopies = @TotalCopies,
        AvailableCopies = @AvailableCopies
    WHERE BookId = @BookId;

    SELECT * FROM Books WHERE BookId = @BookId;
END
')
END

-- ✅ sp_Library_DeleteBook
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Library_DeleteBook]') AND type IN (N'P', N'PC'))
BEGIN
EXEC('
CREATE PROCEDURE [dbo].[sp_Library_DeleteBook]
  @BookId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Books WHERE BookId = @BookId;
END
')
END
