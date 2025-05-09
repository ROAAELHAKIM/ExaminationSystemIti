CREATE OR ALTER PROC prc_CalculateFinalExamResult
    @ExamId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FullMark INT;

        SELECT @FullMark = SUM(ISNULL(eq.InstructorMark, q.DefaultMark))
        FROM ExamQuestion eq
        INNER JOIN Question q ON q.QuestionId = eq.QuestionId
        WHERE eq.ExamId = @ExamId;

        IF @FullMark IS NULL OR @FullMark = 0
        BEGIN
            PRINT 'No full mark data found for this exam.';
            RETURN;
        END

        DELETE FROM StudentExamResult WHERE ExamId = @ExamId;

        INSERT INTO StudentExamResult (ExamId, StudentId, StudentName, TotalScore, Percentage, IsPass, Grade)
        SELECT 
            @ExamId,
            sa.StudentId,
            u.Name,
            SUM(sa.Mark) AS TotalMark,
            CAST(100.0 * SUM(sa.Mark) / NULLIF(@FullMark, 0) AS DECIMAL(5, 2)) AS Percentage,
            CASE 
                WHEN CAST(100.0 * SUM(sa.Mark) / NULLIF(@FullMark, 0) AS DECIMAL(5, 2)) >= 50 THEN 1 
                ELSE 0 
            END AS IsPass,
            CASE 
                WHEN CAST(100.0 * SUM(sa.Mark) / NULLIF(@FullMark, 0) AS DECIMAL(5, 2)) >= 90 THEN N'A'
                WHEN CAST(100.0 * SUM(sa.Mark) / NULLIF(@FullMark, 0) AS DECIMAL(5, 2)) >= 80 THEN N'B'
                WHEN CAST(100.0 * SUM(sa.Mark) / NULLIF(@FullMark, 0) AS DECIMAL(5, 2)) >= 65 THEN N'G'
                WHEN CAST(100.0 * SUM(sa.Mark) / NULLIF(@FullMark, 0) AS DECIMAL(5, 2)) >= 50 THEN N'D'
                ELSE N'F'
            END AS Grade
        FROM StudentAnswer sa
        JOIN Users u ON u.UserId = sa.StudentId
        WHERE sa.ExamId = @ExamId
        GROUP BY sa.StudentId, u.Name;

        PRINT 'Process completed successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error encountered:';
        PRINT ERROR_MESSAGE();
        PRINT ERROR_PROCEDURE();
        PRINT ERROR_LINE();
        ROLLBACK TRANSACTION;  
    END CATCH
END;

exec prc_CalculateFinalExamResult 1

select * from dbo.StudentExamResult

