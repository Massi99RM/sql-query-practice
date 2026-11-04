-- Question: Count questions versus answers per user using conditional aggregation
-- Using CASE WHEN inside SUM to pivot post types into separate columns per user;
SELECT
    u.DisplayName,
    SUM(CASE WHEN p.PostTypeId = 1 THEN 1 ELSE 0 END) AS QuestionCount,
    SUM(CASE WHEN p.PostTypeId = 2 THEN 1 ELSE 0 END) AS AnswerCount,
    COUNT(p.Id) AS TotalPosts
FROM Users u
JOIN Posts p ON u.Id = p.OwnerUserId
GROUP BY u.Id, u.DisplayName
ORDER BY TotalPosts DESC
LIMIT 10;