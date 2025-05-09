CREATE OR ALTER VIEW View_ExamDetails
AS
SELECT 
    e.ExamId,
    c.CourseName,
    e.Type AS ExamType,
    e.ExamYear,
    e.TotalTime,
    e.Allowance,
    e.TotalDegree,
    e.StartTime,
    e.EndTime,
    COUNT(es.StudentId) AS RegisteredStudents
FROM 
    Exam e
    JOIN Course c ON e.CourseId = c.CourseId
    LEFT JOIN ExamStudent es ON e.ExamId = es.ExamId
GROUP BY 
    e.ExamId, c.CourseName, e.Type, e.ExamYear, e.TotalTime, 
    e.Allowance, e.TotalDegree, e.StartTime, e.EndTime;
GO;
SELECT * FROM View_ExamDetails;

