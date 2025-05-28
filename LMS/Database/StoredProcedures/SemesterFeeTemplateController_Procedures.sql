-- ✅ sp_SemesterFeeTemplate_GetAllTemplates
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SemesterFeeTemplate_GetAllTemplates]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SemesterFeeTemplate_GetAllTemplates]
    AS
    BEGIN
        SELECT * FROM SemesterFeeTemplate;
    END
    ')
END

-- ✅ sp_SemesterFeeTemplate_GetTemplate
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SemesterFeeTemplate_GetTemplate]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SemesterFeeTemplate_GetTemplate]
        @Id INT
    AS
    BEGIN
        SELECT * FROM SemesterFeeTemplate WHERE Id = @Id;
    END
    ')
END

-- ✅ sp_SemesterFeeTemplate_CreateTemplate
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SemesterFeeTemplate_CreateTemplate]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SemesterFeeTemplate_CreateTemplate]
        @Programme NVARCHAR(100),
        @Semester NVARCHAR(100),
        @AmountDue DECIMAL(18,2)
    AS
    BEGIN
        INSERT INTO SemesterFeeTemplate (Programme, Semester, AmountDue)
        VALUES (@Programme, @Semester, @AmountDue);

        SELECT * FROM SemesterFeeTemplate WHERE Id = SCOPE_IDENTITY();
    END
    ')
END

-- ✅ sp_SemesterFeeTemplate_UpdateTemplate
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SemesterFeeTemplate_UpdateTemplate]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SemesterFeeTemplate_UpdateTemplate]
        @Id INT,
        @Programme NVARCHAR(100),
        @Semester NVARCHAR(100),
        @AmountDue DECIMAL(18,2)
    AS
    BEGIN
        UPDATE SemesterFeeTemplate
        SET Programme = @Programme,
            Semester = @Semester,
            AmountDue = @AmountDue
        WHERE Id = @Id;
    END
    ')
END

-- ✅ sp_SemesterFeeTemplate_DeleteTemplate
IF NOT EXISTS (
    SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_SemesterFeeTemplate_DeleteTemplate]') AND type IN (N'P', N'PC')
)
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_SemesterFeeTemplate_DeleteTemplate]
        @Id INT
    AS
    BEGIN
        DELETE FROM SemesterFeeTemplate WHERE Id = @Id;
    END
    ')
END
