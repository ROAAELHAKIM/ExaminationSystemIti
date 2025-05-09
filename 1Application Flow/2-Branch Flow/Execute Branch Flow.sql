 EXEC AddBranch @user_id = 128, @Location = N'Cairo';
 EXEC EditBranch @userId = 128, @BranchId = 3, @NewLocation = N'Minya';
 EXEC delete_branch  @user_id = 128,@branch_id = 11

 EXEC prc_AddIntake @UserId = 128                 ,
 @BranchID = 1,
 @IntakeID = 101,
 @SDate = '2025-01-01',
 @EDate = '2025-06-01',
 @IntakeY = 2025;

 EXEC prc_UpdateIntake
    @OldBranchId = 1,
    @OldIntakeId = 101,
    @NewBranchId = 2,
    @NewIntakeId = 102,
    @StartDate = '2025-05-01',
    @EndDate = '2025-10-01',
    @IntakeYear = 2025;

select * from intake;
select * from branch;

EXEC prc_DeleteIntake @user_id = 128, @branch_id = 7, @intake_id = 10;

