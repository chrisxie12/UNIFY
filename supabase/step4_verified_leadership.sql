-- ============================================================
-- UNIFY — VERIFIED LEADERSHIP & COMMUNITY SYSTEM
-- ============================================================
-- This migration adds:
--   1. Badges (system-defined achievement badges)
--   2. User Badges (assignment tracking)
--   3. Leadership Roles (position definitions)
--   4. User Leadership (who holds what position)
--   5. Community Requests (creation requests from leaders)
--   6. Communities (actual community groups)
--   7. Community Members (membership + roles)
-- ============================================================

-- ── 1. BADGES ───────────────────────────────────────────────
-- System-defined badge definitions
CREATE TABLE badges (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL UNIQUE,
  description TEXT,
  icon_url    TEXT,
  category    TEXT NOT NULL DEFAULT 'general',
  is_system   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 2. USER BADGES ───────────────────────────────────────────
-- Which user holds which badge (many-to-many)
CREATE TABLE user_badges (
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  badge_id    UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  assigned_by UUID REFERENCES profiles(id),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, badge_id)
);

-- ── 3. LEADERSHIP ROLES ──────────────────────────────────────
-- Position definitions (class rep, dept rep, etc.)
CREATE TABLE leadership_roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT NOT NULL UNIQUE,
  title       TEXT NOT NULL,              -- "Class Representative"
  description TEXT,
  is_elective BOOLEAN NOT NULL DEFAULT FALSE,
  priority    INTEGER NOT NULL DEFAULT 0, -- higher = more prominent
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 4. USER LEADERSHIP ───────────────────────────────────────
-- Who holds which leadership position
CREATE TABLE user_leadership (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role_id       UUID NOT NULL REFERENCES leadership_roles(id),
  university_id UUID NOT NULL REFERENCES universities(id),
  faculty       TEXT,
  department    TEXT,
  programme     TEXT,
  level         TEXT,
  academic_year TEXT NOT NULL,
  verified_by   UUID REFERENCES profiles(id),
  verified_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 5. COMMUNITY REQUESTS ────────────────────────────────────
-- Verified leaders request community creation here
CREATE TABLE community_requests (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id           UUID NOT NULL REFERENCES profiles(id),
  university_id          UUID NOT NULL REFERENCES universities(id),
  community_name         TEXT NOT NULL,
  community_type         TEXT NOT NULL CHECK (community_type IN (
                           'class','department','faculty','university','club','level'
                         )),
  faculty                TEXT,
  department             TEXT,
  programme              TEXT,
  level                  TEXT,
  academic_year          TEXT,
  estimated_student_count INTEGER,
  purpose                TEXT NOT NULL,
  status                 TEXT NOT NULL DEFAULT 'pending'
                           CHECK (status IN ('pending','approved','rejected','changes_requested')),
  admin_feedback         TEXT,
  reviewed_by            UUID REFERENCES profiles(id),
  reviewed_at            TIMESTAMPTZ,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER community_requests_updated_at
  BEFORE UPDATE ON community_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── 6. COMMUNITIES ───────────────────────────────────────────
-- Actual community groups that users can join
CREATE TABLE communities (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  slug            TEXT NOT NULL UNIQUE,
  description     TEXT,
  community_type  TEXT NOT NULL CHECK (community_type IN (
                    'class','department','faculty','university','club','level'
                  )),
  university_id   UUID NOT NULL REFERENCES universities(id),
  faculty         TEXT,
  department      TEXT,
  programme       TEXT,
  level           TEXT,
  academic_year   TEXT,
  cover_url       TEXT,
  avatar_url      TEXT,
  member_count    INTEGER NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_by      UUID REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER communities_updated_at
  BEFORE UPDATE ON communities
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── 7. COMMUNITY MEMBERS ─────────────────────────────────────
-- Membership + role within a community
CREATE TABLE community_members (
  community_id  UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'member'
                  CHECK (role IN ('owner','moderator','member')),
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (community_id, user_id)
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE badges              ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges         ENABLE ROW LEVEL SECURITY;
ALTER TABLE leadership_roles    ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_leadership     ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_requests  ENABLE ROW LEVEL SECURITY;
ALTER TABLE communities         ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_members   ENABLE ROW LEVEL SECURITY;

-- ── badges: public read ───────────────────────────────────────
CREATE POLICY "badges_public_read" ON badges FOR SELECT USING (TRUE);

-- ── user_badges: public read (profile display), own insert via trigger, admin all ──
CREATE POLICY "user_badges_public_read" ON user_badges FOR SELECT USING (TRUE);
CREATE POLICY "user_badges_admin_all" ON user_badges FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ── leadership_roles: public read ─────────────────────────────
CREATE POLICY "leadership_roles_public_read" ON leadership_roles FOR SELECT USING (TRUE);

-- ── user_leadership: public read, admin all ───────────────────
CREATE POLICY "user_leadership_public_read" ON user_leadership FOR SELECT USING (TRUE);
CREATE POLICY "user_leadership_admin_all" ON user_leadership FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ── community_requests: creator read/update, admin all ────────
CREATE POLICY "community_requests_own" ON community_requests FOR ALL USING (
  auth.uid() = requester_id
);
CREATE POLICY "community_requests_admin_all" ON community_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ── communities: public read, verified leaders can create, admin all ──
CREATE POLICY "communities_public_read" ON communities FOR SELECT USING (TRUE);
CREATE POLICY "communities_admin_all" ON communities FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ── community_members: public read on own, members, admins ────
CREATE POLICY "community_members_public_read" ON community_members FOR SELECT USING (TRUE);
CREATE POLICY "community_members_own_insert" ON community_members FOR INSERT WITH CHECK (
  auth.uid() = user_id
);
CREATE POLICY "community_members_own_delete" ON community_members FOR DELETE USING (
  auth.uid() = user_id
);
CREATE POLICY "community_members_moderator_delete" ON community_members FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM community_members cm
    WHERE cm.community_id = community_members.community_id
      AND cm.user_id = auth.uid()
      AND cm.role IN ('owner','moderator')
  )
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_user_badges_user     ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge    ON user_badges(badge_id);
CREATE INDEX idx_user_leadership_user ON user_leadership(user_id);
CREATE INDEX idx_community_requests_status ON community_requests(status);
CREATE INDEX idx_communities_uni      ON communities(university_id);
CREATE INDEX idx_communities_type     ON communities(community_type);
CREATE INDEX idx_community_members_community ON community_members(community_id);
CREATE INDEX idx_community_members_user      ON community_members(user_id);
CREATE INDEX idx_community_members_role      ON community_members(role);

-- ============================================================
-- SEED DATA — Leadership Roles
-- ============================================================

INSERT INTO leadership_roles (slug, title, description, is_elective, priority) VALUES
  ('class_rep',           'Class Representative',        'Elected representative for a class', TRUE, 10),
  ('assistant_class_rep', 'Assistant Class Representative', 'Assistant to the class representative', TRUE, 9),
  ('course_rep',          'Course Representative',       'Represents students in a specific course', TRUE, 8),
  ('department_rep',      'Department Representative',   'Represents an academic department', TRUE, 7),
  ('faculty_rep',         'Faculty Representative',      'Represents an entire faculty', TRUE, 6),
  ('src_executive',       'SRC Executive',               'Students Representative Council executive', TRUE, 10),
  ('hall_rep',            'Hall Representative',         'Represents a residential hall', TRUE, 5),
  ('club_president',      'Club President',              'President of a student club', TRUE, 8);

-- ============================================================
-- SEED DATA — System Badges
-- ============================================================

INSERT INTO badges (name, slug, description, category, is_system) VALUES
  ('Verified Student',     'verified_student',     'Account verified as a registered student',            'verification', TRUE),
  ('Class Representative', 'class_rep',            'Elected class representative',                        'leadership',   TRUE),
  ('Assistant Class Rep',  'assistant_class_rep',  'Assistant class representative',                     'leadership',   TRUE),
  ('Department Rep',       'department_rep',       'Department representative',                           'leadership',   TRUE),
  ('Faculty Rep',          'faculty_rep',          'Faculty representative',                              'leadership',   TRUE),
  ('SRC Executive',        'src_executive',        'Students Representative Council executive',           'leadership',   TRUE),
  ('Hall Representative',  'hall_rep',             'Residential hall representative',                     'leadership',   TRUE),
  ('Club President',       'club_president',       'President of a recognized student club',             'leadership',   TRUE),
  ('UNIFY Ambassador',     'unify_ambassador',     'Official UNIFY campus ambassador',                   'community',    TRUE),
  ('Early Adopter',        'early_adopter',        'Joined UNIFY during the early launch phase',          'milestone',    TRUE),
  ('Profile Complete',     'profile_complete',     'Completed all profile sections',                      'milestone',    TRUE),
  ('Power User',           'power_user',           'Highly engaged UNIFY user',                           'milestone',    TRUE);
