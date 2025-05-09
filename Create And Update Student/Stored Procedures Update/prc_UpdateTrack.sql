CREATE OR ALTER PROC prc_UpdateTrack @UserId int, @TrackId int,@NewDepartmentId int, @NewTrackName nvarchar(50)
AS
BEGIN
    BEGIN TRY
       
IF EXISTS (
    SELECT 1
    FROM UserRoles ur
    JOIN Roles r ON ur.RoleId = r.RoleId
    JOIN Users u ON u.UserId = ur.UserId
    WHERE ur.UserId = @UserId
    AND r.RoleType IN ('Instrctor', 'Admin')
)
AND EXISTS (
    SELECT 1
    FROM Users u
    JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
    JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
    JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
    WHERE u.UserId = @UserId
    AND role_dp.name IN ('db_owner', 'Instructor')
)
        begin
			update Track
			set Name = @NewTrackName, DepartmentId = @NewDepartmentId
			where TrackId = @TrackId
			print 'Track Updated Successfully';
			end
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Training Managers or Admin can add tracks.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred';
    END CATCH
END

EXEC prc_UpdateTrack 
    @UserId = 15,
    @TrackId = 2,
    @NewDepartmentId = 11,
    @NewTrackName = 'AI Track';
