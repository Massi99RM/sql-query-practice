# SQL Query Practice — Learning Project

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

The goal of this project is to build fluency with relational databases: writing queries by hand against a large, realistic schema, progressing from basic filters to window functions, CTEs, and query optimization.

## Overview

The dataset is a subset of the **StackOverflow Data Explorer** schema (`Posts`, `Users`, `Comments`, `Votes`, `Badges`, `Tags`) — large enough that naive queries become slow, and relational enough that real questions require joins across several tables. Each query lives as a standalone `.sql` file, numbered by topic, with a short note on the question it answers and what it taught me.

## What I'm Practicing

| Area | Skills |
|------|--------|
| Fundamentals | `WHERE`, `GROUP BY`, `HAVING`, multi-table `JOIN`s |
| Aggregations | `COUNT`/`SUM`/`AVG` with conditional logic (`CASE WHEN`), subqueries |
| Window functions | `RANK()`, `ROW_NUMBER()`, running totals, `PARTITION BY` |
| CTEs & recursion | Multi-step `WITH` queries, recursive CTEs for hierarchical data |
| Optimization | Reading `EXPLAIN ANALYZE`, adding indexes, measuring before/after |

## Tech Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| Database | PostgreSQL 16 | Industry-standard RDBMS, strong window function and CTE support |
| Environment | Docker Compose | Reproducible, isolated, runnable with a single command |
| Dataset | StackOverflow Data Explorer subset | Large (millions of rows), realistic, widely recognized schema |

## Project Structure

```
sql-query-practice/
│
├── docker-compose.yml       # Postgres service, single-command startup
├── data/                    # Dataset dump (not committed — see Setup)
├── queries/
│   ├── 01-fundamentals/     # WHERE, JOIN, GROUP BY
│   ├── 02-joins-aggregations/
│   ├── 03-window-functions/
│   ├── 04-ctes-recursive/
│   └── 05-optimization/     # EXPLAIN ANALYZE, indexing, before/after
├── .gitignore
└── README.md
```

Each `.sql` file follows the same pattern: a comment block with the question being answered, the query itself, and a short note on what it did.

## How to Run

### Prerequisites

- Docker Desktop (includes Docker Compose)
- `psql` (PostgreSQL command-line client) to connect and run queries

### Setup

```bash
# Clone the repository
git clone https://github.com/Massi99RM/sql-query-practice.git
cd sql-query-practice

# Start Postgres
docker compose up -d

# Load the dataset (instructions/script added once the subset is finalized)

# Connect
psql -h localhost -U practice -d stackoverflow
# password: practice
```

### Run a query

```bash
psql -h localhost -U practice -d stackoverflow -f queries/01-fundamentals/01-most-active-users.sql
```

## License

MIT