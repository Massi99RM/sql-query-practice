-- Question: Calculate the time gap between consecutive posts for a specific user using LAG()
-- Partitioning by user and ordering by date allows tracking activity intervals with previous row access;
SELECT
    u.DisplayName,
    p.CreationDate,
    p.Id,
    p.Title,
    LAG(p.CreationDate) OVER (PARTITION BY p.OwnerUserId ORDER BY p.CreationDate) AS PreviousPostDate,
    p.CreationDate - LAG(p.CreationDate) OVER (PARTITION BY p.OwnerUserId ORDER BY p.CreationDate) AS Gap
FROM Posts p
JOIN Users u ON p.OwnerUserId = u.Id
WHERE u.DisplayName = 'KRyan'
ORDER BY p.CreationDate;