# SQL Query Practice — Learning Project

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A deliberate practice project to build real fluency with relational databases: writing queries by hand against a large, realistic schema, progressing from basic filters to window functions, CTEs, and query optimization. Every query here is written manually — the goal is the skill, not the output.

## Overview

The dataset is the real **Stack Exchange Data Dump** schema (`Posts`, `Users`, `Comments`, `Votes`, `Badges`, `Tags`) — the same relational structure StackOverflow itself uses — loaded from [RPG Stack Exchange](https://rpg.stackexchange.com/). Over 2.5 million rows across six tables: large enough that naive queries get noticeably slow, and relational enough that real questions require joins across several tables. Each query lives as a standalone `.sql` file, numbered by topic, with a comment block stating the question it answers and what I learned from it.

## What I'm Practicing

| Area | Skills |
|------|--------|
| Fundamentals | `WHERE`, `GROUP BY`, `HAVING`, multi-table `JOIN`s |
| Aggregations | `COUNT`/`SUM`/`AVG` with conditional logic (`CASE WHEN`), subqueries |
| Window functions | `RANK()`, `ROW_NUMBER()`, `DENSE_RANK()`, running totals, `PARTITION BY`, `LAG()` |
| CTEs & recursion | Multi-step `WITH` queries, recursive CTEs for sequences, date spines, and hierarchy traversal |
| Optimization | Reading `EXPLAIN ANALYZE`, adding indexes, measuring real before/after performance |

## Tech Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| Database | PostgreSQL 16 | Industry-standard RDBMS, strong window function and CTE support |
| Environment | Docker Compose | Reproducible, isolated, runnable with a single command |
| Dataset | Stack Exchange Data Dump (RPG site) | Real data, same schema as StackOverflow, manageable size |
| Client | `psql` | Standard command-line client — closest to what's used in real interviews and day-to-day work |

## Project Structure

```
sql-query-practice/
│
├── docker-compose.yml       # Postgres service, single-command startup
├── load_data.py             # Parses the Stack Exchange XML dump and loads it into Postgres
├── requirements.txt         # Python dependency for load_data.py
├── data/                    # Dataset XML files (not committed — see Setup)
├── queries/
│   ├── 1-fundamentals/           # WHERE, JOIN, GROUP BY
│   │   ├── 1.1-high-reputations-users.sql
│   │   ├── 1.2-top-posts-2020.sql
│   │   ├── 1.3-recent-comments-with-authors.sql
│   │   ├── 1.4-top-users-by-post-count.sql
│   │   ├── 1.5-popular-tags.sql
│   │   └── 1.6-derived-tag-counts.sql
│   ├── 2-joins-aggregations/     # multi-table joins, CASE WHEN, subqueries
│   │   ├── 2.1-posts-with-comment-counts.sql
│   │   ├── 2.2-user-question-answer-counts.sql
│   │   ├── 2.3-question-average-answer-scores.sql
│   │   ├── 2.4-users-without-comments.sql
│   │   └── 2.5-tag-average-scores.sql
│   ├── 3-window-functions/       # RANK, PARTITION BY, LAG, running totals
│   │   ├── 3.1-user-top-scored-posts.sql
│   │   ├── 3.2-post-and-author-average-score.sql
│   │   ├── 3.3-tag-running-total.sql
│   │   ├── 3.4-user-post-time-gaps.sql
│   │   └── 3.5-ranking-functions-comparison.sql
│   ├── 4-ctes-recursive/         # multi-step CTEs, recursive CTEs
│   │   ├── 4.1-average-answer-score-multistep-cte.sql
│   │   ├── 4.2-user-activity-pipeline-ctes.sql
│   │   ├── 4.3-recursive-number-sequence.sql
│   │   ├── 4.4-recursive-date-spine-january-2020.sql
│   │   └── 4.5-recursive-hierarchy-walk.sql
│   └── 5-optimization/           # EXPLAIN ANALYZE, indexing, before/after
│       ├── 5.1-baseline-seqscan.sql
│       ├── 5.2-indexed-owneruserid.sql
│       ├── 5.3-indexed-creationdate-range.sql
│       ├── 5.4-indexed-comments-postid-join.sql
│       └── 5.5-composite-index.sql
├── .gitignore
└── README.md
```

## How to Run

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes Docker Compose) — runs Postgres, so no local database install is needed
- [PostgreSQL command-line client (`psql`)](https://www.postgresql.org/download/) — you only need the client tools, not a local Postgres server; during install you can skip "PostgreSQL Server" and "Stack Builder" if prompted, you only need `psql` itself
- Python 3.10+ with `psycopg2-binary` (only needed once, to load the dataset — see below)

### Setup

```bash
# Clone the repository
git clone https://github.com/Massi99RM/sql-query-practice.git
cd sql-query-practice

# Start Postgres
docker compose up -d
```

**Load the dataset** (one-time setup):

1. Download a small site's data dump from the [Internet Archive's Stack Exchange Data Dump](https://archive.org/details/stackexchange) — this project uses `rpg.stackexchange.com.7z` (~80MB), but any small site works, since they all share the same schema
2. Extract the `.7z` archive (any archive tool works, e.g. WinRAR or 7-Zip) and place the resulting `.xml` files (`Posts.xml`, `Users.xml`, `Comments.xml`, `Votes.xml`, `Badges.xml`, `Tags.xml`) into the `data/` folder
3. Install the Python dependency and run the loader:
   ```bash
   pip install -r requirements.txt
   python load_data.py
   ```
   This creates the tables and inserts every row — takes under a minute.

**Encoding note (Windows):** some `DisplayName`/`Text` values contain non-Latin characters, which by default `psql` tries to render using Windows' legacy code page and fails on. Fix this once, permanently, rather than per session:
1. Windows search → "Edit the system environment variables"
2. **Environment Variables** → under **User variables** → **New**
3. Variable name: `PGCLIENTENCODING`, Variable value: `UTF8`
4. OK everything, then close and reopen your terminal

**Connect:**

```bash
psql -h localhost -U practice -d stackoverflow
# password: practice
```

### Every time after initial setup

You do **not** need to repeat the dataset load or the encoding setup — both persist. The routine is just:

1. Open Docker Desktop
2. In the project folder: `docker compose up -d`
   (the `-d` flag runs it in the background, so the terminal stays free — without it, the terminal stays attached to the container's logs and you can't type anything else until you stop it)
3. `psql -h localhost -U practice -d stackoverflow`

Your data lives in a Docker named volume (`pgdata`), which persists across restarts and reboots — `docker compose up -d` just starts the same Postgres server back up with everything still in it. The only way to lose it is running `docker compose down -v` (the `-v` flag specifically wipes volumes) — avoid that unless you intend to reload from scratch.

### Run a query

```bash
psql -h localhost -U practice -d stackoverflow -f queries/1-fundamentals/1.1-high-reputation-users.sql
```

Or connect with `psql` first and paste/run queries interactively — useful while still drafting a query, since you can iterate and inspect results before saving the final version to its file.

## What I Learned

- **Fundamentals (section 1):** comfortable going in with basic `SELECT`/`JOIN`/`GROUP BY` from prior projects, but this section exposed a real debugging case: the `Tags` column isn't wrapped like `<tag1><tag2>` as I initially assumed — it's actually pipe-delimited (`|tag1|tag2|`). Learned to verify raw data with a plain `SELECT` instead of guessing a format, rather than trusting assumption over evidence.
- **Joins & aggregation (section 2):** `CASE WHEN` inside aggregate functions is a clean way to pivot counts into columns without multiple queries. Also reinforced why grouping by a unique ID (`u.Id`) alongside a display column, not the display column alone, matters — two users could share a display name and silently merge their counts otherwise.
- **Window functions (section 3):** the clearest lesson was seeing `RANK()`, `DENSE_RANK()`, and `ROW_NUMBER()` actually diverge on tied values — `RANK` skips numbers after a tie, `DENSE_RANK` doesn't, `ROW_NUMBER` breaks ties arbitrarily. Also learned that a window function can't be filtered directly in the same `SELECT`'s `WHERE` clause — it needs to be wrapped in a CTE or subquery first.
- **CTEs & recursion (section 4):** recursive CTEs aren't only for hierarchical data — generating number sequences and filling date gaps (a "date spine") are genuinely useful, non-hierarchical uses. Also learned to recognize and explain a real schema limitation (this dataset's post hierarchy is only one level deep) rather than writing a recursive query that looked more sophisticated than the data actually supported.
- **Optimization (section 5):** the biggest lesson was that an index being created doesn't guarantee Postgres will use it — the query planner is cost-based, and on a small enough result set (like 67 rows), an in-memory sort is already cheaper than anything an extra index could offer. Also learned to distinguish *why* an index helps in different cases: sometimes it avoids scanning unmatched rows (5.2), sometimes it avoids an expensive sort/disk-spill step entirely during a join (5.4) — not the same mechanism, even though both show up as "it got faster."

## License

MIT