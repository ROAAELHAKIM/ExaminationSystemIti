CREATE OR ALTER PROCEDURE prc_AddQuestionToExamManually
    @UserId int,
    @ExamId INT,           
    @QuestionId INT,
	@QuestionOrder INT = NULL,
	@InstructorMark INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
	 IF NOT EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @UserId
            AND r.RoleType IN ('Instructor', 'Admin')
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
            AND role_dp.name IN ('db_owner', 'Instructor')
        )
        BEGIN
            RAISERROR('You do not have sufficient database permissions.', 16, 1);
            RETURN;
        END
    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM ExamQuestion
            WHERE ExamId = @ExamId AND QuestionId = @QuestionId
        )
        BEGIN
            RAISERROR('The question is already added to the exam.', 16, 1);
            RETURN;
        END

        INSERT INTO ExamQuestion (ExamId, QuestionId,QuestionOrder,InstructorMark)
        VALUES (@ExamId, @QuestionId,@QuestionOrder,@InstructorMark);

        PRINT 'Question added to the exam successfully.';

    END TRY
    BEGIN CATCH
        PRINT 'Error occurred in prc_AddQuestionToExamManually.';
        PRINT ERROR_MESSAGE();
        PRINT ERROR_NUMBER();
        PRINT ERROR_LINE();
    END CATCH
END;

exec prc_AddQuestionToExamManually
@UserId=114,
@ExamId = 1,
@QuestionId = 3 

select eq.ExamId ,eq.QuestionId,q.QuestionText  from ExamQuestion eq
inner join Question q
 on q.QuestionId = eq.QuestionId
 where ExamId = 10
 order by eq.QuestionOrder