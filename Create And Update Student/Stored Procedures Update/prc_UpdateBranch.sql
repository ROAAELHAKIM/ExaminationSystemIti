CREATE OR ALTER PROC EditBranch 
    @branchId INT, 
    @userId INT, 
    @NewLocation NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE BranchId = @branchId)
        BEGIN
            RAISERROR('This branch does not exist to edit it!', 16, 1);
            RETURN;
        END

        IF NOT (
            EXISTS (
                SELECT 1
                FROM UserRoles ur
                JOIN Roles r ON ur.RoleId = r.RoleId
                JOIN Users u ON u.UserId = ur.UserId
                WHERE ur.UserId = @userId
                AND r.RoleType IN ('TrainingManager', 'Admin')
            )
            AND EXISTS (
                SELECT 1
                FROM Users u
                JOIN sys.database_principals dp 
                    ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
                JOIN sys.database_role_members drm 
                    ON dp.principal_id = drm.member_principal_id
                JOIN sys.database_principals role_dp 
                    ON drm.role_principal_id = role_dp.principal_id
                WHERE u.UserId = @userId
                AND role_dp.name IN ('db_owner', 'TrainingManager')
            )
        )
        BEGIN
            RAISERROR('Access denied. Only Training Managers or Admins can edit branches.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1 
            FROM Branch 
            WHERE Location = @NewLocation AND BranchId <> @branchId
        )
        BEGIN
            RAISERROR('Another branch already uses this location.', 16, 1);
            RETURN;
        END

        UPDATE Branch
        SET Location = @NewLocation
        WHERE BranchId = @branchId;

        PRINT 'Branch updated successfully.';
    END TRY

    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END
EXEC EditBranch @userId = 15, @BranchId = 3, @NewLocation = N'samalout';
GO