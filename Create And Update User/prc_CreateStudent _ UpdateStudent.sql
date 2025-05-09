CREATE OR ALTER PROCEDURE CreateStudentAccount
	@UserId INT,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11),
    @GPA FLOAT,
    @College_Degree NVARCHAR(50),
    @IntakeId INT,
    @TrackId INT,
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
			AND r.RoleType IN ('Admin','TrainingManager','BranchManager')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner','TrainingManager','BranchManager')
			)        BEGIN
            BEGIN TRANSACTION;

            -- Insert into Users
            INSERT INTO Users (Name, UserPassword, Gender, Email, Phone)
            VALUES (@Name, @UserPassword, @Gender, @Email, @Phone);

            DECLARE @NewUserId INT = SCOPE_IDENTITY();

            -- Insert into Student
            INSERT INTO Student (UserId, GPA, College_Degree, IntakeId, TrackId, BranchId)
            VALUES (@NewUserId, @GPA, @College_Degree, @IntakeId, @TrackId, @BranchId);

			-- Insert into UserRoles
            INSERT INTO UserRoles(UserId, RoleId)
            SELECT @NewUserId, RoleId 
            FROM Roles 
            WHERE RoleType = 'Student';
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
			    ALTER ROLE db_owner ADD MEMBER [' + @FinalUsername + '];
			END
			ELSE
			BEGIN
			    ALTER LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
			
			    ALTER USER [' + @FinalUsername + '] WITH LOGIN = [' + @FinalUsername + '];
			
			    -- You can optionally re-add the user to db_owner (if needed)
			    ALTER ROLE Student ADD MEMBER [' + @FinalUsername + '];
			END
			';

			EXEC sp_executesql @Sql;



            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only db_owner can perform this action.', 16, 1);
            RETURN;
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO;
CREATE OR ALTER PROCEDURE UpdateStudentAccount
	@UserId INT,
    @StudentUserId INT,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11),
    @GPA FLOAT,
    @College_Degree NVARCHAR(50),
    @IntakeId INT,
    @TrackId INT,
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
			AND r.RoleType IN ('Admin','TrainingManager','BranchManager')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner','TrainingManager','BranchManager')
			)        BEGIN
            BEGIN TRANSACTION;

            UPDATE Users
            SET Name = @Name,
                UserPassword = @UserPassword,
                Gender = @Gender,
                Email = @Email,
                Phone = @Phone
            WHERE UserId = @StudentUserId;

            UPDATE Student
            SET GPA = @GPA,
                College_Degree = @College_Degree,
                IntakeId = @IntakeId,
                TrackId = @TrackId,
                BranchId = @BranchId
            WHERE UserId = @StudentUserId;

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
			    ALTER ROLE db_owner ADD MEMBER [' + @FinalUsername + '];
			END
			ELSE
			BEGIN
			    ALTER LOGIN [' + @FinalUsername + '] WITH PASSWORD = ''' + @UserPassword + ''';
			
			    ALTER USER [' + @FinalUsername + '] WITH LOGIN = [' + @FinalUsername + '];
			
			    -- You can optionally re-add the user to db_owner (if needed)
			    ALTER ROLE Student ADD MEMBER [' + @FinalUsername + '];
			END
			';

			EXEC sp_executesql @Sql;


            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Admins with db_owner rights can perform this action.', 16, 1);
            RETURN;
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;

GO
EXEC CreateStudentAccount
	@UserId = 114,
    @Name = N'Youssef Mohsen',
    @UserPassword = N'Joe1234@@',
    @Gender = N'Male',
    @Email = N'mohsenyoussef235@gmail.com',
    @Phone = '01200297645',
    @GPA = 2.8,
    @College_Degree = N'Bachelor of Computer Science',
    @IntakeId = 1,     
    @TrackId = 1,       
    @BranchId = 1;     

GO
EXEC UpdateStudentAccount
	@UserId = 114,
    @StudentUserId = 117,                         
    @Name = N'Youssef Naguib',
    @UserPassword = N'Joe1234@@',
    @Gender = N'Male',
    @Email = N'mohsenyoussef26363@gmail.com',
    @Phone = '01300297647',
    @GPA = 2.9,
    @College_Degree = N'Bachelor of Computer Science',
    @IntakeId = 1,     
    @TrackId = 1,      
    @BranchId = 1;        
