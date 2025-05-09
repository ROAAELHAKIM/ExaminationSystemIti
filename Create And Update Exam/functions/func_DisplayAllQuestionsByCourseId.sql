CREATE OR ALTER FUNCTION fn_GetQuestionsByCourse
(
    @CourseId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT q.QuestionId, q.QuestionText, q.Type, q.DefaultMark, q.DifficultyLevel,q.CourseId
    FROM Question q
    WHERE q.CourseId = @CourseId
);
SELECT * FROM fn_GetQuestionsByCourse(1); 

