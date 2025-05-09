CREATE OR ALTER TRIGGER trg_CorrectAnswer
ON StudentAnswer
AFTER INSERT
AS
BEGIN
    BEGIN TRY

        UPDATE sa
        SET sa.Mark = ISNULL(eq.InstructorMark, q.DefaultMark)
        FROM StudentAnswer sa
        INNER JOIN inserted i ON sa.StudentAnswerId = i.StudentAnswerId
        INNER JOIN ExamQuestion eq ON eq.QuestionId = i.QuestionId AND eq.ExamId = i.ExamId
        INNER JOIN MCQAnswer ma ON ma.QuestionId = i.QuestionId AND ma.IsTrue = 1
        INNER JOIN Question q ON q.QuestionId = i.QuestionId
        WHERE q.Type = 'MCQ' AND LTRIM(RTRIM(i.StudentAnswerText)) = LTRIM(RTRIM(ma.AnswerText));


        UPDATE sa
        SET sa.Mark = ISNULL(eq.InstructorMark, q.DefaultMark)
        FROM StudentAnswer sa
        INNER JOIN inserted i ON sa.StudentAnswerId = i.StudentAnswerId
        INNER JOIN ExamQuestion eq ON eq.QuestionId = i.QuestionId AND eq.ExamId = i.ExamId
        INNER JOIN TrueAndFalseAnswer tf ON tf.QuestionId = i.QuestionId
        INNER JOIN Question q ON q.QuestionId = i.QuestionId
        WHERE q.Type = 'TrueFalse'
          AND (
            (tf.IsTrue = 1 AND LOWER(LTRIM(RTRIM(i.StudentAnswerText))) = 'true')
            OR
            (tf.IsTrue = 0 AND LOWER(LTRIM(RTRIM(i.StudentAnswerText))) = 'false')
          );


        UPDATE sa
        SET sa.RgxResult = CASE WHEN i.StudentAnswerText LIKE ta.AcceptedAnswerRegex THEN 1 ELSE 0 END,
            sa.Mark = CASE WHEN i.StudentAnswerText LIKE ta.AcceptedAnswerRegex THEN ISNULL(eq.InstructorMark, q.DefaultMark) ELSE 0 END
        FROM StudentAnswer sa
        INNER JOIN inserted i ON sa.StudentAnswerId = i.StudentAnswerId
        INNER JOIN TextAnswer ta ON ta.QuestionId = i.QuestionId
        INNER JOIN ExamQuestion eq ON eq.QuestionId = i.QuestionId AND eq.ExamId = i.ExamId
        INNER JOIN Question q ON q.QuestionId = i.QuestionId
        WHERE q.Type = 'Text';

        -- ??? 0 ???????? ????? ???? ?? ??? ????? Mark ???
        UPDATE sa
        SET sa.Mark = 0
        FROM StudentAnswer sa
        INNER JOIN inserted i ON sa.StudentAnswerId = i.StudentAnswerId
        INNER JOIN Question q ON q.QuestionId = i.QuestionId
        WHERE q.Type IN ('MCQ', 'TrueFalse') AND sa.Mark IS NULL;


UPDATE sa
SET sa.IsCorrect = 1
FROM StudentAnswer sa
JOIN inserted i ON sa.StudentAnswerId = i.StudentAnswerId
WHERE sa.Mark > 0;

UPDATE sa
SET sa.IsCorrect = 0
FROM StudentAnswer sa
JOIN inserted i ON sa.StudentAnswerId = i.StudentAnswerId
WHERE sa.Mark IS NULL OR sa.Mark = 0;


    PRINT 'end trigger';

        PRINT 'Trigger executed successfully.';

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        PRINT 'Trigger Error: ' + @ErrMsg;
    END CATCH
END;