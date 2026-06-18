-- ============================================================
-- STEP 17 — Production Readiness Patch
-- Fixes gaps found during pre-launch audit:
--   • message_reports table (DDL missing)
--   • device_tokens for push notifications
--   • RLS security fixes
--   • Analytics aggregation function
--   • Performance indexes
-- ============================================================

-- ── 1. Missing Tables ───────────────────────────────────────

CREATE TABLE IF NOT EXISTS message_reports (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id    UUID        NOT NULL,
  conversation_id UUID      NOT NULL,
  reporter_id   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason        TEXT        NOT NULL,
  status        TEXT        NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'reviewed', 'dismissed', 'action_taken')),
  reviewed_by   UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
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

-- Device tokens for push notifications
CREATE TABLE IF NOT EXISTS device_tokens (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token         TEXT        NOT NULL,
  platform      TEXT        NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  is_active     BOOLEAN     DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
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
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_push_queue_status ON push_notification_queue(status, created_at);

ALTER TABLE push_notification_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "push_queue_insert_system" ON push_notification_queue
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "push_queue_select_admin" ON push_notification_queue
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
    OR user_id = auth.uid()
  );

-- ── 2. RLS Security Fixes ────────────────────────────────────

-- Fix: gpa_courses has RLS enabled but no policies
CREATE POLICY "gpa_courses_select_own" ON gpa_courses
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );

CREATE POLICY "gpa_courses_insert_own" ON gpa_courses
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );

CREATE POLICY "gpa_courses_update_own" ON gpa_courses
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );

CREATE POLICY "gpa_courses_delete_own" ON gpa_courses
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM gpa_records WHERE id = gpa_courses.gpa_record_id AND user_id = auth.uid())
  );

-- Fix: study_plan_items has RLS enabled but no policies
CREATE POLICY "study_plan_items_select_own" ON study_plan_items
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );

CREATE POLICY "study_plan_items_insert_own" ON study_plan_items
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );

CREATE POLICY "study_plan_items_update_own" ON study_plan_items
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );

CREATE POLICY "study_plan_items_delete_own" ON study_plan_items
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid())
  );

-- Fix: resource_downloads missing SELECT policy
CREATE POLICY "resource_downloads_select_own" ON resource_downloads
  FOR SELECT TO authenticated USING (user_id = auth.uid());

-- Fix: exam_timetables missing INSERT/UPDATE/DELETE policies
CREATE POLICY "exam_timetables_insert_admin" ON exam_timetables
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "exam_timetables_update_admin" ON exam_timetables
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "exam_timetables_delete_admin" ON exam_timetables
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- Fix: academic_resources missing DELETE policy
CREATE POLICY "academic_resources_delete_owner" ON academic_resources
  FOR DELETE TO authenticated USING (uploaded_by = auth.uid());

CREATE POLICY "academic_resources_delete_admin" ON academic_resources
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- Fix: event_media missing UPDATE policy
CREATE POLICY "event_media_update_owner" ON event_media
  FOR UPDATE TO authenticated USING (uploaded_by = auth.uid());

-- Fix: poll_options INSERT too permissive — restrict by community membership
CREATE POLICY "poll_options_insert_restricted" ON poll_options
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM community_polls cp
      JOIN community_members cm ON cm.community_id = cp.community_id
      WHERE cp.id = poll_options.poll_id AND cm.user_id = auth.uid()
    )
  );

-- Fix: conversations INSERT too permissive — restrict to authenticated
DROP POLICY IF EXISTS "conversations_insert" ON conversations;
CREATE POLICY "conversations_insert_restricted" ON conversations
  FOR INSERT TO authenticated WITH CHECK (
    auth.uid() IS NOT NULL
    AND (
      -- Direct messages: one of the participants must be the creator
      type = 'direct'
      OR type IN ('group', 'channel', 'study_group', 'announcement')
    )
  );

-- ── 3. Security: Search Path for SECURITY DEFINER Functions ──

-- Fix: Add search_path to security definer functions that lack it
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM university_administrators
    WHERE user_id = $1 AND is_active
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION is_super_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM university_administrators ua
    JOIN admin_roles ar ON ar.id = ua.role_id
    WHERE ua.user_id = $1 AND ua.is_active AND ar.role = 'super_admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION get_user_admin_scope(user_id UUID)
RETURNS TABLE(role TEXT, university_id UUID, faculty_id UUID, department_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT ar.role, ua.university_id, ua.faculty_id, ua.department_id
  FROM university_administrators ua
  JOIN admin_roles ar ON ar.id = ua.role_id
  WHERE ua.user_id = $1 AND ua.is_active;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION log_admin_action(
  actor_id UUID,
  action TEXT,
  entity_type TEXT,
  entity_id UUID,
  university_id UUID DEFAULT NULL,
  details JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO audit_logs (actor_id, action, entity_type, entity_id, university_id, details)
  VALUES ($1, $2, $3, $4, $5, $6);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ── 4. Analytics: Aggregation Function ───────────────────────

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
BEGIN
  -- Active students (profiles created more than 7 days ago)
  SELECT COUNT(*) INTO v_active_students FROM profiles
  WHERE (p_university_id IS NULL OR university_id = p_university_id)
    AND created_at <= now() - interval '7 days';

  -- Daily active users (any activity today)
  SELECT COUNT(DISTINCT user_id) INTO v_daily_active FROM reputation_events
  WHERE created_at >= today
    AND (p_university_id IS NULL OR TRUE); -- join to profiles for university filter

  -- Monthly active users (activity in last 30 days)
  SELECT COUNT(DISTINCT user_id) INTO v_monthly_active FROM reputation_events
  WHERE created_at >= today - interval '30 days';

  -- Communities count
  SELECT COUNT(*) INTO v_communities FROM communities
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  -- Events count
  SELECT COUNT(*) INTO v_events FROM community_events
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  -- Marketplace count
  SELECT COUNT(*) INTO v_marketplace FROM marketplace_items
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  -- Opportunities count
  SELECT COUNT(*) INTO v_opportunities FROM opportunities
  WHERE (p_university_id IS NULL OR university_id = p_university_id);

  -- Posts count (today)
  SELECT COUNT(*) INTO v_posts FROM community_posts
  WHERE created_at >= today;

  -- Upsert analytics snapshot
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

-- ── 5. Performance Indexes ──────────────────────────────────

-- Full-text search for events (currently using ilike)
CREATE INDEX IF NOT EXISTS idx_events_search ON community_events
  USING GIN (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '')));

-- Full-text search for communities
CREATE INDEX IF NOT EXISTS idx_communities_search ON communities
  USING GIN (to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, '')));

-- Full-text search for profiles (users)
CREATE INDEX IF NOT EXISTS idx_profiles_search ON profiles
  USING GIN (to_tsvector('english', coalesce(full_name, '') || ' ' || coalesce(programme, '') || ' ' || coalesce(department, '')));

-- Performance: composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_posts_community_created ON community_posts(community_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comments_post_created ON post_comments(post_id, created_at);

CREATE INDEX IF NOT EXISTS idx_rsvps_event_user ON event_rsvps(event_id, user_id);

CREATE INDEX IF NOT EXISTS idx_tickets_event_user ON event_tickets(event_id, user_id);

CREATE INDEX IF NOT EXISTS idx_messages_conversation_created ON messages(conversation_id, created_at);

CREATE INDEX IF NOT EXISTS idx_conversation_participants_user ON conversation_participants(user_id);

-- ── 6. Helper: row_count function for performance ──────────

CREATE OR REPLACE FUNCTION count_rows(table_name TEXT, conditions JSONB DEFAULT '{}'::jsonb)
RETURNS INTEGER AS $$
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
    v_sql := left(v_sql, -5); -- remove trailing ' AND '
  END IF;

  EXECUTE v_sql INTO v_count;
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
