CREATE NONCLUSTERED INDEX IX_Exam_CourseId
ON Exam (CourseId)
INCLUDE (ExamId, ExamYear, StartTime);

CREATE NONCLUSTERED INDEX IX_UserRoles_UserId_RoleId
ON UserRoles (UserId, RoleId);

CREATE NONCLUSTERED INDEX IX_ExamStudent_ExamId
ON ExamStudent (ExamId);

CREATE NONCLUSTERED INDEX IX_CourseInstructor_CourseId_InstructorId
ON CourseInstructor (CourseId, InstructorId);

CREATE NONCLUSTERED INDEX IX_Instructor_MainIndex
ON Instructor(UserId, DepartmentId, BranchId);

CREATE NONCLUSTERED INDEX IX_Student_TrackId_Covering
ON Student(TrackId)
INCLUDE (UserId, GPA, College_Degree, BranchId, IntakeId);

CREATE NONCLUSTERED INDEX IX_Question_CourseId
ON Question(CourseId);

CREATE NONCLUSTERED INDEX IX_ExamQuestion_ExamId
ON ExamQuestion(ExamId)
INCLUDE (QuestionId, QuestionOrder);

CREATE NONCLUSTERED INDEX IX_Intake_BranchId
ON Intake(BranchId)
INCLUDE (IntakeId, StartDate, EndDate, IntervalInMonths, IntakeYear);

CREATE NONCLUSTERED INDEX IX_Track_DepartmentId
ON Track(DepartmentId)
INCLUDE (TrackId, Name);