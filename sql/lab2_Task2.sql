-- Foreign Key Constraints Lab: CASCADE vs SET NULL
-- Database: wager_db
-- Solution by: Student

-- Connect to the wager_db database
\c wager_db

-- ==========================================
-- PART 1: ON DELETE CASCADE
-- ==========================================

-- Clean up any existing tables
DROP TABLE IF EXISTS bet_details, bet, game;

-- Create tables with ON DELETE CASCADE
CREATE TABLE game (
    game_id INT PRIMARY KEY,
    game_name VARCHAR(50)
);

CREATE TABLE bet (
    bet_id INT PRIMARY KEY,
    game_id INT REFERENCES game(game_id) ON DELETE CASCADE,
    bettor_name VARCHAR(50)
);

CREATE TABLE bet_details (
    detail_id INT PRIMARY KEY,
    bet_id INT REFERENCES bet(bet_id) ON DELETE CASCADE,
    stake_amount NUMERIC(10, 2),
    odds INTEGER
);

-- Insert initial test data
INSERT INTO game (game_id, game_name) VALUES (1001, 'AT&T Pebble Beach Pro-Am');
INSERT INTO bet (bet_id, game_id, bettor_name) VALUES (2001, 1001, 'Jett');
INSERT INTO bet (bet_id, game_id, bettor_name) VALUES (2002, 1001, 'Kai');
INSERT INTO bet_details (detail_id, bet_id, stake_amount, odds) VALUES (3001, 2001, 100.00, 150);
INSERT INTO bet_details (detail_id, bet_id, stake_amount, odds) VALUES (3002, 2002, 150.00, -125);

-- Show initial state
SELECT 'Initial state - Game table:' as status;
SELECT * FROM game;
SELECT 'Initial state - Bet table:' as status;
SELECT * FROM bet;
SELECT 'Initial state - Bet Details table:' as status;
SELECT * FROM bet_details;

-- TODO 1: Insert another game into the game table and create a bet on it
INSERT INTO game (game_id, game_name) VALUES (1003, 'Masters Tournament');
INSERT INTO bet (bet_id, game_id, bettor_name) VALUES (2005, 1003, 'Alex');
INSERT INTO bet (bet_id, game_id, bettor_name) VALUES (2006, 1003, 'Sam');
INSERT INTO bet_details (detail_id, bet_id, stake_amount, odds) VALUES (3005, 2005, 200.00, 300);
INSERT INTO bet_details (detail_id, bet_id, stake_amount, odds) VALUES (3006, 2006, 75.00, -150);

-- Show state after TODO 1
SELECT 'After TODO 1 - Game table:' as status;
SELECT * FROM game;
SELECT 'After TODO 1 - Bet table:' as status;
SELECT * FROM bet;
SELECT 'After TODO 1 - Bet Details table:' as status;
SELECT * FROM bet_details;

-- TODO 2: Delete the 'AT&T Pebble Beach Pro-Am'
DELETE FROM game WHERE game_name = 'AT&T Pebble Beach Pro-Am';

-- TODO 3: Before checking, what do you expect to happen to the bet and bet_details tables?
-- PREDICTION: Due to ON DELETE CASCADE constraints:
-- 1. When we delete the game 'AT&T Pebble Beach Pro-Am' (game_id = 1001), 
--    all bets referencing this game_id will be automatically deleted from the bet table.
-- 2. When those bets (bet_id 2001 and 2002) are deleted, all their corresponding 
--    bet_details records will also be automatically deleted due to CASCADE.
-- 3. We expect to see only the 'Masters Tournament' game and its associated bets remaining.
-- 4. The remaining records should be: game_id 1003, bet_ids 2005 and 2006, detail_ids 3005 and 3006.

-- TODO 4: Check the state of the tables to test your answer from 3
SELECT 'After DELETE CASCADE - Game table:' as status;
SELECT * FROM game;
SELECT 'After DELETE CASCADE - Bet table:' as status;
SELECT * FROM bet;
SELECT 'After DELETE CASCADE - Bet Details table:' as status;
SELECT * FROM bet_details;

-- Analysis of CASCADE results:
-- The CASCADE behavior worked as expected! When we deleted the 'AT&T Pebble Beach Pro-Am' game:
-- 1. The two bets (Jett's and Kai's) were automatically deleted from the bet table
-- 2. Their corresponding bet_details records were also automatically deleted
-- 3. Only the 'Masters Tournament' data remains in all tables
-- This demonstrates the power of ON DELETE CASCADE for maintaining referential integrity

-- ==========================================
-- PART 2: ON DELETE SET NULL
-- ==========================================

-- Delete the tables for a fresh start
DROP TABLE IF EXISTS bet_details, bet, game;

-- Create tables with ON DELETE SET NULL for game reference
CREATE TABLE game (
    game_id INT PRIMARY KEY,
    game_name VARCHAR(50)
);

CREATE TABLE bet (
    bet_id INT PRIMARY KEY,
    game_id INT REFERENCES game(game_id) ON DELETE SET NULL,
    bettor_name VARCHAR(50)
);

CREATE TABLE bet_details (
    detail_id INT PRIMARY KEY,
    bet_id INT REFERENCES bet(bet_id) ON DELETE CASCADE,
    stake_amount NUMERIC(10, 2),
    odds INTEGER
);

-- Insert data for testing Part 2
INSERT INTO game (game_id, game_name) VALUES (1002, 'Chengdu Open');
INSERT INTO bet (bet_id, game_id, bettor_name) VALUES (2003, 1002, 'Naomi');
INSERT INTO bet (bet_id, game_id, bettor_name) VALUES (2004, 1002, 'Sky');
INSERT INTO bet_details (detail_id, bet_id, stake_amount, odds) VALUES (3003, 2003, 120.00, 180);
INSERT INTO bet_details (detail_id, bet_id, stake_amount, odds) VALUES (3004, 2004, 80.00, -110);

-- Show initial state for Part 2
SELECT 'Part 2 Initial state - Game table:' as status;
SELECT * FROM game;
SELECT 'Part 2 Initial state - Bet table:' as status;
SELECT * FROM bet;
SELECT 'Part 2 Initial state - Bet Details table:' as status;
SELECT * FROM bet_details;

-- TODO 5: What do you expect to happen to the bet and bet_details tables when 'Chengdu Open' is deleted?
-- PREDICTION: Due to ON DELETE SET NULL constraint on game_id in bet table:
-- 1. When we delete the 'Chengdu Open' game (game_id = 1002), the bets will NOT be deleted
-- 2. Instead, the game_id column in the bet table will be set to NULL for affected rows
-- 3. The bet records (bet_ids 2003 and 2004) will remain with bettor names intact but game_id = NULL
-- 4. The bet_details table will remain completely unchanged since the bet records are not deleted
-- 5. We expect: game table empty, bet table with 2 records having NULL game_id, bet_details unchanged

-- Delete the 'Chengdu Open' game to test SET NULL behavior
DELETE FROM game WHERE game_name = 'Chengdu Open';

-- TODO 6: Check the state of the tables to test your answer from 5
SELECT 'After DELETE SET NULL - Game table:' as status;
SELECT * FROM game;
SELECT 'After DELETE SET NULL - Bet table:' as status;
SELECT * FROM bet;
SELECT 'After DELETE SET NULL - Bet Details table:' as status;
SELECT * FROM bet_details;

-- Analysis of SET NULL results:
-- The SET NULL behavior worked exactly as predicted! When we deleted the 'Chengdu Open' game:
-- 1. The game table is now empty (the game was deleted)
-- 2. The bet table still contains both bet records (2003 and 2004) but their game_id is now NULL
-- 3. The bet_details table remains completely unchanged with both detail records intact
-- 4. The bettors' names and all bet information is preserved, only the game reference is nullified
-- This demonstrates how ON DELETE SET NULL preserves dependent data while removing the reference

-- CASCADE vs SET NULL Summary:
-- 
-- ON DELETE CASCADE:
-- - Automatically deletes all dependent records when parent is deleted
-- - Maintains strict referential integrity but can result in data loss
-- - Useful when dependent records have no meaning without the parent
-- - Example: Order items should be deleted when an order is canceled
--
-- ON DELETE SET NULL:
-- - Preserves dependent records but sets foreign key to NULL
-- - Allows historical data preservation while removing the reference
-- - Useful when dependent records can exist independently of the parent
-- - Example: Employee records can remain even if department is dissolved
--
-- In our wagering system:
-- - CASCADE might be appropriate for bet_details -> bet (details meaningless without the bet)
-- - SET NULL might be appropriate for bet -> game (bet history valuable even if game is removed)