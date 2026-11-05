-- Question: Show each post alongside the author's average post score using window aggregates
-- Combining window functions with regular SELECT columns preserves individual rows while calculating author-wide metrics;
SELECT
    Title,
    Score,
    OwnerUserId,
    AVG(Score) OVER (PARTITION BY OwnerUserId) AS AuthorAvgScore
FROM Posts
WHERE OwnerUserId IS NOT NULL
  AND Title IS NOT NULL
LIMIT 20;