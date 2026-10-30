"""
Loads the Stack Exchange XML dump (in data/) into the
Postgres container started by `docker compose up -d`.

"""

import xml.etree.ElementTree as ET
import psycopg2
import os

# --- connection settings ---
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "stackoverflow",
    "user": "practice",
    "password": "practice",
}

DATA_DIR = "data"

# --- table definitions ---
TABLES = {
    "Users.xml": (
        "Users",
        {
            "Id": "Id INTEGER PRIMARY KEY",
            "Reputation": "Reputation INTEGER",
            "DisplayName": "DisplayName TEXT",
            "CreationDate": "CreationDate TIMESTAMP",
            "LastAccessDate": "LastAccessDate TIMESTAMP",
            "Location": "Location TEXT",
            "UpVotes": "UpVotes INTEGER",
            "DownVotes": "DownVotes INTEGER",
        },
    ),
    "Posts.xml": (
        "Posts",
        {
            "Id": "Id INTEGER PRIMARY KEY",
            "PostTypeId": "PostTypeId INTEGER",
            "ParentId": "ParentId INTEGER",
            "CreationDate": "CreationDate TIMESTAMP",
            "Score": "Score INTEGER",
            "ViewCount": "ViewCount INTEGER",
            "Body": "Body TEXT",
            "OwnerUserId": "OwnerUserId INTEGER",
            "LastActivityDate": "LastActivityDate TIMESTAMP",
            "Title": "Title TEXT",
            "Tags": "Tags TEXT",
            "AnswerCount": "AnswerCount INTEGER",
            "CommentCount": "CommentCount INTEGER",
            "FavoriteCount": "FavoriteCount INTEGER",
        },
    ),
    "Comments.xml": (
        "Comments",
        {
            "Id": "Id INTEGER PRIMARY KEY",
            "PostId": "PostId INTEGER",
            "Score": "Score INTEGER",
            "Text": "Text TEXT",
            "CreationDate": "CreationDate TIMESTAMP",
            "UserId": "UserId INTEGER",
        },
    ),
    "Votes.xml": (
        "Votes",
        {
            "Id": "Id INTEGER PRIMARY KEY",
            "PostId": "PostId INTEGER",
            "VoteTypeId": "VoteTypeId INTEGER",
            "CreationDate": "CreationDate TIMESTAMP",
        },
    ),
    "Badges.xml": (
        "Badges",
        {
            "Id": "Id INTEGER PRIMARY KEY",
            "UserId": "UserId INTEGER",
            "Name": "Name TEXT",
            "Date": "Date TIMESTAMP",
        },
    ),
    "Tags.xml": (
        "Tags",
        {
            "Id": "Id INTEGER PRIMARY KEY",
            "TagName": "TagName TEXT",
            "Count": "Count INTEGER",
        },
    ),
}


def create_table(cur, table_name, columns):
    cur.execute(f"DROP TABLE IF EXISTS {table_name} CASCADE;")
    col_defs = ", ".join(columns.values())
    cur.execute(f"CREATE TABLE {table_name} ({col_defs});")


def load_file(cur, filepath, table_name, columns):
    if not os.path.exists(filepath):
        print(f"  Skipping {filepath} (not found)")
        return 0

    col_names = list(columns.keys())
    placeholders = ", ".join(["%s"] * len(col_names))
    insert_sql = f"INSERT INTO {table_name} ({', '.join(col_names)}) VALUES ({placeholders})"

    count = 0
    batch = []
    for _, elem in ET.iterparse(filepath, events=("end",)):
        if elem.tag != "row":
            continue
        values = [elem.get(col) or None for col in col_names]
        batch.append(values)
        count += 1
        if len(batch) >= 1000:
            cur.executemany(insert_sql, batch)
            batch = []
        elem.clear()

    if batch:
        cur.executemany(insert_sql, batch)

    return count


def main():
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    cur = conn.cursor()

    for filename, (table_name, columns) in TABLES.items():
        filepath = os.path.join(DATA_DIR, filename)
        print(f"Loading {filename} -> {table_name}...")
        create_table(cur, table_name, columns)
        n = load_file(cur, filepath, table_name, columns)
        conn.commit()
        print(f"  Inserted {n} rows")

    cur.close()
    conn.close()
    print("Done.")


if __name__ == "__main__":
    main()