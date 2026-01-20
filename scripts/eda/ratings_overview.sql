-- SQL Phase: Exploratory Data Analysis (EDA)
-- 2. Ratings Overview

-- What are the highest-rated dramas overall?
SELECT 
	drama_name,
    rating
FROM drama
ORDER BY rating DESC
LIMIT 10;

-- What is the average rating across all dramas?
SELECT 
    ROUND(AVG(rating), 2) AS avg_drama_rating
FROM drama;

-- How do ratings vary by release year?
SELECT 
	release_year,
    ROUND(AVG(rating), 2) AS avg_drama_rating
FROM drama
GROUP BY release_year
ORDER BY avg_drama_rating DESC;


