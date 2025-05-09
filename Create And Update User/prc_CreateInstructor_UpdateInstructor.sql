 CREATE Or Alter PROCEDURE CreateInstructorAccount
	@UserId INT ,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11),
    @HireDate DATE,
    @InstructorRank NVARCHAR(30),
    @Salary DECIMAL(10, 2),
    @Experience INT,
    @IsDepartmentManager BIT,
    @DepartmentId INT,
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
			AND r.RoleType IN ('Admin','BranchManager','TrainingManager')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner','BranchManager','TrainingManager')
			)BEGIN        
            BEGIN TRANSACTION;

			--Insert Into Users
            INSERT INTO Users (Name, UserPassword, Gender, Email, Phone)
            VALUES (@Name, @UserPassword, @Gender, @Email, @Phone);

            DECLARE @NewUserId INT = SCOPE_IDENTITY();

			--Insert Into Instructors
            INSERT INTO Instructor (UserId, HireDate, InstructorRank, Salary, Experience, IsDepartmentManager, DepartmentId, BranchId)
            VALUES (@NewUserId, @HireDate, @InstructorRank, @Salary, @Experience, @IsDepartmentManager, @DepartmentId, @BranchId);

			-- Insert into UserRoles
            INSERT INTO UserRoles(UserId, RoleId)
            SELECT @NewUserId, RoleId 
            FROM Roles 
            WHERE RoleType = 'Instructor';
            -- تجهيز اسم المستخدم بدون مسافات
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
			    ALTER ROLE Instructor ADD MEMBER [' + @FinalUsername + '];
			END
			';

			EXEC sp_executesql @Sql;


            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only db_owner can perform this action.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO;
CREATE Or Alter PROCEDURE UpdateInstructorAccount
	@UserId INT ,
    @InstructorUserId INT,
    @Name NVARCHAR(100),
    @UserPassword NVARCHAR(50),
    @Gender NVARCHAR(60),
    @Email NVARCHAR(60),
    @Phone VARCHAR(11),
    @HireDate DATE,
    @InstructorRank NVARCHAR(30),
    @Salary DECIMAL(10, 2),
    @Experience INT,
    @IsDepartmentManager BIT,
    @DepartmentId INT,
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
			AND r.RoleType IN ('Admin','BranchManager','TrainingManager')
			)
			AND EXISTS (
			SELECT 1
			FROM Users u
			JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
			JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
			JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
			WHERE u.UserId = @UserId
			AND role_dp.name IN ('db_owner','BranchManager','TrainingManager')
			)BEGIN        
            BEGIN TRANSACTION;

            UPDATE Users
            SET Name = @Name,
                UserPassword = @UserPassword,
                Gender = @Gender,
                Email = @Email,
                Phone = @Phone
            WHERE UserId = @InstructorUserId;

            UPDATE Instructor
            SET HireDate = @HireDate,
                InstructorRank = @InstructorRank,
                Salary = @Salary,
                Experience = @Experience,
                IsDepartmentManager = @IsDepartmentManager,
                DepartmentId = @DepartmentId,
                BranchId = @BranchId
            WHERE UserId = @InstructorUserId;

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
			    ALTER ROLE Instructor ADD MEMBER [' + @FinalUsername + '];
			END
			';

			EXEC sp_executesql @Sql;

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Admins with db_owner rights can perform this action.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
Go;
EXEC CreateInstructorAccount
	@UserId = 114,
    @Name = N'Doctor Joe',
    @UserPassword = N'DrJoe@123',
    @Gender = N'Male',
    @Email = N'joe@prof.com',
    @Phone = '01001234567',
    @HireDate = '2020-09-01',
    @InstructorRank = N'Assistant Professor',
    @Salary = 12000.50,
    @Experience = 5,
    @IsDepartmentManager = 1,
    @DepartmentId = 2,  
    @BranchId = 1;      
	Go;
EXEC UpdateInstructorAccount
	@UserId = 114,
    @InstructorUserId = 118,                      
    @Name = N'Doctor Sara',
    @UserPassword = N'DrAhmed@123',
    @Gender = N'female',
    @Email = N'sara123@prof.com',
    @Phone = '01101264567',
    @HireDate = '2020-09-01',
    @InstructorRank = N'Assistant Professor',
    @Salary = 12000.50,
    @Experience = 5,
    @IsDepartmentManager = 1,
    @DepartmentId = 2,  
    @BranchId = 1;     
