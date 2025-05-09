GO 
CREATE OR ALTER VIEW vw_DisplayAllBranchs AS
SELECT 
	b.BranchId,
	b.Location
FROM Branch b;

SELECT * FROM vw_DisplayAllBranchs;
