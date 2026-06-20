-- ============================================================
-- UNIFY — Step 14: Add missing data column to notifications
--
-- Migration 11 rewrote create_notification() to insert a data
-- JSONB column, and migration 13's push queue trigger reads
-- NEW.data — but the original notifications table (migration 3)
-- never defined that column.  Add it now.
-- ============================================================

BEGIN;

ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS data JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMIT;
