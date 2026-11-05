-- Question: Calculate a cumulative running total of posts for the dnd-5e tag over time
-- Framing the window function with ORDER BY creates a cumulative sum of posts ordered chronologically;
SELECT
    CreationDate,
    Title,
    COUNT(*) OVER (ORDER BY CreationDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeCount
FROM Posts
WHERE Tags LIKE '%|dnd-5e|%'
  AND Title IS NOT NULL
ORDER BY CreationDate
LIMIT 50;