-- UNIFY Academic Hub
-- step13: courses, resources, assignments, GPA, study plans, ratings, search, analytics

-- ─── Courses ─────────────────────────────────────────────────────
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  credits INTEGER NOT NULL DEFAULT 3,
  university TEXT,
  faculty TEXT,
  department TEXT,
  level TEXT,
  semester TEXT,
  lecturer_name TEXT,
  lecturer_id UUID REFERENCES users(id) ON DELETE SET NULL,
  community_id UUID REFERENCES communities(id) ON DELETE SET NULL,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(code, university, faculty, department)
);

-- ─── Academic Resources (notes, past questions, study guides) ─────
CREATE TABLE academic_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('note', 'past_question', 'study_guide', 'flashcard', 'summary', 'other')),
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL CHECK (file_type IN ('pdf', 'docx', 'ppt', 'pptx', 'image', 'video', 'audio', 'link')),
  file_size BIGINT,
  thumbnail_url TEXT,
  university TEXT,
  faculty TEXT,
  department TEXT,
  academic_year TEXT,
  semester TEXT,
  lecturer TEXT,
  uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  verification_status TEXT DEFAULT 'student_uploaded' CHECK (verification_status IN ('student_uploaded', 'verified_course_rep', 'verified_faculty_admin', 'official')),
  verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
  verified_at TIMESTAMPTZ,
  download_count INTEGER DEFAULT 0,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Assignments ─────────────────────────────────────────────────
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMPTZ NOT NULL,
  max_score REAL,
  submission_type TEXT DEFAULT 'link' CHECK (submission_type IN ('link', 'file', 'text', 'none')),
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  submission_url TEXT,
  submission_text TEXT,
  submission_file_url TEXT,
  score REAL,
  feedback TEXT,
  graded_by UUID REFERENCES users(id) ON DELETE SET NULL,
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  graded_at TIMESTAMPTZ,
  UNIQUE(assignment_id, user_id)
);

-- ─── GPA Calculator ──────────────────────────────────────────────
CREATE TABLE gpa_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  semester TEXT NOT NULL,
  academic_year TEXT,
  gpa REAL NOT NULL,
  total_credits INTEGER NOT NULL,
  total_grade_points REAL NOT NULL,
  is_cgpa BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE gpa_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gpa_record_id UUID NOT NULL REFERENCES gpa_records(id) ON DELETE CASCADE,
  course_name TEXT NOT NULL,
  course_code TEXT,
  credits INTEGER NOT NULL,
  grade TEXT NOT NULL,
  grade_point REAL NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Study Planner ───────────────────────────────────────────────
CREATE TABLE study_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  start_date DATE,
  end_date DATE,
  exam_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE study_plan_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  scheduled_date DATE,
  scheduled_time TIME,
  duration_minutes INTEGER,
  is_completed BOOLEAN DEFAULT FALSE,
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Resource Ratings ────────────────────────────────────────────
CREATE TABLE resource_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES academic_resources(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(resource_id, user_id)
);

-- ─── Resource Downloads (analytics) ──────────────────────────────
CREATE TABLE resource_downloads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id UUID NOT NULL REFERENCES academic_resources(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  downloaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Exam Timetables ─────────────────────────────────────────────
CREATE TABLE exam_timetables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  exam_date DATE NOT NULL,
  exam_time TIME,
  venue TEXT,
  duration_minutes INTEGER,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(course_id, exam_date)
);

-- ─── Indexes ─────────────────────────────────────────────────────
CREATE INDEX idx_academic_resources_course ON academic_resources(course_id);
CREATE INDEX idx_academic_resources_type ON academic_resources(type);
CREATE INDEX idx_academic_resources_verification ON academic_resources(verification_status);
CREATE INDEX idx_academic_resources_downloads ON academic_resources(download_count DESC);
CREATE INDEX idx_assignments_course ON assignments(course_id, due_date);
CREATE INDEX idx_assignments_due ON assignments(due_date);
CREATE INDEX idx_submissions_user ON assignment_submissions(user_id);
CREATE INDEX idx_gpa_user ON gpa_records(user_id);
CREATE INDEX idx_study_plans_user ON study_plans(user_id);
CREATE INDEX idx_study_plan_items_plan ON study_plan_items(plan_id, scheduled_date);
CREATE INDEX idx_resource_ratings_resource ON resource_ratings(resource_id);
CREATE INDEX idx_courses_code ON courses(code);
CREATE INDEX idx_courses_department ON courses(department);
CREATE INDEX idx_exam_timetables_course ON exam_timetables(course_id);
CREATE INDEX idx_resources_search ON academic_resources USING gin(to_tsvector('english', title || ' ' || coalesce(description, '')));
CREATE INDEX idx_courses_search ON courses USING gin(to_tsvector('english', name || ' ' || code));

-- ─── RLS ────────────────────────────────────────────────
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gpa_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE gpa_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plan_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE exam_timetables ENABLE ROW LEVEL SECURITY;

CREATE POLICY courses_select ON courses FOR SELECT USING (true);
CREATE POLICY courses_insert ON courses FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY resources_select ON academic_resources FOR SELECT USING (true);
CREATE POLICY resources_insert ON academic_resources FOR INSERT WITH CHECK (uploaded_by = auth.uid());
CREATE POLICY resources_update ON academic_resources FOR UPDATE USING (uploaded_by = auth.uid() OR EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin', 'course_rep', 'faculty_admin')));

CREATE POLICY assignments_select ON assignments FOR SELECT USING (true);
CREATE POLICY assignments_insert ON assignments FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY submissions_select ON assignment_submissions FOR SELECT USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM assignments WHERE id = assignment_id AND created_by = auth.uid()));
CREATE POLICY submissions_insert ON assignment_submissions FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY gpa_select ON gpa_records FOR SELECT USING (user_id = auth.uid());
CREATE POLICY gpa_insert ON gpa_records FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY gpa_update ON gpa_records FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY gpa_delete ON gpa_records FOR DELETE USING (user_id = auth.uid());

CREATE POLICY plans_select ON study_plans FOR SELECT USING (user_id = auth.uid());
CREATE POLICY plans_insert ON study_plans FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY plans_update ON study_plans FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY plans_delete ON study_plans FOR DELETE USING (user_id = auth.uid());

CREATE POLICY ratings_select ON resource_ratings FOR SELECT USING (true);
CREATE POLICY ratings_insert ON resource_ratings FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY downloads_insert ON resource_downloads FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY exam_timetables_select ON exam_timetables FOR SELECT USING (true);
