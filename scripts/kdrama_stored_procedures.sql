DELIMITER $$

-- ============================================================
-- Procedure: sp_get_network_summary
-- Purpose:
--   Quick “network report card” that combines:
--   1) how many dramas a network produced (volume)
--   2) average rating of that network’s dramas (quality)
--   3) how many unique genres it covers (diversity)
--
-- Parameters:
--   p_min_dramas (INT)
--     - What it expects: a number like 5, 10, 20
--     - Meaning: only show networks with at least this many dramas
--     - If you pass NULL: shows ALL networks
--
-- Output (records returned):
--   One row per original_network with:
--     original_network, total_dramas, avg_network_rating, genre_count
--
-- Views used:
--   vw_network_volume, vw_network_quality, vw_network_genre_diversity
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_network_summary $$
CREATE PROCEDURE sp_get_network_summary (
  IN p_min_dramas INT
)
BEGIN
  SELECT
    v.original_network,
    v.total_dramas,
    q.avg_network_rating,
    d.genre_count
  FROM vw_network_volume v
  LEFT JOIN vw_network_quality q
    ON v.original_network = q.original_network
  LEFT JOIN vw_network_genre_diversity d
    ON v.original_network = d.original_network
  WHERE (p_min_dramas IS NULL OR v.total_dramas >= p_min_dramas)
  ORDER BY q.avg_network_rating DESC, v.total_dramas DESC;
END $$


-- ============================================================
-- Procedure: sp_get_top_dramas_for_network
-- Purpose:
--   Returns the best dramas (highest ratings) for ONE network.
--
-- Parameters:
--   p_network (VARCHAR)
--     - What it expects: exact network name from data
--       Examples: 'Netflix', 'tvN', 'SBS'
--     - Meaning: only return dramas from this network
--
--   p_limit_n (INT)
--     - What it expects: a number like 5, 10, 20
--     - Meaning: how many dramas to return
--     - If NULL or < 1: defaults to 10
--
-- Output (records returned):
--   Up to N rows (one row per drama) with:
--     original_network, drama_id, drama_name, release_year, rating
--
-- View used:
--   vw_drama_network
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_top_dramas_for_network $$
CREATE PROCEDURE sp_get_top_dramas_for_network (
  IN p_network VARCHAR(100),
  IN p_limit_n INT
)
BEGIN
  IF p_limit_n IS NULL OR p_limit_n < 1 THEN
    SET p_limit_n = 10;
  END IF;

  SELECT
    original_network,
    drama_id,
    drama_name,
    release_year,
    rating
  FROM vw_drama_network
  WHERE original_network = p_network
    AND rating IS NOT NULL
  GROUP BY original_network, drama_id, drama_name, release_year, rating
  ORDER BY rating DESC, release_year DESC, drama_name ASC
  LIMIT p_limit_n;
END $$


-- ============================================================
-- Procedure: sp_get_genre_breakdown_for_network
-- Purpose:
--   Shows what genres make up the network’s catalog.
--   This is the “genre specialization” view in a reusable procedure.
--
-- Parameters:
--   p_network (VARCHAR)
--     - What it expects: exact network name
--       Examples: 'Netflix', 'tvN', 'OCN'
--     - Meaning: only return genres for this network
--
-- Output (records returned):
--   Multiple rows (one row per genre for that network) with:
--     original_network, genre, drama_count, genre_share_pct
--   Records are sorted so the largest % genre appears first.
--
-- View used:
--   vw_network_genre_share
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_genre_breakdown_for_network $$
CREATE PROCEDURE sp_get_genre_breakdown_for_network (
  IN p_network VARCHAR(100)
)
BEGIN
  SELECT
    original_network,
    genre,
    drama_count,
    genre_share_pct
  FROM vw_network_genre_share
  WHERE original_network = p_network
  ORDER BY genre_share_pct DESC, drama_count DESC, genre ASC;
END $$


-- ============================================================
-- Procedure: sp_get_genre_performance_for_network
-- Purpose:
--   Shows which genres a network performs best in (avg rating).
--   Helpful for answering: “What is this network strongest at?”
--
-- Parameters:
--   p_network (VARCHAR)
--     - What it expects: exact network name
--       Examples: 'Netflix', 'tvN'
--
--   p_min_genre_dramas (INT)
--     - What it expects: a number like 2, 3, 5
--     - Meaning: filters out genres with tiny sample sizes
--       Example: if set to 3, only genres with 3+ dramas appear
--     - If NULL: shows all genres regardless of drama_count
--
-- Output (records returned):
--   Multiple rows (one row per genre for that network) with:
--     original_network, genre, drama_count, avg_rating
--   Records are sorted so the highest-rated genres appear first.
--
-- View used:
--   vw_network_genre_performance
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_genre_performance_for_network $$
CREATE PROCEDURE sp_get_genre_performance_for_network (
  IN p_network VARCHAR(100),
  IN p_min_genre_dramas INT
)
BEGIN
  SELECT
    original_network,
    genre,
    drama_count,
    avg_rating
  FROM vw_network_genre_performance
  WHERE original_network = p_network
    AND (p_min_genre_dramas IS NULL OR drama_count >= p_min_genre_dramas)
  ORDER BY avg_rating DESC, drama_count DESC, genre ASC;
END $$


-- ============================================================
-- Procedure: sp_get_top_network_genre_pairs
-- Purpose:
--   Finds the best-performing network + genre combinations overall.
--
-- Parameters:
--   p_min_dramas (INT)
--     - What it expects: a number like 3, 5, 10
--     - Meaning: only include network–genre pairs with at least this many dramas
--     - If NULL or < 1: defaults to 3
--
--   p_limit_n (INT)
--     - What it expects: a number like 10, 20, 50
--     - Meaning: how many results to return
--     - If NULL or < 1: defaults to 25
--
-- Output (records returned):
--   Up to N rows (one row per network–genre pair) with:
--     original_network, genre, drama_count, avg_rating
--   Records are sorted by highest avg_rating first.
--
-- View used:
--   vw_network_genre_performance
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_top_network_genre_pairs $$
CREATE PROCEDURE sp_get_top_network_genre_pairs (
  IN p_min_dramas INT,
  IN p_limit_n INT
)
BEGIN
  IF p_min_dramas IS NULL OR p_min_dramas < 1 THEN
    SET p_min_dramas = 3;
  END IF;

  IF p_limit_n IS NULL OR p_limit_n < 1 THEN
    SET p_limit_n = 25;
  END IF;

  SELECT
    original_network,
    genre,
    drama_count,
    avg_rating
  FROM vw_network_genre_performance
  WHERE drama_count >= p_min_dramas
  ORDER BY avg_rating DESC, drama_count DESC, original_network ASC, genre ASC
  LIMIT p_limit_n;
END $$


DELIMITER $$

-- ============================================================
-- Procedure: sp_get_year_outperformers
-- Purpose:
--   Finds dramas that performed ABOVE their release-year average.
--   Adds an optional filter to focus on a specific release year.
--
-- Parameters:
--   p_release_year (INT)
--     - What it expects: a year like 2018, 2020, 2023
--     - Meaning: only include dramas from this release year
--     - If NULL: includes dramas from ALL years
--
--   p_limit_n (INT)
--     - What it expects: a number like 10, 25, 50
--     - Meaning: how many dramas to return
--     - If NULL or < 1: defaults to 25
--
-- Output (records returned):
--   Up to N rows (one row per drama), sorted by highest
--   rating_vs_year first.
--
-- View used:
--   vw_release_year_rating_baseline
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_year_outperformers $$
CREATE PROCEDURE sp_get_year_outperformers (
  IN p_release_year INT,
  IN p_limit_n INT
)
BEGIN
  IF p_limit_n IS NULL OR p_limit_n < 1 THEN
    SET p_limit_n = 25;
  END IF;

  SELECT
    drama_id,
    drama_name,
    release_year,
    rating,
    release_year_avg_rating,
    rating_vs_year,
    rating_rank_within_year
  FROM vw_release_year_rating_baseline
  WHERE rating IS NOT NULL
    AND (p_release_year IS NULL OR release_year = p_release_year)
  ORDER BY rating_vs_year DESC, rating DESC
  LIMIT p_limit_n;
END $$


-- ============================================================
-- Procedure: sp_get_year_underperformers
-- Purpose:
--   Finds dramas that performed BELOW their release-year average.
--   Adds an optional filter to focus on a specific release year.
--
-- Parameters:
--   p_release_year (INT)
--     - What it expects: a year like 2018, 2020, 2023
--     - Meaning: only include dramas from this release year
--     - If NULL: includes dramas from ALL years
--
--   p_limit_n (INT)
--     - What it expects: a number like 10, 25, 50
--     - Meaning: how many dramas to return
--     - If NULL or < 1: defaults to 25
--
-- Output (records returned):
--   Up to N rows (one row per drama), sorted by lowest
--   rating_vs_year first.
--
-- View used:
--   vw_release_year_rating_baseline
-- ============================================================

DROP PROCEDURE IF EXISTS sp_get_year_underperformers $$
CREATE PROCEDURE sp_get_year_underperformers (
  IN p_release_year INT,
  IN p_limit_n INT
)
BEGIN
  IF p_limit_n IS NULL OR p_limit_n < 1 THEN
    SET p_limit_n = 25;
  END IF;

  SELECT
    drama_id,
    drama_name,
    release_year,
    rating,
    release_year_avg_rating,
    rating_vs_year,
    rating_rank_within_year
  FROM vw_release_year_rating_baseline
  WHERE rating IS NOT NULL
    AND (p_release_year IS NULL OR release_year = p_release_year)
  ORDER BY rating_vs_year ASC, rating ASC
  LIMIT p_limit_n;
END $$

DELIMITER ;
