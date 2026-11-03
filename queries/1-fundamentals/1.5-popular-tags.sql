-- Question: Find all tags used in more than 500 posts
-- The Tags table already tracks the usage count, making this a simple filtered select without needing a heavy GROUP BY on Posts;
SELECT
    TagName,
    Count
FROM Tags
WHERE Count > 500
ORDER BY Count DESC;