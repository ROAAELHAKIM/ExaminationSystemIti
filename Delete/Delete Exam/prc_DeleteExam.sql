CREATE OR ALTER PROC DeleteExam
    @ExamId INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ������ �� ���� ��������
        IF NOT EXISTS (SELECT 1 FROM Exam WHERE ExamId = @ExamId)
        BEGIN
            RAISERROR('Exam with the specified ID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- ������ �� ������ �������� (��� �� ���� TrainingManager �� Admin + ��� �� db_owner �� TrainingManager)
        IF NOT (
            EXISTS (
                SELECT 1
                FROM UserRoles ur
                JOIN Roles r ON ur.RoleId = r.RoleId
                WHERE ur.UserId = @user_id
                AND r.RoleType IN ('TrainingManager', 'Admin')
            )
            AND EXISTS (
                SELECT 1
                FROM Users u
                JOIN sys.database_principals dp 
                    ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
                JOIN sys.database_role_members drm 
                    ON dp.principal_id = drm.member_principal_id
                JOIN sys.database_principals role_dp 
                    ON drm.role_principal_id = role_dp.principal_id
                WHERE u.UserId = @user_id
                AND role_dp.name IN ('db_owner', 'TrainingManager')
            )
        )
        BEGIN
            RAISERROR('Access denied. Only Training Managers or Admins can delete exams.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- ����� �������� ����� ����� ��� FK
        DELETE FROM StudentAnswer WHERE ExamId = @ExamId;
        DELETE FROM StudentExamResult WHERE ExamId = @ExamId;
        DELETE FROM ExamQuestion WHERE ExamId = @ExamId;
        DELETE FROM ExamStudent WHERE ExamId = @ExamId;
        DELETE FROM Exam WHERE ExamId = @ExamId;

        COMMIT TRANSACTION;

        PRINT 'Exam deleted successfully.';
    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
  --test The Code : 
GO
EXEC DeleteExam @ExamId = 6, @user_id = 15;