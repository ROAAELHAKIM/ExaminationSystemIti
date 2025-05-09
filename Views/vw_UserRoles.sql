CREATE OR ALTER VIEW vw_UserRoles AS
SELECT
    U.UserId,
    U.Name AS UserName,
    U.Email,
	U.UserPassword,
	U.Phone,
    R.RoleType AS Role
FROM Users U
JOIN UserRoles UR ON U.UserId = UR.UserId
JOIN Roles R ON UR.RoleId = R.RoleId;
GO
SELECT * FROM vw_UserRoles