-- Question: Find each user's highest-scored post using RANK() inside a CTE
-- Using a Common Table Expression (CTE) allows filtering on the rank column since window functions cannot be used directly in WHERE;
WITH RankedPosts AS (
    SELECT
        u.DisplayName,
        p.Title,
        p.Score,
        RANK() OVER (PARTITION BY p.OwnerUserId ORDER BY p.Score DESC) AS post_rank
    FROM Posts p
    JOIN Users u ON p.OwnerUserId = u.Id
    WHERE p.OwnerUserId IS NOT NULL
      AND p.Title IS NOT NULL
)
SELECT
    DisplayName,
    Title,
    Score
FROM RankedPosts
WHERE post_rank = 1;