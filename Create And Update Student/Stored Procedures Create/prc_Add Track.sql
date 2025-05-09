-- Proc To Add Track
CREATE OR ALTER PROC prc_AddTrack
@UserId INT,
@TrackName NVARCHAR(50),
@DepartmentId INT
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
    INSERT INTO Track (Name, DepartmentId)
    VALUES (@TrackName, @DepartmentId);
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

EXEC prc_AddTrack 
    @UserId = 1, 
    @TrackName = 'Full Stack Development', 
    @DepartmentId = 2;

EXEC prc_AddTrack 
    @UserId = 1, 
    @TrackName = 'Operation System', 
    @DepartmentId = 5;

EXEC prc_AddTrack 
    @UserId = 15, 
    @TrackName = 'Network', 
    @DepartmentId = 6;

EXEC prc_AddTrack 
    @UserId = 15, 
    @TrackName = 'Power BI', 
    @DepartmentId = 7;

EXEC prc_AddTrack 
    @UserId = 15, 
    @TrackName = 'Fundmentals', 
    @DepartmentId = 8;

EXEC prc_AddTrack 
    @UserId = 15, 
    @TrackName = 'BRAVO3LIK', 
    @DepartmentId = 8;



