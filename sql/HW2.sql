--1. (2 pts) List the Comp. Sci. courses taught in Spring 2009. List the course_id, title, and section_id in order by section_id.
SELECT c.course_id, c.title, s.section_id
FROM course c
JOIN section s ON c.course_id = s.course_id
WHERE s.semester = 'Spring'
  AND s.section_year = 2009
  AND c.dept_name = 'Comp. Sci.'
ORDER BY s.section_id;
--2. (2 pts) For the spring 2009 semester, show the department name and number of students enrolled in courses from each department. Label the number of students as "enrollment". Order the result by department name.
SELECT
  c.dept_name,
  COUNT(DISTINCT t.student_id) AS enrollment
FROM course c
JOIN takes t ON t.course_id = c.course_id
WHERE t.semester = 'Spring'
  AND t.section_year = 2009
GROUP BY c.dept_name
ORDER BY c.dept_name;
--3. (2 pts) List all instructor's ID , name and department with the number of courses taught with the label "courses_taught". If an instructor did not teach, they are listed with a value of 0. Order by result by instructor_id.
--A correct result will have 3 instructors with 0 courses.
SELECT
  i.instructor_id,
  i.instructor_name,
  i.dept_name,
  COALESCE(COUNT(DISTINCT te.course_id), 0) AS courses_taught
FROM instructor i
LEFT JOIN teaches te ON te.instructor_id = i.instructor_id
GROUP BY i.instructor_id, i.instructor_name, i.dept_name
ORDER BY i.instructor_id;

--4. (2 pts) List the student majors (student.dept_name) and the number of students in each major with the label "students_in_major" in order by major.
SELECT
  s.dept_name AS major,
  COUNT(*)    AS students_in_major
FROM student s
GROUP BY s.dept_name
ORDER BY major;

--5. (2 pt) Same as #4 but only list majors with more than 2 students.
SELECT
  s.dept_name AS major,
  COUNT(*)    AS students_in_major
FROM student s
GROUP BY s.dept_name
HAVING COUNT(*) > 2
ORDER BY major;

--6. (2 pts) List all departments and the number of students majoring in that department (use label "students_in_major") and have more than 90 total credits. Order by department name. Answer: 7 department rows. History, Music and Physics departments have 0 students
SELECT
  d.dept_name,
  COUNT(s.student_id) AS students_in_major
FROM department d
LEFT JOIN student s
  ON s.dept_name = d.dept_name
 AND s.tot_cred  > 90
GROUP BY d.dept_name
ORDER BY d.dept_name;

--7. (3 pts) Show the instructor ID, name, course title and number of times taught. Order the result by id, then title. If an instructor has not taught any courses then list title as NULL and count as 0. Answer: Gold, Califeri and Singh have not taught courses.
--(Hint: You will need to use two LEFT JOINs here.)
SELECT
  i.instructor_id,
  i.instructor_name,
  c.title,
  COALESCE(COUNT(te.course_id), 0) AS times_taught
FROM instructor i
LEFT JOIN teaches te ON te.instructor_id = i.instructor_id
LEFT JOIN course  c  ON c.course_id      = te.course_id
GROUP BY i.instructor_id, i.instructor_name, c.title
ORDER BY i.instructor_id, c.title;
--8. (3 pts) List student id and name for students with more than 90 credits or have taken more than 2 courses. Order the result by student_id. Hint: Use UNION operator. Answer: 6 rows
-- > 90 credits
SELECT s.student_id, s.student_name
FROM student s
WHERE s.tot_cred > 90
UNION
-- > 2 courses taken (count rows in takes)
SELECT s.student_id, s.student_name
FROM student s
JOIN takes t ON t.student_id = s.student_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(*) > 2
ORDER BY student_id;
--9. (4 pts) Calculate the GPA for each student: Multiply the sum of numeric value of the grade times the course credits and divide by the sum of course credits for all courses taken. The numeric value of a grade can be found in the grade_points table. The course credit value is in the course table.
--Label the GPA column as GPA and round to two significant digits. To check your work: Zhang has a GPA 3.87, Snow has a NULL GPA (Hint: You will to need use 3 LEFT JOINs here.)
SELECT
  s.student_id,
  s.student_name,
  ROUND(
    SUM(g.points * c.credits) / NULLIF(SUM(c.credits), 0),
    2
  ) AS GPA
FROM student s
LEFT JOIN takes        t ON t.student_id = s.student_id
LEFT JOIN grade_points g ON g.grade      = t.grade
LEFT JOIN course       c ON c.course_id  = t.course_id
GROUP BY s.student_id, s.student_name
ORDER BY s.student_id;
--10. (3 pts) Find courses that have not been taken by any student. Return the course_id. Answer: BIO-399 has not been taken by any students.
SELECT c.course_id
FROM course c
LEFT JOIN takes t ON t.course_id = c.course_id
WHERE t.course_id IS NULL
ORDER BY c.course_id;
