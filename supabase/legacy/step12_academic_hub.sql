-- ============================================================
-- STEP 12 — UNIFY Academic Hub
-- ============================================================
-- The academic operating system for students. Resources organised by
--   University → Faculty → Department → Course → Semester.
--
-- Notes repository, past-questions bank, course pages, assignment hub,
-- exam-prep center, GPA records, study planner, resource ratings,
-- academic search, verification, offline-download tracking, analytics.
-- Integrates with communities, profiles, messaging and notifications.
-- ============================================================

-- ── Courses ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS courses (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id UUID                 REFERENCES universities(id) ON DELETE CASCADE,
  community_id  UUID                 REFERENCES communities(id)  ON DELETE SET NULL,
  code          TEXT        NOT NULL,                 -- e.g. DCIT201
  title         TEXT        NOT NULL,                 -- e.g. Database Systems
  description   TEXT,
  faculty       TEXT,                                 -- e.g. Computing
  department    TEXT,                                 -- e.g. IT
  level         TEXT,                                 -- e.g. 200
  credits       INTEGER,
  lecturer      TEXT,
  academic_year TEXT,
  semester      TEXT,                                 -- 'Semester 1' / 'Semester 2'
  created_by    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  view_count    INTEGER     NOT NULL DEFAULT 0,
  resource_count INTEGER    NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (university_id, code)
);
CREATE INDEX IF NOT EXISTS idx_courses_university ON courses (university_id);
CREATE INDEX IF NOT EXISTS idx_courses_dept       ON courses (university_id, faculty, department);
CREATE INDEX IF NOT EXISTS idx_courses_search
  ON courses USING gin (to_tsvector('english',
    coalesce(code,'') || ' ' || coalesce(title,'') || ' ' || coalesce(lecturer,'')));

-- ── Academic resources (notes, past questions, slides, …) ─────

CREATE TABLE IF NOT EXISTS academic_resources (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id     UUID                 REFERENCES courses(id)      ON DELETE CASCADE,
  community_id  UUID                 REFERENCES communities(id)  ON DELETE SET NULL,
  university_id UUID                 REFERENCES universities(id) ON DELETE CASCADE,
  uploader_id   UUID                 REFERENCES profiles(id)     ON DELETE SET NULL,

  title         TEXT        NOT NULL,
  description   TEXT,
  faculty       TEXT,
  department    TEXT,
  academic_year TEXT,
  semester      TEXT,
  lecturer      TEXT,

  resource_type TEXT        NOT NULL DEFAULT 'lecture_note' CHECK (resource_type IN (
                  'lecture_note','past_question','assignment','slides',
                  'study_guide','textbook','project','other')),
  file_type     TEXT        NOT NULL DEFAULT 'link' CHECK (file_type IN (
                  'pdf','docx','ppt','pptx','image','link','zip','other')),
  file_url      TEXT,                                 -- uploaded media (storage)
  link_url      TEXT,                                 -- external (Drive, etc.)
  file_size     BIGINT,

  -- Verification ladder
  verification  TEXT        NOT NULL DEFAULT 'student' CHECK (verification IN (
                  'student','course_rep','faculty_admin','official')),

  download_count INTEGER    NOT NULL DEFAULT 0,
  view_count     INTEGER    NOT NULL DEFAULT 0,
  rating         NUMERIC(3,2) NOT NULL DEFAULT 0,
  rating_count   INTEGER    NOT NULL DEFAULT 0,
  is_approved   BOOLEAN     NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_acad_res_course  ON academic_resources (course_id);
CREATE INDEX IF NOT EXISTS idx_acad_res_type    ON academic_resources (resource_type);
CREATE INDEX IF NOT EXISTS idx_acad_res_uni     ON academic_resources (university_id, faculty, department);
CREATE INDEX IF NOT EXISTS idx_acad_res_search
  ON academic_resources USING gin (to_tsvector('english',
    coalesce(title,'') || ' ' || coalesce(description,'') || ' ' || coalesce(lecturer,'')));

-- ── Resource ratings ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS resource_ratings (
  resource_id UUID        NOT NULL REFERENCES academic_resources(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES profiles(id)           ON DELETE CASCADE,
  rating      INTEGER     NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (resource_id, user_id)
);

-- ── Download log (analytics + offline tracking) ───────────────

CREATE TABLE IF NOT EXISTS resource_downloads (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID        NOT NULL REFERENCES academic_resources(id) ON DELETE CASCADE,
  user_id     UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_res_downloads_res ON resource_downloads (resource_id);

-- ── Assignments ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS assignments (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id     UUID                 REFERENCES courses(id)     ON DELETE CASCADE,
  community_id  UUID                 REFERENCES communities(id) ON DELETE SET NULL,
  title         TEXT        NOT NULL,
  description   TEXT,
  link_url      TEXT,                                 -- brief / portal link
  due_at        TIMESTAMPTZ,
  created_by    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_assignments_course ON assignments (course_id, due_at);

CREATE TABLE IF NOT EXISTS assignment_submissions (
  assignment_id UUID        NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  user_id       UUID        NOT NULL REFERENCES profiles(id)    ON DELETE CASCADE,
  link_url      TEXT,
  status        TEXT        NOT NULL DEFAULT 'submitted'
                  CHECK (status IN ('todo','submitted','done')),
  submitted_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (assignment_id, user_id)
);

CREATE TABLE IF NOT EXISTS assignment_reminders (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID        NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  user_id       UUID        NOT NULL REFERENCES profiles(id)    ON DELETE CASCADE,
  remind_at     TIMESTAMPTZ NOT NULL,
  sent          BOOLEAN     NOT NULL DEFAULT false,
  UNIQUE (assignment_id, user_id, remind_at)
);

-- ── Exam preparation center ───────────────────────────────────

CREATE TABLE IF NOT EXISTS exam_schedule (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  university_id UUID                 REFERENCES universities(id) ON DELETE CASCADE,
  course_id     UUID                 REFERENCES courses(id)      ON DELETE SET NULL,
  community_id  UUID                 REFERENCES communities(id)  ON DELETE SET NULL,
  title         TEXT        NOT NULL,
  exam_type     TEXT        NOT NULL DEFAULT 'exam'
                  CHECK (exam_type IN ('quiz','midsem','exam','presentation','other')),
  exam_date     TIMESTAMPTZ,
  venue         TEXT,
  notes         TEXT,
  created_by    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_exam_schedule_date ON exam_schedule (university_id, exam_date);

-- ── GPA records (persisted CGPA across devices) ───────────────

CREATE TABLE IF NOT EXISTS gpa_entries (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  semester    TEXT        NOT NULL,                   -- 'Level 200 · Sem 1'
  course_name TEXT        NOT NULL,
  credits     NUMERIC(4,1) NOT NULL DEFAULT 3,
  grade_point NUMERIC(3,2) NOT NULL,                  -- 4.0 scale
  grade_label TEXT,                                   -- 'A', 'B+', …
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gpa_entries_user ON gpa_entries (user_id, semester);

-- ── Study planner ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS study_plans (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  type        TEXT        NOT NULL DEFAULT 'schedule'
                CHECK (type IN ('schedule','revision','countdown')),
  target_date TIMESTAMPTZ,
  color       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS study_tasks (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id    UUID        NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
  title      TEXT        NOT NULL,
  due_at     TIMESTAMPTZ,
  done       BOOLEAN     NOT NULL DEFAULT false,
  position   INTEGER     NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_study_tasks_plan ON study_tasks (plan_id, position);

-- ── Search analytics ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS academic_searches (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  query      TEXT        NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_acad_searches_q ON academic_searches (lower(query));

-- ============================================================
-- Triggers — counters, ratings, timestamps
-- ============================================================

CREATE OR REPLACE FUNCTION sync_resource_rating()
RETURNS TRIGGER AS $$
DECLARE rid UUID := COALESCE(NEW.resource_id, OLD.resource_id);
BEGIN
  UPDATE academic_resources
     SET rating = COALESCE((SELECT round(avg(rating)::numeric, 2)
                              FROM resource_ratings WHERE resource_id = rid), 0),
         rating_count = (SELECT count(*) FROM resource_ratings WHERE resource_id = rid)
   WHERE id = rid;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_resource_rating ON resource_ratings;
CREATE TRIGGER trg_resource_rating
  AFTER INSERT OR DELETE OR UPDATE ON resource_ratings
  FOR EACH ROW EXECUTE FUNCTION sync_resource_rating();

CREATE OR REPLACE FUNCTION bump_resource_download()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE academic_resources SET download_count = download_count + 1
   WHERE id = NEW.resource_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_resource_download ON resource_downloads;
CREATE TRIGGER trg_resource_download
  AFTER INSERT ON resource_downloads
  FOR EACH ROW EXECUTE FUNCTION bump_resource_download();

CREATE OR REPLACE FUNCTION sync_course_resource_count()
RETURNS TRIGGER AS $$
DECLARE cid UUID := COALESCE(NEW.course_id, OLD.course_id);
BEGIN
  IF cid IS NOT NULL THEN
    UPDATE courses SET resource_count =
      (SELECT count(*) FROM academic_resources WHERE course_id = cid)
     WHERE id = cid;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_course_res_count ON academic_resources;
CREATE TRIGGER trg_course_res_count
  AFTER INSERT OR DELETE ON academic_resources
  FOR EACH ROW EXECUTE FUNCTION sync_course_resource_count();

CREATE OR REPLACE FUNCTION increment_course_view(p_id UUID)
RETURNS void AS $$ UPDATE courses SET view_count = view_count + 1 WHERE id = p_id; $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION increment_resource_view(p_id UUID)
RETURNS void AS $$ UPDATE academic_resources SET view_count = view_count + 1 WHERE id = p_id; $$ LANGUAGE sql;

-- ============================================================
-- Analytics helpers
-- ============================================================

CREATE OR REPLACE FUNCTION top_academic_searches(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (query TEXT, total BIGINT) AS $$
  SELECT lower(query), count(*)::bigint FROM academic_searches
   GROUP BY lower(query) ORDER BY count(*) DESC LIMIT p_limit;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION is_campus_admin()
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid()
                  AND role IN ('admin','superadmin'));
$$ LANGUAGE sql STABLE;

-- Verified leaders (course reps etc.) or admins can elevate verification.
CREATE OR REPLACE FUNCTION is_leader_or_admin()
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid()
                  AND (role IN ('admin','superadmin') OR is_verified_leader = true));
$$ LANGUAGE sql STABLE;

-- ============================================================
-- Row Level Security
-- ============================================================

ALTER TABLE courses                ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_resources     ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_ratings       ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_downloads     ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments            ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_reminders   ENABLE ROW LEVEL SECURITY;
ALTER TABLE exam_schedule          ENABLE ROW LEVEL SECURITY;
ALTER TABLE gpa_entries            ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans            ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_tasks            ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_searches      ENABLE ROW LEVEL SECURITY;

-- Courses: any authenticated reads; any student creates; creator/admin edits
DROP POLICY IF EXISTS courses_select ON courses;
CREATE POLICY courses_select ON courses FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS courses_insert ON courses;
CREATE POLICY courses_insert ON courses FOR INSERT TO authenticated
  WITH CHECK (created_by = auth.uid());
DROP POLICY IF EXISTS courses_update ON courses;
CREATE POLICY courses_update ON courses FOR UPDATE TO authenticated
  USING (created_by = auth.uid() OR is_campus_admin())
  WITH CHECK (created_by = auth.uid() OR is_campus_admin());
DROP POLICY IF EXISTS courses_delete ON courses;
CREATE POLICY courses_delete ON courses FOR DELETE TO authenticated
  USING (created_by = auth.uid() OR is_campus_admin());

-- Resources: read approved (or own); uploader inserts; uploader/admin manage;
-- leaders/admins may set the verification level via update.
DROP POLICY IF EXISTS acad_res_select ON academic_resources;
CREATE POLICY acad_res_select ON academic_resources FOR SELECT TO authenticated
  USING (is_approved = true OR uploader_id = auth.uid() OR is_campus_admin());
DROP POLICY IF EXISTS acad_res_insert ON academic_resources;
CREATE POLICY acad_res_insert ON academic_resources FOR INSERT TO authenticated
  WITH CHECK (uploader_id = auth.uid());
DROP POLICY IF EXISTS acad_res_update ON academic_resources;
CREATE POLICY acad_res_update ON academic_resources FOR UPDATE TO authenticated
  USING (uploader_id = auth.uid() OR is_leader_or_admin())
  WITH CHECK (uploader_id = auth.uid() OR is_leader_or_admin());
DROP POLICY IF EXISTS acad_res_delete ON academic_resources;
CREATE POLICY acad_res_delete ON academic_resources FOR DELETE TO authenticated
  USING (uploader_id = auth.uid() OR is_campus_admin());

-- Ratings: read all; write own
DROP POLICY IF EXISTS res_ratings_select ON resource_ratings;
CREATE POLICY res_ratings_select ON resource_ratings FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS res_ratings_write ON resource_ratings;
CREATE POLICY res_ratings_write ON resource_ratings FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Downloads: insert own; admins read for analytics
DROP POLICY IF EXISTS res_downloads_insert ON resource_downloads;
CREATE POLICY res_downloads_insert ON resource_downloads FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
DROP POLICY IF EXISTS res_downloads_admin ON resource_downloads;
CREATE POLICY res_downloads_admin ON resource_downloads FOR SELECT TO authenticated
  USING (is_campus_admin());

-- Assignments: read all; creator/admin manage
DROP POLICY IF EXISTS assignments_select ON assignments;
CREATE POLICY assignments_select ON assignments FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS assignments_write ON assignments;
CREATE POLICY assignments_write ON assignments FOR ALL TO authenticated
  USING (created_by = auth.uid() OR is_leader_or_admin())
  WITH CHECK (created_by = auth.uid() OR is_leader_or_admin());

-- Submissions / reminders / gpa / plans / tasks: own rows
DROP POLICY IF EXISTS assignment_subs_write ON assignment_submissions;
CREATE POLICY assignment_subs_write ON assignment_submissions FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS assignment_rem_write ON assignment_reminders;
CREATE POLICY assignment_rem_write ON assignment_reminders FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS exam_select ON exam_schedule;
CREATE POLICY exam_select ON exam_schedule FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS exam_write ON exam_schedule;
CREATE POLICY exam_write ON exam_schedule FOR ALL TO authenticated
  USING (created_by = auth.uid() OR is_leader_or_admin())
  WITH CHECK (created_by = auth.uid() OR is_leader_or_admin());

DROP POLICY IF EXISTS gpa_write ON gpa_entries;
CREATE POLICY gpa_write ON gpa_entries FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS study_plans_write ON study_plans;
CREATE POLICY study_plans_write ON study_plans FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS study_tasks_write ON study_tasks;
CREATE POLICY study_tasks_write ON study_tasks FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM study_plans p WHERE p.id = plan_id AND p.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM study_plans p WHERE p.id = plan_id AND p.user_id = auth.uid()));

DROP POLICY IF EXISTS acad_searches_insert ON academic_searches;
CREATE POLICY acad_searches_insert ON academic_searches FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
DROP POLICY IF EXISTS acad_searches_admin ON academic_searches;
CREATE POLICY acad_searches_admin ON academic_searches FOR SELECT TO authenticated
  USING (is_campus_admin());

-- ============================================================
-- Storage bucket for academic files
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('academic', 'academic', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "academic media read" ON storage.objects;
CREATE POLICY "academic media read" ON storage.objects
  FOR SELECT TO public USING (bucket_id = 'academic');

DROP POLICY IF EXISTS "academic media write" ON storage.objects;
CREATE POLICY "academic media write" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'academic');
