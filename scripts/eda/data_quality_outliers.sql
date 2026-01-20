-- SQL Phase: Exploratory Data Analysis (EDA)
-- 10. Data Quality & Outliers 

-- Are there dramas with unusually high episode counts?
-- (more than 2x the overall average)
SELECT
  drama_name,
  num_episodes
FROM drama
WHERE num_episodes >
  (
    SELECT AVG(num_episodes) * 2
    FROM drama
    WHERE num_episodes IS NOT NULL
  )
ORDER BY num_episodes DESC;


-- Are there outliers in episode duration?
SELECT
  drama_name,
  duration_minutes
FROM drama
WHERE duration_minutes < 30
   OR duration_minutes > 120
ORDER BY duration_minutes DESC;


-- Are there outliers in ratings?
-- (Ratings very low or very high compared to typical range)
SELECT
  drama_name,
  rating
FROM drama
WHERE rating < 6.0
   OR rating > 9.5
ORDER BY rating DESC;


-- Are there any genres represented by only a single drama?
SELECT
  g.genre,
  COUNT(DISTINCT dg.drama_id) AS drama_count
FROM genre g
LEFT JOIN drama_genre dg
  ON g.genre_id = dg.genre_id
GROUP BY g.genre
HAVING drama_count = 1;


-- Are there any networks represented by only a single drama?
SELECT
  onet.original_network,
  COUNT(DISTINCT don.drama_id) AS drama_count
FROM original_network onet
LEFT JOIN drama_original_network don
  ON onet.original_network_id = don.original_network_id
GROUP BY onet.original_network
HAVING drama_count = 1;


-- Are there dramas with unusually long airing periods?
-- (Define long-running as more than 180 days)
SELECT
  drama_name,
  DATEDIFF(aired_end_date, aired_start_date) AS airing_days
FROM drama
WHERE aired_start_date IS NOT NULL
  AND aired_end_date IS NOT NULL
  AND DATEDIFF(aired_end_date, aired_start_date) > 180
ORDER BY airing_days DESC; 
