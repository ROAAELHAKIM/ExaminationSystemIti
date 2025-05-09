CREATE VIEW CourseDetailsView AS
SELECT 
    c.CourseId,
    c.CourseName,
    c.CourseDescription,
    c.MinDegree,
    c.MaxDegree,
    c.TrackId,
    t.Name AS TrackName
FROM 
    Course c
JOIN 
    Track t ON c.TrackId = t.TrackId;

	SELECT * FROM CourseDetailsView;
