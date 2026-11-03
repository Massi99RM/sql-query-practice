-- Question: Find tags used in more than 500 posts by deriving the count directly from the posts tags column
-- Tags are stored as |tag1|tag2|tag3| (pipe-delimited, with leading/trailing pipes) — 
-- discovered this by inspecting raw values after an initial wrong assumption that they were
-- wrapped like <tag1><tag2>. Trimming the outer pipes first allows a clean split on '|'.
-- Cross-checked against Tags.Count (1.5): counts match closely, small drift is expected
-- since Tags.Count reflects live data and this is a point-in-time dump.
SELECT
    tag AS TagName,
    COUNT(*) AS DerivedCount
FROM Posts,
LATERAL unnest(string_to_array(btrim(Posts.Tags, '|'), '|')) AS tag
WHERE Posts.Tags IS NOT NULL
  AND Posts.Tags <> ''
GROUP BY TagName
HAVING COUNT(*) > 500
ORDER BY DerivedCount DESC;