select * from department
select * from course
select * from track
select * from Intake
EXEC prc_AddDepartment @UserId = 128,@DepartmentName = N'IT';

EXEC prc_Delete_Department @user_id = 128,@department_id = 4;

EXEC prc_UpdateDepartment @DepartmentId = 5,@NewDepartmentName = 'Artificial Intelligence';

EXEC prc_AddTrack @UserId = 128, @TrackName = 'Full Stack Development',  @DepartmentId = 2;

EXEC prc_UpdateTrack @UserId = 128, @TrackId = 2,@NewDepartmentId = 11, @NewTrackName = 'AI Track';

EXEC prc_DeleteTrack @user_id = 128, @track_id = 19;

EXEC prc_AddCourse
    @UserId = 114,
    @CourseName = 'Advanced Databases',
    @Description = 'An in-depth course on relational and NoSQL databases.',
    @MinDegree = 50,
    @MaxDegree = 100,
	@TrackId = 2;

EXEC prc_UpdateCourse
@UserId = 121,
@CourseId = 3,
@TrackId = 3,
@CourseName = N'Advanced SQL',
@CourseDescription = N'Deep dive into SQL Server features.',
@MinDegree = 50,
@MaxDegree = 100;


EXEC prc_delete_course @user_id = 114, @course_id = 6;


--================================================================
select * from vw_DisplayAllDepartment

select * from vw_DisplayAllBranch

Select * from func_DisplayAllIntakeForSpecificBranch 1

select * from func_DisplayAllTrackForSpecificDepartment 1
--=================================================================

EXEC prc_AssignTrackToIntake 1,2

--===========================================================
