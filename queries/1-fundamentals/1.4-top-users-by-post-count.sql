-- Question: Find the top 10 users with the most posts made
-- Grouping by user ID and DisplayName allows counting posts per user while handling users with identical display names correctly;
SELECT
    u.DisplayName,
    COUNT(p.Id) AS PostCount
FROM Users u
JOIN Posts p ON u.Id = p.OwnerUserId
GROUP BY u.Id, u.DisplayName
ORDER BY PostCount DESC
LIMIT 10;