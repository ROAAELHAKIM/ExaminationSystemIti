CREATE DATABASE ITI_Examination_System_2025
on Primary
(
	name='ITIDefault',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SQL Project\ITIExaminationSystem.mdf',
	size=10MB
),
filegroup Users
(
	name='ITIUsers',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ITIUsers.ndf',
	size=4MB,
	FILEGROWTH =2MB,
	MaxSize=100MB
),
filegroup CourseDetails
(
	name='ITICourseDetails',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ITICourseDetails.ndf',
	size=4MB,
	FILEGROWTH =2MB,
	MaxSize=100MB
),
filegroup Structure
(
	name='ITIStructure',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ITIStructure.ndf',
	size=4MB,
	FILEGROWTH =2MB,
	MaxSize=100MB
),
filegroup ExamDetails
(
	name='ITIExamDetails',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ITIExamDetails.ndf',
	size=4MB,
	FILEGROWTH =2MB,
	MaxSize=100MB
)
Log on
(
	name='ITILog',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ITIExaminationSystem.ldf',
	size=16MB
)
USE ITI_Examination_System_2025;
GO

CREATE TABLE Users(
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    UserPassword NVARCHAR(50) NOT NULL CHECK (LEN(UserPassword) >= 8),
    Gender NVARCHAR(60) NOT NULL CHECK (Gender IN ('Male','Female')),
    Email NVARCHAR(60) NOT NULL UNIQUE,
    Phone  VARCHAR(11) NOT NULL UNIQUE
)on Users;
ALTER TABLE Users
ADD CONSTRAINT CK_Users_Phone_Valid
CHECK (
    LEN(Phone) = 11 AND
    Phone LIKE '01%' AND
    Phone NOT LIKE '%[^0-9]%' -- يتأكد إن كله أرقام فقط
);
GO
CREATE TABLE Roles (
	 RoleId INT PRIMARY KEY IDENTITY(1,1),
	 RoleType NVARCHAR(20) NOT NULL UNIQUE
)on Users;
GO
CREATE TABLE UserRoles (
	UserId INT,
	RoleId INT
	PRIMARY KEY (UserId, RoleId)
	--Many Users Can Have More Than One Role
	FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId) 
)on Users;
GO
CREATE TABLE Branch(
	 BranchId INT PRIMARY KEY IDENTITY(1,1),
	 Location NVARCHAR(50) NOT NULL UNIQUE,
)on Structure;                  
GO 
CREATE TABLE BranchManager (
	UserId INT PRIMARY KEY,
	BranchId INT UNIQUE,  -- لضمان أن كل فرع له مدير واحد فقط
	FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (BranchId) REFERENCES Branch(BranchId)
)on Users;
GO
CREATE TABLE Department(
	DepartmentId INT PRIMARY KEY IDENTITY(1,1),
	DepartmentName NVARCHAR(50),
)on Structure;
GO
CREATE TABLE Instructor
(
	UserId INT primary key ,
	HireDate DATE,
	InstructorRank NVARCHAR(30),
	Salary DECIMAL,
	Experience INT,
	IsDepartmentManager BIT DEFAULT 0, 
	DepartmentId INT,
	BranchId INT,
	--Instrucotr Is A User
	FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE ON UPDATE CASCADE,
	-- Many Instructors Belong To One Department
	FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId), 
	-- many instructor belong to one Department 
	FOREIGN KEY (BranchId) REFERENCES Branch(BranchId) 

)on Users;

GO
CREATE TABLE Intake(	
    BranchId INT,
	IntakeId INT,
	StartDate DATETIME2,
	EndDate DATETIME2,
	IntervalInMonths AS DATEDIFF(MONTH, StartDate, EndDate),
	IntakeYear INT  

	-- specific primary key (BranchId,IntakeId)
	primary key (BranchId ,IntakeId),
	--One Branch Has More Than One Intake
	FOREIGN KEY (BranchId) REFERENCES Branch(BranchId) ON DELETE CASCADE
)on Structure;
GO
CREATE TABLE Track(
	TrackId INT PRIMARY KEY IDENTITY(1,1),
	Name NVARCHAR(50),
	DepartmentId INT NOT NULL,
	--Department Can Have More Than One Track
	FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
)on Structure;
GO
CREATE TABLE IntakeTrack
(
	TrackId INT NOT NULL,
	BranchId int not null, 
	IntakeId INT NOT NULL,

	primary key (TrackId ,BranchId,IntakeId),
	foreign key (TrackId) references Track(TrackId),
	foreign key (BranchId,IntakeId) references Intake(BranchId ,IntakeId)
	
)on Structure;
go
CREATE TABLE Student(
	UserId INT primary key,
	GPA FLOAT,
	College_Degree NVARCHAR(50),
	BranchId INT,
	IntakeId INT NOT NULL,
	TrackId INT NOT NULL

	--Student Is A User
	FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE ON UPDATE CASCADE,
	--Student Has Only One Track
	foreign key (TrackId) references Track(TrackId),
	--Student Has Only One Branchid and Intake Id

	foreign key (BranchId,IntakeId) references Intake(BranchId ,IntakeId)


)on Users;
GO
CREATE TABLE Course
(
	CourseId INT PRIMARY KEY IDENTITY(1,1),
	CourseName NVARCHAR(50),
	CourseDescription NVARCHAR(200),
	MinDegree INT,
	MaxDegree INT,
	TrackId INT
    foreign key (TrackId) references  Track(TrackId)

)on CourseDetails;
GO
CREATE TABLE CourseInstructor
(
	CourseId INT,
	InstructorId INT
	--Many Courses Are Taught By Many Instructors
	primary key (CourseId,InstructorId),
	FOREIGN KEY (CourseId) REFERENCES Course(CourseId),
	FOREIGN KEY (InstructorId) REFERENCES Instructor(UserId),
)on CourseDetails;
Go
CREATE TABLE Question (
    QuestionId INT PRIMARY KEY IDENTITY(1,1),
    QuestionText NVARCHAR(2000) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    DifficultyLevel NVARCHAR(10) NOT NULL,
    CourseId INT,
    DefaultMark INT, 

    CONSTRAINT FK_Question_Course FOREIGN KEY (CourseId) REFERENCES Course(CourseId),
    CONSTRAINT CHK_QuestionType CHECK (Type IN ('Text', 'MCQ', 'TrueFalse')),
    CONSTRAINT CHK_DifficultyLevel CHECK (DifficultyLevel IN ('easy', 'medium', 'hard'))
)on ExamDetails;

create table McqAnswer(
   AnswerId int primary key identity(1,1),
   QuestionId int not null ,
   AnswerText nvarchar(2000) not null ,
   IsTrue bit not null 

   foreign key (QuestionId) references Question(QuestionId),

)on ExamDetails;
go
create table TrueAndFalseAnswer(
	  QuestionId int primary key ,
	  IsTrue bit not null, 

foreign key (QuestionId) references Question(QuestionId),

)on ExamDetails;
go
create table TextAnswer(
   QuestionId int  primary key ,
   StandardAnswer  NVARCHAR(Max) NOT NULL,
   AcceptedAnswerRegex NVARCHAR(2000) NOT NULL,


foreign key (QuestionId) references Question(QuestionId),
)on ExamDetails;
go
CREATE TABLE Exam (
    ExamId INT PRIMARY KEY IDENTITY(1,1),
    CourseId INT NOT NULL,
    TotalTime INT NOT NULL,  
    Allowance INT NOT NULL,  
    TotalDegree INT NOT NULL, 
    ExamYear INT NOT NULL,   
    StartTime DATETIME2 NOT NULL, 
    EndTime DATETIME2 NOT NULL,   
    Type NVARCHAR(50) NOT NULL,  

    FOREIGN KEY (CourseId) REFERENCES Course(CourseId),  
    CONSTRAINT CHK_ExamType CHECK (Type IN ('exam', 'corrective'))
	)on ExamDetails;  
go
CREATE TABLE ExamQuestion (
    ExamId INT,
    QuestionId INT,
    QuestionMark INT NOT NULL,  
    QuestionOrder INT NOT NULL, 
    
    PRIMARY KEY (ExamId, QuestionId),
    
    FOREIGN KEY (ExamId) REFERENCES Exam(ExamId),
    FOREIGN KEY (QuestionId) REFERENCES Question(QuestionId)
)on ExamDetails;

go
CREATE TABLE ExamStudent (
    ExamId INT,
    StudentId INT,
    
    PRIMARY KEY (ExamId, StudentId),
    
    FOREIGN KEY (ExamId) REFERENCES Exam(ExamId),
    FOREIGN KEY (StudentId) REFERENCES Student(UserId)
)on ExamDetails;

CREATE TABLE StudentAnswer (
    StudentAnswerId INT PRIMARY KEY IDENTITY(1,1),  
    ExamId INT NOT NULL,                               
    StudentId INT NOT NULL,                          
    QuestionId INT NOT NULL,                          
    StudentAnswerText NVARCHAR(MAX),       
    StudentTrueAndFalseAnswer BIT,  -- Assuming the answer is a boolean (true/false)
    RgxResult BIT,                                  
    IsCorrect BIT,                                     
    Mark INT,                                          -- الدرجة التي حصل عليها الطالب
    FOREIGN KEY (ExamId, StudentId) REFERENCES ExamStudent(ExamId, StudentId),  -- ربط بالامتحان
    FOREIGN KEY (QuestionId) REFERENCES Question(QuestionId),  -- ربط السؤال
    FOREIGN KEY (ExamId, QuestionId) REFERENCES ExamQuestion(ExamId, QuestionId)  -- ربط بالجدول ExamQuestion
)on ExamDetails;
go
CREATE TABLE StudentExamResult (
    StudentExamResultId INT PRIMARY KEY IDENTITY(1,1),  
    ExamId INT NOT NULL,                               
    StudentId INT NOT NULL,                         
    TotalMarks INT NOT NULL,  -- الدرجة الكاملة للامتحان
    TotalScore INT NOT NULL,  -- الدرجة التي حصل عليها الطالب
    Percentage DECIMAL(5, 2) NOT NULL,  -- النسبة المئوية من الدرجة الكاملة
    IsPass BIT NOT NULL,  -- حالة إذا كان الطالب اجتاز الامتحان أم لا
    Grade CHAR(1) NOT NULL,  -- التقدير النهائي (A, B, C, D, F)
    FOREIGN KEY (ExamId) REFERENCES Exam(ExamId),  -- ربط بالامتحان
    FOREIGN KEY (StudentId) REFERENCES Student(UserId), -- ربط بالطالب
    CONSTRAINT CHK_Grade CHECK (Grade IN ('A', 'B', 'C', 'D', 'F'))  -- التحقق من التقدير
)on ExamDetails;
go

CREATE ROLE Student;
CREATE ROLE Instructor;
CREATE ROLE BRANCHMANAGER;
CREATE ROLE TRAININGMANAGER;

--Adding Main Roles







-- رول كل اكونت
  SELECT 
    members.name AS UserName,
    roles.name AS RoleName
FROM 
    sys.database_role_members drm
JOIN 
    sys.database_principals roles ON drm.role_principal_id = roles.principal_id
JOIN 
    sys.database_principals members ON drm.member_principal_id = members.principal_id
WHERE 
    roles.name = 'Student';
