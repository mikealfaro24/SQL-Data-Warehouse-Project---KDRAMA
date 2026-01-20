-- SQL Phase: Exploratory Data Analysis (EDA)
-- 3. Genre Overview

-- Which genres appear most frequently?
SELECT 
	g.genre,
    COUNT(dg.genre_id) AS count_of_genre
FROM genre g  
LEFT JOIN drama_genre dg 
ON g.genre_id = dg.genre_id
GROUP BY g.genre
ORDER BY count_of_genre DESC;

-- Which drama has the highest number of genres?

SELECT
    d.drama_name,
    COUNT(dg.genre_id) AS genre_count
FROM drama d
JOIN drama_genre dg
    ON d.drama_id = dg.drama_id
GROUP BY d.drama_id, d.drama_name
ORDER BY genre_count DESC;


-- What is the average rating by genre?
SELECT 
	g.genre,
    ROUND(AVG(d.rating), 2) AS avg_rating_genre
FROM genre g  
LEFT JOIN drama_genre dg 
ON g.genre_id = dg.genre_id
LEFT JOIN drama d
ON d.drama_id = dg.drama_id
GROUP BY g.genre
ORDER BY avg_rating_genre DESC;

-- Which genres are most common among top-ranked dramas?

SELECT
    g.genre,
    COUNT(*) AS drama_count
FROM drama d
JOIN drama_genre dg
    ON d.drama_id = dg.drama_id
JOIN genre g
    ON dg.genre_id = g.genre_id
WHERE d.rank <= 50
GROUP BY g.genre
ORDER BY drama_count DESC;

-- How many unique genres does the average drama have?

SELECT
    ROUND(AVG(genre_count), 2) AS avg_genres_per_drama
FROM (
    SELECT
        drama_id,
        COUNT(genre_id) AS genre_count
    FROM drama_genre
    GROUP BY drama_id
) AS genre_counts;
