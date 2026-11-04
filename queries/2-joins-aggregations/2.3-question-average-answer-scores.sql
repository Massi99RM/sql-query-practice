-- Question: Find questions with at least 3 answers and their average answer score
-- Joining Posts (questions) to Posts (answers) via ParentId, then filtering aggregated groups with HAVING;
SELECT
    q.Title,
    AVG(a.Score) AS AvgAnswerScore,
    COUNT(a.Id) AS AnswerCount
FROM Posts q
JOIN Posts a ON q.Id = a.ParentId
WHERE q.PostTypeId = 1 
  AND a.PostTypeId = 2
GROUP BY q.Id, q.Title
HAVING COUNT(a.Id) >= 3
ORDER BY AvgAnswerScore DESC
LIMIT 10;