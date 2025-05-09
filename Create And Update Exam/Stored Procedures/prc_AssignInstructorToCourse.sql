CREATE OR ALTER PROCEDURE prc_AssignInstructorToCourse
    @UserId INT,  
    @CourseId INT, 
    @InstructorId INT  
AS
BEGIN
    SET NOCOUNT ON;
	IF NOT EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @UserId
            AND r.RoleType IN ('TrainingManager', 'Admin')
        )
        BEGIN
            RAISERROR('You do not have sufficient privileges to perform this action.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @UserId
            AND role_dp.name IN ('db_owner', 'TrainingManager')
        )
        BEGIN
            RAISERROR('You do not have sufficient database permissions.', 16, 1);
            RETURN;
        END
  
    if EXISTS (
        SELECT 1
        FROM Course c
        WHERE c.CourseId = @CourseId
    )
    AND NOT EXISTS ( 
        SELECT 1
        FROM CourseInstructor ci
        WHERE ci.CourseId = @CourseId AND ci.InstructorId = @InstructorId
    )
    BEGIN

        INSERT INTO CourseInstructor (CourseId, InstructorId)
        VALUES (@CourseId, @InstructorId);

        PRINT 'Instructor assigned to course successfully.';
    END
    ELSE
    BEGIN
        RAISERROR('User is not authorized to assign instructor to course, or instructor is already assigned to this course.', 16, 1);
    END
END;
GO
CREATE OR ALTER PROCEDURE prc_AssignInstructorToCourse
    @UserId INT,  
    @CourseId INT, 
    @InstructorId INT  
AS
BEGIN
    SET NOCOUNT ON;
	IF NOT EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @UserId
            AND r.RoleType IN ('TrainingManager', 'Admin')
        )
        BEGIN
            RAISERROR('You do not have sufficient privileges to perform this action.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @UserId
            AND role_dp.name IN ('db_owner', 'TrainingManager')
        )
        BEGIN
            RAISERROR('You do not have sufficient database permissions.', 16, 1);
            RETURN;
        END
  
    if EXISTS (
        SELECT 1
        FROM Course c
        WHERE c.CourseId = @CourseId
    )
    AND NOT EXISTS ( 
        SELECT 1
        FROM CourseInstructor ci
        WHERE ci.CourseId = @CourseId AND ci.InstructorId = @InstructorId
    )
    BEGIN

        INSERT INTO CourseInstructor (CourseId, InstructorId)
        VALUES (@CourseId, @InstructorId);

        PRINT 'Instructor assigned to course successfully.';
    END
    ELSE
    BEGIN
        RAISERROR('User is not authorized to assign instructor to course, or instructor is already assigned to this course.', 16, 1);
    END
END;
GO


EXEC prc_AssignInstructorToCourse
    @UserId = 15, 
    @CourseId = 2, 
    @InstructorId = 5;  


