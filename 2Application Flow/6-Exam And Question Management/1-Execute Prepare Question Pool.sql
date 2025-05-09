EXEC prc_CreateTextAnswerQuestion
    @UserId = 128,
    @CourseId = 6,
    @QuestionText = N'Paris is the capital of France.',
    @StandardAnswer = N'Paris',  
    @AcceptedAnswerRegex = N'Paris|paris', 
    @DifficultyLevel = 'Easy';

EXEC prc_CreateMCQQuestion
    @UserId = 128,
    @CourseId = 6,
    @QuestionText = N'What is the capital of France?',
    @A = N'Paris',
    @B = N'London',
    @C = N'Madrid',
    @D = N'Berlin',
    @IsTrue = 'A',
    @DifficultyLevel = 'Easy';

EXEC prc_CreateTrueAndFalseQuestion
    @UserId = 128,
    @CourseId = 6,
    @QuestionText = N'London is the capital of France.',
    @IsTrue = 'false',
    @DifficultyLevel = 'Easy';

--Get All Questions For A Specific Course After Insertion
SELECT * FROM fn_GetQuestionsByCourse(6); 


