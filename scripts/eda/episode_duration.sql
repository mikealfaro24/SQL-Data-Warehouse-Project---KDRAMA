-- SQL Phase: Exploratory Data Analysis (EDA)
-- 5. Episode Duration & Structure

-- These questions help understand pacing and format.

-- What is the average episode duration across all dramas?
SELECT
  ROUND(AVG(duration_minutes), 2) AS avg_episode_duration_minutes
FROM drama;

-- How does episode duration vary by release year?
SELECT
  release_year,
  ROUND(AVG(duration_minutes), 2) AS avg_episode_duration_minutes
FROM drama
GROUP BY release_year
ORDER BY release_year;

-- What is the most common episode duration range?
SELECT
  CASE
    WHEN duration_minutes < 30 THEN '<30'
    WHEN duration_minutes BETWEEN 30 AND 44 THEN '30-44'
    WHEN duration_minutes BETWEEN 45 AND 59 THEN '45-59'
    WHEN duration_minutes BETWEEN 60 AND 74 THEN '60-74'
    WHEN duration_minutes BETWEEN 75 AND 89 THEN '75-89'
    WHEN duration_minutes >= 90 THEN '90+'
    ELSE 'Unknown'
  END AS duration_bucket,
  COUNT(*) AS drama_count
FROM drama
WHERE duration_minutes IS NOT NULL
GROUP BY duration_bucket
ORDER BY drama_count DESC;