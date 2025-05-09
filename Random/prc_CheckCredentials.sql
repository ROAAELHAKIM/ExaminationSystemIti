CREATE FUNCTION dbo.CheckLogin
(
    @Email NVARCHAR(100),
    @UserPassword NVARCHAR(50)
)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Result NVARCHAR(100);

    IF EXISTS (
        SELECT 1
        FROM Users
        WHERE Email = @Email AND UserPassword = @UserPassword
    )
        SET @Result = N'Signed in successfully';
    ELSE
        SET @Result = N'Invalid username or password';

    RETURN @Result;
END;
GO
SELECT dbo.CheckLogin(N'youssef.mohsen@example.com', N'StrongPas..s@2025') AS LoginStatus;