ALTER TABLE Question
ADD CONSTRAINT UQ_Question_QuestionText_QuestionType
UNIQUE (QuestionText, [Type]);
