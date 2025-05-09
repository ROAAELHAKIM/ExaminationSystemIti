create or alter procedure CreateBranch
    @user_id int,
    @location nvarchar(50)
as
begin
    set nocount on;

    begin try
        -- تحقق من وجود الفرع بالفعل
        if exists (select 1 from Branch where Location = @location)
        begin
            raiserror('a branch with this location already exists!', 16, 1);
            return;
        end

        -- تحقق من أن المستخدم لديه دور training manager أو admin
IF EXISTS (
SELECT 1
FROM UserRoles ur
JOIN Roles r ON ur.RoleId = r.RoleId
JOIN Users u ON u.UserId = ur.UserId
WHERE ur.UserId = @user_id
AND r.RoleType IN ('TrainingManager', 'Admin')
)
AND EXISTS (
SELECT 1
FROM Users u
JOIN sys.database_principals dp ON (REPLACE(u.Name, ' ', '') + u.Phone) = dp.name
JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals role_dp ON drm.role_principal_id = role_dp.principal_id
WHERE u.UserId = @user_id
AND role_dp.name IN ('db_owner', 'TrainingManager')
)
        begin
            insert into Branch(Location)
            values (@location);

            print 'branch added successfully.';
        end
        else
        begin
            raiserror('access denied. only training managers or admins can add branches.', 16, 1);
        end

    end try
    begin catch
        print 'error occurred: ' + error_message();
    end catch
end


 EXEC CreateBranch @user_id = 15, @Location = N'Roaa';
 Go