-- Question: Create a composite index on (OwnerUserId, Score) and see
-- whether Postgres uses it over the existing single-column index from 5.2
-- A composite index can satisfy both a filter column and a sort column
-- together -- but only when doing so actually saves meaningful work.
 
-- BEFORE (idx_posts_owneruserid from 5.2 already exists):
EXPLAIN ANALYZE
SELECT Id, Title, Score
FROM Posts
WHERE OwnerUserId = 8
ORDER BY Score DESC;
 
--  Sort  (cost=31.84..31.88 rows=13 width=72) (actual time=0.252..0.255 rows=67 loops=1)
--    Sort Key: score DESC
--    Sort Method: quicksort  Memory: 28kB
--    ->  Index Scan using idx_posts_owneruserid on posts  (cost=0.29..31.60 rows=13 width=72) (actual time=0.040..0.229 rows=67 loops=1)
--          Index Cond: (owneruserid = 8)
--  Planning Time: 0.406 ms
--  Execution Time: 0.268 ms
 
CREATE INDEX idx_posts_owner_score ON Posts(OwnerUserId, Score);
 
-- AFTER:
EXPLAIN ANALYZE
SELECT Id, Title, Score
FROM Posts
WHERE OwnerUserId = 8
ORDER BY Score DESC;
 
--  Sort  (cost=31.84..31.88 rows=13 width=72) (actual time=0.067..0.069 rows=67 loops=1)
--    Sort Key: score DESC
--    Sort Method: quicksort  Memory: 28kB
--    ->  Index Scan using idx_posts_owneruserid on posts  (cost=0.29..31.60 rows=13 width=72) (actual time=0.008..0.055 rows=67 loops=1)
--          Index Cond: (owneruserid = 8)
--  Planning Time: 0.939 ms
--  Execution Time: 0.082 ms
--
-- Even after creating the composite index, Postgres kept
-- using the old single-column index (idx_posts_owneruserid), not the new
-- one -- the plan is identical except for timing. This is an important,
-- lesson: creating an index does not guarantee Postgres
-- will use it. Here, only 67 rows match OwnerUserId = 8, so sorting them
-- by Score in memory is almost free (quicksort, 28kB). The query
-- planner is cost-based: it estimated the existing index was already
-- cheap enough and saw no real benefit in switching, so it didn't.
-- A composite index like this would matter more on a column with a much
-- larger per-value row count, where in-memory sorting actually becomes
-- expensive.