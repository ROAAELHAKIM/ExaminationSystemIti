CREATE OR ALTER FUNCTION func_DisplayAllExamsWithCourseId
    (@CourseId INT)  -- ???? ?????? (CourseId)
RETURNS TABLE
AS
RETURN 
(
    SELECT 
        e.ExamId, 
        e.CourseId, 
        e.TotalTime, 
        e.Allowance,
        e.TotalDegree,
		e.ExamYear,
		e.StartTime,
		e.EndTime	
    FROM 
        Exam e
    WHERE 
        e.CourseId = @CourseId
);
GO
SELECT * 
FROM dbo.func_DisplayAllExamsWithCourseId(1);

