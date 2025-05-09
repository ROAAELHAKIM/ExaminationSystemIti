CREATE PROCEDURE DeleteQuestionFromExam
@UserId INT,
@ExamId INT,
@QuestionId INT
AS
BEGIN
IF EXISTS (
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
BEGIN
DELETE FROM ExamQuestion
WHERE ExamId = @ExamId AND QuestionId = @QuestionId;
PRINT 'Question deleted from exam successfully.';
END
ELSE
BEGIN
RAISERROR('Unauthorized: User lacks necessary permissions.', 16, 1);
END
END;

EXEC DeleteQuestionFromExam @UserId = 1, @ExamId = 1, @QuestionId = 1;
