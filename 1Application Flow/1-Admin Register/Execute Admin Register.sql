--Register
EXEC CreateAdminAccount 
	@UserId = 128,
    @Name = N'JOE', 
    @UserPassword = 'Youssef2014#', 
    @Gender = N'male', 
    @Email = 'mohsenyoussef2363@gmail.com', 
    @Phone = '01001318691';

EXEC CreateBranchManagerAccount 
	@UserId = 114,
    @Name = N'BranchManagerJoe',
    @UserPassword = 'StrongPass#123',
    @Gender = N'Male',
    @Email = 'joebranchmanager@example.com',
    @Phone = '01052345699',
    @BranchId = 1;

EXEC CreateInstructorAccount
	@UserId = 114,
    @Name = N'Doctor Joe',
    @UserPassword = N'DrJoe@123',
    @Gender = N'Male',
    @Email = N'joe@prof.com',
    @Phone = '01001234567',
    @HireDate = '2020-09-01',
    @InstructorRank = N'Assistant Professor',
    @Salary = 12000.50,
    @Experience = 5,
    @IsDepartmentManager = 1,
    @DepartmentId = 2,  
    @BranchId = 1;      

	EXEC CreateStudentAccount
	@UserId = 114,
    @Name = N'Youssef Mohsen',
    @UserPassword = N'Joe1234@@',
    @Gender = N'Male',
    @Email = N'mohsenyoussef235@gmail.com',
    @Phone = '01200297645',
    @GPA = 2.8,
    @College_Degree = N'Bachelor of Computer Science',
    @IntakeId = 1,     
    @TrackId = 1,       
    @BranchId = 1;     

EXEC CreateTrainingManagerAccount 
	@UserId = 114,
    @Name = N'JOE', 
    @UserPassword = 'Youssef2014#', 
    @Gender = N'male', 
    @Email = 'mohsenyoussef239@g3mail.com', 
    @Phone = '01061311091';

--Login
SELECT dbo.CheckLogin(N'mohsenyoussef233@gmail.com', N'Youssef2014#')