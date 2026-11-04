-- Question: Find top 10 users by reputation who have never posted a comment
-- Using NOT EXISTS with a subquery against Comments to exclude active commenters efficiently;
SELECT
    u.DisplayName,
    u.Reputation
FROM Users u
WHERE NOT EXISTS (
    SELECT 1 
    FROM Comments c 
    WHERE c.UserId = u.Id
)
ORDER BY u.Reputation DESC
LIMIT 10;