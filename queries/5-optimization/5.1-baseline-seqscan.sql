-- Question: Read and understand a sequential scan plan on an unindexed filter
-- No index exists yet on OwnerUserId, so Postgres must check every row in the
-- table one by one (Seq Scan) and discard the ones that don't match.
 
EXPLAIN ANALYZE
SELECT * FROM Posts WHERE OwnerUserId = 8;
 
-- RESULT:
--  Seq Scan on posts  (cost=0.00..22797.53 rows=13 width=1040) (actual time=0.099..60.924 rows=67 loops=1)
--    Filter: (owneruserid = 8)
--    Rows Removed by Filter: 164135
--  Planning Time: 1.941 ms
--  Execution Time: 61.041 ms
--
-- "Seq Scan" means Postgres read all 164,202 rows in the
-- table and threw away 164,135 of them because they didn't match the
-- filter -- only 67 rows actually matched. Execution Time 61ms. With no
-- index on OwnerUserId, there's no faster way for Postgres to find the
-- matching rows than checking every single one.