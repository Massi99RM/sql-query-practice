-- Question: Generate a sequence of numbers from 1 to 20 using a recursive CTE
-- A recursive CTE combines a non-recursive base case with a recursive step joined via UNION ALL;
WITH RECURSIVE NumberSequence AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM NumberSequence
    WHERE n < 20
)
SELECT n
FROM NumberSequence;