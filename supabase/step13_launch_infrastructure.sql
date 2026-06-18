-- ============================================================
-- STEP 13 — UNIFY Launch Infrastructure & Growth System
-- ============================================================
-- The operational layer required to launch, monitor, grow and support
-- UNIFY at scale. NOT student-facing social features — this is the
-- growth + ops backbone:
--   Beta access, feedback, in-app announcements, referrals, usage
--   analytics, feature-adoption tracking, campus ambassadors, support
--   center, system health, app-update gating, launch readiness.
--
-- Idempotent: safe to re-run (IF NOT EXISTS / CREATE OR REPLACE /
-- DROP POLICY IF EXISTS).
-- ============================================================

-- Admin predicate (re-declared defensively so this file runs standalone).
CREATE OR REPLACE FUNCTION is_campus_admin()
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid()
                  AND role IN ('admin','superadmin'));
$$ LANGUAGE sql STABLE;

-- ============================================================
-- 1. BETA ACCESS SYSTEM
-- ============================================================

-- Waitlist — prospective users queueing for access.
CREATE TABLE IF NOT EXISTS waitlist (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  email         TEXT        NOT NULL,
  full_name     TEXT,
  university_id UUID                 REFERENCES universities(id) ON DELETE SET NULL,
  university_name TEXT,
  programme     TEXT,
  level         TEXT,
  referred_by   TEXT,                                 -- invite/referral code used
  status        TEXT        NOT NULL DEFAULT 'waiting'
                  CHECK (status IN ('waiting','invited','joined','rejected')),
  position      SERIAL,
  note          TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  invited_at    TIMESTAMPTZ,
  UNIQUE (email)
);
CREATE INDEX IF NOT EXISTS idx_waitlist_status ON waitlist (status, created_at);

-- Invite codes — beta / referral / ambassador codes.
CREATE TABLE IF NOT EXISTS invite_codes (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  code          TEXT        NOT NULL UNIQUE,
  created_by    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  type          TEXT        NOT NULL DEFAULT 'beta'
                  CHECK (type IN ('beta','referral','ambassador','general')),
  max_uses      INTEGER     NOT NULL DEFAULT 1,       -- 0 = unlimited
  use_count     INTEGER     NOT NULL DEFAULT 0,
  expires_at    TIMESTAMPTZ,
  is_active     BOOLEAN     NOT NULL DEFAULT true,
  note          TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_invite_codes_creator ON invite_codes (created_by);

-- Who redeemed which code (who invited whom).
CREATE TABLE IF NOT EXISTS invite_redemptions (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  code_id       UUID                 REFERENCES invite_codes(id) ON DELETE CASCADE,
  invite_code   TEXT        NOT NULL,
  redeemed_by   UUID                 REFERENCES profiles(id) ON DELETE CASCADE,
  inviter_id    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (code_id, redeemed_by)
);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON invite_redemptions (redeemed_by);
CREATE INDEX IF NOT EXISTS idx_redemptions_inviter ON invite_redemptions (inviter_id);

-- Beta testers — the active early-access cohort.
CREATE TABLE IF NOT EXISTS beta_testers (
  user_id        UUID        PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  invited_by     UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  cohort         TEXT        NOT NULL DEFAULT 'beta-1',
  status         TEXT        NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active','inactive','removed')),
  feedback_count INTEGER     NOT NULL DEFAULT 0,
  joined_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_active_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_beta_status ON beta_testers (status);

-- ============================================================
-- 2. FEEDBACK CENTER
-- ============================================================

CREATE TABLE IF NOT EXISTS feedback_items (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  type          TEXT        NOT NULL DEFAULT 'bug'
                  CHECK (type IN ('bug','feature','problem')),
  title         TEXT        NOT NULL,
  description   TEXT        NOT NULL,
  screenshot_url TEXT,
  device_info   TEXT,                                 -- model / os summary
  app_version   TEXT,
  platform      TEXT,                                 -- android / ios / web
  status        TEXT        NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open','in_progress','fixed','closed')),
  priority      TEXT        NOT NULL DEFAULT 'normal'
                  CHECK (priority IN ('low','normal','high','critical')),
  vote_count    INTEGER     NOT NULL DEFAULT 0,
  admin_response TEXT,
  resolved_by   UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback_items (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_user   ON feedback_items (user_id);

CREATE TABLE IF NOT EXISTS feedback_votes (
  feedback_id   UUID        NOT NULL REFERENCES feedback_items(id) ON DELETE CASCADE,
  user_id       UUID        NOT NULL REFERENCES profiles(id)       ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (feedback_id, user_id)
);

-- ============================================================
-- 3. IN-APP ANNOUNCEMENTS (system broadcasts)
-- ============================================================

CREATE TABLE IF NOT EXISTS system_announcements (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT        NOT NULL,
  body          TEXT        NOT NULL,
  type          TEXT        NOT NULL DEFAULT 'general'
                  CHECK (type IN ('feature','maintenance','update','general')),
  severity      TEXT        NOT NULL DEFAULT 'info'
                  CHECK (severity IN ('info','warning','critical')),
  audience      TEXT        NOT NULL DEFAULT 'all'
                  CHECK (audience IN ('all','university','beta')),
  university_id UUID                 REFERENCES universities(id) ON DELETE CASCADE,
  action_label  TEXT,
  action_url    TEXT,
  is_active     BOOLEAN     NOT NULL DEFAULT true,
  starts_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  ends_at       TIMESTAMPTZ,
  created_by    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_sysann_active ON system_announcements (is_active, starts_at DESC);

CREATE TABLE IF NOT EXISTS announcement_dismissals (
  announcement_id UUID      NOT NULL REFERENCES system_announcements(id) ON DELETE CASCADE,
  user_id         UUID      NOT NULL REFERENCES profiles(id)             ON DELETE CASCADE,
  dismissed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (announcement_id, user_id)
);

-- ============================================================
-- 4. REFERRAL SYSTEM
-- ============================================================

CREATE TABLE IF NOT EXISTS referrals (
  id              UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id     UUID      NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  referred_email  TEXT,
  referred_user_id UUID              REFERENCES profiles(id) ON DELETE SET NULL,
  invite_code     TEXT,
  channel         TEXT,                               -- whatsapp / link / sms ...
  status          TEXT      NOT NULL DEFAULT 'sent'
                    CHECK (status IN ('sent','accepted','active')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at     TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals (referrer_id, status);

-- ============================================================
-- 5. USAGE ANALYTICS  (events + sessions)
-- ============================================================

CREATE TABLE IF NOT EXISTS analytics_events (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  university_id UUID                 REFERENCES universities(id) ON DELETE SET NULL,
  event_name    TEXT        NOT NULL,                 -- e.g. screen_view, tap_create
  feature       TEXT,                                 -- communities / messaging / marketplace / academic / events / opportunities
  properties    JSONB       NOT NULL DEFAULT '{}'::jsonb,
  session_id    UUID,
  app_version   TEXT,
  platform      TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_events_time    ON analytics_events (created_at);
CREATE INDEX IF NOT EXISTS idx_events_user    ON analytics_events (user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_events_feature ON analytics_events (feature, created_at);
CREATE INDEX IF NOT EXISTS idx_events_name    ON analytics_events (event_name, created_at);

CREATE TABLE IF NOT EXISTS user_sessions (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  started_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at      TIMESTAMPTZ,
  duration_seconds INTEGER,
  app_version   TEXT,
  platform      TEXT
);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions (user_id, started_at);
CREATE INDEX IF NOT EXISTS idx_sessions_time ON user_sessions (started_at);

-- ============================================================
-- 6. CAMPUS AMBASSADOR PROGRAM
-- ============================================================

CREATE TABLE IF NOT EXISTS ambassadors (
  id              UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID      NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  university_id   UUID               REFERENCES universities(id) ON DELETE SET NULL,
  university_name TEXT,
  faculty         TEXT,
  department      TEXT,
  bio             TEXT,
  contact         TEXT,
  status          TEXT      NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','inactive','pending')),
  referral_count  INTEGER   NOT NULL DEFAULT 0,
  events_organized INTEGER  NOT NULL DEFAULT 0,
  joined_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ambassadors_status ON ambassadors (status);

CREATE TABLE IF NOT EXISTS ambassador_events (
  id              UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  ambassador_id   UUID      NOT NULL REFERENCES ambassadors(id) ON DELETE CASCADE,
  title           TEXT      NOT NULL,
  description     TEXT,
  event_date      DATE,
  attendance      INTEGER   NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ambevents_amb ON ambassador_events (ambassador_id);

-- ============================================================
-- 7. SUPPORT CENTER
-- ============================================================

CREATE TABLE IF NOT EXISTS faq_items (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  question      TEXT        NOT NULL,
  answer        TEXT        NOT NULL,
  category      TEXT        NOT NULL DEFAULT 'general',
  order_index   INTEGER     NOT NULL DEFAULT 0,
  is_published  BOOLEAN     NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS help_articles (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug          TEXT        UNIQUE,
  category      TEXT        NOT NULL DEFAULT 'general',
  title         TEXT        NOT NULL,
  body          TEXT        NOT NULL,
  is_published  BOOLEAN     NOT NULL DEFAULT true,
  view_count    INTEGER     NOT NULL DEFAULT 0,
  helpful_count INTEGER     NOT NULL DEFAULT 0,
  order_index   INTEGER     NOT NULL DEFAULT 0,
  created_by    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_help_published ON help_articles (is_published, category, order_index);

CREATE TABLE IF NOT EXISTS support_tickets (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  subject       TEXT        NOT NULL,
  message       TEXT        NOT NULL,
  category      TEXT        NOT NULL DEFAULT 'general',
  status        TEXT        NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open','in_progress','resolved','closed')),
  admin_response TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON support_tickets (status, created_at DESC);

CREATE TABLE IF NOT EXISTS abuse_reports (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id   UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  target_type   TEXT        NOT NULL,                 -- user / post / listing / message / community ...
  target_id     TEXT,
  reason        TEXT        NOT NULL,
  details       TEXT,
  status        TEXT        NOT NULL DEFAULT 'open'
                  CHECK (status IN ('open','reviewing','actioned','dismissed')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_abuse_status ON abuse_reports (status, created_at DESC);

-- ============================================================
-- 8. SYSTEM HEALTH
-- ============================================================

-- Point-in-time metrics recorded by edge functions / cron.
CREATE TABLE IF NOT EXISTS system_health_metrics (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  metric        TEXT        NOT NULL,                 -- api_errors / db_latency_ms / failed_notifications / storage_bytes / active_users
  value         NUMERIC     NOT NULL DEFAULT 0,
  meta          JSONB       NOT NULL DEFAULT '{}'::jsonb,
  recorded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_health_metric ON system_health_metrics (metric, recorded_at DESC);

-- Client + server error stream.
CREATE TABLE IF NOT EXISTS error_logs (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  error_type    TEXT        NOT NULL DEFAULT 'runtime',
  source        TEXT,                                 -- api / client / notification / db
  message       TEXT        NOT NULL,
  stack         TEXT,
  severity      TEXT        NOT NULL DEFAULT 'error'
                  CHECK (severity IN ('warning','error','critical')),
  app_version   TEXT,
  platform      TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_errors_time ON error_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_errors_sev  ON error_logs (severity, created_at DESC);

-- ============================================================
-- 9. APP UPDATE SYSTEM
-- ============================================================

CREATE TABLE IF NOT EXISTS app_versions (
  id              UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  platform        TEXT      NOT NULL DEFAULT 'android'
                    CHECK (platform IN ('android','ios','web')),
  version         TEXT      NOT NULL,                 -- 1.2.0
  build_number    INTEGER   NOT NULL DEFAULT 1,
  min_supported_build INTEGER NOT NULL DEFAULT 1,     -- below this => forced update
  is_mandatory    BOOLEAN   NOT NULL DEFAULT false,
  release_notes   TEXT,
  download_url    TEXT,
  is_active       BOOLEAN   NOT NULL DEFAULT true,
  released_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_appver_platform ON app_versions (platform, is_active, build_number DESC);

-- ============================================================
-- TRIGGERS — counters & timestamps
-- ============================================================

-- Invite code use_count + redemption link.
CREATE OR REPLACE FUNCTION bump_invite_use()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE invite_codes SET use_count = use_count + 1 WHERE id = NEW.code_id;
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS trg_bump_invite_use ON invite_redemptions;
CREATE TRIGGER trg_bump_invite_use
  AFTER INSERT ON invite_redemptions
  FOR EACH ROW EXECUTE FUNCTION bump_invite_use();

-- Feedback vote count.
CREATE OR REPLACE FUNCTION sync_feedback_votes()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE fid UUID;
BEGIN
  fid := COALESCE(NEW.feedback_id, OLD.feedback_id);
  UPDATE feedback_items SET vote_count =
    (SELECT count(*) FROM feedback_votes WHERE feedback_id = fid)
   WHERE id = fid;
  RETURN NULL;
END; $$;
DROP TRIGGER IF EXISTS trg_feedback_votes ON feedback_votes;
CREATE TRIGGER trg_feedback_votes
  AFTER INSERT OR DELETE ON feedback_votes
  FOR EACH ROW EXECUTE FUNCTION sync_feedback_votes();

-- Beta tester feedback_count.
CREATE OR REPLACE FUNCTION bump_beta_feedback()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.user_id IS NOT NULL THEN
    UPDATE beta_testers SET feedback_count = feedback_count + 1,
                            last_active_at = now()
     WHERE user_id = NEW.user_id;
  END IF;
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS trg_beta_feedback ON feedback_items;
CREATE TRIGGER trg_beta_feedback
  AFTER INSERT ON feedback_items
  FOR EACH ROW EXECUTE FUNCTION bump_beta_feedback();

-- Referral count on ambassadors + referrer when a referral becomes active.
CREATE OR REPLACE FUNCTION sync_referral_counts()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ambassadors SET referral_count =
    (SELECT count(*) FROM referrals
      WHERE referrer_id = NEW.referrer_id AND status = 'active')
   WHERE user_id = NEW.referrer_id;
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS trg_referral_counts ON referrals;
CREATE TRIGGER trg_referral_counts
  AFTER INSERT OR UPDATE ON referrals
  FOR EACH ROW EXECUTE FUNCTION sync_referral_counts();

-- Ambassador events_organized.
CREATE OR REPLACE FUNCTION sync_ambassador_events()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE aid UUID;
BEGIN
  aid := COALESCE(NEW.ambassador_id, OLD.ambassador_id);
  UPDATE ambassadors SET events_organized =
    (SELECT count(*) FROM ambassador_events WHERE ambassador_id = aid)
   WHERE id = aid;
  RETURN NULL;
END; $$;
DROP TRIGGER IF EXISTS trg_ambassador_events ON ambassador_events;
CREATE TRIGGER trg_ambassador_events
  AFTER INSERT OR DELETE ON ambassador_events
  FOR EACH ROW EXECUTE FUNCTION sync_ambassador_events();

-- generic updated_at
CREATE OR REPLACE FUNCTION touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

DROP TRIGGER IF EXISTS trg_feedback_touch ON feedback_items;
CREATE TRIGGER trg_feedback_touch BEFORE UPDATE ON feedback_items
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
DROP TRIGGER IF EXISTS trg_ticket_touch ON support_tickets;
CREATE TRIGGER trg_ticket_touch BEFORE UPDATE ON support_tickets
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
DROP TRIGGER IF EXISTS trg_help_touch ON help_articles;
CREATE TRIGGER trg_help_touch BEFORE UPDATE ON help_articles
  FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- ============================================================
-- ANALYTICS RPCs  (admin dashboards)
-- ============================================================

-- DAU / WAU / MAU + session + growth overview.
CREATE OR REPLACE FUNCTION analytics_overview()
RETURNS JSONB LANGUAGE sql STABLE AS $$
  SELECT jsonb_build_object(
    'dau', (SELECT count(DISTINCT user_id) FROM analytics_events
             WHERE created_at >= now() - interval '1 day' AND user_id IS NOT NULL),
    'wau', (SELECT count(DISTINCT user_id) FROM analytics_events
             WHERE created_at >= now() - interval '7 days' AND user_id IS NOT NULL),
    'mau', (SELECT count(DISTINCT user_id) FROM analytics_events
             WHERE created_at >= now() - interval '30 days' AND user_id IS NOT NULL),
    'avg_session_seconds', (SELECT COALESCE(round(avg(duration_seconds)),0)
             FROM user_sessions WHERE started_at >= now() - interval '30 days'
               AND duration_seconds IS NOT NULL),
    'sessions_7d', (SELECT count(*) FROM user_sessions
             WHERE started_at >= now() - interval '7 days'),
    'new_users_7d', (SELECT count(*) FROM profiles
             WHERE created_at >= now() - interval '7 days'),
    'new_users_30d', (SELECT count(*) FROM profiles
             WHERE created_at >= now() - interval '30 days'),
    'total_users', (SELECT count(*) FROM profiles)
  );
$$;

-- Daily active users series for charting.
CREATE OR REPLACE FUNCTION dau_series(days INTEGER DEFAULT 14)
RETURNS TABLE(day DATE, active INTEGER) LANGUAGE sql STABLE AS $$
  SELECT d::date AS day,
         (SELECT count(DISTINCT user_id)::int FROM analytics_events e
           WHERE e.user_id IS NOT NULL
             AND e.created_at >= d AND e.created_at < d + interval '1 day') AS active
  FROM generate_series(
         (now()::date - (days - 1)), now()::date, interval '1 day') AS d
  ORDER BY day;
$$;

-- Feature adoption — distinct users + events per feature over a window.
CREATE OR REPLACE FUNCTION feature_adoption(days INTEGER DEFAULT 30)
RETURNS TABLE(feature TEXT, users INTEGER, events INTEGER) LANGUAGE sql STABLE AS $$
  SELECT feature,
         count(DISTINCT user_id)::int AS users,
         count(*)::int AS events
  FROM analytics_events
  WHERE feature IS NOT NULL
    AND created_at >= now() - (days || ' days')::interval
  GROUP BY feature
  ORDER BY users DESC;
$$;

-- Simple next-day retention for users who joined in the last N days.
CREATE OR REPLACE FUNCTION retention_summary()
RETURNS JSONB LANGUAGE sql STABLE AS $$
  WITH cohort AS (
    SELECT id, created_at::date AS join_day FROM profiles
     WHERE created_at >= now() - interval '30 days'
  )
  SELECT jsonb_build_object(
    'cohort_size', (SELECT count(*) FROM cohort),
    'returned_d1', (SELECT count(DISTINCT c.id) FROM cohort c
        JOIN analytics_events e ON e.user_id = c.id
        WHERE e.created_at::date = c.join_day + 1),
    'returned_d7', (SELECT count(DISTINCT c.id) FROM cohort c
        JOIN analytics_events e ON e.user_id = c.id
        WHERE e.created_at::date BETWEEN c.join_day + 1 AND c.join_day + 7)
  );
$$;

-- Single launch-readiness snapshot for the ops dashboard.
CREATE OR REPLACE FUNCTION launch_readiness()
RETURNS JSONB LANGUAGE sql STABLE AS $$
  SELECT jsonb_build_object(
    'verification_pending',
      (SELECT count(*) FROM verification_requests WHERE status = 'pending'),
    'total_users',        (SELECT count(*) FROM profiles),
    'new_users_7d',       (SELECT count(*) FROM profiles WHERE created_at >= now() - interval '7 days'),
    'verified_leaders',   (SELECT count(*) FROM profiles WHERE is_verified_leader = true),
    'communities',        (SELECT count(*) FROM communities WHERE is_active = true),
    'communities_7d',     (SELECT count(*) FROM communities WHERE created_at >= now() - interval '7 days'),
    'events_upcoming',    (SELECT count(*) FROM community_events
                            WHERE event_date >= now()::date AND is_cancelled = false),
    'listings_active',    (SELECT count(*) FROM marketplace_listings WHERE status = 'active'),
    'beta_testers',       (SELECT count(*) FROM beta_testers WHERE status = 'active'),
    'waitlist',           (SELECT count(*) FROM waitlist WHERE status = 'waiting'),
    'open_feedback',      (SELECT count(*) FROM feedback_items WHERE status IN ('open','in_progress')),
    'open_abuse',         (SELECT count(*) FROM abuse_reports WHERE status IN ('open','reviewing')),
    'critical_errors_24h',(SELECT count(*) FROM error_logs
                            WHERE severity = 'critical' AND created_at >= now() - interval '1 day'),
    'dau',                (SELECT count(DISTINCT user_id) FROM analytics_events
                            WHERE created_at >= now() - interval '1 day' AND user_id IS NOT NULL)
  );
$$;

-- System-health snapshot (latest recorded value per metric + live counts).
CREATE OR REPLACE FUNCTION system_health()
RETURNS JSONB LANGUAGE sql STABLE AS $$
  SELECT jsonb_build_object(
    'api_errors_24h', (SELECT count(*) FROM error_logs
        WHERE source = 'api' AND created_at >= now() - interval '1 day'),
    'errors_24h', (SELECT count(*) FROM error_logs
        WHERE created_at >= now() - interval '1 day'),
    'critical_24h', (SELECT count(*) FROM error_logs
        WHERE severity = 'critical' AND created_at >= now() - interval '1 day'),
    'failed_notifications_24h', (SELECT count(*) FROM error_logs
        WHERE source = 'notification' AND created_at >= now() - interval '1 day'),
    'active_users_now', (SELECT count(DISTINCT user_id) FROM analytics_events
        WHERE created_at >= now() - interval '15 minutes' AND user_id IS NOT NULL),
    'latest_storage_bytes', (SELECT value FROM system_health_metrics
        WHERE metric = 'storage_bytes' ORDER BY recorded_at DESC LIMIT 1),
    'latest_db_latency_ms', (SELECT value FROM system_health_metrics
        WHERE metric = 'db_latency_ms' ORDER BY recorded_at DESC LIMIT 1)
  );
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE waitlist                ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_codes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_redemptions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE beta_testers            ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_items          ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_votes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_announcements    ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_dismissals ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals               ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events        ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE ambassadors             ENABLE ROW LEVEL SECURITY;
ALTER TABLE ambassador_events       ENABLE ROW LEVEL SECURITY;
ALTER TABLE faq_items               ENABLE ROW LEVEL SECURITY;
ALTER TABLE help_articles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets         ENABLE ROW LEVEL SECURITY;
ALTER TABLE abuse_reports           ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_health_metrics   ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs              ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_versions            ENABLE ROW LEVEL SECURITY;

-- Waitlist: anyone may join (public sign-up); admins manage.
DROP POLICY IF EXISTS waitlist_insert ON waitlist;
CREATE POLICY waitlist_insert ON waitlist FOR INSERT TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS waitlist_admin ON waitlist;
CREATE POLICY waitlist_admin ON waitlist FOR SELECT TO authenticated USING (is_campus_admin());
DROP POLICY IF EXISTS waitlist_update ON waitlist;
CREATE POLICY waitlist_update ON waitlist FOR UPDATE TO authenticated USING (is_campus_admin());

-- Invite codes: readable by authenticated (to validate); writable by admins.
DROP POLICY IF EXISTS codes_select ON invite_codes;
CREATE POLICY codes_select ON invite_codes FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS codes_admin ON invite_codes;
CREATE POLICY codes_admin ON invite_codes FOR ALL TO authenticated
  USING (is_campus_admin() OR created_by = auth.uid())
  WITH CHECK (is_campus_admin() OR created_by = auth.uid());

-- Redemptions: a user records their own; admins read all.
DROP POLICY IF EXISTS redeem_insert ON invite_redemptions;
CREATE POLICY redeem_insert ON invite_redemptions FOR INSERT TO authenticated
  WITH CHECK (redeemed_by = auth.uid());
DROP POLICY IF EXISTS redeem_select ON invite_redemptions;
CREATE POLICY redeem_select ON invite_redemptions FOR SELECT TO authenticated
  USING (is_campus_admin() OR redeemed_by = auth.uid() OR inviter_id = auth.uid());

-- Beta testers: self-read; admin manage.
DROP POLICY IF EXISTS beta_select ON beta_testers;
CREATE POLICY beta_select ON beta_testers FOR SELECT TO authenticated
  USING (is_campus_admin() OR user_id = auth.uid());
DROP POLICY IF EXISTS beta_admin ON beta_testers;
CREATE POLICY beta_admin ON beta_testers FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

-- Feedback: a user submits & reads own; admins read/manage all.
DROP POLICY IF EXISTS feedback_insert ON feedback_items;
CREATE POLICY feedback_insert ON feedback_items FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS feedback_select ON feedback_items;
CREATE POLICY feedback_select ON feedback_items FOR SELECT TO authenticated
  USING (is_campus_admin() OR user_id = auth.uid());
DROP POLICY IF EXISTS feedback_update ON feedback_items;
CREATE POLICY feedback_update ON feedback_items FOR UPDATE TO authenticated
  USING (is_campus_admin());

DROP POLICY IF EXISTS fvotes_all ON feedback_votes;
CREATE POLICY fvotes_all ON feedback_votes FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- System announcements: everyone reads active; admins manage.
DROP POLICY IF EXISTS sysann_select ON system_announcements;
CREATE POLICY sysann_select ON system_announcements FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS sysann_admin ON system_announcements;
CREATE POLICY sysann_admin ON system_announcements FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

DROP POLICY IF EXISTS dismiss_all ON announcement_dismissals;
CREATE POLICY dismiss_all ON announcement_dismissals FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Referrals: a user manages own; admins read all.
DROP POLICY IF EXISTS ref_insert ON referrals;
CREATE POLICY ref_insert ON referrals FOR INSERT TO authenticated
  WITH CHECK (referrer_id = auth.uid());
DROP POLICY IF EXISTS ref_select ON referrals;
CREATE POLICY ref_select ON referrals FOR SELECT TO authenticated
  USING (is_campus_admin() OR referrer_id = auth.uid());
DROP POLICY IF EXISTS ref_update ON referrals;
CREATE POLICY ref_update ON referrals FOR UPDATE TO authenticated
  USING (is_campus_admin() OR referrer_id = auth.uid());

-- Analytics events: a user writes own events; admins read all.
DROP POLICY IF EXISTS events_insert ON analytics_events;
CREATE POLICY events_insert ON analytics_events FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
DROP POLICY IF EXISTS events_admin ON analytics_events;
CREATE POLICY events_admin ON analytics_events FOR SELECT TO authenticated
  USING (is_campus_admin());

DROP POLICY IF EXISTS sessions_insert ON user_sessions;
CREATE POLICY sessions_insert ON user_sessions FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
DROP POLICY IF EXISTS sessions_update ON user_sessions;
CREATE POLICY sessions_update ON user_sessions FOR UPDATE TO authenticated
  USING (user_id = auth.uid());
DROP POLICY IF EXISTS sessions_admin ON user_sessions;
CREATE POLICY sessions_admin ON user_sessions FOR SELECT TO authenticated
  USING (is_campus_admin() OR user_id = auth.uid());

-- Ambassadors: self-read; admins manage.
DROP POLICY IF EXISTS amb_select ON ambassadors;
CREATE POLICY amb_select ON ambassadors FOR SELECT TO authenticated
  USING (is_campus_admin() OR user_id = auth.uid());
DROP POLICY IF EXISTS amb_admin ON ambassadors;
CREATE POLICY amb_admin ON ambassadors FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

DROP POLICY IF EXISTS ambev_select ON ambassador_events;
CREATE POLICY ambev_select ON ambassador_events FOR SELECT TO authenticated
  USING (is_campus_admin()
         OR EXISTS (SELECT 1 FROM ambassadors a
                    WHERE a.id = ambassador_events.ambassador_id AND a.user_id = auth.uid()));
DROP POLICY IF EXISTS ambev_write ON ambassador_events;
CREATE POLICY ambev_write ON ambassador_events FOR ALL TO authenticated
  USING (is_campus_admin()
         OR EXISTS (SELECT 1 FROM ambassadors a
                    WHERE a.id = ambassador_events.ambassador_id AND a.user_id = auth.uid()))
  WITH CHECK (is_campus_admin()
         OR EXISTS (SELECT 1 FROM ambassadors a
                    WHERE a.id = ambassador_events.ambassador_id AND a.user_id = auth.uid()));

-- Support content: published items readable by all; admins manage.
DROP POLICY IF EXISTS faq_select ON faq_items;
CREATE POLICY faq_select ON faq_items FOR SELECT TO authenticated USING (is_published OR is_campus_admin());
DROP POLICY IF EXISTS faq_admin ON faq_items;
CREATE POLICY faq_admin ON faq_items FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

DROP POLICY IF EXISTS help_select ON help_articles;
CREATE POLICY help_select ON help_articles FOR SELECT TO authenticated USING (is_published OR is_campus_admin());
DROP POLICY IF EXISTS help_admin ON help_articles;
CREATE POLICY help_admin ON help_articles FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

DROP POLICY IF EXISTS ticket_insert ON support_tickets;
CREATE POLICY ticket_insert ON support_tickets FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS ticket_select ON support_tickets;
CREATE POLICY ticket_select ON support_tickets FOR SELECT TO authenticated
  USING (is_campus_admin() OR user_id = auth.uid());
DROP POLICY IF EXISTS ticket_update ON support_tickets;
CREATE POLICY ticket_update ON support_tickets FOR UPDATE TO authenticated
  USING (is_campus_admin());

DROP POLICY IF EXISTS abuse_insert ON abuse_reports;
CREATE POLICY abuse_insert ON abuse_reports FOR INSERT TO authenticated
  WITH CHECK (reporter_id = auth.uid());
DROP POLICY IF EXISTS abuse_select ON abuse_reports;
CREATE POLICY abuse_select ON abuse_reports FOR SELECT TO authenticated
  USING (is_campus_admin() OR reporter_id = auth.uid());
DROP POLICY IF EXISTS abuse_update ON abuse_reports;
CREATE POLICY abuse_update ON abuse_reports FOR UPDATE TO authenticated
  USING (is_campus_admin());

-- Health + errors: admins read; any authenticated can append an error log.
DROP POLICY IF EXISTS health_admin ON system_health_metrics;
CREATE POLICY health_admin ON system_health_metrics FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

DROP POLICY IF EXISTS errors_insert ON error_logs;
CREATE POLICY errors_insert ON error_logs FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS errors_admin ON error_logs;
CREATE POLICY errors_admin ON error_logs FOR SELECT TO authenticated USING (is_campus_admin());

-- App versions: everyone reads (to check for updates); admins manage.
DROP POLICY IF EXISTS appver_select ON app_versions;
CREATE POLICY appver_select ON app_versions FOR SELECT TO anon, authenticated USING (true);
DROP POLICY IF EXISTS appver_admin ON app_versions;
CREATE POLICY appver_admin ON app_versions FOR ALL TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

-- ============================================================
-- STORAGE — feedback screenshots
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('feedback', 'feedback', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "feedback upload" ON storage.objects;
CREATE POLICY "feedback upload" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'feedback');
DROP POLICY IF EXISTS "feedback read" ON storage.objects;
CREATE POLICY "feedback read" ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'feedback');

-- ============================================================
-- END STEP 13
-- ============================================================
