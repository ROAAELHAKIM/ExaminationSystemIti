CREATE OR ALTER VIEW View_StudentDetails AS
SELECT 
    S.UserId,
	S.TrackId,
	S.IntakeId,
	U.Name AS StudentName,
	U.UserPassword,
	S.GPA,
	S.BranchId AS StudentBranchId,
	U.Email,
	U.Gender,
	I.StartDate,
	I.EndDate,
	I.IntervalInMonths,
	I.IntakeYear,
	I.BranchId AS IntakeBranchId
FROM 
    Student S
JOIN 
    Users U ON S.UserId = U.UserId
JOIN 
    Intake I ON S.IntakeID = I.IntakeID;
GO;

SELECT * FROM View_StudentDetails;
