--Get All Courses Through TrackId,DepartmentId

--Create Exam
DECLARE @NewExamId INT;
EXEC prc_CreateExamForCourse
    @UserId = 128,
    @CourseId = 1,
    @TotalTime = 90,
    @Allowance = 10,
    @TotalDegree = 10,
    @ExamYear = 2025,
    @StartTime = '2025-06-01 10:00:00',
    @EndTime = '2025-06-01 11:30:00',
    @Type = 'exam',
    @NewExamId = @NewExamId OUTPUT;

PRINT 'New Exam ID: ' + CAST(@NewExamId AS NVARCHAR);

--Show Question By CourseId
SELECT * FROM fn_GetQuestionsByCourse(1); 
--Assign Question To Exam Manually
exec prc_AddQuestionToExamManually
@UserId=128,
@ExamId = 6,
@QuestionId = 1

--  Question To Exam Manually
--Assign Question To Exam Randomly
exec prc_AddRandomQuestionsToExam 
    @User_id =128,
    @ExamId = 31,
    @NumberOfEasyQuestion =2,
    @NumberOfMediumQuestion =0,
	@NumberOfHardQuestion =1
--
EXEC DeleteQuestionFromExam @UserId = 128, @ExamId = 1, @QuestionId = 1;

--Assign Student To Exam 
EXEC prc_AssignStudentsToExam
	@UserId = 128,
    @ExamId = 31, 
    @StudentIds = '133,138,139';

--Display All Questions In A Specfic Exam
SELECT *
FROM fn_GetQuestionsByExam(31)
ORDER BY QuestionOrder;
--If Question = MCQ Add Question Id And Choose Your Answer
SELECT * FROM dbo.fn_GetMcqAnswersByQuestionId(1);
--Student Submits His Answer Until All Questions Are Answered
EXEC prc_StudentSubmitAnswer
    @ExamId =31,
    @StudentId = 133,
    @QuestionId = 1,
    @StudentAnswerText = N'HTML stands for HyperText Markup Language.';
--Calculate Final Exam Result
exec prc_CalculateFinalExamResult 31




