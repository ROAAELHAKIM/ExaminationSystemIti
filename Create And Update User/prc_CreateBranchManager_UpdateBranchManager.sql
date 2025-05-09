CREATE OR ALTER PROCEDURE CreateBranchManagerAccount
	@UserId Int,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11),
	@BranchId INT
AS
BEGIN
    BEGIN TRY
       IF EXISTS (
			SELECT 1
			FROM UserRoles ur
			JOIN Roles r ON ur.RoleId = r.RoleId
			JOIN Users u ON u.UserId = ur.UserId
			WHERE ur.UserId = @UserId
			AND r.RoleType IN ('Admin','TrainingManager')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner','TrainingManager')
			)BEGIN        
            BEGIN TRANSACTION;

            INSERT INTO Users (Name, UserPassword, Gender, Email, Phone)
            VALUES (@Name, @UserPassword, @Gender, @Email, @Phone);

            DECLARE @NewUserId INT = SCOPE_IDENTITY();

            INSERT INTO BranchManager(UserId,BranchId)
            VALUES (@NewUserId,@BranchId);

            -- Insert into UserRoles
            INSERT INTO UserRoles(UserId, RoleId)
            SELECT @NewUserId, RoleId 
            FROM Roles 
            WHERE RoleType = 'BranchManager';
            -- Create SQL Server Login/User and add to role
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
			    ALTER ROLE BranchManager ADD MEMBER [' + @FinalUsername + '];
			END
			ELSE
			BEGIN
			    ALTER LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
			
			    ALTER USER [' + @FinalUsername + '] WITH LOGIN = [' + @FinalUsername + '];
			
			    -- You can optionally re-add the user to db_owner (if needed)
			    ALTER ROLE BranchManager ADD MEMBER [' + @FinalUsername + '];
			END
			';

			EXEC sp_executesql @Sql;


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
GO;
CREATE OR ALTER PROCEDURE UpdateBranchManagerAccount
	@UserId Int,
    @TargetUserId INT,       
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11),
	@BranchId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

IF EXISTS (
			SELECT 1
			FROM UserRoles ur
			JOIN Roles r ON ur.RoleId = r.RoleId
			JOIN Users u ON u.UserId = ur.UserId
			WHERE ur.UserId = @UserId
			AND r.RoleType IN ('Admin','TrainingManager')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner','TrainingManager')
			)BEGIN       
			UPDATE Users
            SET Name = @Name,
                UserPassword = @UserPassword,
                Gender = @Gender,
                Email = @Email,
                Phone = @Phone
            WHERE UserId = @TargetUserId;

            UPDATE BranchManager
            SET BranchId = @BranchId
            WHERE UserId = @TargetUserId;

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
			    ALTER ROLE BranchManager ADD MEMBER [' + @FinalUsername + '];
			END
			ELSE
			BEGIN
			    ALTER LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
			
			    ALTER USER [' + @FinalUsername + '] WITH LOGIN = [' + @FinalUsername + '];
			
			    -- You can optionally re-add the user to db_owner (if needed)
			    ALTER ROLE BranchManager ADD MEMBER [' + @FinalUsername + '];
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
EXEC CreateBranchManagerAccount 
	@UserId = 114,
    @Name = N'BranchManagerJoe',
    @UserPassword = 'StrongPass#123',
    @Gender = N'Male',
    @Email = 'joebranchmanager@example.com',
    @Phone = '01052345699',
    @BranchId = 1;
GO;
EXEC UpdateBranchManagerAccount 
	@UserId = 114,
    @TargetUserId = 119,        
    @Name = N'BranchManagerJoeM',
    @UserPassword = 'StrongPass#123',
    @Gender = N'Male',
    @Email = 'joebranchmanager@example.com',
    @Phone = '01052345699',
    @BranchId = 2;
