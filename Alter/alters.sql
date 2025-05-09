ALTER TABLE Course ALTER COLUMN TrackId INT NOT NULL

ALTER TABLE dbo.StudentExamResult
add StudentName nvarchar(255);

ALTER TABLE dbo.StudentExamResult
DROP COLUMN TotalMarks;


ALTER TABLE StudentAnswer
DROP COLUMN [StudentTrueAndFalseAnswer];


ALTER TABLE ExamQuestion
 add InstructorMark int NULL;


ALTER TABLE ExamQuestion
ALTER COLUMN QuestionOrder INT NULL;


ALTER TABLE ExamQuestion
ALTER COLUMN QuestionMark INT NULL;

ALTER TABLE ExamQuestion
ALTER COLUMN QuestionOrder INT NULL

ALTER TABLE ExamQuestion
ALTER COLUMN QuestionOrder INT NULL

ALTER TABLE ExamQuestion
DROP COLUMN QuestionMark


ALTER TABLE ExamQuestion
DROP CONSTRAINT FK_ExamQuestion_Question;
ALTER TABLE ExamQuestion
DROP CONSTRAINT FK_ExamQuestion_Exam;
