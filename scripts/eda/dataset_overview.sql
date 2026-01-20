-- SQL Phase: Exploratory Data Analysis (EDA)
-- 1. Dataset Coverage

USE kdrama_db;

-- How many dramas are in the database?
SELECT
	COUNT(drama_id) AS total_dramas
FROM drama;

-- How many dramas have both an aired start and end date?
SELECT COUNT(drama_id) AS count_of_drama_both_dates
FROM drama
WHERE aired_start_date IS NOT NULL
  AND aired_end_date IS NOT NULL;


-- How many dramas are missing an aired end date?
SELECT 
	COUNT(drama_id) AS count_of_drama_missing_end_date
FROM drama
WHERE aired_end_date IS NULL;

-- What is the distribution of dramas by release year?
SELECT 
	release_year,
	COUNT(drama_id) AS count_of_drama_release_year
FROM drama
GROUP BY release_year
ORDER BY count_of_drama_release_year DESC;

-- What is the range of episode counts across all dramas?

SELECT 
	MIN(num_episodes) AS min_num_episode,
    MAX(num_episodes) AS max_num_episode
FROM drama;




