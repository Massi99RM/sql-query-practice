-- Question: Find individual tags with over 100 uses and calculate the average score of their posts
-- Using pipe-delimited string parsing to isolate individual tags before joining and aggregating score statistics;
SELECT
    tag AS TagName,
    AVG(p.Score) AS AvgScore,
    COUNT(p.Id) AS PostCount
FROM Posts p
CROSS JOIN LATERAL unnest(string_to_array(btrim(p.Tags, '|'), '|')) AS tag
WHERE p.Tags IS NOT NULL 
  AND p.Tags <> ''
  AND tag <> ''
GROUP BY tag
HAVING COUNT(p.Id) > 100
ORDER BY AvgScore DESC
LIMIT 10;