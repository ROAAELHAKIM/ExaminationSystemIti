GO
CREATE OR ALTER PROCEDURE prc_DeleteQuestionAndAnswer
    @QuestionId INT
AS
BEGIN
    BEGIN TRY
        -- check if the question exists
        IF NOT EXISTS (SELECT 1 FROM Question WHERE QuestionId = @QuestionId)
        BEGIN
            RAISERROR('Question not found.', 16, 1);
            RETURN;
        END

        --check a question that has not been corrected yet
        IF EXISTS (
            SELECT 1
            FROM ExamQuestion EQ
            JOIN StudentExamResult SER ON EQ.ExamId = SER.ExamId
            WHERE EQ.QuestionId = @QuestionId
        )
        BEGIN
            RAISERROR('Cannot delete the question. It is part of a graded exam.', 16, 1);
            RETURN;
        END

IF EXISTS (SELECT 1 FROM McqAnswer WHERE QuestionId = @QuestionId)
BEGIN
    DELETE FROM McqAnswer WHERE QuestionId = @QuestionId;
    
END
ELSE

IF EXISTS (SELECT 1 FROM TrueAndFalseAnswer WHERE QuestionId = @QuestionId)
BEGIN
    DELETE FROM TrueAndFalseAnswer WHERE QuestionId = @QuestionId;
    
END
ELSE

IF EXISTS (SELECT 1 FROM TextAnswer WHERE QuestionId = @QuestionId)
BEGIN
    DELETE FROM TextAnswer WHERE QuestionId = @QuestionId;
END

        -- delete the question
        DELETE FROM Question WHERE QuestionId = @QuestionId;

        PRINT 'Question deleted successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;

GO
EXEC prc_DeleteQuestionAndAnswer @QuestionId = 11;
