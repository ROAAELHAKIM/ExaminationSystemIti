	CREATE FUNCTION fn_GetStudentsByTrack
(
    @TrackId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        S.UserId AS StudentId,
        U.Name,
        U.Email,
        S.GPA,
        S.College_Degree,
        S.BranchId,
        S.IntakeId,
        T.Name AS TrackName
    FROM Student S
    JOIN Users U ON S.UserId = U.UserId
    JOIN Track T ON S.TrackId = T.TrackId
    WHERE S.TrackId = @TrackId
);

SELECT * FROM fn_GetStudentsByTrack(1);
go
