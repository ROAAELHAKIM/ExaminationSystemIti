CREATE  or alter PROC prc_StudentSubmitAnswer
    @StudentId INT,
    @ExamId INT,
    @QuestionId INT,
    @StudentAnswerText NVARCHAR(MAX)
as
begin

    SET NOCOUNT ON;
        IF EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            JOIN Users u ON u.UserId = ur.UserId
            WHERE ur.UserId = @StudentId
              AND r.RoleType IN ('Student', 'Admin')
        )  
	
        AND EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @StudentId
              AND role_dp.name IN ('db_owner', 'Student')

        )
      
  if not  exists(
  select 1 from ExamStudent 
  where ExamId=@ExamId and StudentId=@StudentId
  )
     begin
        RAISERROR('Student is not registered for this exam.', 16, 1);
        return;
    end
 if exists(
  select 1 from StudentAnswer
  where ExamId = @ExamId and QuestionId = @QuestionId and StudentId = @StudentId
)
begin
    RAISERROR('You have already answered this question.', 16, 1);
    return;
end


    insert into StudentAnswer (
        ExamId, StudentId, QuestionId,
        StudentAnswerText
      
    )
    values (
        @ExamId, @StudentId, @QuestionId,
        @StudentAnswerText
    );

    print 'Answer added successfully.';
end

SELECT * 
FROM dbo.func_DisplayAllExamsWithCourseId(1);

SELECT * FROM fn_GetStudentsByTrack(1);


EXEC prc_StudentSubmitAnswer
    @ExamId =6,
    @StudentId = 133,
    @QuestionId = 21,
    @StudentAnswerText = N'true';

	select eq.ExamId ,eq.QuestionId,q.QuestionText ,q.Type from ExamQuestion eq
inner join Question q
 on q.QuestionId = eq.QuestionId
 where ExamId = 1
 order by eq.QuestionOrder