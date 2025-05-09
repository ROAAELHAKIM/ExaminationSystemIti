--Register
EXEC CreateAdminAccount 
	@UserId = 128,
    @Name = N'JOENaguib', 
    @UserPassword = 'Youssef2014#', 
    @Gender = N'male', 
    @Email = 'mohsenyoussef234@gmail.com', 
    @Phone = '01001311690';

EXEC CreateBranchManagerAccount 
	@UserId = 128,
    @Name = N'Branch Manager Joe',
    @UserPassword = 'Youssef2014#',
    @Gender = N'Male',
    @Email = 'mohsenyoussef235@gmail.com',
    @Phone = '01001311692',
    @BranchId = 1;

EXEC CreateInstructorAccount
	@UserId = 128,
    @Name = N'Prof Joe 3',
    @UserPassword = N'Youssef2014#',
    @Gender = N'Male',
    @Email = N'mohsenyoussef2387@gmail.com',
    @Phone = '01111311693',
    @HireDate = '2020-09-01',
    @InstructorRank = N'Assistant Professor',
    @Salary = 12000.50,
    @Experience = 5,
    @IsDepartmentManager = 1,
    @DepartmentId = 2,  
    @BranchId = 1;      

	EXEC CreateStudentAccount
	@UserId = 128,
    @Name = N'Youssef Mohsen 3',
    @UserPassword = N'Youssef2014#',
    @Gender = N'Male',
    @Email = N'mohsenyoussef23769@gmail.com',
    @Phone = '01001311699',
    @GPA = 2.8,
    @College_Degree = N'Bachelor of Computer Science',
    @IntakeId = 1,     
    @TrackId = 1,       
    @BranchId = 1;     

EXEC CreateTrainingManagerAccount 
	@UserId = 128,
    @Name = N'JOE', 
    @UserPassword = 'Youssef2014#', 
    @Gender = N'male', 
    @Email = 'mohsenyoussef23988@gmail.com', 
    @Phone = '01001311696';

--Login
SELECT dbo.CheckLogin(N'mohsenyoussef233@gmail.com', N'Youssef2014#')