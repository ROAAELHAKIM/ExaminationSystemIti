CREATE OR ALTER PROCEDURE prc_CreateExamForCourse
    @UserId INT,
    @CourseId INT,
    @TotalTime INT,
    @Allowance INT,
    @TotalDegree INT,
    @ExamYear INT,
    @StartTime DATETIME2,
    @EndTime DATETIME2,
    @Type NVARCHAR(50),
    @NewExamId INT OUTPUT
AS
BEGIN
    BEGIN TRY

        IF EXISTS (
            SELECT 1
            FROM UserRoles ur
            JOIN Roles r ON ur.RoleId = r.RoleId
            JOIN Users u ON u.UserId = ur.UserId
            WHERE ur.UserId = @UserId
              AND r.RoleType IN ('Instructor', 'Admin')
        )  
        AND EXISTS (
            SELECT 1
            FROM Users u
            JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
            JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
            JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
            WHERE u.UserId = @UserId
              AND role_dp.name IN ('db_owner', 'Instructor')
        )
        BEGIN
            INSERT INTO Exam (CourseId, TotalTime, Allowance, TotalDegree, ExamYear, StartTime, EndTime, Type)
            VALUES (@CourseId, @TotalTime, @Allowance, @TotalDegree, @ExamYear, @StartTime, @EndTime, @Type);

            SET @NewExamId = SCOPE_IDENTITY();
            PRINT 'Exam created successfully.';
        END
        ELSE
        BEGIN
            RAISERROR('Access denied. Only Instructors can create exams.', 16, 1);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred';
        PRINT ERROR_MESSAGE();
        PRINT ERROR_NUMBER();
        PRINT ERROR_LINE();
    END CATCH
END
GO

------------------------------------------
GO
DECLARE @NewExamId INT;

EXEC prc_CreateExamForCourse
    @UserId = 128,
    @CourseId = 1,
    @TotalTime = 90,
    @Allowance = 10,
    @TotalDegree = 10,
    @ExamYear = 2025,
    @StartTime = '2025-06-01 10:00:00',
    @EndTime = '2025-06-01 11:30:00',
    @Type = 'exam',
    @NewExamId = @NewExamId OUTPUT;

PRINT 'New Exam ID: ' + CAST(@NewExamId AS NVARCHAR);
----------------
GO
DECLARE @NewExamId INT;
EXEC prc_CreateExamForCourse
    @UserId = 15,
    @CourseId = 7,
    @TotalTime = 2,
    @Allowance = 1,
    @TotalDegree = 10,
    @ExamYear = 2025,
    @StartTime = '2025-05-05 10:00:00',
    @EndTime = '2025-05-05 11:00:00',
    @Type = 'exam',
   @NewExamId = @NewExamId OUTPUT;

SELECT @NewExamId AS CreatedExamId
