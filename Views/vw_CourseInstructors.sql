CREATE OR ALTER VIEW vw_CourseInstructor 
AS
SELECT
    ci.CourseId,
    c.CourseName,
    ci.InstructorId,
    u.Name AS InstructorName
FROM CourseInstructor ci
JOIN Course c ON ci.CourseId = c.CourseId
JOIN Users u ON ci.InstructorId = u.UserId;
GO
SELECT * FROM vw_CourseInstructor;

