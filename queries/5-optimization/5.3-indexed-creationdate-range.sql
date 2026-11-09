-- Question: Add an index on CreationDate and measure its effect on a
-- date-range + extra-condition filter (reusing query 1.2)
-- A date range that matches a small fraction of the table should let
-- the planner use an index; this also shows that a single-column index
-- can only help with the condition it covers (CreationDate), not with
-- the rest of the WHERE clause (Score > 5).
 
-- BEFORE (no index on CreationDate):
EXPLAIN ANALYZE
SELECT Id, Title, Score, CreationDate
FROM Posts
WHERE CreationDate >= '2020-01-01' AND CreationDate < '2021-01-01' AND Score > 5;
 
--  Seq Scan on posts  (cost=0.00..23618.53 rows=7074 width=80) (actual time=24.003..40.665 rows=6914 loops=1)
--    Filter: ((creationdate >= '2020-01-01 00:00:00'::timestamp without time zone) AND (creationdate < '2021-01-01 00:00:00'::timestamp without time zone) AND (score > 5))
--    Rows Removed by Filter: 157288
--  Planning Time: 0.249 ms
--  Execution Time: 40.850 ms
 
CREATE INDEX idx_posts_creationdate ON Posts(CreationDate);
 
-- AFTER:
EXPLAIN ANALYZE
SELECT Id, Title, Score, CreationDate
FROM Posts
WHERE CreationDate >= '2020-01-01' AND CreationDate < '2021-01-01' AND Score > 5;
 
--  Index Scan using idx_posts_creationdate on posts  (cost=0.42..2299.77 rows=7074 width=80) (actual time=0.045..20.462 rows=6914 loops=1)
--    Index Cond: ((creationdate >= '2020-01-01 00:00:00'::timestamp without time zone) AND (creationdate < '2021-01-01 00:00:00'::timestamp without time zone))
--    Filter: (score > 5)
--    Rows Removed by Filter: 7056
--  Planning Time: 0.270 ms
--  Execution Time: 20.682 ms
--
-- Execution time dropped from 40.85ms to 20.68ms (about
-- 2x faster), smaller than 5.2's 73x because the date range still
-- matches ~4% of the table (6,914 of 164,202 rows). 
-- About the "Filter: (score > 5)" line, it still
-- appears after the Index Condition in the "after" plan: the index only
-- helped with the CreationDate condition, and Postgres still had to
-- check Score > 5 row-by-row on the 7,074 rows the index returned,
-- discarding 7,056 of them. A single-column index only covers the
-- condition it's built on -- this is exactly why a composite index
-- (5.5) can help when multiple conditions are involved.