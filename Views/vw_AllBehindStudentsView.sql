CREATE VIEW AllBehindStudents AS
SELECT 
    s.UserId,
    s.GPA,
    s.College_Degree,
    s.BranchId,
    s.IntakeId,
    s.TrackId,
    se.ExamId,
    se.TotalScore,
    se.Percentage,
    se.Grade,
    se.IsPass
FROM 
    Student s
JOIN 
    StudentExamResult se ON s.UserId = se.StudentId
WHERE 
    se.IsPass = 'false';

	SELECT * FROM AllBehindStudents;
