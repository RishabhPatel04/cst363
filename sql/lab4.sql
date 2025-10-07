-- 1. Show the names of all players who played in 1997 whose  first name started with the letter 'X'. HINT: Use a join of the players and performances. Answer has 1 row.
SELECT DISTINCT p.first_name FROM players p
JOIN performances perf ON perf.player_id = perf.player_id
WHERE perf.year = 1997 AND p.first_name LIKE 'X%';

-- 2. Show all players who played for the Oakland Athletics in the year 1978. Sort the result by the player's last name. Answer has 46 rows.
select DISTINCT pl.id, pl.first_name, pl.last_name
from players pl
JOIN performances pr ON pr.player_id = pl.id
JOIN teams t ON t.id = pr.team_id
where 
	t.name = 'Oakland Athletics'
	AND pr.year = '1978'

ORDER BY pl.last_name ASC;	
-- 3. Show all players who were born in Panama and the year they played. Do a “natural join” on players and performances. Answer has 43 rows
select DISTINCT pl.id, pl.first_name, pl.last_name, pr.year
from players pl
JOIN performances pr ON pr.player_id = pl.id
where 
	pl.birth_city = 'Panama'
ORDER BY pl.last_name, pl.first_name, pr.year;	
-- 4. List the teams and the number of players for teams that have fewer than 40 players. Answer has 45 rows
SELECT t.name, count(pr.player_id) 
from teams t
LEFT JOIN performances pr ON t.id = pr.team_id
GROUP BY t.name
HAVING count(pr.player_id) < 40;
-- 5. Write a SQL query to find the name of the player who’s been paid the highest salary, of all time. Try using a subquery and then (separately) a join.
SELECT p.first_name, p.last_name
FROM salaries s
JOIN (
  SELECT MAX(salary) AS max_salary
  FROM salaries
) m ON s.salary = m.max_salary
JOIN players p ON p.id = s.player_id;
-- 6. Write a SQL query to find the 5 lowest paying teams (by average salary) in 1999. Round the average salary to 2 decimal places or nearest dollar.(Use LIMIT 5)
SELECT
  t.name AS team,
  ROUND(AVG(s.salary), 2) AS avg_salary_1999
FROM salaries s
JOIN teams t ON t.id = s.team_id
WHERE s.year = 1999
GROUP BY t.id, t.name
ORDER BY avg_salary_1999 ASC
LIMIT 5;

-- 7. Come up with some interesting queries of your own! Explain what you are trying to do and how the query works.
-- Explanation: compute each player’s salary change year-to-year and show the top increases.

--LAG(s.salary) = look at the previous row’s salary (based on ordering).
--PARTITION BY s.player_id = restart the numbering for each player.
--ORDER BY s.year = compare rows in chronological order.

WITH ranked AS (
  SELECT
    s.player_id,
    s.year,
    s.salary,
    LAG(s.salary) OVER (PARTITION BY s.player_id ORDER BY s.year) AS prev_salary
  FROM salaries s
),
--We subtract prev_salary from salary.
--WHERE r.prev_salary IS NOT NULL removes the first year (since no previous salary exists).
deltas AS (
  SELECT
    r.player_id,
    r.year,
    (r.salary - r.prev_salary) AS raise_amount
  FROM ranked r
  WHERE r.prev_salary IS NOT NULL
)
--Now you can show names instead of IDs.
--Sorting by raise_amount DESC means the biggest raises appear first.
--LIMIT 10 gives you the top 10 raises in the dataset.
SELECT p.first_name, p.last_name, d.year, d.raise_amount
FROM deltas d
JOIN players p ON p.id = d.player_id
ORDER BY d.raise_amount DESC
LIMIT 10;
