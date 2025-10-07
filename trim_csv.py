
import csv

keep = ["time", "latitude", "longitude", "depth", "mag", "place"]

with open("earthquakes.csv", newline="", encoding="utf-8") as src, \
     open("earthquakes_trimmed.csv", "w", newline="", encoding="utf-8") as out:
    reader = csv.DictReader(src)
    writer = csv.DictWriter(out, fieldnames=keep)
    writer.writeheader()
    for row in reader:
        writer.writerow({k: row.get(k, "") for k in keep})

print("Wrote earthquakes_trimmed.csv")