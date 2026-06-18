-- ============================================================
-- UNIFY — Step 3: Minimal - only ensures required functions and
-- column patches exist before step 4+ creates new tables.
-- ============================================================

BEGIN;

-- Ensure the trigger function exists
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;

-- Add missing columns to existing announcements table if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='announcements') THEN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='announcements' AND column_name='is_published') THEN
      ALTER TABLE announcements ADD COLUMN is_published BOOLEAN NOT NULL DEFAULT FALSE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='announcements' AND column_name='published_at') THEN
      ALTER TABLE announcements ADD COLUMN published_at TIMESTAMPTZ;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='announcements' AND column_name='expires_at') THEN
      ALTER TABLE announcements ADD COLUMN expires_at TIMESTAMPTZ;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='announcements' AND column_name='updated_at') THEN
      ALTER TABLE announcements ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
    END IF;

    -- Add updated_at trigger
    DROP TRIGGER IF EXISTS announcements_updated_at ON announcements;
    CREATE TRIGGER announcements_updated_at
      BEFORE UPDATE ON announcements
      FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
  END IF;
END $$;

-- Ensure existing RLS policies on announcements are dropped to avoid conflicts
DROP POLICY IF EXISTS announcements_student_read ON announcements;
DROP POLICY IF EXISTS announcements_admin_read ON announcements;
DROP POLICY IF EXISTS announcements_leader_insert ON announcements;
DROP POLICY IF EXISTS announcements_update ON announcements;
DROP POLICY IF EXISTS announcement_reads_own ON announcement_reads;

COMMIT;
