-- ============================================
-- UNIFY DATABASE SCHEMA (Ghanaian ZeeMee)
-- ============================================

-- 1. UNIVERSITIES TABLE
CREATE TABLE universities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    shortcode TEXT UNIQUE,
    location TEXT NOT NULL,
    domain_pattern TEXT,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. STUDENTS TABLE
CREATE TABLE students (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    university_id UUID REFERENCES universities(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    photo_url TEXT,
    bio TEXT,
    level_of_study TEXT,
    department TEXT,
    student_id_number TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_code TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- 3. ROOMMATE QUIZ TABLE (ZeeMee's 10-question quiz)
CREATE TABLE roommate_quiz (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,

    -- Cleanliness (1-5)
    cleanliness_level INTEGER CHECK (cleanliness_level BETWEEN 1 AND 5),

    -- Study habits
    study_habits TEXT CHECK (study_habits IN ('quiet', 'background_music', 'group_study', 'any')),

    -- Sleep schedule
    sleep_schedule TEXT CHECK (sleep_schedule IN ('early_bird', 'night_owl', 'flexible')),
    wake_up_time TEXT,
    bed_time TEXT,

    -- Social preference
    social_preference TEXT CHECK (social_preference IN ('very_social', 'moderately_social', 'quiet', 'vary')),
    hang_out_in_room BOOLEAN DEFAULT FALSE,

    -- Noise tolerance
    noise_tolerance TEXT CHECK (noise_tolerance IN ('very_quiet', 'moderate', 'loud_music_ok', 'any')),

    -- Budget (GHS)
    budget_range TEXT CHECK (budget_range IN ('budget', 'moderate', 'luxury')),
    monthly_rent_budget INTEGER,

    -- Pets
    pet_preference TEXT CHECK (pet_preference IN ('love_pets', 'ok_with_pets', 'no_pets', 'have_pets')),
    have_allergy_to_pets BOOLEAN DEFAULT FALSE,

    -- Smoking/Drinking
    smoking_preference TEXT CHECK (smoking_preference IN ('never', 'occasionally', 'regularly')),
    drinking_preference TEXT CHECK (drinking_preference IN ('never', 'occasionally', 'regularly')),

    -- Sharing
    sharing_food BOOLEAN DEFAULT FALSE,
    sharing_utilities BOOLEAN DEFAULT TRUE,

    -- Gender preference
    gender_preference TEXT CHECK (gender_preference IN ('any', 'same_gender', 'specific')),
    preferred_gender TEXT CHECK (preferred_gender IN ('male', 'female', 'other')),

    -- AC preference
    ac_preference TEXT CHECK (ac_preference IN ('need_ac', 'fan_ok', 'no_preference')),
    internet_importance INTEGER CHECK (internet_importance BETWEEN 1 AND 5),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX unique_student_quiz ON roommate_quiz(student_id);
ALTER TABLE roommate_quiz ENABLE ROW LEVEL SECURITY;

-- 4. HOUSING LISTINGS TABLE
CREATE TABLE housing_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id),
    university_id UUID REFERENCES universities(id),

    location TEXT NOT NULL,
    distance_to_campus TEXT,

    housing_type TEXT CHECK (housing_type IN ('hostel', 'private_room', 'shared_apartment', 'bungalow', 'studio')),
    room_type TEXT CHECK (room_type IN ('single', 'double', 'triple')),

    rent_amount INTEGER NOT NULL,
    utilities_included BOOLEAN DEFAULT FALSE,
    utilities_cost INTEGER,

    has_ac BOOLEAN DEFAULT FALSE,
    has_fan BOOLEAN DEFAULT TRUE,
    has_wifi BOOLEAN DEFAULT FALSE,
    has_water_storage BOOLEAN DEFAULT TRUE,
    has_security BOOLEAN DEFAULT TRUE,
    has_parking BOOLEAN DEFAULT FALSE,

    available_from DATE,
    spots_available INTEGER DEFAULT 1,

    photo_urls TEXT[],
    description TEXT,

    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE housing_listings ENABLE ROW LEVEL SECURITY;

-- 5. MATCHES TABLE
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id),
    matched_student_id UUID REFERENCES students(id),

    compatibility_score INTEGER CHECK (compatibility_score BETWEEN 0 AND 100),

    cleanliness_match BOOLEAN,
    schedule_match BOOLEAN,
    budget_match BOOLEAN,
    style_match BOOLEAN,

    status TEXT CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX unique_match_pair ON matches(student_id, matched_student_id);
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- 6. CHATS TABLE
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(id),
    student_id UUID REFERENCES students(id),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- 7. VERIFICATION REQUESTS TABLE
CREATE TABLE verification_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID REFERENCES students(id),
    verification_code TEXT NOT NULL,
    university_email TEXT NOT NULL,
    student_id_photo_url TEXT,
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;

-- ============================================
-- INSERT GHANAIAN UNIVERSITIES
-- ============================================

INSERT INTO universities (name, shortcode, location, domain_pattern) VALUES
    ('University of Ghana', 'ug', 'Accra', 'ug.edu.gh'),
    ('Kwame Nkrumah University of Science and Technology', 'knust', 'Kumasi', 'knust.edu.gh'),
    ('University of Cape Coast', 'ucc', 'Cape Coast', 'ucc.edu.gh'),
    ('University for Development Studies', 'uds', 'Tamale', 'uds.edu.gh'),
    ('Ashesi University', 'ashesi', 'Berekuso', 'ashesi.org'),
    ('Ghana Communication Technology University', 'gctu', 'Accra', 'gctu.edu.gh'),
    ('Central University', 'central', 'Accra', 'central.edu.gh'),
    ('Christian Service University', 'csu', 'Kumasi', 'csu.edu.gh');

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Students can view/update their own profile
CREATE POLICY "Students can view own profile" ON students
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Students can update own profile" ON students
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Students can insert own profile" ON students
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Quiz policies
CREATE POLICY "Students can view own quiz" ON roommate_quiz
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Students can update own quiz" ON roommate_quiz
    FOR UPDATE USING (student_id = auth.uid());

CREATE POLICY "Students can insert own quiz" ON roommate_quiz
    FOR INSERT WITH CHECK (student_id = auth.uid());

-- Housing: Anyone can view active listings
CREATE POLICY "Anyone can view active listings" ON housing_listings
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Students can manage own listings" ON housing_listings
    FOR ALL USING (student_id = auth.uid());

-- Matches: Students can view their own matches
CREATE POLICY "Students can view own matches" ON matches
    FOR SELECT USING (student_id = auth.uid() OR matched_student_id = auth.uid());

-- ============================================
-- PERFORMANCE INDEXES
-- ============================================

CREATE INDEX idx_students_university ON students(university_id);
CREATE INDEX idx_students_is_verified ON students(is_verified);
CREATE INDEX idx_listings_university ON housing_listings(university_id);
CREATE INDEX idx_matches_student ON matches(student_id);
