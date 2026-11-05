-- Question: Compare RANK, DENSE_RANK, and ROW_NUMBER side by side on tied badge counts
-- Filtering to a specific tier of badge counts allows observing how each ranking function handles ties differently;
WITH UserBadges AS (
    SELECT
        u.DisplayName,
        COUNT(b.Id) AS BadgeCount
    FROM Users u
    JOIN Badges b ON u.Id = b.UserId
    GROUP BY u.Id, u.DisplayName
),
RankedUsers AS (
    SELECT
        DisplayName,
        BadgeCount,
        RANK() OVER (ORDER BY BadgeCount DESC) AS RankVal,
        DENSE_RANK() OVER (ORDER BY BadgeCount DESC) AS DenseRankVal,
        ROW_NUMBER() OVER (ORDER BY BadgeCount DESC) AS RowNumVal
    FROM UserBadges
)
SELECT *
FROM RankedUsers
WHERE BadgeCount BETWEEN 10 and 15
ORDER BY BadgeCount DESC, DisplayName
LIMIT 15;
