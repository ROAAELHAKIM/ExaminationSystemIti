go
CREATE OR ALTER PROCEDURE delete_branch
    @user_id INT,
    @branch_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
       
        IF NOT EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @user_id
              AND r.RoleType IN ('TrainingManager', 'Admin')
        )
        OR NOT EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @user_id
              AND role_dp.name IN ('db_owner', 'TrainingManager')
        )
        BEGIN
            RAISERROR('Access denied. Only Training Managers or Admins can delete branches.', 16, 1);
            RETURN;
        END

        
        IF NOT EXISTS (
            SELECT 1 FROM Branch WHERE BranchId = @branch_id
        )
        BEGIN
            RAISERROR('Branch not found.', 16, 1);
            RETURN;
        END


        DELETE FROM Branch WHERE BranchId = @branch_id;

        PRINT 'Branch deleted successfully.';
    END TRY

    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END

--test the code :
exec delete_branch 
    @user_id = 15,        
    @branch_id = 11