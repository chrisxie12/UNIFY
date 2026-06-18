-- ============================================================
-- STEP 15 — Reputation & Campus Identity System
-- Reputation scores, achievements, skills, endorsements,
-- contributions, leadership history, portfolio, certificates
-- ============================================================

-- ── 1. Reputation Score ────────────────────────────────────

CREATE TABLE IF NOT EXISTS reputation_scores (
  user_id    UUID        PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  score      INTEGER     NOT NULL DEFAULT 0,
  level      TEXT        NOT NULL DEFAULT 'beginner', -- beginner | bronze | silver | gold | platinum | diamond
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 2. Reputation Events (points log) ─────────────────────

CREATE TABLE IF NOT EXISTS reputation_events (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_type    TEXT        NOT NULL, -- post_created | comment_upvoted | event_attended | resource_uploaded | etc
  points        INTEGER     NOT NULL,
  reference_type TEXT,
  reference_id  TEXT,
  description   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 3. Achievement Definitions ─────────────────────────────

CREATE TABLE IF NOT EXISTS achievement_definitions (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT        NOT NULL UNIQUE,
  title       TEXT        NOT NULL,
  description TEXT,
  icon_url    TEXT,
  category    TEXT        NOT NULL DEFAULT 'general', -- general | community | academic | leadership | event | marketplace
  criteria    JSONB,       -- {type: 'count', table: 'posts', column: 'id', threshold: 1}
  points      INTEGER     NOT NULL DEFAULT 0,
  is_system   BOOLEAN     NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 4. User Achievements ───────────────────────────────────

CREATE TABLE IF NOT EXISTS user_achievements (
  user_id         UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id  UUID        NOT NULL REFERENCES achievement_definitions(id) ON DELETE CASCADE,
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  notification_sent BOOLEAN   NOT NULL DEFAULT false,
  PRIMARY KEY (user_id, achievement_id)
);

-- ── 5. Skills ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS user_skills (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  skill_name       TEXT        NOT NULL,
  proficiency_level TEXT       NOT NULL DEFAULT 'beginner', -- beginner | intermediate | advanced | expert
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, skill_name)
);

-- ── 6. Skill Endorsements ──────────────────────────────────

CREATE TABLE IF NOT EXISTS skill_endorsements (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id      UUID        NOT NULL REFERENCES user_skills(id) ON DELETE CASCADE,
  endorsed_by   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  message       TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (skill_id, endorsed_by)
);

-- ── 7. Contribution Log ────────────────────────────────────

CREATE TABLE IF NOT EXISTS contribution_log (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  contribution_type TEXT      NOT NULL, -- post | resource | event | comment | marketplace | volunteer
  reference_type  TEXT,
  reference_id    TEXT,
  label           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 8. Portfolio Projects ──────────────────────────────────

CREATE TABLE IF NOT EXISTS portfolio_projects (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  description TEXT,
  url         TEXT,
  start_date  DATE,
  end_date    DATE,
  is_current  BOOLEAN     NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ
);

-- ── 9. Leadership History ──────────────────────────────────

CREATE TABLE IF NOT EXISTS leadership_history (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  position     TEXT        NOT NULL,
  organization TEXT        NOT NULL,
  start_date   DATE,
  end_date     DATE,
  is_current   BOOLEAN     NOT NULL DEFAULT false,
  description  TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 10. User Certificates Vault ────────────────────────────

CREATE TABLE IF NOT EXISTS user_certificates (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title            TEXT        NOT NULL,
  issuer           TEXT        NOT NULL,
  certificate_type TEXT        NOT NULL, -- workshop | competition | event | leadership | training
  url              TEXT,
  issued_at        DATE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── RLS: reputation_scores ─────────────────────────────────

ALTER TABLE reputation_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reputation_select" ON reputation_scores
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "reputation_update" ON reputation_scores
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid());

-- ── RLS: reputation_events ─────────────────────────────────

ALTER TABLE reputation_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "rep_events_select" ON reputation_events
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "rep_events_insert" ON reputation_events
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- ── RLS: achievement_definitions ───────────────────────────

ALTER TABLE achievement_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "achievements_def_select" ON achievement_definitions
  FOR SELECT TO authenticated USING (true);

-- ── RLS: user_achievements ─────────────────────────────────

ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_achievements_select" ON user_achievements
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_achievements_insert" ON user_achievements
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- ── RLS: user_skills ───────────────────────────────────────

ALTER TABLE user_skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "skills_select" ON user_skills
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "skills_insert" ON user_skills
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "skills_update" ON user_skills
  FOR UPDATE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "skills_delete" ON user_skills
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ── RLS: skill_endorsements ────────────────────────────────

ALTER TABLE skill_endorsements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "endorsements_select" ON skill_endorsements
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "endorsements_insert" ON skill_endorsements
  FOR INSERT TO authenticated WITH CHECK (endorsed_by = auth.uid());

-- ── RLS: contribution_log ──────────────────────────────────

ALTER TABLE contribution_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "contributions_select" ON contribution_log
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "contributions_insert" ON contribution_log
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- ── RLS: portfolio_projects ────────────────────────────────

ALTER TABLE portfolio_projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "projects_select" ON portfolio_projects
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "projects_insert" ON portfolio_projects
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "projects_update" ON portfolio_projects
  FOR UPDATE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "projects_delete" ON portfolio_projects
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ── RLS: leadership_history ────────────────────────────────

ALTER TABLE leadership_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "leader_history_select" ON leadership_history
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "leader_history_insert" ON leadership_history
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "leader_history_update" ON leadership_history
  FOR UPDATE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "leader_history_delete" ON leadership_history
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ── RLS: user_certificates ─────────────────────────────────

ALTER TABLE user_certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "certs_select" ON user_certificates
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "certs_insert" ON user_certificates
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "certs_delete" ON user_certificates
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ── Indexes ────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_reputation_user ON reputation_scores(user_id);
CREATE INDEX IF NOT EXISTS idx_rep_events_user ON reputation_events(user_id);
CREATE INDEX IF NOT EXISTS idx_rep_events_type ON reputation_events(event_type);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_skills_user ON user_skills(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_endorsements_skill ON skill_endorsements(skill_id);
CREATE INDEX IF NOT EXISTS idx_contributions_user ON contribution_log(user_id);
CREATE INDEX IF NOT EXISTS idx_contributions_type ON contribution_log(contribution_type);
CREATE INDEX IF NOT EXISTS idx_portfolio_projects_user ON portfolio_projects(user_id);
CREATE INDEX IF NOT EXISTS idx_leadership_history_user ON leadership_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_certificates_user ON user_certificates(user_id);

-- ── Seed Achievements ─────────────────────────────────────

INSERT INTO achievement_definitions (slug, title, description, category, criteria, points) VALUES
  ('first_post', 'First Post', 'Created your first post in a community', 'community', '{"type": "count", "table": "community_posts", "threshold": 1}', 10),
  ('community_builder', 'Community Builder', 'Joined 5 communities', 'community', '{"type": "count", "table": "community_members", "threshold": 5}', 25),
  ('top_contributor', 'Top Contributor', 'Received 50 upvotes on your posts', 'community', '{"type": "sum", "table": "community_posts", "column": "upvote_count", "threshold": 50}', 100),
  ('course_rep', 'Course Representative', 'Became a verified course representative', 'leadership', '{"type": "role", "role": "course_rep"}', 50),
  ('event_organizer', 'Event Organizer', 'Organized your first event', 'event', '{"type": "count", "table": "community_events", "threshold": 1}', 30),
  ('resource_contributor', 'Resource Contributor', 'Uploaded 5 academic resources', 'academic', '{"type": "count", "table": "academic_resources", "threshold": 5}', 40),
  ('study_leader', 'Study Leader', 'Created a study plan and completed 10 tasks', 'academic', '{"type": "custom", "description": "Complete 10 study plan items"}', 35),
  ('event_attendee', 'Event Goer', 'Attended 3 events', 'event', '{"type": "count", "table": "event_tickets", "where": "attended = true", "threshold": 3}', 15),
  ('helpful_member', 'Helpful Member', 'Had a comment marked as best answer', 'community', '{"type": "count", "table": "post_comments", "where": "is_best_answer = true", "threshold": 1}', 50),
  ('campus_influencer', 'Campus Influencer', 'Reached 100 reputation points', 'general', '{"type": "custom", "description": "Reach 100 reputation score"}', 0)
ON CONFLICT (slug) DO NOTHING;
