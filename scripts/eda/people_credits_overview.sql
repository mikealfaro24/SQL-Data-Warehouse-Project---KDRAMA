-- SQL Phase: Exploratory Data Analysis (EDA)
-- 7. People & Credits Overview

-- Which actors appear in the most dramas?
SELECT
  CONCAT(cn.first_name, ' ', cn.last_name) AS actor_name,
  COUNT(*) AS drama_count
FROM drama_cast_name dcn
JOIN cast_name cn
  ON dcn.cast_name_id = cn.cast_name_id
GROUP BY cn.cast_name_id, cn.first_name, cn.last_name
ORDER BY drama_count DESC;

-- Which directors have worked on the most dramas?
SELECT
  CONCAT(d.first_name, ' ', d.last_name) AS director_name,
  COUNT(*) AS drama_count
FROM drama_director dd
JOIN director d
  ON dd.director_id = d.director_id
GROUP BY d.director_id, d.first_name, d.last_name
ORDER BY drama_count DESC;

-- Which screenwriters have contributed to the most dramas?
SELECT
  CONCAT(s.first_name, ' ', s.last_name) AS screenwriter_name,
  COUNT(*) AS drama_count
FROM drama_screenwriter ds
JOIN screenwriter s
  ON ds.screenwriter_id = s.screenwriter_id
GROUP BY s.screenwriter_id, s.first_name, s.last_name
ORDER BY drama_count DESC;


-- How often do the same director and screenwriter collaborate?
SELECT
  CONCAT(d.first_name, ' ', d.last_name) AS director_name,
  CONCAT(s.first_name, ' ', s.last_name) AS screenwriter_name,
  COUNT(DISTINCT dd.drama_id) AS shared_drama_count
FROM drama_director dd
JOIN director d
  ON dd.director_id = d.director_id
JOIN drama_screenwriter ds
  ON dd.drama_id = ds.drama_id
JOIN screenwriter s
  ON ds.screenwriter_id = s.screenwriter_id
GROUP BY d.director_id, d.first_name, d.last_name,
         s.screenwriter_id, s.first_name, s.last_name
ORDER BY shared_drama_count DESC;