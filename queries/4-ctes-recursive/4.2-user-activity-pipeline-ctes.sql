-- Question: Find users with more than 50 combined posts and comments using a chained CTE pipeline
-- Step 1 and 2 calculate activity totals independently, then combine and filter in the final pipeline step;
WITH PostCounts AS (
    SELECT 
        OwnerUserId AS UserId, 
        COUNT(*) AS PostCount
    FROM Posts
    WHERE OwnerUserId IS NOT NULL
    GROUP BY OwnerUserId
),
CommentCounts AS (
    SELECT 
        UserId, 
        COUNT(*) AS CommentCount
    FROM Comments
    WHERE UserId IS NOT NULL
    GROUP BY UserId
),
UserActivityCombined AS (
    SELECT
        u.DisplayName,
        u.Reputation,
        COALESCE(p.PostCount, 0) AS PostCount,
        COALESCE(c.CommentCount, 0) AS CommentCount,
        COALESCE(p.PostCount, 0) + COALESCE(c.CommentCount, 0) AS TotalActivity
    FROM Users u
    LEFT JOIN PostCounts p ON u.Id = p.UserId
    LEFT JOIN CommentCounts c ON u.Id = c.UserId
)
SELECT
    DisplayName,
    Reputation,
    PostCount,
    CommentCount,
    TotalActivity
FROM UserActivityCombined
WHERE TotalActivity > 50
ORDER BY TotalActivity DESC
LIMIT 20;