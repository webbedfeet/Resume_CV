#!/usr/bin/env python3
"""Extract entries in dasgupta_pubs.json missing from mypublications.json as CSV."""

import csv
import json
import sys


def get_year(item):
    raw = item.get("issued", {}).get("date-parts", [[None]])[0][0]
    try:
        return int(raw)
    except (TypeError, ValueError):
        return 0


def format_authors(item):
    return "; ".join(
        f"{a.get('family', '')}, {a.get('given', '')}".strip(", ")
        for a in item.get("author", [])
    )


with open("dasgupta_pubs.json") as f:
    dasgupta = json.load(f)
with open("mypublications.json") as f:
    mypubs = json.load(f)

mypubs_keys = {item["citation-key"] for item in mypubs}
discrepant = [item for item in dasgupta if item["citation-key"] not in mypubs_keys]
discrepant.sort(key=get_year)

fields = ["citation-key", "type", "year", "title", "authors",
          "container-title", "volume", "issue", "page", "DOI", "PMID"]

out = sys.argv[1] if len(sys.argv) > 1 else "discrepant_pubs.csv"
with open(out, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    for item in discrepant:
        year = get_year(item) or ""
        writer.writerow({
            "citation-key":   item.get("citation-key", ""),
            "type":           item.get("type", ""),
            "year":           year,
            "title":          item.get("title", ""),
            "authors":        format_authors(item),
            "container-title": item.get("container-title", ""),
            "volume":         item.get("volume", ""),
            "issue":          item.get("issue", ""),
            "page":           item.get("page", ""),
            "DOI":            item.get("DOI", ""),
            "PMID":           item.get("PMID", ""),
        })

print(f"Written {len(discrepant)} entries to {out}")
