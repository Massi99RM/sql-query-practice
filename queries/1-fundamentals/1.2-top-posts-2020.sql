-- Question: Find all posts created in 2020 with a score greater than 5
-- Using a date range (>= '2020-01-01' AND < '2021-01-01') is safer and faster for indexing than wrapping CreationDate in an EXTRACT function;
SELECT
    Id,
    Title,
    Score,
    CreationDate
FROM Posts
WHERE CreationDate >= '2020-01-01' 
  AND CreationDate < '2021-01-01'
  AND Score > 5;