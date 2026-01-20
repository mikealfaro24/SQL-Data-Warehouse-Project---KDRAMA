-- ============================================================
-- View: vw_drama_base
-- Purpose: Core drama attributes used across analytical queries
-- Grain: One row per drama
-- Dependencies: drama
-- ============================================================

DROP VIEW IF EXISTS vw_drama_base;

CREATE VIEW vw_drama_base AS
SELECT
  drama_id,
  drama_name,
  release_year,
  rating,
  `rank`
FROM drama;

-- ============================================================
-- View: vw_drama_network
-- Purpose: Simplifies drama-to-network relationship
-- Grain: One row per drama–network combination
-- Dependencies: drama, drama_original_network, original_network
-- ============================================================

DROP VIEW IF EXISTS vw_drama_network;

CREATE VIEW vw_drama_network AS
SELECT
  d.drama_id,
  d.drama_name,
  d.release_year,
  d.rating,
  onet.original_network
FROM drama d
JOIN drama_original_network don
  ON d.drama_id = don.drama_id
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id;
  
-- ============================================================
-- View: vw_drama_genre
-- Purpose: Simplifies drama-to-genre relationship
-- Grain: One row per drama–genre combination
-- Dependencies: drama, drama_genre, genre
-- ============================================================

DROP VIEW IF EXISTS vw_drama_genre;

CREATE VIEW vw_drama_genre AS
SELECT
  d.drama_id,
  d.drama_name,
  d.release_year,
  d.rating,
  g.genre
FROM drama d
JOIN drama_genre dg
  ON d.drama_id = dg.drama_id
JOIN genre g
  ON dg.genre_id = g.genre_id;
  
-- ============================================================
-- View: vw_drama_network_genre
-- Purpose: Central analytical view combining drama, network, and genre
-- Grain: One row per drama–network–genre combination
-- Usage: Foundation for most business-facing analytics
-- Dependencies: drama, drama_original_network, original_network,
--               drama_genre, genre
-- ============================================================

DROP VIEW IF EXISTS vw_drama_network_genre;

CREATE VIEW vw_drama_network_genre AS
SELECT
  d.drama_id,
  d.drama_name,
  d.release_year,
  d.rating,
  onet.original_network,
  g.genre
FROM drama d
JOIN drama_original_network don
  ON d.drama_id = don.drama_id
JOIN original_network onet
  ON don.original_network_id = onet.original_network_id
JOIN drama_genre dg
  ON d.drama_id = dg.drama_id
JOIN genre g
  ON dg.genre_id = g.genre_id;
  
-- ============================================================
-- BUSINESS / ANALYTICS VIEWS
-- Purpose:
-- These views answer specific analytical or business questions and are built on top of foundation views.

-- ============================================================
-- View: vw_network_volume
-- Purpose: Measure production volume by original network
-- Grain: One row per network
-- Metric: total_dramas
-- Dependencies: vw_drama_network
-- ============================================================

DROP VIEW IF EXISTS vw_network_volume;

CREATE VIEW vw_network_volume AS
SELECT
  original_network,
  COUNT(DISTINCT drama_id) AS total_dramas
FROM vw_drama_network
GROUP BY original_network;

-- ============================================================
-- View: vw_network_quality
-- Purpose: Evaluate average drama rating per network
-- Grain: One row per network
-- Metrics: total_dramas, avg_network_rating
-- Dependencies: vw_drama_network
-- ============================================================

DROP VIEW IF EXISTS vw_network_quality;

CREATE VIEW vw_network_quality AS
SELECT
  original_network,
  COUNT(DISTINCT drama_id) AS total_dramas,
  ROUND(AVG(rating), 2) AS avg_network_rating
FROM vw_drama_network
WHERE rating IS NOT NULL
GROUP BY original_network;

-- ============================================================
-- View: vw_network_genre_share
-- Purpose: Identify genre specialization per network
-- Grain: One row per network–genre
-- Metric: genre_share_pct (percent of network catalog)
-- Dependencies: vw_drama_network_genre
-- ============================================================

DROP VIEW IF EXISTS vw_network_genre_share;

CREATE VIEW vw_network_genre_share AS
SELECT
  original_network,
  genre,
  COUNT(DISTINCT drama_id) AS drama_count,
  ROUND(
    COUNT(DISTINCT drama_id)
    / SUM(COUNT(DISTINCT drama_id)) OVER (PARTITION BY original_network)
    * 100,
    2
  ) AS genre_share_pct
FROM vw_drama_network_genre
GROUP BY original_network, genre;

-- ============================================================
-- View: vw_network_genre_performance
-- Purpose: Measure average rating at the network–genre level
-- Grain: One row per network–genre
-- Metrics: drama_count, avg_rating
-- Dependencies: vw_drama_network_genre
-- ============================================================

DROP VIEW IF EXISTS vw_network_genre_performance;

CREATE VIEW vw_network_genre_performance AS
SELECT
  original_network,
  genre,
  COUNT(DISTINCT drama_id) AS drama_count,
  ROUND(AVG(rating), 2) AS avg_rating
FROM vw_drama_network_genre
WHERE rating IS NOT NULL
GROUP BY original_network, genre;

-- ============================================================
-- View: vw_network_genre_diversity
-- Purpose: Compare genre breadth against average network rating
-- Grain: One row per network
-- Metrics: genre_count, avg_network_rating
-- Dependencies: vw_drama_network_genre
-- ============================================================

DROP VIEW IF EXISTS vw_network_genre_diversity;

CREATE VIEW vw_network_genre_diversity AS
SELECT
  original_network,
  COUNT(DISTINCT genre) AS genre_count,
  ROUND(AVG(rating), 2) AS avg_network_rating
FROM vw_drama_network_genre
WHERE rating IS NOT NULL
GROUP BY original_network;

-- ============================================================
-- View: vw_release_year_rating_baseline
-- Purpose: Normalize drama ratings by release-year averages
-- Grain: One row per drama
-- Metrics: release_year_avg_rating, rating_vs_year,
--          rating_rank_within_year
-- Dependencies: vw_drama_base
-- ============================================================

DROP VIEW IF EXISTS vw_release_year_rating_baseline;

CREATE VIEW vw_release_year_rating_baseline AS
SELECT
  drama_id,
  drama_name,
  release_year,
  rating,
  ROUND(AVG(rating) OVER (PARTITION BY release_year), 2) AS release_year_avg_rating,
  ROUND(
    rating - AVG(rating) OVER (PARTITION BY release_year),
    2
  ) AS rating_vs_year,
  DENSE_RANK() OVER (
    PARTITION BY release_year
    ORDER BY rating DESC
  ) AS rating_rank_within_year
FROM vw_drama_base;











