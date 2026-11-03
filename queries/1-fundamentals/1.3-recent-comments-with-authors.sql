-- Question: List the 10 most recent comments showing text, author name, and date
-- Joining Comments to Users using UserId and sorting by date descending gives the latest activity feed;
SELECT
    c.Text,
    u.DisplayName,
    c.CreationDate
FROM Comments c
JOIN Users u ON c.UserId = u.Id
ORDER BY c.CreationDate DESC
LIMIT 10;