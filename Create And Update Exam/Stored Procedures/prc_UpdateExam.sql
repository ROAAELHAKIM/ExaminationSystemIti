create or alter proc prc_UpdateExam
    @user_id int,
    @exam_id int,
    @new_start_time datetime2,
    @new_end_time datetime2,
    @new_type nvarchar(50)
as
begin
    set nocount on;

    -- Check application-level role
    if not exists (
        select 1
        from userroles ur
        join roles r on ur.roleid = r.roleid
        where ur.userid = @user_id
          and r.roletype in ('TrainingManager', 'Instructor', 'Admin')
    )
    begin
        raiserror('Access denied: user does not have required application role.', 16, 1);
        return;
    end

    -- Check database-level role
    if not exists (
        select 1
        from users u
        join sys.database_principals dp on (replace(u.name, ' ', '') + u.phone) = dp.name
        join sys.database_role_members drm on dp.principal_id = drm.member_principal_id
        join sys.database_principals role_dp on drm.role_principal_id = role_dp.principal_id
        where u.userid = @user_id
          and role_dp.name in ('db_owner', 'TrainingManager', 'Instructor')
    )
    begin
        raiserror('Access denied: user does not have required database role.', 16, 1);
        return;
    end

    -- Check exam existence
    if not exists (select 1 from exam where examid = @exam_id)
    begin
        raiserror('Exam not found.', 16, 1);
        return;
    end

    -- Validate type
    if @new_type not in ('exam', 'corrective')
    begin
        raiserror('Invalid exam type. Allowed values are: exam, corrective.', 16, 1);
        return;
    end

    -- Perform update
    update exam
    set starttime = @new_start_time,
        endtime = @new_end_time,
        type = @new_type
    where examid = @exam_id;

    print 'Exam schedule updated successfully.';
end


exec prc_UpdateExam
    @user_id = 114,
    @exam_id = 1,
    @new_start_time = '2025-05-03 09:00',
    @new_end_time = '2025-05-03 11:00',
    @new_type = 'corrective';

	go