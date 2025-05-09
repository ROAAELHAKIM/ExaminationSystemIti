CREATE or alter PROC prc_AddIntake
@UserID Int,
@BranchId Int,
@IntakeId Int,
@SDate DATETIME2,
@EDate DATETIME2,
@IntakeY Int
AS
BEGIN
BEGIN TRY

IF EXISTS (
SELECT 1
FROM UserRoles ur
JOIN Roles r ON ur.RoleId = r.RoleId
JOIN Users u ON u.UserId = ur.UserId
WHERE ur.UserId = @UserID
AND r.RoleType IN ('TrainingManager', 'Admin')
)
AND EXISTS (
SELECT 1
FROM Users u
JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
WHERE u.UserId = @UserID
AND role_dp.name IN ('db_owner', 'TrainingManager')
)
    BEGIN
        INSERT INTO Intake (BranchId, IntakeId, StartDate,EndDate,IntakeYear)
        VALUES (@BranchId, @IntakeId,@SDate,@EDate,@IntakeY);
        PRINT 'Track Added Successfully';
    END
    ELSE
    BEGIN
        RAISERROR('Access denied. Only Training Managers or Admin can add tracks.', 16, 1);
    END
END TRY
BEGIN CATCH
    PRINT 'Error occurred';
END CATCH
END

EXEC prc_AddIntake
@UserId = 26,
@BranchID = 1,
@IntakeID = 101,
@SDate = '2025-01-01',
@EDate = '2025-06-01',
@IntakeY = 2025;
