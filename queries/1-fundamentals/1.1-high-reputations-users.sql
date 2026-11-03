-- Question: Find all users with a reputation greater than 10,000
-- Basic WHERE filtering combined with ORDER BY DESC to rank top users;
SELECT
    DisplayName,
    Reputation
FROM Users
WHERE Reputation > 10000
ORDER BY Reputation DESC;