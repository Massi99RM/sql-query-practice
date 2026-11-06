-- Question: Walk down from a specific question to its direct answers using a recursive CTE
-- Demonstrates recursive hierarchy traversal; on this schema it terminates after one level because answers have no sub-answers;
WITH RECURSIVE PostHierarchy AS (
    -- Base case: pick a specific question (PostTypeId = 1)
    SELECT
        Id,
        ParentId,
        Title,
        PostTypeId,
        1 AS depth
    FROM Posts
    WHERE PostTypeId = 1
      AND Id = 7 -- Arbitrary valid question Id from the database
    
    UNION ALL
    
    -- Recursive step: find direct answers linked by ParentId (terminates after 1 level since answers have no children)
    SELECT
        p.Id,
        p.ParentId,
        p.Title,
        p.PostTypeId,
        ph.depth + 1
    FROM Posts p
    JOIN PostHierarchy ph ON p.ParentId = ph.Id
    WHERE p.PostTypeId = 2
)
SELECT
    Id,
    ParentId,
    PostTypeId,
    depth,
    LEFT(COALESCE(Title, 'Answer Node'), 50) AS TitleOrContext
FROM PostHierarchy;