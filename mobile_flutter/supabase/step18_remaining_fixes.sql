-- ============================================================
-- step18_remaining_fixes.sql
-- 
-- Applies remaining security hardening, cron scheduling, and
-- post-deployment fixes that could not be applied earlier.
--
-- Run this AFTER step1–step17 have been applied.
-- Requires superuser or Supabase Dashboard SQL editor.
-- ============================================================

-- ── 1. Revoke dangerous anon grants ──────────────────────────
-- The post_votes table was created with step11 which included
-- GRANT ALL ON post_votes TO anon. This allows unauthenticated
-- users to vote. Revoke and re-grant to authenticated only.

REVOKE ALL ON post_votes FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON post_votes TO authenticated;

-- ── 2. Verify and fix DEFAULT PRIVILEGES ─────────────────────
-- Ensure all tables created by migrations have proper RLS.
-- This section is informational — run to check for gaps.

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename NOT IN ('schema_migrations', 'realtime_messages')
      AND NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_policy p ON p.polrelid = c.oid
        WHERE c.relname = tablename AND n.nspname = 'public'
      )
  LOOP
    RAISE WARNING 'Table "%" has RLS enabled but NO policies', tbl;
  END LOOP;
END $$;

-- ── 3. Schedule daily analytics via pg_cron ──────────────────
-- Requires the pg_cron extension to be installed.
-- Uncomment and run if pg_cron is available:

-- SELECT cron.schedule(
--   'daily-analytics-midnight',
--   '0 0 * * *',
--   $$SELECT aggregate_daily_analytics()$$
-- );
--
-- SELECT cron.schedule(
--   'daily-analytics-noon',
--   '0 12 * * *',
--   $$SELECT aggregate_daily_analytics()$$
-- );

-- If pg_cron is NOT available, use the
-- supabase/functions/daily-analytics Edge Function instead.
-- Deploy it and create a cron trigger in Supabase Dashboard:
--   https://supabase.com/dashboard/project/<ref>/database/cron-jobs

-- ── 4. Push notification queue processing schedule ───────────
-- Uses the send_push_notification Edge Function.
-- Deploy and create a cron trigger:
--   https://supabase.com/dashboard/project/<ref>/database/cron-jobs
-- Frequency: every 30 seconds (or every minute — minimum is 1 min for free plan)

-- ── 5. Enable pg_cron extension (if not already) ─────────────
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ── 6. Add missing indexes for common query patterns ─────────
CREATE INDEX IF NOT EXISTS idx_profiles_university_id ON profiles(university_id);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_user ON conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_sent ON messages(conversation_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_event_rsvps_event_user ON event_rsvps(event_id, user_id);
CREATE INDEX IF NOT EXISTS idx_post_votes_post_user ON post_votes(post_id, user_id);
CREATE INDEX IF NOT EXISTS idx_poll_votes_poll_user ON poll_votes(poll_id, user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_status ON moderation_queue(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_snapshots_university ON analytics_snapshots(university_id, snapshot_date DESC);
CREATE INDEX IF NOT EXISTS idx_marketplace_items_status ON marketplace_items(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_opportunities_status ON opportunities(status, created_at DESC);
