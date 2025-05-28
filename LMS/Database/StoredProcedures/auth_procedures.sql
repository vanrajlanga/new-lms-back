
-- ===========================================
-- Stored Procedure: sp_Auth_LoginWithFeeCheck
-- Purpose: Fetch user by username with fee overdue check
-- Models: User, Fee
-- Tables: Users, Fees
-- ===========================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Auth_LoginWithFeeCheck]') AND type IN (N'P', N'PC'))
BEGIN
    EXEC('
    CREATE PROCEDURE sp_Auth_LoginWithFeeCheck
        @Username NVARCHAR(100)
    AS
    BEGIN
        SET NOCOUNT ON;

        -- 1. Get user details by username
        SELECT TOP 1 
            u.UserId,
            u.PasswordHash,
            u.Role
        FROM Users u
        WHERE u.Username = @Username;

        -- 2. Get overdue unpaid fees if role is Student
        SELECT COUNT(*) AS HasOverdueUnpaidFees
        FROM Users u
        JOIN Fees f ON f.StudentId = u.UserId
        WHERE u.Username = @Username
          AND u.Role = ''Student''
          AND (
              f.FeeStatus != ''Paid'' 
              OR f.AmountPaid < f.AmountDue
          )
          AND f.DueDate < GETUTCDATE();
    END
    ')
END
