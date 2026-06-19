-- UNIFY Community Core: badges, leadership, communities, verification, managers, discussions

BEGIN;

-- ── Badges ───────────────────────────────────────────────────────
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
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  badge_slug  TEXT NOT NULL REFERENCES badges(slug),
  assigned_by UUID REFERENCES profiles(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, badge_slug)
);

-- ── Leadership Roles ─────────────────────────────────────────────
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
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role_id       UUID NOT NULL REFERENCES leadership_roles(id),
  university_id TEXT,
  faculty       TEXT,
  department    TEXT,
  programme     TEXT,
  level         TEXT,
  academic_year TEXT,
  verified_by   UUID REFERENCES profiles(id),
  verified_at   TIMESTAMPTZ,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, role_id)
);

-- ── Community Requests ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS community_requests (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id            UUID NOT NULL REFERENCES profiles(id),
  university_id           TEXT NOT NULL,
  community_name          TEXT NOT NULL,
  community_type          TEXT NOT NULL DEFAULT 'class',
  faculty                 TEXT,
  department              TEXT,
  programme               TEXT,
  level                   TEXT,
  academic_year           TEXT,
  estimated_student_count INTEGER DEFAULT 0,
  purpose                 TEXT,
  status                  TEXT NOT NULL DEFAULT 'pending',
  admin_feedback          TEXT,
  reviewed_by             UUID REFERENCES profiles(id),
  reviewed_at             TIMESTAMPTZ,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER community_requests_updated_at
  BEFORE UPDATE ON community_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── Communities ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS communities (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  slug            TEXT NOT NULL UNIQUE,
  description     TEXT,
  community_type  TEXT NOT NULL DEFAULT 'class',
  university_id   TEXT,
  faculty         TEXT,
  department      TEXT,
  programme       TEXT,
  level           TEXT,
  academic_year   TEXT,
  cover_url       TEXT,
  avatar_url      TEXT,
  member_count    INTEGER NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  is_featured     BOOLEAN NOT NULL DEFAULT FALSE,
  created_by      UUID NOT NULL REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER communities_updated_at
  BEFORE UPDATE ON communities
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

CREATE TABLE IF NOT EXISTS community_members (
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role         TEXT NOT NULL DEFAULT 'member',
  joined_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (community_id, user_id)
);

-- ── Community Managers ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS community_managers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id  UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'manager'
                  CHECK (role IN ('owner', 'manager', 'moderator')),
  assigned_by   UUID REFERENCES profiles(id),
  assigned_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (community_id, user_id)
);

-- ── Announcement Requests ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcement_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id    UUID NOT NULL REFERENCES profiles(id),
  university_id   TEXT,
  community_id    UUID REFERENCES communities(id),
  title           TEXT NOT NULL,
  body            TEXT NOT NULL,
  category        TEXT NOT NULL DEFAULT 'general',
  is_urgent       BOOLEAN NOT NULL DEFAULT FALSE,
  target_audience TEXT,
  status          TEXT NOT NULL DEFAULT 'pending',
  admin_notes     TEXT,
  reviewed_by     UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER announcement_requests_updated_at
  BEFORE UPDATE ON announcement_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── Verification ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS verification_requests (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id),
  university_id     TEXT,
  position          TEXT NOT NULL,
  class_represented TEXT,
  department        TEXT,
  academic_year     TEXT,
  evidence_url      TEXT,
  evidence_type     TEXT,
  status            TEXT NOT NULL DEFAULT 'pending',
  admin_notes       TEXT,
  reviewed_by       UUID REFERENCES profiles(id),
  reviewed_at       TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER verification_requests_updated_at
  BEFORE UPDATE ON verification_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

CREATE TABLE IF NOT EXISTS verification_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES profiles(id),
  action       TEXT NOT NULL,
  old_status   TEXT,
  new_status   TEXT,
  performed_by UUID NOT NULL REFERENCES profiles(id),
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── RLS ──────────────────────────────────────────────────────────
ALTER TABLE badges               ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges          ENABLE ROW LEVEL SECURITY;
ALTER TABLE leadership_roles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_leadership      ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_requests   ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities          ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members    ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_managers   ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_log      ENABLE ROW LEVEL SECURITY;

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

-- Leadership roles (public read)
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
CREATE POLICY community_requests_own ON community_requests FOR ALL USING (auth.uid() = requester_id);
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
CREATE POLICY community_members_self_join ON community_members FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS community_members_self_leave ON community_members;
CREATE POLICY community_members_self_leave ON community_members FOR DELETE USING (auth.uid() = user_id);
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
CREATE POLICY announcement_requests_own ON announcement_requests FOR ALL USING (auth.uid() = requester_id);
DROP POLICY IF EXISTS announcement_requests_admin_all ON announcement_requests;
CREATE POLICY announcement_requests_admin_all ON announcement_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

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

-- ── Indexes ──────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_user_badges_user              ON user_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge             ON user_badges(badge_slug);
CREATE INDEX IF NOT EXISTS idx_user_leadership_user           ON user_leadership(user_id);
CREATE INDEX IF NOT EXISTS idx_community_requests_creator     ON community_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_community_requests_status      ON community_requests(status);
CREATE INDEX IF NOT EXISTS idx_communities_university         ON communities(university_id);
CREATE INDEX IF NOT EXISTS idx_communities_type               ON communities(community_type);
CREATE INDEX IF NOT EXISTS idx_community_members_user         ON community_members(user_id);
CREATE INDEX IF NOT EXISTS idx_community_members_community    ON community_members(community_id);
CREATE INDEX IF NOT EXISTS idx_community_members_role         ON community_members(role);
CREATE INDEX IF NOT EXISTS idx_community_managers_community   ON community_managers(community_id);
CREATE INDEX IF NOT EXISTS idx_community_managers_user        ON community_managers(user_id);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_status   ON announcement_requests(status);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_creator  ON announcement_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_announcement_requests_community ON announcement_requests(community_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_user     ON verification_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status   ON verification_requests(status);
CREATE INDEX IF NOT EXISTS idx_verification_log_target        ON verification_log(target_user_id);

-- ── Seed data ────────────────────────────────────────────────────
INSERT INTO badges (name, slug, description, category, is_system) VALUES
  ('Administrator',    'admin',                'UNIFY platform administrator',                   'verification', TRUE),
  ('Verified Student', 'verified_student',     'Identity verified as a real student',            'verification', TRUE),
  ('Class Representative', 'class_representative', 'Official class representative',              'leadership',   TRUE),
  ('SRC Executive',    'src_executive',        'Students Representative Council executive',      'leadership',   TRUE),
  ('Department Executive', 'department_executive', 'Department-level student leader',            'leadership',   TRUE),
  ('Hall Executive',   'hall_executive',       'Hall/Residence student leader',                  'leadership',   TRUE)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO leadership_roles (slug, title, description, is_elective, priority) VALUES
  ('class_representative',          'Class Representative',          'Official class representative',          TRUE,  10),
  ('assistant_class_representative','Assistant Class Representative','Assistant to the class representative', TRUE,  9),
  ('course_representative',         'Course Representative',         'Course-level student representative',    TRUE,  8),
  ('src_executive',                 'SRC Executive',                 'Students Representative Council',        TRUE,  7),
  ('department_executive',          'Department Executive',          'Department-level student leader',        TRUE,  6),
  ('hall_executive',                'Hall Executive',                'Hall/Residence student leader',          TRUE,  5)
ON CONFLICT (slug) DO NOTHING;

COMMIT;
