CREATE OR ALTER PROCEDURE prc_UpdateIntake
    @OldBranchId INT,
    @OldIntakeId INT,
    @NewBranchId INT,
    @NewIntakeId INT,
    @StartDate DATETIME2,
    @EndDate DATETIME2,
    @IntakeYear INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM Intake
            WHERE BranchId = @NewBranchId AND IntakeId = @NewIntakeId
              AND NOT (BranchId = @OldBranchId AND IntakeId = @OldIntakeId)
        )
        BEGIN
            RAISERROR(N'Update failed: The new BranchId and IntakeId combination already exists.', 16, 1);
            RETURN;
        END

        UPDATE Intake
        SET BranchId = @NewBranchId,
            IntakeId = @NewIntakeId,
            StartDate = @StartDate,
            EndDate = @EndDate,
            IntakeYear = @IntakeYear
        WHERE BranchId = @OldBranchId AND IntakeId = @OldIntakeId;

        IF @@ROWCOUNT = 0
            RAISERROR(N'Update failed: Original intake not found.', 16, 1);
        ELSE
            PRINT N'Intake updated successfully';
    END TRY
    BEGIN CATCH
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END

EXEC prc_UpdateIntake
    @OldBranchId = 1,
    @OldIntakeId = 101,
    @NewBranchId = 2,
    @NewIntakeId = 102,
    @StartDate = '2025-05-01',
    @EndDate = '2025-10-01',
    @IntakeYear = 2025;