
--CREATE LOGIN Admin
--WITH PASSWORD = 'admin12345';

--CREATE USER Admin
--FOR LOGIN Admin;

--ALTER ROLE db_owner add member Admin
-----------------------------------------------------------------------
--ADD ADMIN
GO
CREATE OR ALTER PROCEDURE CreateAdminAccount123
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11)
AS
BEGIN
    BEGIN TRY
        -- Check if the current user is a member of db_owner
        IF (IS_ROLEMEMBER('db_owner') = 1)
        BEGIN
            BEGIN TRANSACTION;

            -- Insert into Users table
            INSERT INTO Users (Name, UserPassword, Gender, Email, Phone)
            VALUES (@Name, @UserPassword, @Gender, @Email, @Phone);

            DECLARE @NewUserId INT = SCOPE_IDENTITY();

            -- Generate SQL login name
            DECLARE @CleanName NVARCHAR(100) = REPLACE(@Name, ' ', '');
            DECLARE @FinalUsername NVARCHAR(200) = @CleanName + @Phone;

            -- Check if login already exists and create login, user, and add to db_owner
            IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = @FinalUsername)
            BEGIN
                DECLARE @SQL NVARCHAR(MAX) = '
                    CREATE LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
                    CREATE USER [' + @FinalUsername + '] FOR LOGIN [' + @FinalUsername + '];
                    ALTER ROLE db_owner ADD MEMBER [' + @FinalUsername + '];';

                EXEC sp_executesql @SQL;
            END

            -- Insert into UserRoles
            INSERT INTO UserRoles(UserId, RoleId)
            SELECT @NewUserId, RoleId
            FROM Roles
            WHERE RoleType = 'Admin';

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Admins can perform this action.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

GO
EXEC CreateAdminAccount123
    @Name = 'JOE',
    @UserPassword = 'Youssef2014#',
    @Gender = 'Male',
    @Email = 'mohsenyoussef233@gmail.com',
    @Phone = '01001311691';
GO