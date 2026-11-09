-- Question: Add an index on OwnerUserId and measure the before/after difference
-- Creating a single-column index lets Postgres jump directly to matching
-- rows instead of scanning the whole table.
 
CREATE INDEX idx_posts_owneruserid ON Posts(OwnerUserId);
 
EXPLAIN ANALYZE
SELECT * FROM Posts WHERE OwnerUserId = 8;
 
-- BEFORE (from 5.1): Seq Scan, Execution Time 61.041 ms
--
-- AFTER:
--  Index Scan using idx_posts_owneruserid on posts  (cost=0.29..31.60 rows=13 width=1040) (actual time=0.047..0.810 rows=67 loops=1)
--    Index Cond: (owneruserid = 8)
--  Planning Time: 0.430 ms
--  Execution Time: 0.837 ms
--
-- The plan switched from Seq Scan to Index Scan, and
-- execution time dropped from 61ms to 0.84ms -- about 73x faster. The
-- index lets Postgres go straight to the 67 matching rows instead of
-- reading all 164,202. This is the clearest possible case for an index:
-- a highly selective filter (67 out of 164,202 rows) on an unindexed column.