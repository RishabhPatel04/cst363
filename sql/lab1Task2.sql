-- 1. Insert a new student with ID 12399, name "Fred Brooks", majoring in Comp. Sci., total credits 0.
INSERT INTO Student
(id, name, dept_name, tot_cred)
VALUES
(
'12399', 'Fred Brooks', 'Comp. Sci.', 0
)

-- 2. Change the tot_cred for student 12399 to 100 General syntax is:
update student 
set tot_cred = 100
where id = '12399'

-- 3. Give all instructors a 4% increase in salary. Here you can omit the WHERE clause. We will learn a "safer" way to do this using transactions.
update instructor 
set salary = (salary * 1.04)

-- 4. Give all instructors in the Physics department a $3,500 salary increase
update instructor 
set salary = (salary + 3500)
where dept_name = 'Physics'

-- 5. Try to delete the course 'PHY-101' General syntax is:
delete from course
where course_id = 'PHY-101'

ERROR:  update or delete on table "course" violates foreign key constraint "prereq2" on table "prereq"
Key (course_id)=(PHY-101) is still referenced from table "prereq". 

-- 6. Try to delete the course 'CS-315'
delete from course
where course_id = 'CS-315'

-- 7. Why does the delete in #5 fail while #6 works?
because #5 was trying to delete a record that was referenced by another table using a foreign key

-- 8. Student 12399 enrolls into section: course_id 'CS-101', section 1, semester 'Fall', year 2009, grade null
--Insert a row into the takes table for the enrollment.
insert into takes (
    id, course_id, sec_id, semester, year, grade
    
    ) values (
        '12399', 'CS-101', '1', 'Fall', 2009, NULL
        )

-- 9. Find all the rows in the takes table with a null grade. Use IS NULL. The answer should have 2 rows.
select * from takes
where grade is NULL

-- 10. Update the grade for student 12399 in 'CS-101' to 'A'.
update takes
set grade = 'A'
where id = '12399' AND course_id = 'CS-101'