	CREATE OR ALTER PROCEDURE dbo.prc_AssignStudentsToExam
	@UserId INT,
    @ExamId INT,
    @StudentIds NVARCHAR(MAX)  -- Comma-separated list like '101,102,103'
	AS
	BEGIN
	SET NOCOUNT ON;
			IF EXISTS (
		SELECT 1
		FROM UserRoles ur
		JOIN Roles r ON ur.RoleId = r.RoleId
		JOIN Users u ON u.UserId = ur.UserId
		WHERE ur.UserId = @UserId
		AND r.RoleType IN ('Instructor', 'Admin')
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
    BEGIN TRY
        -- Insert students who exist and are not already assigned to the exam
        INSERT INTO ExamStudent (ExamId, StudentId)
        SELECT 
            @ExamId, 
            TRY_CAST(value AS INT)
        FROM 
            STRING_SPLIT(@StudentIds, ',')
        WHERE 
            TRY_CAST(value AS INT) IS NOT NULL
            AND EXISTS (
                SELECT 1 
                FROM Student 
                WHERE UserId = TRY_CAST(value AS INT)
            )
            AND NOT EXISTS (
                SELECT 1 
                FROM ExamStudent
                WHERE ExamId = @ExamId 
                AND StudentId = TRY_CAST(value AS INT)
            );

        PRINT 'Students assigned successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

EXEC prc_AssignStudentsToExam
	@UserId = 128,
    @ExamId = 6, 
    @StudentIds = '133';

select eq.ExamId ,eq.QuestionId,q.QuestionText ,q.Type from ExamQuestion eq
inner join Question q
 on q.QuestionId = eq.QuestionId
 where ExamId = 1
 order by eq.QuestionOrder