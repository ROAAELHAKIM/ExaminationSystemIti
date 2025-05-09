CREATE OR ALTER PROC prc_AddDepartment
    @UserId INT,
    @DepartmentName NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            JOIN Users u ON u.UserId = ur.UserId
            WHERE ur.UserId = @UserId
              AND r.RoleType IN ('TrainingManager', 'Admin')
        )
        AND EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @UserId
              AND role_dp.name IN ('db_owner', 'TrainingManager')
        )
        BEGIN
            INSERT INTO Department ( DepartmentName)
            VALUES ( @DepartmentName);

            PRINT 'Department Added Successfully';
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Training Managers or Admin can add Department.', 16, 1);
        END
    END TRY
    BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT, @ErrState INT;
    SELECT 
        @ErrMsg = ERROR_MESSAGE(),
        @ErrSeverity = ERROR_SEVERITY(),
        @ErrState = ERROR_STATE();
		 RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);

    END CATCH
END

EXEC prc_AddDepartment
    @UserId = 26,
    @DepartmentName = N'roaa';