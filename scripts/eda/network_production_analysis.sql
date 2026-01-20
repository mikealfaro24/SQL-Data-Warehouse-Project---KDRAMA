-- SQL Phase: Exploratory Data Analysis (EDA)
-- 6. Network & Production Analysis

-- These explore production and distribution patterns.

-- Which original networks have produced the most dramas?
SELECT
  onet.original_network,
  COUNT(*) AS drama_count
FROM drama_original_network don
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id
GROUP BY onet.original_network
ORDER BY drama_count DESC;

-- Which networks have the highest average drama ratings?
SELECT
  onet.original_network,
  COUNT(*) AS drama_count,
  ROUND(AVG(d.rating), 2) AS avg_rating
FROM drama_original_network don
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id
JOIN drama d
  ON don.drama_id = d.drama_id
GROUP BY onet.original_network
ORDER BY avg_rating DESC, drama_count DESC;

-- Which production companies appear most frequently?
SELECT
  pc.production_company,
  COUNT(*) AS drama_count
FROM drama_production_company dpc
JOIN production_company pc
  ON dpc.production_company_id = pc.production_company_id
GROUP BY pc.production_company
ORDER BY drama_count DESC;

-- Are certain production companies associated with higher-ranked dramas?
SELECT
  pc.production_company,
  COUNT(*) AS drama_count,
  ROUND(AVG(d.rank), 2) AS avg_rank
FROM drama_production_company dpc
JOIN production_company pc
  ON dpc.production_company_id = pc.production_company_id
JOIN drama d
  ON dpc.drama_id = d.drama_id
GROUP BY pc.production_company
ORDER BY avg_rank ASC, drama_count DESC;

-- How many dramas are associated with multiple production companies?
SELECT
  COUNT(*) AS dramas_with_multiple_production_companies
FROM (
  SELECT
    dpc.drama_id,
    COUNT(DISTINCT dpc.production_company_id) AS company_count
  FROM drama_production_company dpc
  GROUP BY dpc.drama_id
  HAVING company_count > 1
) t;