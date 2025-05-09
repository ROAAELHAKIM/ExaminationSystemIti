CREATE OR ALTER PROCEDURE prc_UpdateDepartment
    @DepartmentId INT,
    @NewDepartmentName NVARCHAR(50)
AS
BEGIN
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentId = @DepartmentId)
        BEGIN
            RAISERROR('Department not found.', 16, 1);
            RETURN;
        END

        UPDATE Department
        SET DepartmentName = @NewDepartmentName
        WHERE DepartmentId = @DepartmentId;

        PRINT 'Department updated successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;


EXEC prc_UpdateDepartment
    @DepartmentId = 11,
    @NewDepartmentName = 'Artificial Intelligence';
