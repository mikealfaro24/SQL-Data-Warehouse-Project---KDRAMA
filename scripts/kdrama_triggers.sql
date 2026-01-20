DELIMITER $$

-- ============================================================
-- Trigger: trg_drama_validate_before_insert
-- Purpose:
--   Stop bad data from entering the drama table.
--
-- Why this matters:
--   Ratings and release years are core fields used in every analysis.
--   If someone inserts a rating like 15 or a future release year,
--   results become unreliable.
--
-- What this trigger checks:
--   1) rating must be between 0.00 and 10.00 (if rating is provided)
--   2) release_year must be a realistic year (not in the future)
--
-- What happens if the data is bad:
--   The INSERT fails and MySQL returns a clear error message.
-- ============================================================

DROP TRIGGER IF EXISTS trg_drama_validate_before_insert $$
CREATE TRIGGER trg_drama_validate_before_insert
BEFORE INSERT ON drama
FOR EACH ROW
BEGIN
  -- Check rating range only if rating is not NULL
  IF NEW.rating IS NOT NULL AND (NEW.rating < 0 OR NEW.rating > 10) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid rating: rating must be between 0 and 10.';
  END IF;

  -- Check release_year is not in the future
  IF NEW.release_year IS NOT NULL AND NEW.release_year > YEAR(CURDATE()) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid release_year: release year cannot be in the future.';
  END IF;

  -- Optional: prevent unrealistic old years (helps keep data clean)
  IF NEW.release_year IS NOT NULL AND NEW.release_year < 1960 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid release_year: release year is unrealistically old for this dataset.';
  END IF;
END $$


-- ============================================================
-- Trigger: trg_drama_validate_before_update
-- Purpose:
--   Apply the same data rules when someone updates an existing drama.
--
-- Why this matters:
--   Without this trigger, someone could update a clean record
--   into a bad record later (ex: change rating to -2).
--
-- What this trigger checks:
--   Same validations as the insert trigger.
-- ============================================================

DROP TRIGGER IF EXISTS trg_drama_validate_before_update $$
CREATE TRIGGER trg_drama_validate_before_update
BEFORE UPDATE ON drama
FOR EACH ROW
BEGIN
  IF NEW.rating IS NOT NULL AND (NEW.rating < 0 OR NEW.rating > 10) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid rating: rating must be between 0 and 10.';
  END IF;

  IF NEW.release_year IS NOT NULL AND NEW.release_year > YEAR(CURDATE()) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid release_year: release year cannot be in the future.';
  END IF;

  IF NEW.release_year IS NOT NULL AND NEW.release_year < 1960 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid release_year: release year is unrealistically old for this dataset.';
  END IF;
END $$


-- ============================================================
-- Trigger: trg_no_duplicate_drama_genre
-- Purpose:
--   Prevent duplicate links in the drama_genre bridge table.
--
-- Why this matters:
--   drama_genre represents a many-to-many relationship.
--   If duplicates exist (same drama_id + genre_id repeated),
--   genre counts and percentages become inflated.
--
-- What this trigger checks:
--   If the same drama_id + genre_id combination already exists,
--   block the insert.
-- ============================================================

DROP TRIGGER IF EXISTS trg_no_duplicate_drama_genre $$
CREATE TRIGGER trg_no_duplicate_drama_genre
BEFORE INSERT ON drama_genre
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM drama_genre
    WHERE drama_id = NEW.drama_id
      AND genre_id = NEW.genre_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Duplicate relationship: this drama is already linked to this genre.';
  END IF;
END $$


-- ============================================================
-- Trigger: trg_no_duplicate_drama_original_network
-- Purpose:
--   Prevent duplicate links in the drama_original_network bridge table.
--
-- Why this matters:
--   If duplicates exist (same drama_id + original_network_id),
--   network volume and averages can be incorrectly inflated.
--
-- What this trigger checks:
--   If the same drama_id + original_network_id already exists,
--   block the insert.
-- ============================================================

DROP TRIGGER IF EXISTS trg_no_duplicate_drama_original_network $$
CREATE TRIGGER trg_no_duplicate_drama_original_network
BEFORE INSERT ON drama_original_network
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM drama_original_network
    WHERE drama_id = NEW.drama_id
      AND original_network_id = NEW.original_network_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Duplicate relationship: this drama is already linked to this network.';
  END IF;
END $$

DELIMITER ;
