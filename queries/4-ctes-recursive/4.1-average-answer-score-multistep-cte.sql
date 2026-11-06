-- Question: Find questions with at least 3 answers and their average answer score using multi-step CTEs
-- Breaking down the logic into named CTE steps to improve readability and query structure;
WITH AnswerStats AS (
    SELECT
        ParentId AS QuestionId,
        AVG(Score) AS AvgAnswerScore,
        COUNT(Id) AS AnswerCount
    FROM Posts
    WHERE PostTypeId = 2
    GROUP BY ParentId
    HAVING COUNT(Id) >= 3
),
QualifiedQuestions AS (
    SELECT
        q.Title,
        ast.AvgAnswerScore,
        ast.AnswerCount
    FROM AnswerStats ast
    JOIN Posts q ON ast.QuestionId = q.Id
    WHERE q.PostTypeId = 1
)
SELECT
    Title,
    AvgAnswerScore,
    AnswerCount
FROM QualifiedQuestions
ORDER BY AvgAnswerScore DESC
LIMIT 10;