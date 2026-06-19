-- ============================================================
-- UNIFY MIGRATION — STEP 1 OF 3
-- Drop unused legacy tables
-- ============================================================
-- What this does:
--   Removes 5 tables from the roommate-matching era that are no
--   longer used. Does NOT touch students, universities, or auth.
--
-- Auth risk:  NONE. auth.users and the students table are untouched.
-- Data loss:  Any rows in these 5 tables are permanently deleted.
-- Re-runnable: Yes. IF EXISTS guards on every DROP.
--
-- Run in: Supabase Dashboard → SQL Editor → Run
-- ============================================================


BEGIN;

-- Drop in FK dependency order (children before parents).
-- CASCADE removes any dependent objects (indexes, policies, triggers)
-- that belong to these tables.

DROP TABLE IF EXISTS chats                  CASCADE;
DROP TABLE IF EXISTS verification_requests  CASCADE;
DROP TABLE IF EXISTS matches                CASCADE;
DROP TABLE IF EXISTS housing_listings       CASCADE;
DROP TABLE IF EXISTS roommate_quiz          CASCADE;

COMMIT;


-- ============================================================
-- VERIFY (run these SELECT statements after the script above)
-- ============================================================
-- Expected result: 0 rows for each query.

-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
--   AND table_name IN (
--     'chats','verification_requests','matches',
--     'housing_listings','roommate_quiz'
--   );

-- Expected surviving tables:
-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
-- ORDER BY table_name;
-- → should show only: students, universities


-- ============================================================
-- ROLLBACK
-- ============================================================
-- Data in these tables cannot be recovered once dropped.
-- The table STRUCTURES below can be recreated if needed,
-- but rows are gone. Export to CSV from Supabase before
-- running this step if any data must be preserved.
--
-- To recreate the table shells (no data):
--
-- CREATE TABLE IF NOT EXISTS roommate_quiz (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   student_id UUID REFERENCES students(id) ON DELETE CASCADE,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- CREATE TABLE IF NOT EXISTS housing_listings (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   student_id UUID REFERENCES students(id),
--   university_id UUID REFERENCES universities(id),
--   rent_amount INTEGER NOT NULL,
--   is_active BOOLEAN DEFAULT TRUE,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- CREATE TABLE IF NOT EXISTS matches (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   student_id UUID REFERENCES students(id),
--   matched_student_id UUID REFERENCES students(id),
--   status TEXT CHECK (status IN ('pending','accepted','rejected','expired')),
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- CREATE TABLE IF NOT EXISTS chats (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   match_id UUID REFERENCES matches(id),
--   student_id UUID REFERENCES students(id),
--   message TEXT NOT NULL,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- CREATE TABLE IF NOT EXISTS verification_requests (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   student_id UUID REFERENCES students(id),
--   verification_code TEXT NOT NULL,
--   university_email TEXT NOT NULL,
--   status TEXT CHECK (status IN ('pending','approved','rejected')),
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
