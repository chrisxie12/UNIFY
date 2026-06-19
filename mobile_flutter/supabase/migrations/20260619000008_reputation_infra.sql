-- UNIFY Reputation, Identity & Launch Infrastructure

BEGIN;

-- ============================================================
-- PART 1: REPUTATION & IDENTITY SYSTEM
-- ============================================================

CREATE TABLE IF NOT EXISTS reputation_scores (
  user_id    UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  score      INTEGER NOT NULL DEFAULT 0,
  level      TEXT NOT NULL DEFAULT 'beginner',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reputation_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_type    TEXT NOT NULL,
  points        INTEGER NOT NULL,
  reference_type TEXT,
  reference_id  TEXT,
  description   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS achievement_definitions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT NOT NULL UNIQUE,
  title       TEXT NOT NULL,
  description TEXT,
  icon_url    TEXT,
  category    TEXT NOT NULL DEFAULT 'general',
  criteria    JSONB,
  points      INTEGER NOT NULL DEFAULT 0,
  is_system   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_achievements (
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id  UUID NOT NULL REFERENCES achievement_definitions(id) ON DELETE CASCADE,
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  notification_sent BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE IF NOT EXISTS user_skills (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  skill_name        TEXT NOT NULL,
  proficiency_level TEXT NOT NULL DEFAULT 'beginner',
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, skill_name)
);

CREATE TABLE IF NOT EXISTS skill_endorsements (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id     UUID NOT NULL REFERENCES user_skills(id) ON DELETE CASCADE,
  endorsed_by  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  message      TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (skill_id, endorsed_by)
);

CREATE TABLE IF NOT EXISTS contribution_log (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  contribution_type TEXT NOT NULL,
  reference_type   TEXT,
  reference_id     TEXT,
  label            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS portfolio_projects (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT,
  url         TEXT,
  start_date  DATE,
  end_date    DATE,
  is_current  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS leadership_history (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  position     TEXT NOT NULL,
  organization TEXT NOT NULL,
  start_date   DATE,
  end_date     DATE,
  is_current   BOOLEAN NOT NULL DEFAULT FALSE,
  description  TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_certificates (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  issuer           TEXT NOT NULL,
  certificate_type TEXT NOT NULL,
  url              TEXT,
  issued_at        DATE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS: reputation
ALTER TABLE reputation_scores      ENABLE ROW LEVEL SECURITY;
ALTER TABLE reputation_events      ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievement_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements      ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_skills            ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_endorsements     ENABLE ROW LEVEL SECURITY;
ALTER TABLE contribution_log       ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_projects     ENABLE ROW LEVEL SECURITY;
ALTER TABLE leadership_history     ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_certificates      ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reputation_select" ON reputation_scores FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "reputation_update" ON reputation_scores FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "rep_events_select" ON reputation_events FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "rep_events_insert" ON reputation_events FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "achievements_def_select" ON achievement_definitions FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "user_achievements_select" ON user_achievements FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "user_achievements_insert" ON user_achievements FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "skills_select" ON user_skills FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "skills_insert" ON user_skills FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "skills_update" ON user_skills FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "skills_delete" ON user_skills FOR DELETE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "endorsements_select" ON skill_endorsements FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "endorsements_insert" ON skill_endorsements FOR INSERT TO authenticated WITH CHECK (endorsed_by = auth.uid());
CREATE POLICY "contributions_select" ON contribution_log FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "contributions_insert" ON contribution_log FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "projects_select" ON portfolio_projects FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "projects_insert" ON portfolio_projects FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "projects_update" ON portfolio_projects FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "projects_delete" ON portfolio_projects FOR DELETE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "leader_history_select" ON leadership_history FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "leader_history_insert" ON leadership_history FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "leader_history_update" ON leadership_history FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "leader_history_delete" ON leadership_history FOR DELETE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "certs_select" ON user_certificates FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "certs_insert" ON user_certificates FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "certs_delete" ON user_certificates FOR DELETE TO authenticated USING (user_id = auth.uid());

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

-- Seed achievements
INSERT INTO achievement_definitions (slug, title, description, category, criteria, points) VALUES
  ('first_post', 'First Post', 'Created your first post in a community', 'community', '{"type": "count", "table": "community_posts", "threshold": 1}', 10),
  ('community_builder', 'Community Builder', 'Joined 5 communities', 'community', '{"type": "count", "table": "community_members", "threshold": 5}', 25),
  ('top_contributor', 'Top Contributor', 'Received 50 upvotes on your posts', 'community', '{"type": "sum", "table": "community_posts", "column": "upvote_count", "threshold": 50}', 100),
  ('event_organizer', 'Event Organizer', 'Organized your first event', 'event', '{"type": "count", "table": "community_events", "threshold": 1}', 30),
  ('resource_contributor', 'Resource Contributor', 'Uploaded 5 academic resources', 'academic', '{"type": "count", "table": "academic_resources", "threshold": 5}', 40)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- PART 2: FEATURE FLAGS
-- ============================================================

CREATE TABLE IF NOT EXISTS feature_flags (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL UNIQUE,
  label       TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  enabled     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read feature_flags" ON feature_flags;
CREATE POLICY "Anyone can read feature_flags" ON feature_flags FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Super admins can toggle feature_flags" ON feature_flags;
CREATE POLICY "Super admins can toggle feature_flags" ON feature_flags FOR UPDATE USING (is_super_admin(auth.uid()));

INSERT INTO feature_flags (key, label, description, enabled) VALUES
  ('communities',   'Communities',     'Community creation, feed, and interaction',                    TRUE),
  ('messaging',     'Messaging',       'Direct messages, group chats, and channels',                   TRUE),
  ('marketplace',   'Marketplace',     'Buy, sell, and list items on campus',                          FALSE),
  ('academic',      'Academic Hub',    'Courses, notes, GPA, study planner, assignments, exams',         FALSE),
  ('events',        'Events & Ticketing', 'Event discovery, RSVP, ticketing, check-in, and gallery',  FALSE),
  ('opportunities', 'Opportunities',   'Job listings, internships, and campus opportunities',           FALSE),
  ('referrals',     'Referrals',       'Invite friends and earn rewards',                              TRUE),
  ('ambassadors',   'Ambassadors',     'Campus ambassador program',                                    TRUE),
  ('feedback',      'Feedback',        'In-app feedback submission and admin queue',                    TRUE),
  ('beta_access',   'Beta Access',     'Waitlist, invite codes, and beta-tester management',            TRUE),
  ('analytics',     'Usage Analytics', 'DAU/WAU/MAU tracking, retention, and feature-adoption metrics', TRUE),
  ('announcements', 'Announcements',   'Admin broadcast and system announcements',                      TRUE),
  ('support_center', 'Support Center', 'FAQ, help articles, support tickets, and abuse reporting',     TRUE),
  ('reputation',    'Reputation System', 'Reputation scores, skills, and badges',                      FALSE),
  ('global_search', 'Global Search',   'Cross-module full-text search',                                TRUE)
ON CONFLICT (key) DO NOTHING;

-- ============================================================
-- PART 3: LAUNCH INFRASTRUCTURE
-- ============================================================

-- Waitlist
CREATE TABLE IF NOT EXISTS waitlist (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT NOT NULL,
  full_name       TEXT,
  university_id   UUID REFERENCES universities(id) ON DELETE SET NULL,
  university_name TEXT,
  programme       TEXT,
  level           TEXT,
  referred_by     TEXT,
  status          TEXT NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting','invited','joined','rejected')),
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  invited_at      TIMESTAMPTZ,
  UNIQUE (email)
);
CREATE INDEX IF NOT EXISTS idx_waitlist_status ON waitlist(status, created_at);

-- Invite codes
CREATE TABLE IF NOT EXISTS invite_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code        TEXT NOT NULL UNIQUE,
  created_by  UUID REFERENCES profiles(id) ON DELETE SET NULL,
  type        TEXT NOT NULL DEFAULT 'beta' CHECK (type IN ('beta','referral','ambassador','general')),
  max_uses    INTEGER NOT NULL DEFAULT 1,
  use_count   INTEGER NOT NULL DEFAULT 0,
  expires_at  TIMESTAMPTZ,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_invite_codes_creator ON invite_codes(created_by);

CREATE TABLE IF NOT EXISTS invite_redemptions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code_id     UUID REFERENCES invite_codes(id) ON DELETE CASCADE,
  invite_code TEXT NOT NULL,
  redeemed_by UUID REFERENCES profiles(id) ON DELETE CASCADE,
  inviter_id  UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (code_id, redeemed_by)
);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON invite_redemptions(redeemed_by);
CREATE INDEX IF NOT EXISTS idx_redemptions_inviter ON invite_redemptions(inviter_id);

CREATE TABLE IF NOT EXISTS beta_testers (
  user_id        UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  invited_by     UUID REFERENCES profiles(id) ON DELETE SET NULL,
  cohort         TEXT NOT NULL DEFAULT 'beta-1',
  status         TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','removed')),
  feedback_count INTEGER NOT NULL DEFAULT 0,
  joined_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_active_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_beta_status ON beta_testers(status);

-- Feedback
CREATE TABLE IF NOT EXISTS feedback_items (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID REFERENCES profiles(id) ON DELETE SET NULL,
  type           TEXT NOT NULL DEFAULT 'bug' CHECK (type IN ('bug','feature','problem')),
  title          TEXT NOT NULL,
  description    TEXT NOT NULL,
  screenshot_url TEXT,
  device_info    TEXT,
  app_version    TEXT,
  platform       TEXT,
  status         TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','fixed','closed')),
  priority       TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('low','normal','high','critical')),
  vote_count     INTEGER NOT NULL DEFAULT 0,
  admin_response TEXT,
  resolved_by    UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback_items(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_user   ON feedback_items(user_id);

CREATE TABLE IF NOT EXISTS feedback_votes (
  feedback_id UUID NOT NULL REFERENCES feedback_items(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (feedback_id, user_id)
);

-- System announcements
CREATE TABLE IF NOT EXISTS system_announcements (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL,
  body          TEXT NOT NULL,
  type          TEXT NOT NULL DEFAULT 'general' CHECK (type IN ('feature','maintenance','update','general')),
  severity      TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info','warning','critical')),
  audience      TEXT NOT NULL DEFAULT 'all' CHECK (audience IN ('all','university','beta')),
  university_id UUID REFERENCES universities(id) ON DELETE CASCADE,
  action_label  TEXT,
  action_url    TEXT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  starts_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at       TIMESTAMPTZ,
  created_by    UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sysann_active ON system_announcements(is_active, starts_at DESC);

CREATE TABLE IF NOT EXISTS announcement_dismissals (
  announcement_id UUID NOT NULL REFERENCES system_announcements(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  dismissed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);

-- Referrals
CREATE TABLE IF NOT EXISTS referrals (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  referred_email   TEXT,
  referred_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  invite_code      TEXT,
  channel          TEXT,
  status           TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent','accepted','active')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at      TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id, status);

-- Analytics
CREATE TABLE IF NOT EXISTS analytics_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES profiles(id) ON DELETE SET NULL,
  university_id UUID REFERENCES universities(id) ON DELETE SET NULL,
  event_name    TEXT NOT NULL,
  feature       TEXT,
  properties    JSONB NOT NULL DEFAULT '{}'::jsonb,
  session_id    UUID,
  app_version   TEXT,
  platform      TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_events_time    ON analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_events_user    ON analytics_events(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_events_feature ON analytics_events(feature, created_at);
CREATE INDEX IF NOT EXISTS idx_events_name    ON analytics_events(event_name, created_at);

CREATE TABLE IF NOT EXISTS user_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES profiles(id) ON DELETE SET NULL,
  started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at        TIMESTAMPTZ,
  duration_seconds INTEGER,
  app_version     TEXT,
  platform        TEXT
);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id, started_at);
CREATE INDEX IF NOT EXISTS idx_sessions_time ON user_sessions(started_at);

-- Ambassadors
CREATE TABLE IF NOT EXISTS ambassadors (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  university_id    UUID REFERENCES universities(id) ON DELETE SET NULL,
  university_name  TEXT,
  faculty          TEXT,
  department       TEXT,
  bio              TEXT,
  contact          TEXT,
  status           TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','pending')),
  referral_count   INTEGER NOT NULL DEFAULT 0,
  events_organized INTEGER NOT NULL DEFAULT 0,
  joined_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ambassadors_status ON ambassadors(status);

CREATE TABLE IF NOT EXISTS ambassador_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ambassador_id UUID NOT NULL REFERENCES ambassadors(id) ON DELETE CASCADE,
  title         TEXT NOT NULL,
  description   TEXT,
  event_date    DATE,
  attendance    INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ambevents_amb ON ambassador_events(ambassador_id);

-- Support center
CREATE TABLE IF NOT EXISTS faq_items (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question     TEXT NOT NULL,
  answer       TEXT NOT NULL,
  category     TEXT NOT NULL DEFAULT 'general',
  order_index  INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS help_articles (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug          TEXT UNIQUE,
  category      TEXT NOT NULL DEFAULT 'general',
  title         TEXT NOT NULL,
  body          TEXT NOT NULL,
  is_published  BOOLEAN NOT NULL DEFAULT TRUE,
  view_count    INTEGER NOT NULL DEFAULT 0,
  helpful_count INTEGER NOT NULL DEFAULT 0,
  order_index   INTEGER NOT NULL DEFAULT 0,
  created_by    UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_help_published ON help_articles(is_published, category, order_index);

CREATE TABLE IF NOT EXISTS support_tickets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES profiles(id) ON DELETE SET NULL,
  subject       TEXT NOT NULL,
  message       TEXT NOT NULL,
  category      TEXT NOT NULL DEFAULT 'general',
  status        TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','in_progress','resolved','closed')),
  admin_response TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON support_tickets(status, created_at DESC);

CREATE TABLE IF NOT EXISTS abuse_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL,
  target_id   TEXT,
  reason      TEXT NOT NULL,
  details     TEXT,
  status      TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','reviewing','actioned','dismissed')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_abuse_status ON abuse_reports(status, created_at DESC);

-- System health
CREATE TABLE IF NOT EXISTS system_health_metrics (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric      TEXT NOT NULL,
  value       NUMERIC NOT NULL DEFAULT 0,
  meta        JSONB NOT NULL DEFAULT '{}'::jsonb,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_health_metric ON system_health_metrics(metric, recorded_at DESC);

CREATE TABLE IF NOT EXISTS error_logs (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES profiles(id) ON DELETE SET NULL,
  error_type TEXT NOT NULL DEFAULT 'runtime',
  source     TEXT,
  message    TEXT NOT NULL,
  stack      TEXT,
  severity   TEXT NOT NULL DEFAULT 'error' CHECK (severity IN ('warning','error','critical')),
  app_version TEXT,
  platform   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_errors_time ON error_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_errors_sev  ON error_logs(severity, created_at DESC);

-- App versions
CREATE TABLE IF NOT EXISTS app_versions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  platform          TEXT NOT NULL DEFAULT 'android' CHECK (platform IN ('android','ios','web')),
  version           TEXT NOT NULL,
  build_number      INTEGER NOT NULL DEFAULT 1,
  min_supported_build INTEGER NOT NULL DEFAULT 1,
  is_mandatory      BOOLEAN NOT NULL DEFAULT FALSE,
  release_notes     TEXT,
  download_url      TEXT,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  released_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_appver_platform ON app_versions(platform, is_active, build_number DESC);

-- ============================================================
-- PART 4: NOTIFICATION SYSTEM (Enhanced)
-- ============================================================

-- Upgrade notifications table
ALTER TABLE IF EXISTS notifications
  ADD COLUMN IF NOT EXISTS data JSONB DEFAULT '{}'::jsonb;

ALTER TABLE IF EXISTS notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE IF EXISTS notifications
  ADD CONSTRAINT notifications_type_check
  CHECK (type IN ('new_message','community_announcement','community_join_request','community_approval',
    'marketplace_inquiry','marketplace_sale','event_registration','event_reminder',
    'event_checkin_confirmation','opportunity_deadline_reminder','scholarship_alert',
    'academic_resource_upload','verification_approved','role_assigned','admin_broadcast'));

-- Notification preferences
CREATE TABLE IF NOT EXISTS notification_preferences (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  messages          BOOLEAN NOT NULL DEFAULT TRUE,
  communities       BOOLEAN NOT NULL DEFAULT TRUE,
  marketplace       BOOLEAN NOT NULL DEFAULT TRUE,
  events            BOOLEAN NOT NULL DEFAULT TRUE,
  opportunities     BOOLEAN NOT NULL DEFAULT TRUE,
  academic_resources BOOLEAN NOT NULL DEFAULT TRUE,
  admin_notices     BOOLEAN NOT NULL DEFAULT TRUE,
  push_enabled      BOOLEAN NOT NULL DEFAULT TRUE,
  email_enabled     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Notification logs (analytics)
CREATE TABLE IF NOT EXISTS notification_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id UUID REFERENCES notifications(id) ON DELETE SET NULL,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type            TEXT NOT NULL,
  channel         TEXT NOT NULL CHECK (channel IN ('in_app', 'push', 'email')),
  status          TEXT NOT NULL CHECK (status IN ('sent', 'delivered', 'opened', 'clicked', 'failed')),
  device_token    TEXT,
  error_message   TEXT,
  opened_at       TIMESTAMPTZ,
  clicked_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_prefs_user ON notification_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_logs_user ON notification_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_logs_type ON notification_logs(type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_logs_status ON notification_logs(status);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "preferences_select_own" ON notification_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "preferences_insert_own" ON notification_preferences FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "preferences_update_own" ON notification_preferences FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "logs_select_own" ON notification_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "logs_insert_system" ON notification_logs FOR INSERT WITH CHECK (TRUE);

-- Rate limiting
CREATE OR REPLACE FUNCTION check_notification_rate(p_user_id UUID)
RETURNS BOOLEAN LANGUAGE plpgsql STABLE AS $$
BEGIN
  RETURN (SELECT COUNT(*) < 50 FROM notifications WHERE user_id = p_user_id AND created_at > NOW() - INTERVAL '1 hour');
END;
$$;

-- ============================================================
-- PART 5: INFRASTRUCTURE TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION bump_invite_use()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE invite_codes SET use_count = use_count + 1 WHERE id = NEW.code_id;
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS trg_bump_invite_use ON invite_redemptions;
CREATE TRIGGER trg_bump_invite_use AFTER INSERT ON invite_redemptions FOR EACH ROW EXECUTE FUNCTION bump_invite_use();

CREATE OR REPLACE FUNCTION sync_feedback_votes()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE fid UUID;
BEGIN
  fid := COALESCE(NEW.feedback_id, OLD.feedback_id);
  UPDATE feedback_items SET vote_count = (SELECT COUNT(*) FROM feedback_votes WHERE feedback_id = fid) WHERE id = fid;
  RETURN NULL;
END; $$;
DROP TRIGGER IF EXISTS trg_feedback_votes ON feedback_votes;
CREATE TRIGGER trg_feedback_votes AFTER INSERT OR DELETE ON feedback_votes FOR EACH ROW EXECUTE FUNCTION sync_feedback_votes();

-- ============================================================
-- PART 6: ANALYTICS RPCs
-- ============================================================

CREATE OR REPLACE FUNCTION is_campus_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'));
$$;

CREATE OR REPLACE FUNCTION analytics_overview()
RETURNS JSONB LANGUAGE sql STABLE AS $$
  SELECT jsonb_build_object(
    'dau', (SELECT COUNT(DISTINCT user_id) FROM analytics_events WHERE created_at >= NOW() - INTERVAL '1 day' AND user_id IS NOT NULL),
    'wau', (SELECT COUNT(DISTINCT user_id) FROM analytics_events WHERE created_at >= NOW() - INTERVAL '7 days' AND user_id IS NOT NULL),
    'mau', (SELECT COUNT(DISTINCT user_id) FROM analytics_events WHERE created_at >= NOW() - INTERVAL '30 days' AND user_id IS NOT NULL),
    'total_users', (SELECT COUNT(*) FROM profiles)
  );
$$;

CREATE OR REPLACE FUNCTION dau_series(days INTEGER DEFAULT 14)
RETURNS TABLE(day DATE, active INTEGER) LANGUAGE sql STABLE AS $$
  SELECT d::date AS day, (SELECT COUNT(DISTINCT user_id)::int FROM analytics_events e WHERE e.user_id IS NOT NULL AND e.created_at >= d AND e.created_at < d + INTERVAL '1 day') AS active
  FROM generate_series((NOW()::date - (days - 1)), NOW()::date, INTERVAL '1 day') AS d
  ORDER BY day;
$$;

CREATE OR REPLACE FUNCTION feature_adoption(days INTEGER DEFAULT 30)
RETURNS TABLE(feature TEXT, users INTEGER, events INTEGER) LANGUAGE sql STABLE AS $$
  SELECT feature, COUNT(DISTINCT user_id)::int AS users, COUNT(*)::int AS events
  FROM analytics_events
  WHERE feature IS NOT NULL AND created_at >= NOW() - (days || ' days')::INTERVAL
  GROUP BY feature ORDER BY users DESC;
$$;

COMMIT;
