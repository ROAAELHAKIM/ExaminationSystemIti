 CREATE VIEW DepartmentManagers AS
SELECT 
    d.DepartmentId,
    d.DepartmentName,
    bm.UserId AS ManagerUserId,
    u.Name AS ManagerName,
    u.Email AS ManagerEmail,
    bm.BranchId
FROM 
    Department d
JOIN 
    Track t ON d.DepartmentId = t.DepartmentId
JOIN 
    IntakeTrack it ON it.TrackId = t.TrackId  
JOIN 
    BranchManager bm ON bm.BranchId = it.BranchId  
JOIN 
    Users u ON u.UserId = bm.UserId;


	SELECT * FROM DepartmentManagers;
