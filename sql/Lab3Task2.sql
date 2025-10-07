--1. what `workclass` values appear in the data?  (Don't show any duplicates.)
SELECT DISTINCT workclass FROM census;

--2. What is the average age of people in the data, rounded to one significant digit? (The answer should be 38.6)
SELECT ROUND(avg(age),1) FROM census;

--3. How many countries of birth appear in the data? (Your answer should be 42.)
SELECT COUNT(DISTINCT native_country) FROM census;

--4. Which native countries start with 'F'? (Answer:  France)
SELECT DISTINCT native_country From census
where native_country LIKE 'F%';

--5. Which native countries end with 'a'?
SELECT DISTINCT native_country From census
where native_country LIKE '%a';

--6. Which native countries do not have 'a' anywhere in their name?  Use the predicate `NOT LIKE`.  (Answer has 7 rows.)
SELECT DISTINCT native_country From census
where native_country NOT LIKE '%a%';

--7. What is the average age of people who have never worked, rounded to one significant digit? (Answer is 20.6) Hint: use predicate `workclass = 'Never_worked'`
SELECT ROUND(avg(age), 1) FROM census
where workclass = 'Never_worked';

--8.  What is the average age for each workclass? Answer has 9 rows. Use the name "average_age" for the averages.The first non-NA row is:workclass     average_age
--State_gov     39.4361
SELECT workclass, AVG(age) AS average_age
FROM census
GROUP BY workclass
ORDER BY workclass;

--9. What is the average age by workclass, listed in order of average age?
SELECT workclass, AVG(age) AS average_age
FROM census
GROUP BY workclass
ORDER BY average_age;

--10. What is the average of years-of-education by both workclass and sex?
SELECT workclass, sex, AVG(education_num) AS avg_education_years
FROM census
GROUP BY workclass, sex
ORDER BY workclass, sex;

--11. What is the average, maximum, and minimum number of years of education by workclass?
SELECT workclass,
       AVG(education_num) AS avg_years,
       MAX(education_num) AS max_years,
       MIN(education_num) AS min_years
FROM census
GROUP BY workclass
ORDER BY workclass;

--12. change "NA" values of the attribute 'workclass' to NULL values, as follows: UPDATE census SET workclass = NULL WHERE workclass = 'NA';1836 rows should be changed.
UPDATE census
SET workclass = NULL
WHERE workclass = 'NA';

--13. Write an SQL query to count the number of rows in the census table. (Answer: 32,561 rows)
SELECT COUNT(*) FROM census;

--14. Write an SQL query to count the number of 'workclass' values. (Answer: 30,725)
SELECT COUNT(workclass) FROM census;

--15. What is the difference between the two count values you just found?
-- The difference I saw was that #13 was counting by total rows within the whole table
-- and #14 was reading all the rows within its called column while excluding all the NULL values.

--16. Write an SQL query to count the number of rows in which workclass is `NULL`. (Answer:  1,836)
SELECT COUNT(*) FROM census WHERE workclass IS NULL;
