create or alter view vw_studentexamresults
as
select 
    ser.studentexamresultid,
    ser.examid,
    ser.studentid,
    u.name as studentname,
    ser.totalmarks,
    ser.totalscore,
    ser.percentage,
    ser.ispass,
    ser.grade
from StudentExamResult ser
join Exam e on ser.examid = e.examid
join Student s on ser.studentid = s.userid
join Users u on s.userid = u.userid;
go

SELECT *FROM vw_StudentExamResults WHERE ExamId = 1;  