GO
CREATE OR ALTER PROCEDURE prc_DeleteStudentFromExam
    @ExamId INT,
    @StudentId INT
AS
BEGIN
    BEGIN TRY
        -- Check if exam exists
        IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamId = @ExamId)
        BEGIN
            RAISERROR('Exam not found.', 16, 1);
            RETURN;
        END

        -- Check if student exists
        IF NOT EXISTS (SELECT 1 FROM Student WHERE UserId = @StudentId)
        BEGIN
            RAISERROR('Student not found.', 16, 1);
            RETURN;
        END

        -- Check if student is registered in this exam
        IF NOT EXISTS (
            SELECT 1 
            FROM ExamStudent 
            WHERE ExamId = @ExamId AND StudentId = @StudentId
        )
        BEGIN
            RAISERROR('Student is not registered in this exam.', 16, 1);
            RETURN;
        END

        -- Delete student from the exam
        DELETE FROM ExamStudent 
        WHERE ExamId = @ExamId AND StudentId = @StudentId;

        PRINT 'Student removed from exam successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

EXEC prc_DeleteStudentFromExam @ExamId = 2, @StudentId = 11;
