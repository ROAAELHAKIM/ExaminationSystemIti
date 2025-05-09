CREATE PROCEDURE DeleteInstructorFromCourse
    @UserId INT,
    @InstructorId INT,
    @CourseId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the instructor is assigned to the course
    IF NOT EXISTS (
        SELECT 1 
        FROM CourseInstructor 
        WHERE InstructorId = @InstructorId AND CourseId = @CourseId
    )
    BEGIN
        PRINT 'This Instructor Doesn''t Exist For This Course';
        RETURN;
    END

    -- Authorization Check
    IF NOT (
        EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @UserId
              AND r.RoleType IN ('TrainingManager', 'Admin')
        )
        AND EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp 
                ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @UserId
              AND role_dp.name IN ('db_owner', 'TrainingManager')
        )
    )
    BEGIN
        PRINT 'You are not authorized to perform this action.';
        RETURN;
    END

    -- Delete instructor from the course
    DELETE FROM CourseInstructor
    WHERE InstructorId = @InstructorId AND CourseId = @CourseId;

    PRINT 'Instructor successfully removed from the course.';
END

EXEC DeleteInstructorFromCourse @UserId = 128, @InstructorId = 5, @CourseId = 10;
