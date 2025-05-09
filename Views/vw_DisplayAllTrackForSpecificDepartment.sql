CREATE FUNCTION func_display_all_track_for_specific_department
(
    @department_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        trackid,
        name
    FROM track
    WHERE departmentid = @department_id
);


SELECT * FROM func_display_all_track_for_specific_department(1);

