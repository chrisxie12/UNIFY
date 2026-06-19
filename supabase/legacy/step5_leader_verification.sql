-- ============================================================
-- UNIFY — STEP 5: LEADER VERIFICATION SYSTEM
-- ============================================================
-- Adds:
--   1. Leader verification fields to profiles table
--   2. Verification requests table with evidence storage
--   3. RLS policies for verification requests
-- ============================================================

-- ── 1. Add leader verification columns to profiles ─────────
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_verified_leader   BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS leadership_role      TEXT,
  ADD COLUMN IF NOT EXISTS represented_class    TEXT,
  ADD COLUMN IF NOT EXISTS represented_department TEXT,
  ADD COLUMN IF NOT EXISTS verification_status  TEXT NOT NULL DEFAULT 'none'
    CHECK (verification_status IN ('none','pending','verified','rejected'));

-- ── 2. VERIFICATION REQUESTS ─────────────────────────────────
-- Students submit these to apply for verified leader status.
-- Admin reviews evidence and approves/rejects.
CREATE TABLE verification_requests (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  university_id     UUID NOT NULL REFERENCES universities(id),
  position          TEXT NOT NULL,
  class_represented TEXT,
  department        TEXT,
  academic_year     TEXT NOT NULL,
  evidence_url      TEXT,                    -- uploaded file in storage
  evidence_type     TEXT,                    -- 'appointment_letter', 'screenshot', 'official_doc'
  status            TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending','approved','rejected')),
  admin_notes       TEXT,
  reviewed_by       UUID REFERENCES profiles(id),
  reviewed_at       TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER verification_requests_updated_at
  BEFORE UPDATE ON verification_requests
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── 3. VERIFICATION LOG ──────────────────────────────────────
-- Audit log for all verification actions.
CREATE TABLE verification_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_user_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  action          TEXT NOT NULL CHECK (action IN ('submitted','approved','rejected','revoked')),
  performed_by    UUID REFERENCES profiles(id),
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_log      ENABLE ROW LEVEL SECURITY;

-- verification_requests: own read, admin all
CREATE POLICY "verification_requests_own" ON verification_requests FOR ALL USING (
  auth.uid() = user_id
);
CREATE POLICY "verification_requests_admin_all" ON verification_requests FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- verification_log: admin only
CREATE POLICY "verification_log_admin_all" ON verification_log FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_verification_requests_user   ON verification_requests(user_id);
CREATE INDEX idx_verification_requests_status ON verification_requests(status);
CREATE INDEX idx_verification_log_target      ON verification_log(target_user_id);
CREATE INDEX idx_profiles_verification_status ON profiles(verification_status);
