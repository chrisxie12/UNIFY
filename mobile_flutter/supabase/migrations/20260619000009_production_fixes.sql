-- UNIFY Production Fixes: missing tables, RLS policies, indexes, RPCs, GRANT cleanup, pg_cron guide
-- Run after migrations 1-8 have been applied.

BEGIN;

-- ── 1. Missing Tables ─────────────────────────────────────────────

-- Message reports
CREATE TABLE IF NOT EXISTS message_reports (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id      UUID        NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  conversation_id UUID        NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  reporter_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason          TEXT        NOT NULL,
  status          TEXT        NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'reviewed', 'dismissed', 'action_taken')),
  reviewed_by     UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE message_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "message_reports_insert" ON message_reports
  FOR INSERT TO authenticated WITH CHECK (reporter_id = auth.uid());
CREATE POLICY "message_reports_select_own" ON message_reports
  FOR SELECT TO authenticated USING (reporter_id = auth.uid());
CREATE POLICY "message_reports_select_admin" ON message_reports
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );
CREATE POLICY "message_reports_update_admin" ON message_reports
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE INDEX IF NOT EXISTS idx_message_reports_reporter ON message_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_message_reports_status ON message_reports(status, created_at DESC);

-- Device tokens for push notifications
CREATE TABLE IF NOT EXISTS device_tokens (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token      TEXT        NOT NULL,
  platform   TEXT        NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  is_active  BOOLEAN     DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens(user_id);

ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "device_tokens_manage" ON device_tokens
  FOR ALL TO authenticated USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Push notification queue (server-side processing)
CREATE TABLE IF NOT EXISTS push_notification_queue (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title         TEXT        NOT NULL,
  body          TEXT        NOT NULL,
  data          JSONB       DEFAULT '{}'::jsonb,
  status        TEXT        NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'sent', 'failed', 'cancelled')),
  error_message TEXT,
  sent_at       TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_push_queue_status ON push_notification_queue(status, created_at);

ALTER TABLE push_notification_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "push_queue_insert_system" ON push_notification_queue
  FOR INSERT TO authenticated WITH CHECK (TRUE);
CREATE POLICY "push_queue_select_own" ON push_notification_queue
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "push_queue_select_admin" ON push_notification_queue
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- ── 2. Missing RLS Policies ───────────────────────────────────────

-- gpa_courses: RLS enabled but no policies (migration 6 creates table with RLS)
DROP POLICY IF EXISTS "gpa_courses_select_own" ON gpa_courses;
CREATE POLICY "gpa_courses_select_own" ON gpa_courses
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );
DROP POLICY IF EXISTS "gpa_courses_insert_own" ON gpa_courses;
CREATE POLICY "gpa_courses_insert_own" ON gpa_courses
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );
DROP POLICY IF EXISTS "gpa_courses_update_own" ON gpa_courses;
CREATE POLICY "gpa_courses_update_own" ON gpa_courses
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );
DROP POLICY IF EXISTS "gpa_courses_delete_own" ON gpa_courses;
CREATE POLICY "gpa_courses_delete_own" ON gpa_courses
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );

-- study_plan_items: RLS enabled but no policies (migration 6 creates table with RLS)
DROP POLICY IF EXISTS "study_plan_items_select_own" ON study_plan_items;
CREATE POLICY "study_plan_items_select_own" ON study_plan_items
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );
DROP POLICY IF EXISTS "study_plan_items_insert_own" ON study_plan_items;
CREATE POLICY "study_plan_items_insert_own" ON study_plan_items
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );
DROP POLICY IF EXISTS "study_plan_items_update_own" ON study_plan_items;
CREATE POLICY "study_plan_items_update_own" ON study_plan_items
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );
DROP POLICY IF EXISTS "study_plan_items_delete_own" ON study_plan_items;
CREATE POLICY "study_plan_items_delete_own" ON study_plan_items
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );

-- resource_downloads: missing SELECT policy (migration 6 has INSERT only)
DROP POLICY IF EXISTS "resource_downloads_select_own" ON resource_downloads;
CREATE POLICY "resource_downloads_select_own" ON resource_downloads
  FOR SELECT TO authenticated USING (user_id = auth.uid());

-- exam_timetables: missing INSERT/UPDATE/DELETE policies (migration 6 has SELECT only)
DROP POLICY IF EXISTS "exam_timetables_insert_admin" ON exam_timetables;
CREATE POLICY "exam_timetables_insert_admin" ON exam_timetables
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );
DROP POLICY IF EXISTS "exam_timetables_update_admin" ON exam_timetables;
CREATE POLICY "exam_timetables_update_admin" ON exam_timetables
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );
DROP POLICY IF EXISTS "exam_timetables_delete_admin" ON exam_timetables;
CREATE POLICY "exam_timetables_delete_admin" ON exam_timetables
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- academic_resources: missing DELETE policies (migration 6 has SELECT/INSERT/UPDATE only)
DROP POLICY IF EXISTS "academic_resources_delete_owner" ON academic_resources;
CREATE POLICY "academic_resources_delete_owner" ON academic_resources
  FOR DELETE TO authenticated USING (uploaded_by = auth.uid());
DROP POLICY IF EXISTS "academic_resources_delete_admin" ON academic_resources;
CREATE POLICY "academic_resources_delete_admin" ON academic_resources
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- event_media: missing UPDATE policy (migration 4 has SELECT/INSERT/DELETE)
DROP POLICY IF EXISTS "event_media_update_owner" ON event_media;
CREATE POLICY "event_media_update_owner" ON event_media
  FOR UPDATE TO authenticated USING (uploaded_by = auth.uid());

-- poll_options: restrict INSERT to community members (migration 3 has SELECT only)
DROP POLICY IF EXISTS "poll_options_insert_restricted" ON poll_options;
CREATE POLICY "poll_options_insert_restricted" ON poll_options
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM community_polls cp
      JOIN community_members cm ON cm.community_id = cp.community_id
      WHERE cp.id = poll_options.poll_id AND cm.user_id = auth.uid()
    )
  );

-- conversations INSERT: restrict to authenticated users (migration 5 is too permissive WITH CHECK TRUE)
DROP POLICY IF EXISTS "conversations_insert" ON conversations;
CREATE POLICY "conversations_insert_restricted" ON conversations
  FOR INSERT TO authenticated WITH CHECK (
    auth.uid() IS NOT NULL
    AND (type = 'direct' OR type IN ('group', 'channel', 'study_group', 'announcement'))
  );

-- moderation_queue: add CHECK constraint on target_type
ALTER TABLE moderation_queue
  DROP CONSTRAINT IF EXISTS moderation_queue_target_type_check;
ALTER TABLE moderation_queue
  ADD CONSTRAINT moderation_queue_target_type_check
  CHECK (target_type IN ('user', 'post', 'community', 'marketplace_listing', 'event'));

-- ── 3. Full-Text Search Indexes ───────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_events_search ON community_events
  USING GIN (to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(description, '')));
CREATE INDEX IF NOT EXISTS idx_communities_search ON communities
  USING GIN (to_tsvector('english', COALESCE(name, '') || ' ' || COALESCE(description, '')));
CREATE INDEX IF NOT EXISTS idx_profiles_search ON profiles
  USING GIN (to_tsvector('english', COALESCE(full_name, '') || ' ' || COALESCE(programme, '') || ' ' || COALESCE(department, '')));

-- Composite performance indexes
CREATE INDEX IF NOT EXISTS idx_comments_post_created ON post_comments(post_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tickets_event_user ON event_tickets(event_id, user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_lookup ON conversation_participants(user_id, conversation_id);

-- Query pattern indexes from step18
CREATE INDEX IF NOT EXISTS idx_post_votes_post_user ON post_votes(post_id, user_id);
CREATE INDEX IF NOT EXISTS idx_poll_votes_poll_user ON poll_votes(poll_id, user_id);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_status ON moderation_queue(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_snapshots_university ON analytics_snapshots(university_id, snapshot_date DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_university_id ON profiles(university_id);

-- ── 4. Missing FK Column Indexes (step_fix_database_relationships.sql section 3) ──

-- Messaging FK indexes
CREATE INDEX IF NOT EXISTS idx_conversations_created_by ON conversations(created_by);
CREATE INDEX IF NOT EXISTS idx_channels_created_by ON channels(created_by);
CREATE INDEX IF NOT EXISTS idx_message_requests_from ON message_requests(from_user_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_user ON message_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_poll_votes_user ON chat_poll_votes(user_id);
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
CREATE INDEX IF NOT EXISTS idx_moderation_queue_reported ON moderation_queue(reported_by);
CREATE INDEX IF NOT EXISTS idx_moderation_queue_reviewed ON moderation_queue(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_marketplace_reports_reported ON marketplace_reports(reported_by);
CREATE INDEX IF NOT EXISTS idx_marketplace_reports_reviewed ON marketplace_reports(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_opportunities_organizer ON opportunities(organizer_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_reviewed ON opportunities(reviewed_by);
CREATE INDEX IF NOT EXISTS idx_admin_announcements_sender ON admin_announcements(sender_id);

-- marketplace_reports.listing_id FK (dynamic — try both table names)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    EXECUTE 'ALTER TABLE marketplace_reports
      DROP CONSTRAINT IF EXISTS marketplace_reports_listing_id_fkey;
      ALTER TABLE marketplace_reports
      ADD CONSTRAINT marketplace_reports_listing_id_fkey
      FOREIGN KEY (listing_id) REFERENCES marketplace_listings(id) ON DELETE CASCADE';
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    EXECUTE 'ALTER TABLE marketplace_reports
      DROP CONSTRAINT IF EXISTS marketplace_reports_listing_id_fkey;
      ALTER TABLE marketplace_reports
      ADD CONSTRAINT marketplace_reports_listing_id_fkey
      FOREIGN KEY (listing_id) REFERENCES marketplace_items(id) ON DELETE CASCADE';
  ELSE
    RAISE WARNING 'marketplace_reports.listing_id FK skipped — no marketplace table found';
  END IF;
END $$;

-- Fix wrong index names from step18 (column mismatch)
DROP INDEX IF EXISTS idx_messages_conversation_sent;
DROP INDEX IF EXISTS idx_notifications_user_read;
-- Migration 3 already has idx_notifications_user_read with correct is_read column.
-- Migration 5 already has idx_messages_conversation on (conversation_id, created_at DESC).

-- ── 5. Missing RPC Functions ──────────────────────────────────────

-- Increment resource view count
CREATE OR REPLACE FUNCTION increment_resource_view(p_resource_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE academic_resources SET view_count = view_count + 1 WHERE id = p_resource_id;
END;
$$;

-- Increment listing view count (marketplace, dynamic table)
CREATE OR REPLACE FUNCTION increment_listing_view(p_listing_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  table_name TEXT;
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    EXECUTE 'UPDATE marketplace_listings SET view_count = COALESCE(view_count, 0) + 1 WHERE id = $1' USING p_listing_id;
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    EXECUTE 'UPDATE marketplace_items SET view_count = COALESCE(view_count, 0) + 1 WHERE id = $1' USING p_listing_id;
  END IF;
END;
$$;

-- Get unread message count
CREATE OR REPLACE FUNCTION get_unread_count(p_user_id UUID)
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
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
$$;

-- Replace create_notification with UUID-returning version
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id TEXT, p_type TEXT, p_title TEXT, p_body TEXT DEFAULT NULL,
  p_reference_id TEXT DEFAULT NULL, p_reference_type TEXT DEFAULT NULL
)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_id TEXT;
BEGIN
  INSERT INTO notifications (user_id, type, title, body, reference_id, reference_type)
  VALUES (p_user_id, p_type, p_title, p_body, p_reference_id, p_reference_type)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- Marketplace RPCs
CREATE OR REPLACE FUNCTION seller_rating(p_user_id UUID)
RETURNS REAL LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_rating REAL;
BEGIN
  SELECT COALESCE(AVG(rating), 0)::REAL INTO v_rating
  FROM marketplace_reviews
  WHERE seller_id = p_user_id;
  RETURN v_rating;
END;
$$;

CREATE OR REPLACE FUNCTION marketplace_category_counts()
RETURNS TABLE(category TEXT, count BIGINT) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    RETURN QUERY SELECT m.category, COUNT(*)::BIGINT FROM marketplace_listings m GROUP BY m.category;
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    RETURN QUERY SELECT m.category, COUNT(*)::BIGINT FROM marketplace_items m GROUP BY m.category;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION top_marketplace_searches()
RETURNS TABLE(search_term TEXT, count BIGINT) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY SELECT s.search_term, COUNT(*)::BIGINT
    FROM marketplace_searches s
    GROUP BY s.search_term ORDER BY COUNT(*) DESC LIMIT 10;
END;
$$;

-- Opportunity RPCs
CREATE OR REPLACE FUNCTION increment_opportunity_view(p_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE opportunities SET view_count = COALESCE(view_count, 0) + 1 WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION opportunity_type_counts()
RETURNS TABLE(opportunity_type TEXT, count BIGINT) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY SELECT o.opportunity_type, COUNT(*)::BIGINT FROM opportunities o
    GROUP BY o.opportunity_type;
END;
$$;

CREATE OR REPLACE FUNCTION top_opportunity_searches()
RETURNS TABLE(search_term TEXT, count BIGINT) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY SELECT s.search_term, COUNT(*)::BIGINT FROM opportunity_searches s
    GROUP BY s.search_term ORDER BY COUNT(*) DESC LIMIT 10;
END;
$$;

-- Analytics RPCs
CREATE OR REPLACE FUNCTION retention_summary()
RETURNS TABLE(period TEXT, rate REAL) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY
  SELECT 'd1'::TEXT,
    (SELECT COUNT(DISTINCT user_id)::REAL / NULLIF(
      (SELECT COUNT(DISTINCT user_id) FROM reputation_events WHERE created_at >= CURRENT_DATE - 1), 0)
    FROM reputation_events WHERE created_at >= CURRENT_DATE - 1
      AND user_id IN (SELECT user_id FROM reputation_events WHERE created_at >= CURRENT_DATE - 2));
END;
$$;

CREATE OR REPLACE FUNCTION launch_readiness()
RETURNS TABLE(check_name TEXT, status TEXT, details TEXT) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY
  SELECT 'RLS Enabled'::TEXT,
    CASE WHEN (SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public' AND rowsecurity) > 0
      THEN 'PASS' ELSE 'FAIL' END,
    (SELECT COUNT(*)::TEXT || ' tables with RLS' FROM pg_tables WHERE schemaname = 'public' AND rowsecurity);
END;
$$;

CREATE OR REPLACE FUNCTION system_health()
RETURNS TABLE(metric TEXT, value TEXT) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY
  SELECT 'Database size'::TEXT, pg_size_pretty(pg_database_size(current_database()))::TEXT
  UNION ALL SELECT 'Active connections'::TEXT, (SELECT COUNT(*)::TEXT FROM pg_stat_activity);
END;
$$;

-- Old name alias (used by academic_repository_impl.dart)
CREATE OR REPLACE FUNCTION increment_resource_downloads(rid UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  PERFORM increment_resource_download(rid);
END;
$$;

-- Row count helper
CREATE OR REPLACE FUNCTION count_rows(table_name TEXT, conditions JSONB DEFAULT '{}'::jsonb)
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_sql TEXT;
  v_count INTEGER;
  v_key TEXT;
  v_val TEXT;
BEGIN
  v_sql := 'SELECT COUNT(*) FROM ' || quote_ident(table_name);
  IF conditions != '{}'::jsonb THEN
    v_sql := v_sql || ' WHERE ';
    FOR v_key, v_val IN SELECT * FROM jsonb_each_text(conditions)
    LOOP
      v_sql := v_sql || format('%I = %L AND ', v_key, v_val);
    END LOOP;
    v_sql := LEFT(v_sql, -5);
  END IF;
  EXECUTE v_sql INTO v_count;
  RETURN v_count;
END;
$$;

-- ── 6. aggregate_daily_analytics with dynamic marketplace lookup ──

CREATE OR REPLACE FUNCTION aggregate_daily_analytics(p_university_id UUID DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
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
BEGIN
  SELECT COUNT(*) INTO v_active_students FROM profiles
  WHERE (p_university_id IS NULL OR university_id = p_university_id)
    AND created_at <= NOW() - INTERVAL '7 days';
  SELECT COUNT(DISTINCT user_id) INTO v_daily_active FROM reputation_events WHERE created_at >= today;
  SELECT COUNT(DISTINCT user_id) INTO v_monthly_active FROM reputation_events WHERE created_at >= today - INTERVAL '30 days';
  SELECT COUNT(*) INTO v_communities FROM communities WHERE (p_university_id IS NULL OR university_id = p_university_id);
  SELECT COUNT(*) INTO v_events FROM community_events WHERE (p_university_id IS NULL OR university_id = p_university_id);

  -- Dynamic marketplace table lookup
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_listings') THEN
    EXECUTE 'SELECT COUNT(*) FROM marketplace_listings WHERE ($1 IS NULL OR university_id = $1)' INTO v_marketplace USING p_university_id;
  ELSIF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'marketplace_items') THEN
    EXECUTE 'SELECT COUNT(*) FROM marketplace_items WHERE ($1 IS NULL OR university_id = $1)' INTO v_marketplace USING p_university_id;
  ELSE
    v_marketplace := 0;
  END IF;

  SELECT COUNT(*) INTO v_opportunities FROM opportunities WHERE (p_university_id IS NULL OR university_id = p_university_id);
  SELECT COUNT(*) INTO v_posts FROM community_posts WHERE created_at >= today;

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
$$;

-- ── 7. GRANT Cleanup ──────────────────────────────────────────────

REVOKE ALL ON post_votes FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON post_votes TO authenticated;

-- ── 8. No-Policy Checker (informational) ─────────────────────────

DO $$
DECLARE
  tbl TEXT;
  v_count INTEGER := 0;
BEGIN
  FOR tbl IN
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename NOT IN ('schema_migrations', 'realtime_messages')
      AND EXISTS (SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = tablename AND n.nspname = 'public' AND c.relrowsecurity)
      AND NOT EXISTS (
        SELECT 1 FROM pg_policy p
        JOIN pg_class c ON c.oid = p.polrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = tablename AND n.nspname = 'public'
      )
  LOOP
    RAISE WARNING 'Table "%" has RLS enabled but NO policies', tbl;
    v_count := v_count + 1;
  END LOOP;
  IF v_count = 0 THEN
    RAISE NOTICE 'All RLS-enabled tables have at least one policy. ✓';
  END IF;
END $$;

-- ── 9. pg_cron Scheduling Guide (comment-only, uncomment if pg_cron available) ──
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
--
-- SELECT cron.schedule('daily-analytics-midnight', '0 0 * * *',
--   $$SELECT aggregate_daily_analytics()$$);
-- SELECT cron.schedule('daily-analytics-noon', '0 12 * * *',
--   $$SELECT aggregate_daily_analytics()$$);
-- SELECT cron.schedule('push-notification-process', '*/1 * * * *',
--   $$SELECT process_push_notification_queue()$$);
--
-- If pg_cron not available, deploy Edge Functions instead:
--   supabase functions deploy send_push_notification --no-verify-jwt
--   supabase functions deploy daily-analytics --no-verify-jwt

-- ── 10. Verify FK Count ───────────────────────────────────────────

DO $$
DECLARE
  v_fk_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_fk_count
  FROM pg_constraint
  WHERE contype = 'f'
    AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
  RAISE NOTICE 'Total FK constraints in public schema: %', v_fk_count;
END $$;

COMMIT;
