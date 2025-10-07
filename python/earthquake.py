import requests

BASE_URL = "https://earthquake.usgs.gov/fdsnws/event/1/query"

params = {
    "format": "csv",
    "starttime": "2025-01-01",
    "endtime": "2025-01-31",
    "minmagnitude": 5,
}

resp = requests.get(BASE_URL, params=params, timeout=20)
resp.raise_for_status()

with open("earthquakes.csv", "wb") as f:
    f.write(resp.content)

print(f'Saved "earthquakes.csv", size={len(resp.content)} bytes.')