CREATE PROCEDURE DeleteUser
    @UserId INT,
	@DeletedUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
    BEGIN
        PRINT 'User not found.';
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
        PRINT 'User cannot be deleted: missing proper roles or DB access.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Delete from UserRoles
        DELETE FROM UserRoles
        WHERE UserId = @DeletedUserId;

        -- Delete from BranchManager
		IF EXISTS (SELECT 1 FROM Instructor WHERE UserId = @DeletedUserId)
        BEGIN
        DELETE FROM BranchManager
        WHERE UserId = @DeletedUserId;
		END

        -- Delete instructor-related records
        IF EXISTS (SELECT 1 FROM Instructor WHERE UserId = @DeletedUserId)
        BEGIN
            DELETE FROM CourseInstructor
            WHERE InstructorId = @DeletedUserId;

            DELETE FROM Instructor
            WHERE UserId = @DeletedUserId;
        END

        -- Delete student-related records
        IF EXISTS (SELECT 1 FROM Student WHERE UserId = @DeletedUserId)
        BEGIN
            DELETE FROM StudentAnswer
            WHERE StudentId = @DeletedUserId;

            DELETE FROM StudentExamResult
            WHERE StudentId = @DeletedUserId;

            DELETE FROM ExamStudent
            WHERE StudentId = @DeletedUserId;

            DELETE FROM Student
            WHERE UserId = @DeletedUserId;
        END

        -- Delete from Users table
        DELETE FROM Users
        WHERE UserId = @UserId;

        COMMIT TRANSACTION;
        PRINT 'User and all related data deleted successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred while deleting the user: ' + ERROR_MESSAGE();
    END CATCH
END;


EXEC DeleteUser @UserId = 118,@DeletedUserId = 125;
