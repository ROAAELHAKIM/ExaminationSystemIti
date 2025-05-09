
	CREATE OR ALTER PROCEDURE prc_UpdateCourse
    @UserId INT, 
    @CourseId INT,
    @TrackId INT,
    @CourseName NVARCHAR(50),
    @CourseDescription NVARCHAR(200),
    @MinDegree INT,
    @MaxDegree INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @UserId
              AND r.RoleType IN ('Instructor', 'Admin')
        )
        AND EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp 
                ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @UserId
              AND role_dp.name IN ('db_owner', 'Instructor')
        )
        BEGIN
            -- Update course only if it belongs to the correct track
            IF EXISTS (
                SELECT 1 FROM Course WHERE CourseId = @CourseId AND TrackId = @TrackId
            )
            BEGIN
                UPDATE Course
                SET 
                    CourseName = @CourseName,
                    CourseDescription = @CourseDescription,
                    MinDegree = @MinDegree,
                    MaxDegree = @MaxDegree
                WHERE CourseId = @CourseId;

                PRINT 'Course updated successfully.';
            END
            ELSE
            BEGIN
                THROW 50002, 'Course not found in the specified track.', 1;
            END
        END
        ELSE
        BEGIN
            THROW 50001, 'Access denied. Only Instructors or Admins can update courses.', 1;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000);
        SET @ErrMsg = ERROR_MESSAGE();
        PRINT N'Error occurred: ' + @ErrMsg;
    END CATCH
END

EXEC prc_UpdateCourse
    @UserId = 121,
    @CourseId = 3,
    @TrackId = 3,
    @CourseName = N'Advanced SQL',
    @CourseDescription = N'Deep dive into SQL Server features.',
    @MinDegree = 50,
    @MaxDegree = 100;


