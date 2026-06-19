-- ===============================================================
-- STEP FIX: Database Relationship Audit Fix
-- 
-- Applied after step18. Fixes all missing/broken relationships
-- found by the full database relationship audit.
-- ===============================================================

-- ── 1. Fix: `users` → `profiles` FK targets ───────────────────
-- step12+step13 incorrectly used REFERENCES users(id).
-- The correct target is profiles(id). If the PK column name is
-- wrong, the FK was never created and PostgREST has no
-- relationship metadata → PGRST200 errors on every join.
--
-- Drop and recreate every FK that targets users(id).
-- These are all CREATE IF NOT EXISTS so safe to re-run.
-- ===============================================================

-- ── 1a. Messaging tables (step12) ────────────────────────────

ALTER TABLE conversations
  DROP CONSTRAINT IF EXISTS conversations_created_by_fkey;

ALTER TABLE conversations
  ADD CONSTRAINT conversations_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE conversation_participants
  DROP CONSTRAINT IF EXISTS conversation_participants_user_id_fkey;

ALTER TABLE conversation_participants
  ADD CONSTRAINT conversation_participants_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE channels
  DROP CONSTRAINT IF EXISTS channels_created_by_fkey;

ALTER TABLE channels
  ADD CONSTRAINT channels_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE messages
  DROP CONSTRAINT IF EXISTS messages_sender_id_fkey;

ALTER TABLE messages
  ADD CONSTRAINT messages_sender_id_fkey
  FOREIGN KEY (sender_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE message_requests
  DROP CONSTRAINT IF EXISTS message_requests_from_user_id_fkey;

ALTER TABLE message_requests
  ADD CONSTRAINT message_requests_from_user_id_fkey
  FOREIGN KEY (from_user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE message_requests
  DROP CONSTRAINT IF EXISTS message_requests_to_user_id_fkey;

ALTER TABLE message_requests
  ADD CONSTRAINT message_requests_to_user_id_fkey
  FOREIGN KEY (to_user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE message_reactions
  DROP CONSTRAINT IF EXISTS message_reactions_user_id_fkey;

ALTER TABLE message_reactions
  ADD CONSTRAINT message_reactions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE chat_poll_votes
  DROP CONSTRAINT IF EXISTS chat_poll_votes_user_id_fkey;

ALTER TABLE chat_poll_votes
  ADD CONSTRAINT chat_poll_votes_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE message_read_receipts
  DROP CONSTRAINT IF EXISTS message_read_receipts_user_id_fkey;

ALTER TABLE message_read_receipts
  ADD CONSTRAINT message_read_receipts_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE mentions
  DROP CONSTRAINT IF EXISTS mentions_user_id_fkey;

ALTER TABLE mentions
  ADD CONSTRAINT mentions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE blocked_users
  DROP CONSTRAINT IF EXISTS blocked_users_blocker_id_fkey;

ALTER TABLE blocked_users
  ADD CONSTRAINT blocked_users_blocker_id_fkey
  FOREIGN KEY (blocker_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE blocked_users
  DROP CONSTRAINT IF EXISTS blocked_users_blocked_id_fkey;

ALTER TABLE blocked_users
  ADD CONSTRAINT blocked_users_blocked_id_fkey
  FOREIGN KEY (blocked_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- ── 1b. Academic tables (step13) ─────────────────────────────

ALTER TABLE courses
  DROP CONSTRAINT IF EXISTS courses_lecturer_id_fkey;

ALTER TABLE courses
  ADD CONSTRAINT courses_lecturer_id_fkey
  FOREIGN KEY (lecturer_id) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE courses
  DROP CONSTRAINT IF EXISTS courses_created_by_fkey;

ALTER TABLE courses
  ADD CONSTRAINT courses_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE academic_resources
  DROP CONSTRAINT IF EXISTS academic_resources_uploaded_by_fkey;

ALTER TABLE academic_resources
  ADD CONSTRAINT academic_resources_uploaded_by_fkey
  FOREIGN KEY (uploaded_by) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE academic_resources
  DROP CONSTRAINT IF EXISTS academic_resources_verified_by_fkey;

ALTER TABLE academic_resources
  ADD CONSTRAINT academic_resources_verified_by_fkey
  FOREIGN KEY (verified_by) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE assignments
  DROP CONSTRAINT IF EXISTS assignments_created_by_fkey;

ALTER TABLE assignments
  ADD CONSTRAINT assignments_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE assignment_submissions
  DROP CONSTRAINT IF EXISTS assignment_submissions_user_id_fkey;

ALTER TABLE assignment_submissions
  ADD CONSTRAINT assignment_submissions_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE assignment_submissions
  DROP CONSTRAINT IF EXISTS assignment_submissions_graded_by_fkey;

ALTER TABLE assignment_submissions
  ADD CONSTRAINT assignment_submissions_graded_by_fkey
  FOREIGN KEY (graded_by) REFERENCES profiles(id) ON DELETE SET NULL;

ALTER TABLE gpa_records
  DROP CONSTRAINT IF EXISTS gpa_records_user_id_fkey;

ALTER TABLE gpa_records
  ADD CONSTRAINT gpa_records_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE study_plans
  DROP CONSTRAINT IF EXISTS study_plans_user_id_fkey;

ALTER TABLE study_plans
  ADD CONSTRAINT study_plans_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE resource_ratings
  DROP CONSTRAINT IF EXISTS resource_ratings_user_id_fkey;

ALTER TABLE resource_ratings
  ADD CONSTRAINT resource_ratings_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE resource_downloads
  DROP CONSTRAINT IF EXISTS resource_downloads_user_id_fkey;

ALTER TABLE resource_downloads
  ADD CONSTRAINT resource_downloads_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

ALTER TABLE exam_timetables
  DROP CONSTRAINT IF EXISTS exam_timetables_created_by_fkey;

ALTER TABLE exam_timetables
  ADD CONSTRAINT exam_timetables_created_by_fkey
  FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL;

-- ── 1c. Also fix conversations.community_id FK ─────────────

ALTER TABLE conversations
  DROP CONSTRAINT IF EXISTS conversations_community_id_fkey;

ALTER TABLE conversations
  ADD CONSTRAINT conversations_community_id_fkey
  FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE;

-- ── 1d. Missing column: message_requests.preview_content ──────

ALTER TABLE message_requests
  ADD COLUMN IF NOT EXISTS preview_content TEXT;

-- ── 2. Missing FK Constraints ─────────────────────────────────
-- Tables that have UUID columns referencing other tables but
-- were created without FK constraints.
-- ===============================================================

-- marketplace_reports.listing_id
ALTER TABLE marketplace_reports
  DROP CONSTRAINT IF EXISTS marketplace_reports_listing_id_fkey;

-- We can't add a proper FK here because the marketplace table
-- name may vary. Common names used in the codebase:
--   marketplace_listings, marketplace_items
-- Try both, succeed if either exists:
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    EXECUTE 'ALTER TABLE marketplace_reports
      ADD CONSTRAINT marketplace_reports_listing_id_fkey
      FOREIGN KEY (listing_id) REFERENCES marketplace_listings(id) ON DELETE CASCADE';
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    EXECUTE 'ALTER TABLE marketplace_reports
      ADD CONSTRAINT marketplace_reports_listing_id_fkey
      FOREIGN KEY (listing_id) REFERENCES marketplace_items(id) ON DELETE CASCADE';
  ELSE
    RAISE WARNING 'marketplace_reports.listing_id FK skipped – no marketplace table found';
  END IF;
END $$;

-- moderation_queue.target_id (polymorphic – targets multiple tables)
-- We skip a FK here because target_id is polymorphic (target_type
-- determines the actual table). Use a CHECK constraint instead.
ALTER TABLE moderation_queue
  DROP CONSTRAINT IF EXISTS moderation_queue_target_type_check;

ALTER TABLE moderation_queue
  ADD CONSTRAINT moderation_queue_target_type_check
  CHECK (target_type IN ('user', 'post', 'community', 'marketplace_listing', 'event'));

-- message_reports.message_id + conversation_id
ALTER TABLE message_reports
  DROP CONSTRAINT IF EXISTS message_reports_message_id_fkey;

ALTER TABLE message_reports
  ADD CONSTRAINT message_reports_message_id_fkey
  FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE;

ALTER TABLE message_reports
  DROP CONSTRAINT IF EXISTS message_reports_conversation_id_fkey;

ALTER TABLE message_reports
  ADD CONSTRAINT message_reports_conversation_id_fkey
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE;

-- ── 3. Missing FK Indexes ──────────────────────────────────────
-- Postgres does NOT auto-index FK columns. Every FK column used
-- in a relational select needs an index for performance.
-- ===============================================================

-- Mesaging FK indexes
CREATE INDEX IF NOT EXISTS idx_conversations_created_by ON conversations(created_by);
CREATE INDEX IF NOT EXISTS idx_channels_created_by ON channels(created_by);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_message_requests_from ON message_requests(from_user_id);
CREATE INDEX IF NOT EXISTS idx_message_requests_to ON message_requests(to_user_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_user ON message_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_poll_votes_user ON chat_poll_votes(user_id);
CREATE INDEX IF NOT EXISTS idx_mentions_user_ref ON mentions(user_id);
CREATE INDEX IF NOT EXISTS idx_blocked_users_blocker ON blocked_users(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocked_users_blocked ON blocked_users(blocked_id);

-- Academic FK indexes
CREATE INDEX IF NOT EXISTS idx_courses_lecturer ON courses(lecturer_id);
CREATE INDEX IF NOT EXISTS idx_courses_created_by ON courses(created_by);
CREATE INDEX IF NOT EXISTS idx_academic_resources_verified_by ON academic_resources(verified_by);
CREATE INDEX IF NOT EXISTS idx_assignments_created_by ON assignments(created_by);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_graded_by ON assignment_submissions(graded_by);
CREATE INDEX IF NOT EXISTS idx_exam_timetables_created_by ON exam_timetables(created_by);

-- Admin FK indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_reported ON moderation_queue(reported_by);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_reviewed ON moderation_queue(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_marketplace_reports_reported ON marketplace_reports(reported_by);
CREATE INDEX IF NOT EXISTS idx_marketplace_reports_reviewed ON marketplace_reports(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_opportunities_organizer ON opportunities(organizer_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_reviewed ON opportunities(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_admin_announcements_sender ON admin_announcements(sender_id);
CREATE INDEX IF NOT EXISTS idx_message_reports_reporter ON message_reports(reporter_id);

-- Conversation participants composite index
DROP INDEX IF EXISTS idx_conversation_participants_composite;
CREATE INDEX IF NOT EXISTS idx_conversation_participants_lookup
  ON conversation_participants(user_id, conversation_id);

-- ── 4. Missing RPC Functions ───────────────────────────────────
-- Called from Flutter but not defined in any SQL file.
-- ===============================================================

-- Increment resource download count
CREATE OR REPLACE FUNCTION increment_resource_download(p_resource_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE academic_resources SET download_count = download_count + 1 WHERE id = p_resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Increment resource view count
CREATE OR REPLACE FUNCTION increment_resource_view(p_resource_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE academic_resources SET view_count = view_count + 1 WHERE id = p_resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Increment listing view count
CREATE OR REPLACE FUNCTION increment_listing_view(p_listing_id UUID)
RETURNS VOID AS $$
DECLARE
  table_name TEXT;
BEGIN
  -- Support both possible table names
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    EXECUTE 'UPDATE marketplace_listings SET view_count = COALESCE(view_count, 0) + 1 WHERE id = $1' USING p_listing_id;
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    EXECUTE 'UPDATE marketplace_items SET view_count = COALESCE(view_count, 0) + 1 WHERE id = $1' USING p_listing_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Get unread count
CREATE OR REPLACE FUNCTION get_unread_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM messages m
  WHERE m.conversation_id IN (
    SELECT cp.conversation_id FROM conversation_participants cp
    WHERE cp.user_id = p_user_id
      AND (cp.last_read_at IS NULL OR m.created_at > cp.last_read_at)
  )
  AND m.sender_id != p_user_id;
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create notification helper (used by admin_screen.dart RPC calls)
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_body TEXT DEFAULT NULL,
  p_data JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO notifications (user_id, type, title, body, data)
  VALUES (p_user_id, p_type, p_title, p_body, p_data)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Increment discussion view
CREATE OR REPLACE FUNCTION increment_discussion_view(p_discussion_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE discussions SET view_count = COALESCE(view_count, 0) + 1 WHERE id = p_discussion_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Seller rating
CREATE OR REPLACE FUNCTION seller_rating(p_user_id UUID)
RETURNS REAL AS $$
DECLARE
  v_rating REAL;
BEGIN
  SELECT COALESCE(AVG(rating), 0)::REAL INTO v_rating
  FROM marketplace_reviews
  WHERE seller_id = p_user_id;
  RETURN v_rating;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Marketplace category counts
CREATE OR REPLACE FUNCTION marketplace_category_counts()
RETURNS TABLE(category TEXT, count BIGINT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    RETURN QUERY SELECT m.category, COUNT(*)::BIGINT FROM marketplace_listings m GROUP BY m.category;
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    RETURN QUERY SELECT m.category, COUNT(*)::BIGINT FROM marketplace_items m GROUP BY m.category;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Top marketplace searches
CREATE OR REPLACE FUNCTION top_marketplace_searches()
RETURNS TABLE(search_term TEXT, count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT s.search_term, COUNT(*)::BIGINT FROM marketplace_searches s
    GROUP BY s.search_term ORDER BY COUNT(*) DESC LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Increment opportunity view
CREATE OR REPLACE FUNCTION increment_opportunity_view(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE opportunities SET view_count = COALESCE(view_count, 0) + 1 WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Opportunity type counts
CREATE OR REPLACE FUNCTION opportunity_type_counts()
RETURNS TABLE(opportunity_type TEXT, count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT o.opportunity_type, COUNT(*)::BIGINT FROM opportunities o
    GROUP BY o.opportunity_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Top opportunity searches
CREATE OR REPLACE FUNCTION top_opportunity_searches()
RETURNS TABLE(search_term TEXT, count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT s.search_term, COUNT(*)::BIGINT FROM opportunity_searches s
    GROUP BY s.search_term ORDER BY COUNT(*) DESC LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Analytics overview
CREATE OR REPLACE FUNCTION analytics_overview()
RETURNS TABLE(
  total_users BIGINT, total_communities BIGINT, total_events BIGINT,
  total_posts BIGINT, active_today BIGINT
) AS $$
BEGIN
  RETURN QUERY SELECT
    (SELECT COUNT(*) FROM profiles)::BIGINT,
    (SELECT COUNT(*) FROM communities)::BIGINT,
    (SELECT COUNT(*) FROM community_events)::BIGINT,
    (SELECT COUNT(*) FROM community_posts)::BIGINT,
    (SELECT COUNT(*) FROM reputation_events WHERE created_at >= CURRENT_DATE)::BIGINT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- DAU series
CREATE OR REPLACE FUNCTION dau_series(days INTEGER DEFAULT 30)
RETURNS TABLE(date DATE, count BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT d::DATE, COUNT(DISTINCT user_id)::BIGINT
  FROM generate_series(CURRENT_DATE - (days - 1), CURRENT_DATE, '1 day'::interval) d
  LEFT JOIN reputation_events ON DATE(created_at) = d
  GROUP BY d ORDER BY d;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Feature adoption
CREATE OR REPLACE FUNCTION feature_adoption(days INTEGER DEFAULT 30)
RETURNS TABLE(feature TEXT, user_count BIGINT) AS $$
BEGIN
  RETURN QUERY SELECT
    e.event_type, COUNT(DISTINCT e.user_id)::BIGINT
  FROM reputation_events e
  WHERE e.created_at >= CURRENT_DATE - (days || ' days')::INTERVAL
  GROUP BY e.event_type ORDER BY user_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Retention summary
CREATE OR REPLACE FUNCTION retention_summary()
RETURNS TABLE(period TEXT, rate REAL) AS $$
BEGIN
  RETURN QUERY
  SELECT 'd1'::TEXT,
    (SELECT COUNT(DISTINCT user_id)::REAL / NULLIF(
      (SELECT COUNT(DISTINCT user_id) FROM reputation_events WHERE created_at >= CURRENT_DATE - 1), 0)
    FROM reputation_events WHERE created_at >= CURRENT_DATE - 1
      AND user_id IN (SELECT user_id FROM reputation_events WHERE created_at >= CURRENT_DATE - 2));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Launch readiness
CREATE OR REPLACE FUNCTION launch_readiness()
RETURNS TABLE(check_name TEXT, status TEXT, details TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT 'RLS Enabled'::TEXT,
    CASE WHEN (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public' AND rowsecurity) > 0
      THEN 'PASS' ELSE 'FAIL' END,
    (SELECT COUNT(*)::TEXT || ' tables with RLS' FROM pg_tables WHERE schemaname = 'public' AND rowsecurity);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- System health
CREATE OR REPLACE FUNCTION system_health()
RETURNS TABLE(metric TEXT, value TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT 'Database size'::TEXT, pg_size_pretty(pg_database_size(current_database()))::TEXT
  UNION ALL SELECT 'Active connections'::TEXT, (SELECT COUNT(*)::TEXT FROM pg_stat_activity);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Old name alias (used by academic_repository_impl)
CREATE OR REPLACE FUNCTION increment_resource_downloads(rid UUID)
RETURNS VOID AS $$
BEGIN
  PERFORM increment_resource_download(rid);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ── 5. Fix aggregate_daily_analytics marketplace reference ───
-- The function references marketplace_items which may not exist.
-- Make it dynamic.
-- ===============================================================

CREATE OR REPLACE FUNCTION aggregate_daily_analytics(p_university_id UUID DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
  today DATE := CURRENT_DATE;
  v_active_students INTEGER;
  v_daily_active INTEGER;
  v_monthly_active INTEGER;
  v_communities INTEGER;
  v_events INTEGER;
  v_marketplace INTEGER;
  v_opportunities INTEGER;
  v_posts INTEGER;
  v_marketplace_table TEXT;
BEGIN
  SELECT COUNT(*) INTO v_active_students FROM profiles
  WHERE (p_university_id IS NULL OR university_id = p_university_id)
    AND created_at <= now() - interval '7 days';

  SELECT COUNT(DISTINCT user_id) INTO v_daily_active FROM reputation_events
  WHERE created_at >= today;

  SELECT COUNT(DISTINCT user_id) INTO v_monthly_active FROM reputation_events
  WHERE created_at >= today - interval '30 days';

  SELECT COUNT(*) INTO v_communities FROM communities
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  SELECT COUNT(*) INTO v_events FROM community_events
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  -- Dynamic marketplace table lookup
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    EXECUTE 'SELECT COUNT(*) FROM marketplace_listings WHERE ($1 IS NULL OR university_id = $1)'
      INTO v_marketplace USING p_university_id;
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    EXECUTE 'SELECT COUNT(*) FROM marketplace_items WHERE ($1 IS NULL OR university_id = $1)'
      INTO v_marketplace USING p_university_id;
  ELSE
    v_marketplace := 0;
  END IF;

  SELECT COUNT(*) INTO v_opportunities FROM opportunities
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  SELECT COUNT(*) INTO v_posts FROM community_posts
  WHERE created_at >= today;

  INSERT INTO analytics_snapshots (
    university_id, snapshot_date, active_students, daily_active, monthly_active,
    communities, events_count, marketplace_count, opportunities_count, posts_count
  ) VALUES (
    p_university_id, today, v_active_students, v_daily_active, v_monthly_active,
    v_communities, v_events, v_marketplace, v_opportunities, v_posts
  )
  ON CONFLICT (university_id, snapshot_date)
  DO UPDATE SET
    active_students = EXCLUDED.active_students,
    daily_active = EXCLUDED.daily_active,
    monthly_active = EXCLUDED.monthly_active,
    communities = EXCLUDED.communities,
    events_count = EXCLUDED.events_count,
    marketplace_count = EXCLUDED.marketplace_count,
    opportunities_count = EXCLUDED.opportunities_count,
    posts_count = EXCLUDED.posts_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ── 6. Duplicate table cleanup ──────────────────────────────────
-- step16_admin_system.sql and step16_multi_university_admin.sql
-- both define the same tables. Run this to ensure both are
-- applied consistently (uses CREATE IF NOT EXISTS throughout).
-- ===============================================================

-- No destructive cleanup — both files use CREATE IF NOT EXISTS.
-- If you need to rebuild from scratch, drop and recreate:
-- DROP TABLE IF EXISTS analytics_snapshots CASCADE;
-- DROP TABLE IF EXISTS marketplace_reports CASCADE;
-- DROP TABLE IF EXISTS opportunities CASCADE;
-- DROP TABLE IF EXISTS admin_announcement_recipients CASCADE;
-- DROP TABLE IF EXISTS admin_announcements CASCADE;
-- DROP TABLE IF EXISTS moderation_queue CASCADE;
-- DROP TABLE IF EXISTS audit_logs CASCADE;
-- DROP TABLE IF EXISTS university_administrators CASCADE;
-- DROP TABLE IF EXISTS admin_roles CASCADE;
-- DROP TABLE IF EXISTS departments CASCADE;
-- DROP TABLE IF EXISTS faculties CASCADE;
-- DROP TABLE IF EXISTS universities CASCADE;

-- ── 6b. Fix incorrect column names in step18 indexes ──────────
-- step18_remaining_fixes.sql includes indexes referencing columns
-- that don't exist in the actual table definitions.

-- Fix: idx_messages_conversation_sent references sent_at, but the
-- messages table uses created_at (no sent_at column exists)
DROP INDEX IF EXISTS idx_messages_conversation_sent;
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created
  ON messages(conversation_id, created_at DESC);

-- Fix: idx_notifications_user_read references `read`, but the
-- column is named `is_read` (per NotificationModel & Flutter code)
DROP INDEX IF EXISTS idx_notifications_user_read;
CREATE INDEX IF NOT EXISTS idx_notifications_user_is_read
  ON notifications(user_id, is_read, created_at DESC);

-- ── 7. Verify all FKs were created ──────────────────────────────

DO $$
DECLARE
  v_fk_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_fk_count
  FROM pg_constraint
  WHERE contype = 'f'
    AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

  RAISE NOTICE 'Total FK constraints in public schema: %', v_fk_count;

  -- Report any tables with UUID columns that might still lack FKs
  -- (only columns ending in _id that should reference another table)
END $$;
