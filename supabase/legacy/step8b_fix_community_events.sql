-- ============================================================
-- STEP 8b — Fix community_events missing columns
-- Run this if step8 was applied before is_cancelled was added.
-- All statements are idempotent (IF NOT EXISTS / DO NOTHING).
-- ============================================================

ALTER TABLE community_events
  ADD COLUMN IF NOT EXISTS is_cancelled BOOLEAN NOT NULL DEFAULT false;
