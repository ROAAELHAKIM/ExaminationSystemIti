	create or alter view vw_all_exam_result_for_student
as
select 
    ser.studentexamresultid,
    ser.examid,
    e.type as exam_type,
    e.examyear,
    e.starttime,
    e.endtime,
    e.totaldegree,
    ser.studentid,
    ser.totalscore,
    ser.percentage,
    ser.ispass,
    ser.grade
from studentexamresult ser
join exam e on ser.examid = e.examid
join student s on ser.studentid = s.userid;



	select * from vw_all_exam_result_for_student
where studentid = 7;
