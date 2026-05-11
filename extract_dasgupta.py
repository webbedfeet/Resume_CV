#!/usr/bin/env python3
"""Extract Zotero items where Dasgupta is a co-author."""

import argparse
import json


def extract_dasgupta_items(input_path: str, output_path: str | None = None, verbose: bool = False, pub_types: list | None = None) -> list:
    with open(input_path) as f:
        data = json.load(f)

    matches = [
        item for item in data
        if any(
            author.get("family", "").lower() == "dasgupta"
            for author in item.get("author", [])
        )
        and (pub_types is None or item.get("type") in pub_types)
    ]

    if output_path:
        with open(output_path, "w") as f:
            json.dump(matches, f, indent=2)
        print(f"Written {len(matches)} items to {output_path}")

    if verbose or not output_path:
        for item in matches:
            authors = ", ".join(
                f"{a.get('given', '')} {a.get('family', '')}".strip()
                for a in item.get("author", [])
            )
            print(f"[{item.get('issued', {}).get('date-parts', [['']])[0][0]}] "
                  f"{item.get('title', '(no title)')}\n  Authors: {authors}\n")

    return matches


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract Zotero items where Dasgupta is an author.")
    parser.add_argument("input", nargs="?", default="zotlib.json", help="Input JSON file (default: zotlib.json)")
    parser.add_argument("-o", "--output", default=None, metavar="FILE", help="Output JSON file (prints to stdout if omitted)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print each item to stdout even when writing to a file")
    parser.add_argument("-t", "--type", dest="pub_types", metavar="TYPE", action="append",
                        help="Filter by publication type (e.g. article-journal, book, paper-conference). "
                             "Can be specified multiple times.")
    parser.add_argument("--list-types", action="store_true", help="List all publication types present in the input file and exit")
    args = parser.parse_args()

    if args.list_types:
        with open(args.input) as f:
            data = json.load(f)
        types = sorted(set(item.get("type", "unknown") for item in data))
        print("\n".join(types))
    else:
        extract_dasgupta_items(args.input, output_path=args.output, verbose=args.verbose, pub_types=args.pub_types)
