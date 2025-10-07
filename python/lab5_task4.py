import psycopg
from pprint import pprint


def fetch_players(cur):
    """Return dict {player_id: full_name}."""
    cur.execute(
        """
        SELECT id, first_name || ' ' || last_name AS full_name
        FROM players;
        """
    )
    players = {}
    for row in cur.fetchall():
        player_id = row[0]
        full_name = row[1]
        players[player_id] = full_name
    return players


def fetch_performances(cur):
    """Return dict {player_id: [(team_id, year), ...]}."""
    cur.execute(
        """
        SELECT player_id, team_id, year
        FROM performances;
        """
    )
    perf = {}
    for row in cur.fetchall():
        player_id = row[0]
        team_id = row[1]
        year = row[2]
        perf.setdefault(player_id, []).append((team_id, year))
    return perf


def build_player_team_year(players_dict, perf_dict):
    """Return dict {player_name: [(team_id, year), ...]} with empty list if none."""
    merged = {}
    for player_id, full_name in players_dict.items():
        merged[full_name] = perf_dict.get(player_id, [])
    return merged


def main():
    # Connect to the database (same settings as lab5_task3.py)
    connection = psycopg.connect(
        host="127.0.0.1",
        port=5431,
        dbname="baseball_db",
        user="postgres",
        password="ott3r",
    )
    cur = connection.cursor()

    try:
        # 1) players -> {player_id: full_name}
        players_dict = fetch_players(cur)

        # 2) performances -> {player_id: [(team_id, year), ...]}
        perf_dict = fetch_performances(cur)

        # 3) merge -> {player_name: [(team_id, year), ...]} (or [])
        player_teams_by_name = build_player_team_year(players_dict, perf_dict)

        # Print results (may be large). Show counts and a small sample.
        print(f"Players count: {len(players_dict)}")
        print(f"Performances players count: {len(perf_dict)}")
        print("Sample (first 20 entries):")
        sample_items = list(player_teams_by_name.items())[:20]
        pprint(sample_items)

    finally:
        cur.close()
        connection.close()


if __name__ == "__main__":
    main()

