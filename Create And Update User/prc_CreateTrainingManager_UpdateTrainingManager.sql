CREATE OR ALTER PROCEDURE CreateTrainingManagerAccount
	@UserId Int,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
			SELECT 1
			FROM UserRoles ur
			JOIN Roles r ON ur.RoleId = r.RoleId
			JOIN Users u ON u.UserId = ur.UserId
			WHERE ur.UserId = @UserId
			AND r.RoleType IN ('Admin')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner')
			)BEGIN       
            BEGIN TRANSACTION;

            -- Insert into Users
            INSERT INTO Users (Name, UserPassword, Gender, Email, Phone)
            VALUES (@Name, @UserPassword, @Gender, @Email, @Phone);


            DECLARE @NewUserId INT = SCOPE_IDENTITY();
			-- Insert into UserRoles
            INSERT INTO UserRoles(UserId, RoleId)
            SELECT @NewUserId, RoleId 
            FROM Roles 
            WHERE RoleType = 'TrainingManager';

            -- Clean up username
            DECLARE @CleanName NVARCHAR(100) = REPLACE(@Name, ' ', '');
            DECLARE @FinalUsername NVARCHAR(200) = @CleanName + @Phone;
            DECLARE @Sql NVARCHAR(2000);
			SET @Sql = '
			IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = ''' + @FinalUsername + ''')
			BEGIN
			    -- Create login at the server level
			    CREATE LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
			
			    -- Create user in the database
			    CREATE USER [' + @FinalUsername + '] FOR LOGIN [' + @FinalUsername + '];
			
			    -- Add user to db_owner role
			    ALTER ROLE TrainingManager ADD MEMBER [' + @FinalUsername + '];
			END
			ELSE
			BEGIN
			    ALTER LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
			
			    ALTER USER [' + @FinalUsername + '] WITH LOGIN = [' + @FinalUsername + '];
			
			    -- You can optionally re-add the user to db_owner (if needed)
			    ALTER ROLE db_owner ADD MEMBER [' + @FinalUsername + '];
			END
			';

            -- Create SQL statement for creating login and user
			EXEC sp_executesql @Sql;
            -- Execute the dynamic SQL


            -- Commit transaction
            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            -- Rollback if any transaction started (just in case)
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;

            -- If user is not an admin, raise an error
            RAISERROR('Access denied. Only Admins can perform this action.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        -- Rollback transaction if any error occurs
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE UpdateTrainingManagerAccount
	@UserId INT,
    @TargetUserId INT,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

         IF (IS_ROLEMEMBER('db_owner') = 1)
        BEGIN
            UPDATE Users
            SET Name = @Name,
                UserPassword = @UserPassword,
                Gender = @Gender,
                Email = @Email,
                Phone = @Phone
            WHERE UserId = @TargetUserId;

            -- بناء اسم اليوزر لتحديث الـ Login و User في السيرفر
            DECLARE @CleanName NVARCHAR(100) = REPLACE(@Name, ' ', '');
            DECLARE @FinalUsername NVARCHAR(200) = @CleanName + @Phone;
            DECLARE @Sql NVARCHAR(2000);

SET @Sql = '
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = ''' + @FinalUsername + ''')
BEGIN
    -- Create login at the server level
    CREATE LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';

    -- Create user in the database
    CREATE USER [' + @FinalUsername + '] FOR LOGIN [' + @FinalUsername + '];

    -- Add user to db_owner role
    ALTER ROLE TrainingManager ADD MEMBER [' + @FinalUsername + '];
END
ELSE
BEGIN
    ALTER LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';

    ALTER USER [' + @FinalUsername + '] WITH LOGIN = [' + @FinalUsername + '];

    -- You can optionally re-add the user to db_owner (if needed)
    ALTER ROLE TrainingManager ADD MEMBER [' + @FinalUsername + '];
END
';

EXEC sp_executesql @Sql;

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Access denied. Only Admins can perform this action.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END
GO;
EXEC CreateTrainingManagerAccount 
	@UserId = 114,
    @Name = N'JOE', 
    @UserPassword = 'Youssef2014#', 
    @Gender = N'male', 
    @Email = 'mohsenyoussef239@g3mail.com', 
    @Phone = '01061311091';
GO;

GO;
EXEC UpdateTrainingManagerAccount 
	@UserId = 114,
    @TargetUserId = 120,     
    @Name = N'JOETM', 
    @UserPassword = 'Youssef2014#', 
    @Gender = N'male', 
    @Email = 'mohsenyoussef2383@gmail.com', 
    @Phone = '01384804657';
