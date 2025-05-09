CREATE OR ALTER PROCEDURE prc_AddRandomQuestionsToExam
    @User_id INT,
    @ExamId INT,
    @NumberOfEasyQuestion INT,
    @NumberOfMediumQuestion INT,
	@NumberOfHardQuestion INT
AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
  IF NOT EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            WHERE ur.UserId = @User_id
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
            WHERE u.UserId = @User_id
            AND role_dp.name IN ('db_owner', 'Instructor')
        )
        BEGIN
            RAISERROR('You do not have sufficient database permissions.', 16, 1);
            RETURN;
        END
 DECLARE @CourseId INT, 
         @ExamDegree INT, 
         @TotalPastDegrees INT, 
         @MaxDegree INT,
		 @NumberOfQuestion INT;
	--Calculate Number of Question 
SET @NumberOfQuestion = @NumberOfEasyQuestion + @NumberOfMediumQuestion + @NumberOfHardQuestion;
	
 --retrive course id and examDegree for specific exam
 SELECT @CourseId = e.CourseId,
       @ExamDegree = e.TotalDegree
        FROM Exam e
        WHERE e.ExamId = @ExamId;

--Calculating total past degrees for all exam in specific course ex 40
        SELECT @TotalPastDegrees = ISNULL(SUM(TotalDegree), 0)
        FROM Exam 
        WHERE CourseId = @CourseId AND ExamId <> @ExamId;

--Rereive the course maximum degree ex100
SELECT @MaxDegree = MaxDegree FROM Course WHERE CourseId = @CourseId;

--Compare totalpastdegrees + exam degree greater than coourse maximum degree or not 
      IF @TotalPastDegrees + @ExamDegree > @MaxDegree
		  BEGIN
            RAISERROR('Total exam degrees exceed max allowed for the course.', 16, 1);
            RETURN;
        END
-- create temp table to calculate the number of question and exam degree
 CREATE TABLE #CandidateQuestions (
            QuestionId INT,
            Degree INT
        );

-- Insert  number of easy question 

INSERT INTO #CandidateQuestions (QuestionId, Degree)
SELECT TOP (@NumberOfEasyQuestion) q.QuestionId, q.DefaultMark
FROM Question q
WHERE q.CourseId = @CourseId
  AND q.DifficultyLevel = 'easy'
  AND q.QuestionId NOT IN (
        SELECT QuestionId FROM ExamQuestion WHERE ExamId = @ExamId
  )
ORDER BY NEWID();
  IF @@ROWCOUNT < @NumberOfEasyQuestion
BEGIN
    RAISERROR('Not enough easy questions available.', 16, 1);
    RETURN;
END
--Insert  number of  medium question 
INSERT INTO #CandidateQuestions (QuestionId, Degree)
SELECT TOP (@NumberOfMediumQuestion) q.QuestionId, q.DefaultMark
FROM Question q
WHERE q.CourseId = @CourseId
  AND q.DifficultyLevel = 'medium'
  AND q.QuestionId NOT IN (
        SELECT QuestionId FROM ExamQuestion WHERE ExamId = @ExamId
  )
ORDER BY NEWID();
  IF @@ROWCOUNT < @NumberOfMediumQuestion
BEGIN
    RAISERROR('Not enough medium questions available.', 16, 1);
    RETURN;
END
--Insert Number of Hard Question 
INSERT INTO #CandidateQuestions (QuestionId, Degree)
SELECT TOP (@NumberOfHardQuestion) q.QuestionId, q.DefaultMark
FROM Question q
WHERE q.CourseId = @CourseId
  AND q.DifficultyLevel = 'hard'
  AND q.QuestionId NOT IN (
        SELECT QuestionId FROM ExamQuestion WHERE ExamId = @ExamId
  )ORDER BY NEWID();

  IF @@ROWCOUNT < @NumberOfHardQuestion
BEGIN
    RAISERROR('Not enough Hard questions available.', 16, 1);
    RETURN;
END
-- Ensure Total degrees of selected questions (%d) is less than the required exam degree 

DECLARE @TotalQuestionSelectedDegrees INT;

SELECT @TotalQuestionSelectedDegrees = SUM(Degree)
FROM #CandidateQuestions;

IF @TotalQuestionSelectedDegrees < @ExamDegree
BEGIN
    RAISERROR('Total degrees of selected questions (%d) is less than the required exam degree (%d).', 
              16, 1, @TotalQuestionSelectedDegrees, @ExamDegree);
    RETURN;
END
        CREATE TABLE #SelectedQuestion (
            QuestionId INT,
            Degree INT
        );

        DECLARE @CurrentTotal INT = 0, @CurrentCount INT = 0;

        DECLARE cur CURSOR FOR
SELECT QuestionId, Degree FROM #CandidateQuestions;

        DECLARE @QId INT, @QDegree INT;

        OPEN cur;
        FETCH NEXT FROM cur INTO @QId, @QDegree;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @CurrentTotal + @QDegree <= @ExamDegree AND @CurrentCount < @NumberOfQuestion
            BEGIN
                INSERT INTO #SelectedQuestion (QuestionId, Degree)
                VALUES (@QId, @QDegree);

                SET @CurrentTotal += @QDegree;
                SET @CurrentCount += 1;
            END

            IF @CurrentTotal = @ExamDegree
                BREAK;

            FETCH NEXT FROM cur INTO @QId, @QDegree;
        END

        CLOSE cur;
        DEALLOCATE cur;

        IF @CurrentTotal <> @ExamDegree
        BEGIN
            RAISERROR('Could not find a combination of questions totaling exactly %d. Only %d degrees from %d questions selected.', 
                      16, 1, @ExamDegree, @CurrentTotal, @CurrentCount);
            RETURN;
        END

        INSERT INTO ExamQuestion (ExamId, QuestionId)
        SELECT @ExamId, QuestionId FROM #SelectedQuestion;

        DROP TABLE #SelectedQuestion;
        DROP TABLE #CandidateQuestions;


    END TRY
    BEGIN CATCH
        PRINT 'Error occurred in prc_AddRandomQuestionsToExam.';
        PRINT ERROR_MESSAGE();
        PRINT ERROR_NUMBER();
        PRINT ERROR_LINE();
    END CATCH
END;




