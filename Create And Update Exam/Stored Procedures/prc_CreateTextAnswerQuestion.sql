CREATE OR ALTER PROCEDURE prc_CreateTextAnswerQuestion
    @UserId INT,
    @CourseId INT,
    @QuestionText NVARCHAR(2000),
    @StandardAnswer NVARCHAR(2000),
	@AcceptedAnswerRegex NVARCHAR(2000),
    @DifficultyLevel NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DefaultMark INT;

    IF EXISTS (
        SELECT 1
        FROM UserRoles ur
        JOIN Roles r ON ur.RoleId = r.RoleId
        WHERE ur.UserId = @UserId
          AND r.RoleType IN ('Admin', 'Instructor')
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
    BEGIN
       
        SET @DefaultMark = 
            CASE LOWER(@DifficultyLevel)
                WHEN 'easy' THEN 2
                WHEN 'medium' THEN 4
                WHEN 'hard' THEN 6
                ELSE 0
            END;

        INSERT INTO Question (QuestionText, Type, DifficultyLevel, CourseId, DefaultMark)
        VALUES (@QuestionText, 'TrueFalse', @DifficultyLevel, @CourseId, @DefaultMark);

        DECLARE @QuestionId INT = SCOPE_IDENTITY();

        INSERT INTO TextAnswer(QuestionId , StandardAnswer , AcceptedAnswerRegex)
        VALUES (@QuestionId,@StandardAnswer,@AcceptedAnswerRegex);          

        PRINT 'Question created successfully.';
    END
    ELSE
    BEGIN
        RAISERROR('User is not authorized to add questions.', 16, 1);
    END
END;
GO


EXEC prc_CreateTextAnswerQuestion
    @UserId = 126,
    @CourseId = 6,
    @QuestionText = N'Paris is the capital of France.',
    @StandardAnswer = N'Paris',  
    @AcceptedAnswerRegex = N'Paris|paris', 
    @DifficultyLevel = 'easy';



select * from TextAnswer