CREATE OR ALTER PROCEDURE prc_AddCourse
    @UserId INT,
    @CourseName NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @MinDegree INT,
    @MaxDegree INT,
	@TrackId INT
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
            
            INSERT INTO Course (CourseName, CourseDescription, MinDegree, MaxDegree, TrackId)
            VALUES (@CourseName, @Description, @MinDegree, @MaxDegree, @TrackId);

            PRINT 'Course created successfully.';
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Admin or Training Manager can create a course.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error occoured'
    END CATCH
END

GO
EXEC prc_AddCourse
    @UserId = 114,
    @CourseName = 'Advanced Databases',
    @Description = 'An in-depth course on relational and NoSQL databases.',
    @MinDegree = 50,
    @MaxDegree = 100,
	@TrackId = 2;
