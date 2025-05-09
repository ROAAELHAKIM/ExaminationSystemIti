CREATE FUNCTION func_DisplayAllIntakeForSpecificBranch
(
    @BranchId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        IntakeId,
        StartDate,
        EndDate,
        IntervalInMonths,
        IntakeYear
    FROM Intake
    WHERE BranchId = @BranchId
);

SELECT * FROM dbo.func_DisplayAllIntakeForSpecificBranch(1);
