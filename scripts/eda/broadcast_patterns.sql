-- -- SQL Phase: Exploratory Data Analysis (EDA)
-- 4. Broadcast Patterns

-- These examine scheduling behavior.

-- On which days of the week do dramas most commonly air?
SELECT 
	d.day_name,
    COUNT(dd.day_id) AS count_of_days
FROM day d
INNER JOIN  drama_day dd 
ON d.day_id = dd.day_id
GROUP BY d.day_name
ORDER BY count_of_days DESC;

-- How many dramas air on multiple days?
SELECT 
	COUNT(t.drama_id) AS count_of_drama_multiple_days
FROM (
SELECT 
	d.drama_id,
	COUNT(dd.day_id) AS count_of_days
FROM drama_day dd 
INNER JOIN drama d
ON d.drama_id = dd.drama_id
GROUP BY d.drama_id
HAVING count_of_days > 1) t;



-- Are certain days associated with higher-rated dramas?
SELECT
    day.day_name,
    COUNT(*) AS drama_count,
    ROUND(AVG(d.rating), 2) AS avg_rating
FROM drama d
JOIN drama_day dd
    ON d.drama_id = dd.drama_id
JOIN day
    ON dd.day_id = day.day_id
GROUP BY day.day_name
ORDER BY avg_rating DESC;


-- What is the most common broadcast day combination?
SELECT
    GROUP_CONCAT(day.day_name ORDER BY day.day_name SEPARATOR ', ') AS day_combination,
    COUNT(*) AS drama_count
FROM drama_day dd
JOIN day
    ON dd.day_id = day.day_id
GROUP BY dd.drama_id
ORDER BY drama_count DESC;


