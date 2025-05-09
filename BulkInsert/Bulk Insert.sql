-- Insert Data To Users Table By Bulk insert
BULK INSERT Users
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\UsersData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Department Table By Bulk insert
BULK INSERT Department
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\DepartmentData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Branch Table By Bulk insert
BULK INSERT Branch
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\BranchData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Instructor Table By Bulk insert
BULK INSERT Instructor
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\InstructorData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Student Table By Bulk insert
BULK INSERT Student
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\StudentData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Track Table By Bulk insert
BULK INSERT Track
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\TrackData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Intake Table By Bulk insert
BULK INSERT Intake
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\IntakeData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Course Table By Bulk insert
BULK INSERT Course
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\CourseData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To IntakeTrack Table By Bulk insert
BULK INSERT IntakeTrack
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\IntakeTrackData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Question Table By Bulk insert
BULK INSERT Question
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\QuestionData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To StudentAnswer Table By Bulk insert
BULK INSERT StudentAnswer
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\StudentAnswerData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To Exam Table By Bulk insert
BULK INSERT Exam
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ExamData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To ExamQuestion Table By Bulk insert
BULK INSERT ExamQuestion
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ExamQuestionData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To McqAnswer Table By Bulk insert
BULK INSERT McqAnswer
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\McqAnswerData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);
-- Insert Data To ExamStudent Table By Bulk insert
BULK INSERT ExamStudent
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ExamStudentData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
);

-- Insert Data To TrueAndFalseAnswer Table By Bulk insert 
BULK INSERT TrueAndFalseAnswer
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\TrueAndFalseAnswerData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
)

-- Insert Data To StudentResult Table By Bulk insert
BULK INSERT StudentExamResult
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\StudentExamResultData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
)
-- Insert Data To TextAnswer Table By Bulk insert
BULK INSERT TextAnswer
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\TextAnswerData.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    TABLOCK
)
---------TO KNOW SPECIFIC TABLE IN WHICH FILE GROUP----------
SELECT 
    t.name AS Users,
    fg.name AS FileGroup
FROM 
    sys.tables t
JOIN 
    sys.indexes i ON t.object_id = i.object_id AND i.index_id < 2
JOIN 
    sys.data_spaces ds ON i.data_space_id = ds.data_space_id
JOIN 
    sys.filegroups fg ON ds.data_space_id = fg.data_space_id;
---------TO RESET IDENTITY KEY IN SPECIFIC TABLE------------
--DBCC CHECKIDENT ('Users', RESEED, 0);
--DBCC CHECKIDENT ('Department', RESEED, 0);
--DBCC CHECKIDENT ('Branch', RESEED, 0);
--DBCC CHECKIDENT ('Student', RESEED, 0);
--DBCC CHECKIDENT ('StudentExamResult', RESEED, 0);
--DBCC CHECKIDENT ('StudentExamResult', RESEED, 0);

---------------------------------------------------------------------------------
CREATE LOGIN Joe WITH PASSWORD = 'Joe123456#'; 
use ITI_Examination_System_2025
CREATE USER Joe FOR LOGIN Joe;
ALTER ROLE db_owner ADD MEMBER Joe;
---------------------------------------------------------------------------------
go;