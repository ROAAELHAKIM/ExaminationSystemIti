CREATE FUNCTION func_DisplayAllExamsForSpecificCoursess(@CourseId INT)
RETURNS TABLE
AS
RETURN
(
SELECT
ExamId,
CourseId,
Type
FROM
Exam
WHERE
CourseId = @CourseId
);
GO;
SELECT * FROM func_DisplayAllExamsForSpecificCourses(1);