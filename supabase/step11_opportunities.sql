-- ============================================================
-- STEP 11 — UNIFY Opportunities Hub
-- ============================================================
-- A dedicated opportunities ecosystem for African university
-- students: scholarships, internships, competitions, conferences,
-- fellowships, exchange programs and campus opportunities.
--
-- Students browse, save, set deadline reminders, and track each
-- opportunity from discovery → application. Verified badges,
-- personalized recommendations, admin management and analytics.
-- Future-ready for organization (recruiter) accounts.
-- ============================================================

-- ── Organizations (future recruiter accounts) ─────────────────

CREATE TABLE IF NOT EXISTS organizations (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  name        TEXT        NOT NULL,
  logo_url    TEXT,
  website     TEXT,
  about       TEXT,
  is_verified BOOLEAN     NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_orgs_owner ON organizations (owner_id);

-- ── Opportunities ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS opportunities (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  type            TEXT        NOT NULL CHECK (type IN (
                    'scholarship','internship','competition','conference',
                    'fellowship','exchange','campus')),
  title           TEXT        NOT NULL,
  organization    TEXT,                                 -- free-text org name
  organization_id UUID                 REFERENCES organizations(id) ON DELETE SET NULL,
  description     TEXT,
  summary         TEXT,                                 -- short one-liner for cards
  cover_url       TEXT,

  location        TEXT,                                 -- 'Accra, Ghana' / 'Pan-African'
  is_remote       BOOLEAN     NOT NULL DEFAULT false,
  country         TEXT,                                 -- ISO-ish or free text

  funding         TEXT,                                 -- 'Fully funded' / 'GHS 5,000' / 'Stipend'
  is_funded       BOOLEAN     NOT NULL DEFAULT false,

  eligibility     TEXT,
  fields          TEXT[]      NOT NULL DEFAULT '{}',    -- study fields / interest tags
  levels          TEXT[]      NOT NULL DEFAULT '{}',    -- target levels (100..600, postgrad)
  tags            TEXT[]      NOT NULL DEFAULT '{}',

  application_url  TEXT,
  deadline        TIMESTAMPTZ,                          -- null = rolling / no deadline
  starts_at       TIMESTAMPTZ,

  university_id   UUID                 REFERENCES universities(id) ON DELETE CASCADE,
                                                        -- null = open to all campuses
  posted_by       UUID                 REFERENCES profiles(id) ON DELETE SET NULL,

  is_verified     BOOLEAN     NOT NULL DEFAULT false,   -- vetted by UNIFY admins
  is_featured     BOOLEAN     NOT NULL DEFAULT false,
  status          TEXT        NOT NULL DEFAULT 'published'
                    CHECK (status IN ('published','draft','closed','archived')),

  view_count      INTEGER     NOT NULL DEFAULT 0,
  save_count      INTEGER     NOT NULL DEFAULT 0,
  application_count INTEGER   NOT NULL DEFAULT 0,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_opps_type       ON opportunities (type, status);
CREATE INDEX IF NOT EXISTS idx_opps_deadline   ON opportunities (deadline);
CREATE INDEX IF NOT EXISTS idx_opps_status     ON opportunities (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_opps_university ON opportunities (university_id);
CREATE INDEX IF NOT EXISTS idx_opps_featured   ON opportunities (is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_opps_fields     ON opportunities USING gin (fields);
CREATE INDEX IF NOT EXISTS idx_opps_search
  ON opportunities
  USING gin (to_tsvector('english',
    coalesce(title,'') || ' ' || coalesce(organization,'') || ' ' ||
    coalesce(summary,'') || ' ' || coalesce(description,'')));

-- ── Saves (wishlist / bookmarks) ──────────────────────────────

CREATE TABLE IF NOT EXISTS opportunity_saves (
  user_id        UUID        NOT NULL REFERENCES profiles(id)     ON DELETE CASCADE,
  opportunity_id UUID        NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, opportunity_id)
);

-- ── Application tracking (discovery → application) ─────────────

CREATE TABLE IF NOT EXISTS opportunity_applications (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL REFERENCES profiles(id)     ON DELETE CASCADE,
  opportunity_id UUID        NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
  stage          TEXT        NOT NULL DEFAULT 'saved'
                   CHECK (stage IN ('saved','preparing','applied','interview',
                                    'accepted','rejected','withdrawn')),
  notes          TEXT,
  applied_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, opportunity_id)
);
CREATE INDEX IF NOT EXISTS idx_opp_apps_user ON opportunity_applications (user_id, stage);

-- ── Deadline reminders (push-notification readiness) ──────────

CREATE TABLE IF NOT EXISTS opportunity_reminders (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL REFERENCES profiles(id)     ON DELETE CASCADE,
  opportunity_id UUID        NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
  remind_at      TIMESTAMPTZ NOT NULL,
  sent           BOOLEAN     NOT NULL DEFAULT false,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, opportunity_id, remind_at)
);
CREATE INDEX IF NOT EXISTS idx_opp_reminders_due
  ON opportunity_reminders (remind_at) WHERE sent = false;

-- ── Reports (moderation) ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS opportunity_reports (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  opportunity_id UUID        NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
  reporter_id    UUID        NOT NULL REFERENCES profiles(id)     ON DELETE CASCADE,
  reason         TEXT        NOT NULL,
  status         TEXT        NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending','reviewed','dismissed','actioned')),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Search analytics ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS opportunity_searches (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  query      TEXT        NOT NULL,
  type       TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_opp_searches_query ON opportunity_searches (lower(query));

-- ============================================================
-- Triggers — counters & timestamps
-- ============================================================

CREATE OR REPLACE FUNCTION sync_opportunity_save_count()
RETURNS TRIGGER AS $$
DECLARE oid UUID := COALESCE(NEW.opportunity_id, OLD.opportunity_id);
BEGIN
  UPDATE opportunities
     SET save_count = (SELECT count(*) FROM opportunity_saves WHERE opportunity_id = oid)
   WHERE id = oid;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_opp_save_count ON opportunity_saves;
CREATE TRIGGER trg_opp_save_count
  AFTER INSERT OR DELETE ON opportunity_saves
  FOR EACH ROW EXECUTE FUNCTION sync_opportunity_save_count();

CREATE OR REPLACE FUNCTION sync_opportunity_app_count()
RETURNS TRIGGER AS $$
DECLARE oid UUID := COALESCE(NEW.opportunity_id, OLD.opportunity_id);
BEGIN
  UPDATE opportunities
     SET application_count = (SELECT count(*) FROM opportunity_applications
                               WHERE opportunity_id = oid AND stage <> 'saved')
   WHERE id = oid;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_opp_app_count ON opportunity_applications;
CREATE TRIGGER trg_opp_app_count
  AFTER INSERT OR DELETE OR UPDATE ON opportunity_applications
  FOR EACH ROW EXECUTE FUNCTION sync_opportunity_app_count();

CREATE OR REPLACE FUNCTION touch_opportunity_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_opp_touch ON opportunities;
CREATE TRIGGER trg_opp_touch
  BEFORE UPDATE ON opportunities
  FOR EACH ROW EXECUTE FUNCTION touch_opportunity_updated_at();

DROP TRIGGER IF EXISTS trg_opp_app_touch ON opportunity_applications;
CREATE TRIGGER trg_opp_app_touch
  BEFORE UPDATE ON opportunity_applications
  FOR EACH ROW EXECUTE FUNCTION touch_opportunity_updated_at();

CREATE OR REPLACE FUNCTION increment_opportunity_view(p_id UUID)
RETURNS void AS $$
  UPDATE opportunities SET view_count = view_count + 1 WHERE id = p_id;
$$ LANGUAGE sql;

-- ============================================================
-- Analytics helpers (admin dashboard)
-- ============================================================

CREATE OR REPLACE FUNCTION opportunity_type_counts()
RETURNS TABLE (type TEXT, total BIGINT) AS $$
  SELECT type, count(*)::bigint
    FROM opportunities WHERE status = 'published'
   GROUP BY type ORDER BY count(*) DESC;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION top_opportunity_searches(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (query TEXT, total BIGINT) AS $$
  SELECT lower(query) AS query, count(*)::bigint
    FROM opportunity_searches
   GROUP BY lower(query) ORDER BY count(*) DESC LIMIT p_limit;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION is_campus_admin()
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid()
                  AND role IN ('admin','superadmin'));
$$ LANGUAGE sql STABLE;

-- ============================================================
-- Row Level Security
-- ============================================================

ALTER TABLE organizations            ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunities            ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunity_saves        ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunity_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunity_reminders    ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunity_reports      ENABLE ROW LEVEL SECURITY;
ALTER TABLE opportunity_searches     ENABLE ROW LEVEL SECURITY;

-- Organizations: public read; owner or admin writes
DROP POLICY IF EXISTS orgs_select ON organizations;
CREATE POLICY orgs_select ON organizations
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS orgs_write ON organizations;
CREATE POLICY orgs_write ON organizations
  FOR ALL TO authenticated
  USING (owner_id = auth.uid() OR is_campus_admin())
  WITH CHECK (owner_id = auth.uid() OR is_campus_admin());

-- Opportunities: everyone reads published (campus-scoped or global);
-- admins & the original poster manage.
DROP POLICY IF EXISTS opps_select ON opportunities;
CREATE POLICY opps_select ON opportunities
  FOR SELECT TO authenticated
  USING (status = 'published' OR posted_by = auth.uid() OR is_campus_admin());

DROP POLICY IF EXISTS opps_insert ON opportunities;
CREATE POLICY opps_insert ON opportunities
  FOR INSERT TO authenticated
  WITH CHECK (is_campus_admin() OR posted_by = auth.uid());

DROP POLICY IF EXISTS opps_update ON opportunities;
CREATE POLICY opps_update ON opportunities
  FOR UPDATE TO authenticated
  USING (is_campus_admin() OR posted_by = auth.uid())
  WITH CHECK (is_campus_admin() OR posted_by = auth.uid());

DROP POLICY IF EXISTS opps_delete ON opportunities;
CREATE POLICY opps_delete ON opportunities
  FOR DELETE TO authenticated
  USING (is_campus_admin() OR posted_by = auth.uid());

-- Saves: own rows
DROP POLICY IF EXISTS opp_saves_write ON opportunity_saves;
CREATE POLICY opp_saves_write ON opportunity_saves
  FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Applications: own rows
DROP POLICY IF EXISTS opp_apps_write ON opportunity_applications;
CREATE POLICY opp_apps_write ON opportunity_applications
  FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Reminders: own rows
DROP POLICY IF EXISTS opp_reminders_write ON opportunity_reminders;
CREATE POLICY opp_reminders_write ON opportunity_reminders
  FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Reports: reporters insert / read own; admins read & action
DROP POLICY IF EXISTS opp_reports_insert ON opportunity_reports;
CREATE POLICY opp_reports_insert ON opportunity_reports
  FOR INSERT TO authenticated WITH CHECK (reporter_id = auth.uid());
DROP POLICY IF EXISTS opp_reports_select ON opportunity_reports;
CREATE POLICY opp_reports_select ON opportunity_reports
  FOR SELECT TO authenticated
  USING (reporter_id = auth.uid() OR is_campus_admin());
DROP POLICY IF EXISTS opp_reports_update ON opportunity_reports;
CREATE POLICY opp_reports_update ON opportunity_reports
  FOR UPDATE TO authenticated
  USING (is_campus_admin()) WITH CHECK (is_campus_admin());

-- Searches: insert own; admins read for analytics
DROP POLICY IF EXISTS opp_searches_insert ON opportunity_searches;
CREATE POLICY opp_searches_insert ON opportunity_searches
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
DROP POLICY IF EXISTS opp_searches_admin ON opportunity_searches;
CREATE POLICY opp_searches_admin ON opportunity_searches
  FOR SELECT TO authenticated USING (is_campus_admin());

-- ============================================================
-- Storage bucket for opportunity cover images / org logos
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('opportunities', 'opportunities', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "opportunity media read" ON storage.objects;
CREATE POLICY "opportunity media read" ON storage.objects
  FOR SELECT TO public USING (bucket_id = 'opportunities');

DROP POLICY IF EXISTS "opportunity media write" ON storage.objects;
CREATE POLICY "opportunity media write" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'opportunities');
