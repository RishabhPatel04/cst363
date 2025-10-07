import psycopg
from pprint import pprint

# Connect to the database
connection = psycopg.connect(
    host='127.0.0.1',
    port=5431,
    dbname='baseball_db',    
    user='postgres',
    password='ott3r'
)

# Open a cursor to perform database operations
cur = connection.cursor()

# Define the query: Get player names and birth years

query = """
SELECT id, first_name || ' ' || last_name AS player_name, birth_year
FROM players;
"""

# Execute the query
cur.execute(query)

# Initialize an empty dictionary
players_dict = {}


# Fetch all rows from the query
rows = cur.fetchall()

# Iterate over each row and add it to the dictionary
for row in rows:
    player_id = row[0]      # Player's ID
    player_name = row[1]    # Player's full name
    birth_year = row[2]     # Birth year

    # Add entry to dictionary
    players_dict[player_id] = (player_name, birth_year)


# Close the database connection
cur.close()
connection.close()

# Print the dictionary
pprint(players_dict)