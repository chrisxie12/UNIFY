-- ============================================================
-- UNIFY - Consolidated Step 4-7: Full Community & Leadership
-- ============================================================
-- All ID columns use TEXT to match existing profiles.id type.
-- auth.uid() cast to ::text for consistent comparisons.
-- All operations guarded for re-runnability.
-- ============================================================

BEGIN;

-- ============================================================
-- STEP 4: LEADERSHIP & COMMUNITY TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS badges (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL UNIQUE,
  description TEXT,
  icon_url    TEXT,
  category    TEXT NOT NULL DEFAULT 'verification',
  is_system   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_badges (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  badge_slug  TEXT NOT NULL REFERENCES badges(slug),
  assigned_by UUID REFERENCES profiles(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, badge_slug)
);

CREATE TABLE IF NOT EXISTS leadership_roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT NOT NULL UNIQUE,
  title       TEXT NOT NULL,
  description TEXT,
  is_elective BOOLEAN NOT NULL DEFAULT FALSE,
  priority    INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_leadership (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES leadership_roles(id),
  university_id TEXT,
  faculty       TEXT,
  department    TEXT,
  programme     TEXT,
  level         TEXT,
  academic_year TEXT,
  verified_by UUID REFERENCES profiles(id),
  verified_at   TIMESTAMPTZ,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS community_requests (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES profiles(id),
  university_id TEXT NOT NULL,
  community_name        TEXT NOT NULL,
  community_type        TEXT NOT NULL DEFAULT 'class',
  faculty               TEXT,
  department            TEXT,
  programme             TEXT,
  level                 TEXT,
  academic_year         TEXT,
  estimated_student_count INTEGER DEFAULT 0,
  purpose               TEXT,
  status                TEXT NOT NULL DEFAULT 'pending',
  admin_feedback        TEXT,
  reviewed_by UUID REFERENCES profiles(id),
  reviewed_at           TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS community_requests_updated_at ON community_requests;
CREATE TRIGGER community_requests_updated_at
  BEFORE UPDATE ON community_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

CREATE TABLE IF NOT EXISTS communities (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  slug            TEXT NOT NULL UNIQUE,
  description     TEXT,
  community_type  TEXT NOT NULL DEFAULT 'class',
  university_id TEXT,
  faculty         TEXT,
  department      TEXT,
  programme       TEXT,
  level           TEXT,
  academic_year   TEXT,
  cover_url       TEXT,
  avatar_url      TEXT,
  member_count    INTEGER NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS communities_updated_at ON communities;
CREATE TRIGGER communities_updated_at
  BEFORE UPDATE ON communities
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

CREATE TABLE IF NOT EXISTS community_members (
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'member',
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (community_id, user_id)
);

-- ============================================================
-- STEP 5: VERIFICATION
-- ============================================================

CREATE TABLE IF NOT EXISTS verification_requests (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  university_id TEXT,
  position            TEXT NOT NULL,
  class_represented   TEXT,
  department          TEXT,
  academic_year       TEXT,
  evidence_url        TEXT,
  evidence_type       TEXT,
  status              TEXT NOT NULL DEFAULT 'pending',
  admin_notes         TEXT,
  reviewed_by UUID REFERENCES profiles(id),
  reviewed_at         TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS verification_requests_updated_at ON verification_requests;
CREATE TRIGGER verification_requests_updated_at
  BEFORE UPDATE ON verification_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

CREATE TABLE IF NOT EXISTS verification_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  action          TEXT NOT NULL,
  old_status      TEXT,
  new_status      TEXT,
  performed_by UUID NOT NULL REFERENCES profiles(id),
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add verification columns to profiles if missing
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='verification_status') THEN
    ALTER TABLE profiles ADD COLUMN verification_status TEXT NOT NULL DEFAULT 'none';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='is_verified_leader') THEN
    ALTER TABLE profiles ADD COLUMN is_verified_leader BOOLEAN NOT NULL DEFAULT FALSE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='leadership_role') THEN
    ALTER TABLE profiles ADD COLUMN leadership_role TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='represented_class') THEN
    ALTER TABLE profiles ADD COLUMN represented_class TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='represented_department') THEN
    ALTER TABLE profiles ADD COLUMN represented_department TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='level') THEN
    ALTER TABLE profiles ADD COLUMN level TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='academic_year') THEN
    ALTER TABLE profiles ADD COLUMN academic_year TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='student_id') THEN
    ALTER TABLE profiles ADD COLUMN student_id TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='programme') THEN
    ALTER TABLE profiles ADD COLUMN programme TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='faculty') THEN
    ALTER TABLE profiles ADD COLUMN faculty TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='department') THEN
    ALTER TABLE profiles ADD COLUMN department TEXT;
  END IF;
END $$;

-- Seed badges
INSERT INTO badges (name, slug, description, category, is_system) VALUES
  ('Administrator',    'admin',             'UNIFY platform administrator',                    'verification', TRUE),
  ('Verified Student', 'verified_student',  'Identity verified as a real student',              'verification', TRUE),
  ('Class Representative', 'class_representative', 'Official class representative',             'leadership',   TRUE),
  ('SRC Executive',   'src_executive',      'Students Representative Council executive',        'leadership',   TRUE),
  ('Department Executive', 'department_executive', 'Department-level student leader',           'leadership',   TRUE),
  ('Hall Executive',  'hall_executive',     'Hall/Residence student leader',                   'leadership',   TRUE)
ON CONFLICT (slug) DO NOTHING;

-- Seed leadership roles
INSERT INTO leadership_roles (slug, title, description, is_elective, priority) VALUES
  ('class_representative',         'Class Representative',         'Official class representative',         TRUE,  10),
  ('assistant_class_representative','Assistant Class Representative','Assistant to the class representative',TRUE,  9),
  ('course_representative',        'Course Representative',        'Course-level student representative',   TRUE,  8),
  ('src_executive',                'SRC Executive',                'Students Representative Council',       TRUE,  7),
  ('department_executive',         'Department Executive',         'Department-level student leader',       TRUE,  6),
  ('hall_executive',               'Hall Executive',               'Hall/Residence student leader',         TRUE,  5)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- STEP 6: COMMUNITY MANAGERS & ANNOUNCEMENT REQUESTS
-- ============================================================

CREATE TABLE IF NOT EXISTS community_managers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'manager'
                  CHECK (role IN ('owner', 'manager', 'moderator')),
  assigned_by UUID REFERENCES profiles(id),
  assigned_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (community_id, user_id)
);

CREATE TABLE IF NOT EXISTS announcement_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES profiles(id),
  university_id TEXT,
  community_id UUID REFERENCES communities(id),
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  category        TEXT NOT NULL DEFAULT 'general',
  is_urgent       BOOLEAN NOT NULL DEFAULT FALSE,
  target_audience TEXT,
  status          TEXT NOT NULL DEFAULT 'pending',
  admin_notes     TEXT,
  reviewed_by UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS announcement_requests_updated_at ON announcement_requests;
CREATE TRIGGER announcement_requests_updated_at
  BEFORE UPDATE ON announcement_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ============================================================
-- STEP 7: DISCUSSIONS, RESOURCES, REPORTS, NOTIFICATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS discussions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id),
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  is_locked       BOOLEAN NOT NULL DEFAULT FALSE,
  tags            TEXT[] DEFAULT '{}',
  likes_count     INTEGER NOT NULL DEFAULT 0,
  comments_count  INTEGER NOT NULL DEFAULT 0,
  view_count      INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS discussion_comments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES discussion_comments(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id),
  body          TEXT NOT NULL,
  likes_count   INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS discussion_likes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (discussion_id, user_id)
);

CREATE TABLE IF NOT EXISTS discussion_comment_likes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES discussion_comments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);

CREATE TABLE IF NOT EXISTS community_resources (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  uploader_id UUID NOT NULL REFERENCES profiles(id),
  title           TEXT NOT NULL,
  description     TEXT,
  file_type       TEXT NOT NULL,
  file_url        TEXT NOT NULL,
  file_size       BIGINT,
  resource_type   TEXT NOT NULL DEFAULT 'other',
  download_count  INTEGER NOT NULL DEFAULT 0,
  is_approved     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reports (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES profiles(id),
  report_type     TEXT NOT NULL,
  target_id TEXT NOT NULL,
  target_owner_id UUID REFERENCES profiles(id),
  reason          TEXT NOT NULL,
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'open',
  resolved_by UUID REFERENCES profiles(id),
  resolved_at     TIMESTAMPTZ,
  admin_notes     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type            TEXT NOT NULL,
  title           TEXT NOT NULL,
  body            TEXT,
  reference_id TEXT,
  reference_type  TEXT,
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_user_badges_user           ON user_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_user_leadership_user       ON user_leadership(user_id);
CREATE INDEX IF NOT EXISTS idx_community_requests_creator ON community_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_community_requests_status  ON community_requests(status);
CREATE INDEX IF NOT EXISTS idx_communities_university     ON communities(university_id);
CREATE INDEX IF NOT EXISTS idx_communities_type           ON communities(community_type);
CREATE INDEX IF NOT EXISTS idx_community_members_user     ON community_members(user_id);
CREATE INDEX IF NOT EXISTS idx_community_members_community ON community_members(community_id);
CREATE INDEX IF NOT EXISTS idx_community_managers_community ON community_managers(community_id);
CREATE INDEX IF NOT EXISTS idx_community_managers_user    ON community_managers(user_id);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_status ON announcement_requests(status);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_creator ON announcement_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_discussions_community      ON discussions(community_id);
CREATE INDEX IF NOT EXISTS idx_discussions_author         ON discussions(author_id);
CREATE INDEX IF NOT EXISTS idx_discussions_pinned         ON discussions(community_id, is_pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_discussion ON discussion_comments(discussion_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_parent ON discussion_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_community_resources_community ON community_resources(community_id);
CREATE INDEX IF NOT EXISTS idx_reports_status              ON reports(status);
CREATE INDEX IF NOT EXISTS idx_notifications_user          ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread        ON notifications(user_id) WHERE NOT is_read;
CREATE INDEX IF NOT EXISTS idx_verification_requests_user  ON verification_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status ON verification_requests(status);

-- ============================================================
-- RLS POLICIES
-- ============================================================

ALTER TABLE badges                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges                ENABLE ROW LEVEL SECURITY;
ALTER TABLE leadership_roles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_leadership            ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_requests         ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities                ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members          ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_managers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_requests      ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussions                ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_likes           ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comment_likes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_resources        ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications              ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests      ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_log           ENABLE ROW LEVEL SECURITY;

-- Badges
DROP POLICY IF EXISTS badges_public_read ON badges;
CREATE POLICY badges_public_read ON badges FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS badges_admin_all ON badges;
CREATE POLICY badges_admin_all ON badges FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- User badges
DROP POLICY IF EXISTS user_badges_public_read ON user_badges;
CREATE POLICY user_badges_public_read ON user_badges FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS user_badges_admin_all ON user_badges;
CREATE POLICY user_badges_admin_all ON user_badges FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Leadership roles
DROP POLICY IF EXISTS leadership_roles_public_read ON leadership_roles;
CREATE POLICY leadership_roles_public_read ON leadership_roles FOR SELECT USING (TRUE);

-- User leadership
DROP POLICY IF EXISTS user_leadership_public_read ON user_leadership;
CREATE POLICY user_leadership_public_read ON user_leadership FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS user_leadership_admin_all ON user_leadership;
CREATE POLICY user_leadership_admin_all ON user_leadership FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Community requests
DROP POLICY IF EXISTS community_requests_own ON community_requests;
CREATE POLICY community_requests_own ON community_requests FOR ALL USING (
  auth.uid() = requester_id
);

DROP POLICY IF EXISTS community_requests_admin_all ON community_requests;
CREATE POLICY community_requests_admin_all ON community_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Communities
DROP POLICY IF EXISTS communities_public_read ON communities;
CREATE POLICY communities_public_read ON communities FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS communities_verified_insert ON communities;
CREATE POLICY communities_verified_insert ON communities FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS communities_admin_all ON communities;
CREATE POLICY communities_admin_all ON communities FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Community members
DROP POLICY IF EXISTS community_members_read ON community_members;
CREATE POLICY community_members_read ON community_members FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS community_members_self_join ON community_members;
CREATE POLICY community_members_self_join ON community_members FOR INSERT WITH CHECK (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS community_members_self_leave ON community_members;
CREATE POLICY community_members_self_leave ON community_members FOR DELETE USING (
  auth.uid() = user_id
);

DROP POLICY IF EXISTS community_members_owner_manage ON community_members;
CREATE POLICY community_members_owner_manage ON community_members FOR ALL USING (
  EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_members.community_id AND user_id = auth.uid() AND role IN ('owner', 'manager') AND is_active = TRUE)
);

-- Community managers
DROP POLICY IF EXISTS community_managers_public_read ON community_managers;
CREATE POLICY community_managers_public_read ON community_managers FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS community_managers_admin_all ON community_managers;
CREATE POLICY community_managers_admin_all ON community_managers FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Announcement requests
DROP POLICY IF EXISTS announcement_requests_own ON announcement_requests;
CREATE POLICY announcement_requests_own ON announcement_requests FOR ALL USING (
  auth.uid() = requester_id
);

DROP POLICY IF EXISTS announcement_requests_admin_all ON announcement_requests;
CREATE POLICY announcement_requests_admin_all ON announcement_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussions
DROP POLICY IF EXISTS discussions_read_members ON discussions;
CREATE POLICY discussions_read_members ON discussions FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = discussions.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS discussions_insert_members ON discussions;
CREATE POLICY discussions_insert_members ON discussions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS discussions_update_own_mod ON discussions;
CREATE POLICY discussions_update_own_mod ON discussions FOR UPDATE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = discussions.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS discussions_delete_own_mod ON discussions;
CREATE POLICY discussions_delete_own_mod ON discussions FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = discussions.community_id AND user_id = auth.uid() AND role IN ('owner', 'manager', 'moderator') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussion comments
DROP POLICY IF EXISTS discussion_comments_read ON discussion_comments;
CREATE POLICY discussion_comments_read ON discussion_comments FOR SELECT USING (
  EXISTS (SELECT 1 FROM discussions d JOIN community_members cm ON d.community_id = cm.community_id WHERE d.id = discussion_comments.discussion_id AND cm.user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS discussion_comments_insert ON discussion_comments;
CREATE POLICY discussion_comments_insert ON discussion_comments FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members cm JOIN discussions d ON cm.community_id = d.community_id WHERE d.id = discussion_id AND cm.user_id = auth.uid())
);

DROP POLICY IF EXISTS discussion_comments_delete ON discussion_comments;
CREATE POLICY discussion_comments_delete ON discussion_comments FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers cm JOIN discussions d ON cm.community_id = d.community_id WHERE d.id = discussion_comments.discussion_id AND cm.user_id = auth.uid() AND cm.is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussion likes
DROP POLICY IF EXISTS discussion_likes_manage ON discussion_likes;
CREATE POLICY discussion_likes_manage ON discussion_likes FOR ALL USING (auth.uid() = user_id);

-- Discussion comment likes
DROP POLICY IF EXISTS discussion_comment_likes_manage ON discussion_comment_likes;
CREATE POLICY discussion_comment_likes_manage ON discussion_comment_likes FOR ALL USING (auth.uid() = user_id);

-- Resources
DROP POLICY IF EXISTS resources_read_members ON community_resources;
CREATE POLICY resources_read_members ON community_resources FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_resources.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS resources_insert_members ON community_resources;
CREATE POLICY resources_insert_members ON community_resources FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS resources_update_mod ON community_resources;
CREATE POLICY resources_update_mod ON community_resources FOR UPDATE USING (
  uploader_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_resources.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Reports
DROP POLICY IF EXISTS reports_insert_own ON reports;
CREATE POLICY reports_insert_own ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS reports_select_admin ON reports;
CREATE POLICY reports_select_admin ON reports FOR SELECT USING (
  auth.uid() = reporter_id
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

DROP POLICY IF EXISTS reports_update_admin ON reports;
CREATE POLICY reports_update_admin ON reports FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Notifications
DROP POLICY IF EXISTS notifications_select_own ON notifications;
CREATE POLICY notifications_select_own ON notifications FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS notifications_update_own ON notifications;
CREATE POLICY notifications_update_own ON notifications FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS notifications_insert_system ON notifications;
CREATE POLICY notifications_insert_system ON notifications FOR INSERT WITH CHECK (TRUE);

-- Verification requests
DROP POLICY IF EXISTS verification_requests_own ON verification_requests;
CREATE POLICY verification_requests_own ON verification_requests FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS verification_requests_admin_all ON verification_requests;
CREATE POLICY verification_requests_admin_all ON verification_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Verification log
DROP POLICY IF EXISTS verification_log_admin_all ON verification_log;
CREATE POLICY verification_log_admin_all ON verification_log FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- ============================================================
-- NOTIFICATION FUNCTIONS & TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION create_notification(
  p_user_id TEXT,
  p_type TEXT,
  p_title TEXT,
  p_body TEXT DEFAULT NULL,
  p_reference_id TEXT DEFAULT NULL,
  p_reference_type TEXT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id TEXT;
BEGIN
  INSERT INTO notifications (user_id, type, title, body, reference_id, reference_type)
  VALUES (p_user_id, p_type, p_title, p_body, p_reference_id, p_reference_type)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- Auto-notify community request approval
CREATE OR REPLACE FUNCTION notify_community_approved()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    PERFORM create_notification(
      NEW.requester_id, 'community_approved', 'Community Approved',
      'Your community "' || NEW.community_name || '" has been approved!',
      NEW.id, 'community_request'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS community_approved_notification ON community_requests;
CREATE TRIGGER community_approved_notification
  AFTER UPDATE ON community_requests
  FOR EACH ROW
  WHEN (NEW.status = 'approved' AND OLD.status = 'pending')
  EXECUTE FUNCTION notify_community_approved();

-- Auto-notify verification review
CREATE OR REPLACE FUNCTION notify_verification_reviewed()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.user_id, 'verification_approved', 'Verification Approved', 'Your leadership verification has been approved!', NEW.id, 'verification_request');
  ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.user_id, 'verification_rejected', 'Verification Rejected', COALESCE('Your verification was rejected: ' || NEW.admin_notes, 'Your verification was rejected.'), NEW.id, 'verification_request');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS verification_reviewed_notification ON verification_requests;
CREATE TRIGGER verification_reviewed_notification
  AFTER UPDATE ON verification_requests
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected'))
  EXECUTE FUNCTION notify_verification_reviewed();

-- ============================================================
-- AUTO-COUNT TRIGGERS
-- ============================================================

-- Community member count
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE communities SET member_count = member_count + 1 WHERE id = community_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = OLD.community_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS community_members_count_trigger ON community_members;
CREATE TRIGGER community_members_count_trigger
  AFTER INSERT OR DELETE ON community_members
  FOR EACH ROW EXECUTE FUNCTION update_community_member_count();

-- Discussion like count
CREATE OR REPLACE FUNCTION update_discussion_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE discussions SET likes_count = likes_count + 1 WHERE id = discussion_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE discussions SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.discussion_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS discussion_likes_count_trigger ON discussion_likes;
CREATE TRIGGER discussion_likes_count_trigger
  AFTER INSERT OR DELETE ON discussion_likes
  FOR EACH ROW EXECUTE FUNCTION update_discussion_likes_count();

-- Discussion comment count
CREATE OR REPLACE FUNCTION update_discussion_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE discussions SET comments_count = comments_count + 1 WHERE id = discussion_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE discussions SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.discussion_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS discussion_comments_count_trigger ON discussion_comments;
CREATE TRIGGER discussion_comments_count_trigger
  AFTER INSERT OR DELETE ON discussion_comments
  FOR EACH ROW EXECUTE FUNCTION update_discussion_comments_count();

-- ============================================================
-- RPC FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION increment_discussion_view(p_discussion_id TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  UPDATE discussions SET view_count = view_count + 1 WHERE id = p_discussion_id;
END;
$$;

CREATE OR REPLACE FUNCTION increment_resource_download(p_resource_id TEXT)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  UPDATE community_resources SET download_count = download_count + 1 WHERE id = p_resource_id;
END;
$$;

COMMIT;




