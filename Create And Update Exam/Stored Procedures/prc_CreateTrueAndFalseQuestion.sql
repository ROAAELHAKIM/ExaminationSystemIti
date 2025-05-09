CREATE OR ALTER PROCEDURE prc_CreateTrueAndFalseQuestion
    @UserId INT,
    @CourseId INT,
    @QuestionText NVARCHAR(2000),
    @IsTrue NVARCHAR(10),
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
        IF LOWER(@IsTrue) NOT IN ('true', 'false')
        BEGIN
            RAISERROR('Invalid value for IsTrue. Must be "true" or "false".', 16, 1);
            RETURN;
        END

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

        INSERT INTO TrueAndFalseAnswer (QuestionId, IsTrue)
        VALUES (@QuestionId, CASE WHEN LOWER(@IsTrue) = 'true' THEN 1 ELSE 0 END);          

        PRINT 'Question created successfully.';
    END
    ELSE
    BEGIN
        RAISERROR('User is not authorized to add questions.', 16, 1);
    END
END;
GO


EXEC prc_CreateTrueAndFalseQuestion
    @UserId = 15,
    @CourseId = 6,
    @QuestionText = N'London is the capital of France.',
    @IsTrue = 'false',
    @DifficultyLevel = 'easy';


	EXEC prc_CreateTrueAndFalseQuestion
    @UserId = 15,
    @CourseId = 6,
    @QuestionText = N'Paris is the capital of France.',
    @IsTrue = 'true',
    @DifficultyLevel = 'easy';

