GO
CREATE OR ALTER VIEW vw_InstructorProfile AS
SELECT 
    I.UserId,
    U.Name AS InstructorName,
    U.Email,
    I.HireDate,
    I.InstructorRank,
    I.Salary,
    I.Experience,
	I.IsDepartmentManager
    D.DepartmentName,
	B.Location
FROM 
    Instructor I
    JOIN Users U ON I.UserId = U.UserId
    LEFT JOIN Department D ON I.DepartmentId = D.DepartmentId
    LEFT JOIN Branch B ON I.BranchId = B.BranchId;

SELECT * FROM vw_InstructorProfile WHERE UserId = 1;