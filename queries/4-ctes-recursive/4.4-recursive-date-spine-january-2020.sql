-- Question: Generate a complete date spine for January 2020 and left join to posts to include zero-activity days
-- Explicitly casting the date column ensures type consistency between the non-recursive base case and recursive step;
WITH RECURSIVE DateSpine AS (
    SELECT TIMESTAMP '2020-01-01 00:00:00' AS dt
    UNION ALL
    SELECT dt + INTERVAL '1 day'
    FROM DateSpine
    WHERE dt < TIMESTAMP '2020-01-31 00:00:00'
)
SELECT
    ds.dt::date AS PostDate,
    COUNT(p.Id) AS PostCount
FROM DateSpine ds
LEFT JOIN Posts p ON DATE(p.CreationDate) = ds.dt::date
GROUP BY ds.dt
ORDER BY ds.dt;