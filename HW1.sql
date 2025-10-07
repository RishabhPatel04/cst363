-- Rishabh Patel
-- CST363-01-02-M_224
-- 17-09-2025

-- 1. Show the name and salary of all instructors sorted by instructor_name
select instructor_name, salary from instructor
order by instructor_name ASC;

-- 2. Show all columns for instructors in the 'Comp. Sci.' department in order by instructor_name.
-- Answer: has 3 rows for Brandt, Katz, Srinivasan
select * from instructor
where dept_name = 'Comp. Sci.'
order by instructor_name ASC;

-- 3. Show name, salary, department for instructors with salaries less than $50,000 in order by instructor_name.
-- Answer: 1 row for Mozart
SELECT instructor_name, dept_name, salary FROM instructor
where salary < 50000;

-- 4. Show the student name, major department and total credits for students with at least 98 credits. Sort the list by total credits (tot_cred).
-- Answer has 4 rows
SELECT student_name, dept_name, tot_cred FROM student
where tot_cred >= 98
order by tot_cred ASC;

-- 5. Show the student ID and name for students who are majoring in 'Elec. Eng.' or 'Comp. Sci.' and have at least 90 credits. Sort the list by student_id.
-- Answer has 2 rows for Zhang, Bourikas
SELECT student_id, student_name FROM student
where dept_name IN ('Elec. Eng.', 'Comp. Sci.') AND tot_cred >= 90
order by student_id ASC;

-- 6.Show the instructor_id, instructor_name and salary for all instructors. Order by salary from highest to lowest.
SELECT instructor_id, instructor_name, salary From instructor
order by salary DESC;

-- 7. Show all the student majors (the dept_name column in the student table) without duplicates. Label the dept_name column as 'major'. List the majors in alphabetical order.
-- Answer has 7 rows
SELECT DISTINCT dept_name AS major
FROM student
ORDER BY major;

-- 8. List the course_id and title for courses that have "System" or "Computer" in their title. Order the list by course_id.
-- Answer has 3 rows
select course_id, title from course
WHERE title LIKE '%System%' OR title LIKE '%Computer%'
order by course_id;

-- 9. List the instructor_id and name of instructors whose name start with the letter "S". Sort the list by name.
-- Answer has 2 rows
SELECT instructor_id, instructor_name FROM instructor
where instructor_name LIKE 'S%'
order by instructor_name ASC;

-- 10. (2 points) Return a list of all course ids and credits. Use CONCAT with an alias so there is a single column called course_credits that looks like:
-- course_credits BIO-399: 3 units Order the list by depart_name and credits (units).
SELECT CONCAT(course_id, ': ', credits, ' units') AS course_credits FROM course
ORDER BY dept_name, credits;


-- 11. Use the BETWEEN predicate to show the student_id and student_name of students who have total credits in the range 50 to 90 inclusive. The result should be sorted by student_id.
SELECT student_id, student_name FROM student
WHERE tot_cred BETWEEN 50 AND 90
ORDER BY student_id;

-- 12. List all the buildings used to teach classes from the sections table. Do not list duplicates. List the buildings alphabetically.
SELECT DISTINCT building FROM classroom
ORDER BY building;

-- 13. Show the instructor_id and the course_id taught by the instructor. If an instructor taught a course multiple times, don't list duplicates. Sort the results by instructor_id, then course_id.
SELECT DISTINCT instructor_id, course_id FROM teaches
GROUP BY instructor_id, course_id
ORDER BY instructor_id, course_id;

-- 14. (2 points) For each instructor show the instructor_id, instructor_name, monthly salary (salary divided by 12 rounded to integer) labeled as "monthly_salary". Order the result by monthly salary largest to smallest. Hint: use an alias for monthly salary
SELECT instructor_id, instructor_name, ROUND(salary / 12) AS monthly_salary FROM instructor
ORDER BY monthly_salary DESC;

-- 15. Use the section table to list all Computer Science courses taught in Spring 2009. List the course_id, section_id, building and room_number. Order the result by course_id then section_id.
SELECT course_id, section_id, building, room_number FROM section
WHERE semester = 'Spring' AND section_year = 2009 AND course_id LIKE 'CS%'
ORDER BY course_id, section_id;

-- 16. (2 points) Repeat 15, but only for upper division courses (CS class over 300). Use SUBSTRING and CAST, ex. CAST(expression AS INT)
SELECT course_id, section_id, building, room_number FROM section
WHERE course_id LIKE 'CS-%' AND CAST(SUBSTRING(course_id FROM 4) AS INT) > 300
ORDER BY course_id, section_id;

-- 17. Which students have a NULL value for grade? Return the student_id, course_id, section_year, semester in order by student_id;
SELECT student_id, course_id, section_year, semester FROM takes
WHERE grade IS NULL
ORDER BY student_id;