-- ============================================================
-- STEP 16 — Multi-University Administration System
-- ============================================================
-- Universities, faculties, departments, RBAC, verification,
-- moderation, audit logs, analytics, communication center.
-- ============================================================

-- ── 1. Universities ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS universities (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name              TEXT        NOT NULL,
  short_name        TEXT,
  logo_url          TEXT,
  country           TEXT,
  region            TEXT,
  website           TEXT,
  verification_domain TEXT,
  theme_primary     TEXT        DEFAULT '#0066FF',
  theme_secondary   TEXT        DEFAULT '#FF8C00',
  welcome_screen    TEXT,
  verification_requirements JSONB DEFAULT '{}'::jsonb,
  is_active         BOOLEAN     DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 2. Faculties / Schools / Colleges ──────────────────────

CREATE TABLE IF NOT EXISTS faculties (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id UUID        NOT NULL REFERENCES universities(id) ON DELETE CASCADE,
  name          TEXT        NOT NULL,
  type          TEXT        NOT NULL DEFAULT 'faculty'
                CHECK (type IN ('faculty', 'school', 'college')),
  description   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (university_id, name)
);

-- ── 3. Departments / Programmes ────────────────────────────

CREATE TABLE IF NOT EXISTS departments (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  faculty_id  UUID        NOT NULL REFERENCES faculties(id) ON DELETE CASCADE,
  name        TEXT        NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (faculty_id, name)
);

-- ── 4. Admin Roles ─────────────────────────────────────────

CREATE TABLE IF NOT EXISTS admin_roles (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  role        TEXT        NOT NULL UNIQUE
              CHECK (role IN ('super_admin', 'university_admin', 'faculty_admin',
                     'department_admin', 'moderator', 'analyst')),
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO admin_roles (role, description) VALUES
  ('super_admin', 'Platform owner — can manage every university'),
  ('university_admin', 'Can manage one university'),
  ('faculty_admin', 'Can manage one faculty'),
  ('department_admin', 'Can manage one department'),
  ('moderator', 'Can moderate content across assigned scope'),
  ('analyst', 'Read-only access to analytics')
ON CONFLICT (role) DO NOTHING;

-- ── 5. University Administrators ───────────────────────────

CREATE TABLE IF NOT EXISTS university_administrators (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role_id       UUID        NOT NULL REFERENCES admin_roles(id) ON DELETE CASCADE,
  university_id UUID        REFERENCES universities(id) ON DELETE CASCADE,
  faculty_id    UUID        REFERENCES faculties(id) ON DELETE CASCADE,
  department_id UUID        REFERENCES departments(id) ON DELETE CASCADE,
  assigned_by   UUID        REFERENCES profiles(id),
  is_active     BOOLEAN     DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, role_id)
);

-- ── 6. Verification Requests (enhanced) ────────────────────

ALTER TABLE IF EXISTS verification_requests
  ADD COLUMN IF NOT EXISTS university_id UUID REFERENCES universities(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS faculty_id    UUID REFERENCES faculties(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS reviewed_by   UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS reviewed_at   TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS admin_notes   TEXT;

-- ── 7. Audit Log ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS audit_logs (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id      UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  action        TEXT        NOT NULL,
  entity_type   TEXT        NOT NULL,
  entity_id     UUID,
  university_id UUID        REFERENCES universities(id) ON DELETE SET NULL,
  details       JSONB       DEFAULT '{}'::jsonb,
  ip_address    TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 8. Moderation Queue ────────────────────────────────────

CREATE TABLE IF NOT EXISTS moderation_queue (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  report_type   TEXT        NOT NULL
                CHECK (report_type IN ('user', 'post', 'community', 'marketplace', 'event')),
  reported_by   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_id     UUID        NOT NULL,
  target_type   TEXT        NOT NULL,
  reason        TEXT,
  status        TEXT        NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
  reviewed_by   UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  resolution    TEXT,
  university_id UUID        REFERENCES universities(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 9. Communications / Announcements ─────────────────────

CREATE TABLE IF NOT EXISTS admin_announcements (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title         TEXT        NOT NULL,
  body          TEXT        NOT NULL,
  scope_type    TEXT        NOT NULL
                CHECK (scope_type IN ('university', 'faculty', 'department', 'community', 'all')),
  scope_id      UUID,
  priority      TEXT        DEFAULT 'normal'
                CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  send_push     BOOLEAN     DEFAULT false,
  send_email    BOOLEAN     DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS admin_announcement_recipients (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  announcement_id UUID        NOT NULL REFERENCES admin_announcements(id) ON DELETE CASCADE,
  user_id         UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  read_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (announcement_id, user_id)
);

-- ── 10. Opportunities ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS opportunities (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT        NOT NULL,
  description     TEXT        NOT NULL,
  opportunity_type TEXT       NOT NULL
                  CHECK (opportunity_type IN ('scholarship', 'internship', 'fellowship', 'competition', 'other')),
  university_id   UUID        REFERENCES universities(id) ON DELETE SET NULL,
  organizer_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  deadline        TIMESTAMPTZ,
  eligibility     TEXT,
  url             TEXT,
  status          TEXT        NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'approved', 'rejected', 'expired')),
  reviewed_by     UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 11. Marketplace Admin ─────────────────────────────────

CREATE TABLE IF NOT EXISTS marketplace_reports (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id    UUID        NOT NULL,
  reported_by   UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason        TEXT        NOT NULL,
  status        TEXT        NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
  action_taken  TEXT,
  reviewed_by   UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 12. Analytics Snapshots ───────────────────────────────

CREATE TABLE IF NOT EXISTS analytics_snapshots (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id   UUID        REFERENCES universities(id) ON DELETE CASCADE,
  snapshot_date   DATE        NOT NULL DEFAULT CURRENT_DATE,
  active_students INTEGER     DEFAULT 0,
  daily_active    INTEGER     DEFAULT 0,
  monthly_active  INTEGER     DEFAULT 0,
  communities     INTEGER     DEFAULT 0,
  events_count    INTEGER     DEFAULT 0,
  marketplace_count INTEGER   DEFAULT 0,
  opportunities_count INTEGER DEFAULT 0,
  posts_count      INTEGER    DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (university_id, snapshot_date)
);

-- ── Indexes ────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_faculties_university ON faculties(university_id);
CREATE INDEX IF NOT EXISTS idx_departments_faculty   ON departments(faculty_id);
CREATE INDEX IF NOT EXISTS idx_admins_user           ON university_administrators(user_id);
CREATE INDEX IF NOT EXISTS idx_admins_role           ON university_administrators(role_id);
CREATE INDEX IF NOT EXISTS idx_admins_university     ON university_administrators(university_id);
CREATE INDEX IF NOT EXISTS idx_audit_actor           ON audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_entity          ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_university      ON audit_logs(university_id);
CREATE INDEX IF NOT EXISTS idx_moderation_status     ON moderation_queue(status);
CREATE INDEX IF NOT EXISTS idx_moderation_type       ON moderation_queue(report_type);
CREATE INDEX IF NOT EXISTS idx_announcements_scope   ON admin_announcements(scope_type, scope_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_status  ON opportunities(status);
CREATE INDEX IF NOT EXISTS idx_opportunities_type    ON opportunities(opportunity_type);
CREATE INDEX IF NOT EXISTS idx_analytics_university  ON analytics_snapshots(university_id, snapshot_date);

-- ── RLS — Universities ────────────────────────────────────

ALTER TABLE universities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "universities_select" ON universities
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "universities_insert" ON universities
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ar.role = 'super_admin' AND ua.is_active)
  );

CREATE POLICY "universities_update" ON universities
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid()
            AND ua.is_active
            AND (ar.role = 'super_admin'
                 OR (ar.role = 'university_admin' AND ua.university_id = universities.id)))
  );

CREATE POLICY "universities_delete" ON universities
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ar.role = 'super_admin' AND ua.is_active)
  );

-- ── RLS — Faculties ───────────────────────────────────────

ALTER TABLE faculties ENABLE ROW LEVEL SECURITY;

CREATE POLICY "faculties_select" ON faculties
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "faculties_insert" ON faculties
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active
            AND (ar.role = 'super_admin'
                 OR (ar.role = 'university_admin' AND ua.university_id = university_id)))
  );

CREATE POLICY "faculties_update" ON faculties
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active
            AND (ar.role = 'super_admin'
                 OR (ar.role = 'university_admin' AND ua.university_id = university_id)
                 OR (ar.role = 'faculty_admin' AND ua.faculty_id = faculties.id)))
  );

CREATE POLICY "faculties_delete" ON faculties
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active
            AND (ar.role = 'super_admin'
                 OR (ar.role = 'university_admin' AND ua.university_id = university_id)))
  );

-- ── RLS — Departments ─────────────────────────────────────

ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "departments_select" ON departments
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "departments_insert" ON departments
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active
            AND (ar.role IN ('super_admin', 'university_admin')
                 OR (ar.role = 'faculty_admin' AND ua.faculty_id = faculty_id)))
  );

CREATE POLICY "departments_update" ON departments
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active
            AND (ar.role IN ('super_admin', 'university_admin')
                 OR (ar.role = 'faculty_admin' AND ua.faculty_id = faculty_id)
                 OR (ar.role = 'department_admin' AND ua.department_id = departments.id)))
  );

CREATE POLICY "departments_delete" ON departments
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active
            AND (ar.role IN ('super_admin', 'university_admin')
                 OR (ar.role = 'faculty_admin' AND ua.faculty_id = faculty_id)))
  );

-- ── RLS — University Administrators ───────────────────────

ALTER TABLE university_administrators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admins_select" ON university_administrators
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "admins_insert" ON university_administrators
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active AND ar.role = 'super_admin')
  );

CREATE POLICY "admins_update" ON university_administrators
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active AND ar.role = 'super_admin')
  );

CREATE POLICY "admins_delete" ON university_administrators
  FOR DELETE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active AND ar.role = 'super_admin')
  );

-- ── RLS — Audit Logs ──────────────────────────────────────

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_select" ON audit_logs
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "audit_insert" ON audit_logs
  FOR INSERT TO authenticated WITH CHECK (actor_id = auth.uid());

-- ── RLS — Moderation Queue ─────────────────────────────────

ALTER TABLE moderation_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "moderation_select" ON moderation_queue
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "moderation_insert" ON moderation_queue
  FOR INSERT TO authenticated WITH CHECK (reported_by = auth.uid());

CREATE POLICY "moderation_update" ON moderation_queue
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- ── RLS — Admin Announcements ─────────────────────────────

ALTER TABLE admin_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_announcement_recipients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "announcements_select" ON admin_announcements
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM admin_announcement_recipients
            WHERE announcement_id = admin_announcements.id AND user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM university_administrators ua
               JOIN admin_roles ar ON ar.id = ua.role_id
               WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "announcements_insert" ON admin_announcements
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "recipients_select" ON admin_announcement_recipients
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "recipients_insert" ON admin_announcement_recipients
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- ── RLS — Opportunities ───────────────────────────────────

ALTER TABLE opportunities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "opportunities_select" ON opportunities
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "opportunities_insert" ON opportunities
  FOR INSERT TO authenticated WITH CHECK (organizer_id = auth.uid());

CREATE POLICY "opportunities_update" ON opportunities
  FOR UPDATE TO authenticated USING (
    organizer_id = auth.uid()
    OR EXISTS (SELECT 1 FROM university_administrators ua
               JOIN admin_roles ar ON ar.id = ua.role_id
               WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "opportunities_delete" ON opportunities
  FOR DELETE TO authenticated USING (organizer_id = auth.uid());

-- ── RLS — Marketplace Reports ─────────────────────────────

ALTER TABLE marketplace_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "marketplace_reports_select" ON marketplace_reports
  FOR SELECT TO authenticated USING (
    reported_by = auth.uid()
    OR EXISTS (SELECT 1 FROM university_administrators ua
               JOIN admin_roles ar ON ar.id = ua.role_id
               WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "marketplace_reports_insert" ON marketplace_reports
  FOR INSERT TO authenticated WITH CHECK (reported_by = auth.uid());

CREATE POLICY "marketplace_reports_update" ON marketplace_reports
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

-- ── RLS — Analytics Snapshots ─────────────────────────────

ALTER TABLE analytics_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "analytics_select" ON analytics_snapshots
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active)
  );

CREATE POLICY "analytics_insert" ON analytics_snapshots
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM university_administrators ua
            JOIN admin_roles ar ON ar.id = ua.role_id
            WHERE ua.user_id = auth.uid() AND ua.is_active AND ar.role = 'super_admin')
  );

-- ── Helper Functions ──────────────────────────────────────

CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM university_administrators
    WHERE user_id = $1 AND is_active
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_super_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM university_administrators ua
    JOIN admin_roles ar ON ar.id = ua.role_id
    WHERE ua.user_id = $1 AND ua.is_active AND ar.role = 'super_admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_user_admin_scope(user_id UUID)
RETURNS TABLE(role TEXT, university_id UUID, faculty_id UUID, department_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT ar.role, ua.university_id, ua.faculty_id, ua.department_id
  FROM university_administrators ua
  JOIN admin_roles ar ON ar.id = ua.role_id
  WHERE ua.user_id = $1 AND ua.is_active;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
$$ LANGUAGE plpgsql SECURITY DEFINER;
