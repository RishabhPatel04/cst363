-- What are the first names of all the patients in alphabetical order? Use ORDER BY column_name ASC -- here column_name is first_name

SELECT first_name FROM patient ORDER BY first_name ASC;

-- What are the first names of all the patients in order Z-A? Use DESC instead of ASC

SELECT first_name FROM patient ORDER BY first_name DESC;

-- What is the last name of patient 234?

SELECT last_name FROM patient WHERE patient_no = 234;

-- Which wards have patients with the last name 'Smith'?

SELECT ward FROM patient WHERE last_name = 'Smith';

-- What are all the attributes of patients in ward 6?

SELECT * FROM patient WHERE ward = 6;

-- What are the first and last names of patients with sex F in order by last name?

SELECT first_name, last_name FROM patient WHERE sex = 'F' ORDER BY last_name ASC;

-- What are the patient numbers between 200 and 300, inclusive? Use BETWEEN ... AND ...

SELECT patient_no FROM patient WHERE patient_no BETWEEN 200 AND 300;

-- What are the first and last names of patients in either ward 6 or ward 7? Use logical OR, or try out the IN operator:
-- value IN (value1, value2, value3, ...)
-- Return the list in alphabetical order by last name, first name:
-- ORDER BY col1 ASC, col2 ASC;

SELECT first_name, last_name FROM patient WHERE ward IN (6, 7) ORDER BY last_name ASC, first_name ASC;

-- What are the last names of patients that are either in ward 3 or are sex M?

SELECT last_name FROM patient WHERE ward = 3 OR sex = 'M';

