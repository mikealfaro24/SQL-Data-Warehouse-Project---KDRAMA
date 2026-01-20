/* ============================================================
   Advanced SQL Analysis 1: Rating vs Release-Year Baseline
   Question: Which dramas are above/below their release-year average?
   ============================================================ */
SELECT
  drama_id,
  drama_name,
  release_year,
  rating,
  ROUND(AVG(rating) OVER (PARTITION BY release_year), 2) AS release_year_avg_rating,
  ROUND(rating - AVG(rating) OVER (PARTITION BY release_year), 2) AS rating_vs_year,
  DENSE_RANK() OVER (PARTITION BY release_year ORDER BY rating DESC) AS rating_rank_within_year
FROM drama
ORDER BY release_year DESC, rating_vs_year DESC;

/* ============================================================
   Advanced SQL Analysis 2: Top-N Dramas per Genre (Rank Window)
   Question: For each genre, what are the top 3 dramas by rating?
   ============================================================ */

WITH genre_ranked AS (
  SELECT
    g.genre,
    d.drama_id,
    d.drama_name,
    d.rating,
    d.rank,
    ROW_NUMBER() OVER (
      PARTITION BY g.genre
      ORDER BY d.rating DESC, d.rank ASC, d.drama_name ASC
    ) AS rn
  FROM genre g
  JOIN drama_genre dg
    ON g.genre_id = dg.genre_id
  JOIN drama d
    ON dg.drama_id = d.drama_id
)
SELECT
  genre,
  drama_id,
  drama_name,
  rating,
  `rank`,
  rn AS position_within_genre
FROM genre_ranked
WHERE rn <= 3
ORDER BY genre ASC, position_within_genre ASC;


/* ------------------------------------------------------------
   Advanced SQL Analysis 3:
   Which original networks have produced the most dramas?

   Why:
   Establish baseline production volume and identify
   dominant networks in the dataset.
   ------------------------------------------------------------ */
SELECT
  onet.original_network,
  COUNT(DISTINCT d.drama_id) AS total_dramas
FROM drama d
JOIN drama_original_network don
  ON d.drama_id = don.drama_id
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id
GROUP BY onet.original_network
ORDER BY total_dramas DESC;


/* ------------------------------------------------------------
Advanced SQL Analysis 4:
   Which original networks have the highest average drama ratings?

   Why:
   Compare network performance independent of volume.
   Average rating is used as a high-level quality signal.
   ------------------------------------------------------------ */
SELECT
  onet.original_network,
  COUNT(DISTINCT d.drama_id) AS total_dramas,
  ROUND(AVG(d.rating), 2) AS avg_network_rating
FROM drama d
JOIN drama_original_network don
  ON d.drama_id = don.drama_id
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id
WHERE d.rating IS NOT NULL
GROUP BY onet.original_network
ORDER BY avg_network_rating DESC;


/* ------------------------------------------------------------
Advanced SQL Analysis 5:
   Which genres make up the largest share of each network’s catalog?

   Why:
   Identify genre specialization by calculating each genre’s
   share of a network’s total drama output.
   ------------------------------------------------------------ */
WITH network_genre_counts AS (
  SELECT
    onet.original_network,
    g.genre,
    COUNT(DISTINCT d.drama_id) AS drama_count
  FROM drama d
  JOIN drama_original_network don
    ON d.drama_id = don.drama_id
  JOIN original_network onet
    ON don.original_network_id = onet.original_network_id
  JOIN drama_genre dg
    ON d.drama_id = dg.drama_id
  JOIN genre g
    ON dg.genre_id = g.genre_id
  GROUP BY onet.original_network, g.genre
)
SELECT
  original_network,
  genre,
  drama_count,
  ROUND(
    drama_count / SUM(drama_count) OVER (PARTITION BY original_network) * 100,
    2
  ) AS genre_share_pct
FROM network_genre_counts
ORDER BY original_network, drama_count DESC;


/* ------------------------------------------------------------
Advanced SQL Analysis 6:
   Which network–genre combinations have the highest
   average ratings?

   Why:
   Connect genre focus to performance by evaluating
   average ratings at the network–genre level.
   ------------------------------------------------------------ */
SELECT
  onet.original_network,
  g.genre,
  COUNT(DISTINCT d.drama_id) AS drama_count,
  ROUND(AVG(d.rating), 2) AS avg_rating
FROM drama d
JOIN drama_original_network don
  ON d.drama_id = don.drama_id
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id
JOIN drama_genre dg
  ON d.drama_id = dg.drama_id
JOIN genre g
  ON dg.genre_id = g.genre_id
WHERE d.rating IS NOT NULL
GROUP BY onet.original_network, g.genre
ORDER BY avg_rating DESC;

/* ------------------------------------------------------------
Advanced SQL Analysis 7:
   Do networks with more focused genre portfolios
   perform better on average?

   Why:
   Compare genre diversity (number of unique genres)
   against average network rating to evaluate whether
   specialization correlates with performance.
   ------------------------------------------------------------ */
WITH network_genre_diversity AS (
  SELECT
    onet.original_network,
    COUNT(DISTINCT g.genre_id) AS genre_count,
    ROUND(AVG(d.rating), 2) AS avg_network_rating
  FROM drama d
  JOIN drama_original_network don
    ON d.drama_id = don.drama_id
  JOIN original_network onet
    ON don.original_network_id = onet.original_network_id
  JOIN drama_genre dg
    ON d.drama_id = dg.drama_id
  JOIN genre g
    ON dg.genre_id = g.genre_id
  WHERE d.rating IS NOT NULL
  GROUP BY onet.original_network
)
SELECT
  original_network,
  genre_count,
  avg_network_rating
FROM network_genre_diversity
ORDER BY genre_count ASC, avg_network_rating DESC;







  


