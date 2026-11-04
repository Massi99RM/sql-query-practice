-- Question: For each post, show its Title, author DisplayName, and comment count
-- Combining a primary join with Users and a left join with Comments, using GROUP BY to aggregate comment counts per post;
SELECT
    COALESCE(p.Title, 'Untitled Post') AS Title,
    u.DisplayName,
    COUNT(c.Id) AS CommentCount
FROM Posts p
LEFT JOIN Users u ON p.OwnerUserId = u.Id
LEFT JOIN Comments c ON p.Id = c.PostId
GROUP BY p.Id, p.Title, u.DisplayName
ORDER BY CommentCount DESC
LIMIT 15;