select * from songs

-- TODO 1: Fix the first insert and create a valid one
-- Original insert that should fail:
-- INSERT INTO songs (song_name, artist, genre, plays, song_length)
-- VALUES ('PARTY OF YOUR LIFETIME', 'On-lyne', 'Pop', -1, '00:03:36');
-- This insert previously failed because plays = -1, which is logically invalid 
-- (you cannot have negative plays)

INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES ('PARTY OF YOUR LIFETIME', 'On-lyne', 'Pop', 1, '00:03:36');

-- TODO 2: Comment out the second insert and create a valid one
-- Original insert that should fail:
-- INSERT INTO songs (song_name, artist, genre, plays, song_length)
-- VALUES ('THE GREAT DESPAIR', 'On-lyne', 'Pop', 0, -199);
-- This insert should fail because song_length = -199 is invalid 
-- (you cannot have negative song duration)

INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES ('THE GREAT DESPAIR', 'On-lyne', 'Pop', 0, '00:03:19');

-- TODO 3: Add constraints to the songs table using ALTER TABLE
-- First, let's drop the table and recreate with proper constraints
DROP TABLE songs;

CREATE TABLE songs (
    song_id SERIAL,
    song_name VARCHAR(512) NOT NULL, -- Songs must have names
    artist VARCHAR(256) NOT NULL,    -- Songs must have artists
    genre VARCHAR(64),               -- Genre can be NULL (optional)
    plays INT NOT NULL CHECK (plays >= 0), -- Plays cannot be negative
    song_length INTERVAL NOT NULL CHECK (song_length > INTERVAL '0'), -- Song must have positive duration
    PRIMARY KEY (song_id)
);

-- TODO 4: Test the batch insert with constraints in place
-- Some of these inserts should fail with our new constraints

INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES 
('Bohemian Rhapsody', 'Queen', 'Rock', 15000000, '05:55'),        -- Should succeed
('Smells Like Teen Spirit', 'Nirvana', 'Grunge', 2780000, '05:00'), -- Should succeed
-- (NULL, 'The Beatles', 'Pop', 5000000, '01:45'),                    -- Should fail: song_name is NULL
-- ('Lose Yourself', NULL, 'Hip-Hop', 8000000, '04:27'),              -- Should fail: artist is NULL
-- ('Billie Jean', 'Michael Jackson', 'Pop', NULL, '04:54'),           -- Should fail: plays is NULL
-- ('Hotel California', 'Eagles', 'Rock', 14000000, NULL);            -- Should fail: song_length is NULL
('Stairway to Heaven', 'Led Zeppelin', 'Rock', 12000000, '08:02'), -- Should succeed
('Imagine', 'John Lennon', 'Pop', 9000000, '03:07');               -- Should succeed

-- TODO 5: Comment on which column each of these rows should fail, or whether they should fail:
-- Row 1 ('Bohemian Rhapsody'): Should SUCCEED - all constraints satisfied
-- Row 2 ('Smells Like Teen Spirit'): Should SUCCEED - all constraints satisfied  
-- Row 3 (NULL, 'The Beatles'): Should FAIL on song_name - NOT NULL constraint violated
-- Row 4 ('Lose Yourself', NULL): Should FAIL on artist - NOT NULL constraint violated
-- Row 5 ('Billie Jean', plays = NULL): Should FAIL on plays - NOT NULL constraint violated
-- Row 6 ('Hotel California', song_length = NULL): Should FAIL on song_length - NOT NULL constraint violated

-- TODO 6-8: Create 3 invalid unique inserts into the song table
-- These should fail due to constraint violations

-- TODO 6: Invalid insert - negative plays
-- INSERT INTO songs (song_name, artist, genre, plays, song_length)
-- VALUES ('Bad Insert 1', 'Test Artist', 'Test', -5, '03:00');

-- TODO 7: Invalid insert - zero or negative song_length  
-- INSERT INTO songs (song_name, artist, genre, plays, song_length)
-- VALUES ('Bad Insert 2', 'Test Artist', 'Test', 100, '00:00:00');

-- TODO 8: Invalid insert - NULL song_name
-- INSERT INTO songs (song_name, artist, genre, plays, song_length)
-- VALUES (NULL, 'Test Artist', 'Test', 100, '03:00');

-- TODO 9-12: Create 4 valid unique inserts into the song table

-- TODO 9: Valid insert
INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES ('Thunderstruck', 'AC/DC', 'Hard Rock', 8500000, '04:52');

-- TODO 10: Valid insert with NULL genre (allowed)
INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES ('Mysterious Song', 'Unknown Band', NULL, 1000, '03:30');

-- TODO 11: Valid insert
INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES ('Dancing Queen', 'ABBA', 'Disco', 12000000, '03:50');

-- TODO 12: Valid insert with zero plays (allowed)
INSERT INTO songs (song_name, artist, genre, plays, song_length)
VALUES ('Brand New Song', 'New Artist', 'Alternative', 0, '04:15');

-- Display all successfully inserted songs
SELECT * FROM songs;

-- TODO 13: Short response question about constraints in production databases
-- Constraints and checks work exceptionally well in production databases because they ensure data integrity 
-- and prevent invalid data from being stored, which could corrupt business logic or cause application errors. 
-- They act as a safety net that catches data quality issues at the database level before they can propagate 
-- through the system, ultimately saving time and preventing costly bugs in production applications.

-- TODO 14: ChatGPT response comparison
-- ChatGPT Response: "Constraints and checks are essential in production databases as they enforce business rules 
-- and maintain data quality by preventing invalid data entry. They help ensure referential integrity, reduce 
-- the likelihood of application errors, and provide a consistent layer of validation that protects against 
-- both user errors and application bugs. This leads to more reliable systems and reduces maintenance overhead."
-- 
-- Did the answer match expectations? Yes, the ChatGPT response aligns closely with my intuition, emphasizing 
-- data integrity, error prevention, and system reliability. Both responses highlight how constraints serve as 
-- a protective layer that maintains data quality and reduces potential issues in production environments.

-- TODO 15: Lab learning reflection
-- From this lab, I learned how crucial database constraints are for maintaining data integrity and preventing 
-- logically invalid data from entering the system. The hands-on experience with CHECK constraints, NOT NULL 
-- constraints, and analyzing failed inserts helped me understand how these safeguards work in practice. 
-- This reinforced the importance of thinking about data validation at the database level, not just in application code.