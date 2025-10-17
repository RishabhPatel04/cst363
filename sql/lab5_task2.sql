--1. Find the most recent season (year) of the data.
SELECT MAX(year) AS most_recent_season
FROM performances;

-- 2. Find all players who hit exactly 17 home runs (HR) in the 1993 season.
-- Include their full name, the team they played for, and the number of runs batted in (RBI).
-- Order by RBIs (high to low). Answer has 7 rows.
SELECT 
  p.first_name || ' ' || p.last_name AS player_name,
  t.name AS team_name,
  pr.RBI
FROM performances pr
JOIN players p ON p.id = pr.player_id
JOIN teams t ON t.id = pr.team_id
WHERE pr.year = 1993
  AND pr.HR = 17
ORDER BY pr.RBI DESC;

--3. Use a scalar subquery to find players born in the most recent birth year.
SELECT 
  p.id,
  p.first_name,
  p.last_name,
  p.birth_year
FROM players p
WHERE p.birth_year = (
  SELECT MAX(birth_year) FROM players
);

-- 4. Find the year in which a player played the most games (G) across all records.
-- Note: If multiple rows tie for max G, this returns one arbitrarily due to LIMIT 1.
SELECT year
FROM performances
ORDER BY G DESC
LIMIT 1;

--  5. What is the name of the player from the previous question (most games played)?
SELECT 
  p.first_name,
  p.last_name,
  pr.year,
  pr.G
FROM performances pr
JOIN players p ON p.id = pr.player_id
ORDER BY pr.G DESC
LIMIT 1;

-- 6. Retrieve team names where at least one player had more than 100 stolen bases (SB) in a season.
SELECT DISTINCT t.name AS team_name
FROM teams t
JOIN performances pr ON pr.team_id = t.id
WHERE pr.SB > 100
ORDER BY team_name;

-- 7. Create a CTE that lists total hits per player per year. Then use the CTE in the main
-- query to retrieve the player names. Order by year (ascending) and total hits (descending).
WITH hits_cte AS (
  SELECT 
    pr.player_id,
    pr.year,
    SUM(pr.H) AS total_hits
  FROM performances pr
  GROUP BY pr.player_id, pr.year
)
SELECT 
  c.year,
  c.total_hits,
  p.first_name || ' ' || p.last_name AS player_name
FROM hits_cte c
JOIN players p ON p.id = c.player_id
ORDER BY c.year ASC, c.total_hits DESC;
