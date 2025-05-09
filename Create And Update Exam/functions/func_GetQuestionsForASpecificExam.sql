CREATE FUNCTION fn_GetQuestionsByExam
(
    @ExamId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        eq.ExamId,
        eq.QuestionId,
        q.QuestionText,
        q.Type,
        eq.QuestionOrder
    FROM ExamQuestion eq
    INNER JOIN Question q ON q.QuestionId = eq.QuestionId
    WHERE eq.ExamId = @ExamId
);
SELECT *
FROM fn_GetQuestionsByExam(6)
ORDER BY QuestionOrder;