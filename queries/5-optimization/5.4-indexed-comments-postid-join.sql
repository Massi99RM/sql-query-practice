-- Question: Add an index on Comments.PostId and measure its effect on
-- the post+comment-count join from query 2.1
-- Foreign-key-style join columns without an index are one of the most
-- common real-world performance problems.
 
-- BEFORE (no index on Comments.PostId):
EXPLAIN ANALYZE
SELECT p.Title, COUNT(c.Id) AS CommentCount
FROM Posts p
LEFT JOIN Comments c ON p.Id = c.PostId
GROUP BY p.Id, p.Title
ORDER BY CommentCount DESC
LIMIT 15;
 
--  Limit  (cost=80479.30..80479.34 rows=15 width=76) (actual time=579.204..579.207 rows=15 loops=1)
--    ->  Sort  (cost=80479.30..80889.81 rows=164202 width=76) (actual time=579.203..579.204 rows=15 loops=1)
--          Sort Key: (count(c.id)) DESC
--          Sort Method: top-N heapsort  Memory: 27kB
--          ->  GroupAggregate  (cost=42917.87..76450.70 rows=164202 width=76) (actual time=227.856..564.105 rows=164202 loops=1)
--                Group Key: p.id
--                ->  Merge Left Join  (cost=42917.87..73380.68 rows=285599 width=72) (actual time=227.846..520.784 rows=357315 loops=1)
--                      Merge Cond: (p.id = c.postid)
--                      ->  Index Scan using posts_pkey on posts p  (cost=0.42..25054.97 rows=164202 width=68) (actual time=0.004..205.627 rows=164202 loops=1)
--                      ->  Materialize  (cost=42917.45..44345.44 rows=285599 width=8) (actual time=227.837..265.445 rows=285599 loops=1)
--                            ->  Sort  (cost=42917.45..43631.44 rows=285599 width=8) (actual time=227.835..246.454 rows=285599 loops=1)
--                                  Sort Key: c.postid
--                                  Sort Method: external merge  Disk: 5040kB
--                                  ->  Seq Scan on comments c  (cost=0.00..13130.99 rows=285599 width=8) (actual time=0.037..188.456 rows=285599 loops=1)
--  Planning Time: 2.474 ms
--  Execution Time: 581.079 ms
 
CREATE INDEX idx_comments_postid ON Comments(PostId);
 
-- AFTER:
EXPLAIN ANALYZE
SELECT p.Title, COUNT(c.Id) AS CommentCount
FROM Posts p
LEFT JOIN Comments c ON p.Id = c.PostId
GROUP BY p.Id, p.Title
ORDER BY CommentCount DESC
LIMIT 15;
 
--  Limit  (cost=52696.02..52696.05 rows=15 width=76) (actual time=220.276..220.279 rows=15 loops=1)
--    ->  Sort  (cost=52696.02..53106.52 rows=164202 width=76) (actual time=220.275..220.276 rows=15 loops=1)
--          Sort Key: (count(c.id)) DESC
--          Sort Method: top-N heapsort  Memory: 27kB
--          ->  GroupAggregate  (cost=0.84..48667.41 rows=164202 width=76) (actual time=0.020..206.254 rows=164202 loops=1)
--                Group Key: p.id
--                ->  Merge Left Join  (cost=0.84..45597.40 rows=285599 width=72) (actual time=0.016..167.045 rows=357315 loops=1)
--                      Merge Cond: (p.id = c.postid)
--                      ->  Index Scan using posts_pkey on posts p  (cost=0.42..25054.97 rows=164202 width=68) (actual time=0.005..75.421 rows=164202 loops=1)
--                      ->  Index Scan using idx_comments_postid on comments c  (cost=0.42..16561.94 rows=285599 width=8) (actual time=0.009..48.310 rows=285599 loops=1)
--  Planning Time: 0.387 ms
--  Execution Time: 220.303 ms
--
-- Execution time dropped from 581ms to 220ms (about
-- 2.6x faster) -- but the mechanism is different from 5.1/5.2. The
-- "before" plan had to sort 285,599 comments by PostId before it could
-- merge-join them with Posts, and that sort was too big for memory
-- (Sort Method: external merge, Disk: 5040kB) -- a slow disk spill.
-- Once the index on Comments.PostId existed, rows were already available
-- in that sorted order, so Postgres could skip the sort step entirely
-- and use an Index Scan directly in the merge join. The result here is
-- avoiding an expensive sort, not just finding rows faster.