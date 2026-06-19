-- ============================================================
-- STEP 10 — UNIFY Campus Marketplace
-- ============================================================
-- A student-only, university-verified marketplace covering:
--   buy_sell · hostel · academic · service · roommate ·
--   lost_found · job · internship · ticket
--
-- All listings are tied to a verified student identity. Includes
-- freelancer profiles, reviews & ratings, saved listings (wishlist),
-- reporting / moderation, and search analytics.
-- ============================================================

-- ── Listings ──────────────────────────────────────────────────
-- One flexible table for every marketplace category. Common,
-- frequently-filtered fields are promoted to columns; category-
-- specific fields live in `details` JSONB.

CREATE TABLE IF NOT EXISTS marketplace_listings (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id     UUID        NOT NULL REFERENCES profiles(id)     ON DELETE CASCADE,
  university_id UUID                 REFERENCES universities(id) ON DELETE SET NULL,

  category      TEXT        NOT NULL CHECK (category IN (
                  'buy_sell','hostel','academic','service','roommate',
                  'lost_found','job','internship','ticket')),
  subcategory   TEXT,                                  -- e.g. 'laptop', 'graphic_design'

  title         TEXT        NOT NULL,
  description   TEXT,

  price         NUMERIC(12,2),                         -- null = free / N/A
  price_type    TEXT        NOT NULL DEFAULT 'fixed'
                  CHECK (price_type IN ('fixed','hourly','quote','free','swap')),
  is_negotiable BOOLEAN     NOT NULL DEFAULT false,
  currency      TEXT        NOT NULL DEFAULT 'GHS',

  condition     TEXT        CHECK (condition IN ('new','like_new','good','fair','for_parts')),
  location      TEXT,

  status        TEXT        NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active','pending','sold','fulfilled','expired','removed')),
  moderation    TEXT        NOT NULL DEFAULT 'approved'
                  CHECK (moderation IN ('approved','pending','rejected')),

  is_featured   BOOLEAN     NOT NULL DEFAULT false,
  view_count    INTEGER     NOT NULL DEFAULT 0,
  save_count    INTEGER     NOT NULL DEFAULT 0,

  details       JSONB       NOT NULL DEFAULT '{}'::jsonb,  -- category-specific fields

  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at    TIMESTAMPTZ                                -- null = never
);

CREATE INDEX IF NOT EXISTS idx_mkt_listings_category   ON marketplace_listings (category, status);
CREATE INDEX IF NOT EXISTS idx_mkt_listings_university ON marketplace_listings (university_id);
CREATE INDEX IF NOT EXISTS idx_mkt_listings_seller     ON marketplace_listings (seller_id);
CREATE INDEX IF NOT EXISTS idx_mkt_listings_active     ON marketplace_listings (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mkt_listings_featured   ON marketplace_listings (is_featured) WHERE is_featured = true;
-- Full-text search over title + description
CREATE INDEX IF NOT EXISTS idx_mkt_listings_search
  ON marketplace_listings
  USING gin (to_tsvector('english', coalesce(title,'') || ' ' || coalesce(description,'')));

-- ── Listing images ────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS listing_images (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id  UUID        NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  url         TEXT        NOT NULL,
  position    INTEGER     NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_listing_images_listing ON listing_images (listing_id, position);

-- ── Freelancer / service profiles (mini Fiverr) ───────────────

CREATE TABLE IF NOT EXISTS freelancer_profiles (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID        NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  headline       TEXT,                                 -- "Graphic Designer & Brand Strategist"
  bio            TEXT,
  skills         TEXT[]      NOT NULL DEFAULT '{}',
  categories     TEXT[]      NOT NULL DEFAULT '{}',    -- service categories offered
  hourly_rate    NUMERIC(12,2),
  portfolio_urls TEXT[]      NOT NULL DEFAULT '{}',
  is_available   BOOLEAN     NOT NULL DEFAULT true,
  rating         NUMERIC(3,2) NOT NULL DEFAULT 0,      -- cached average
  review_count   INTEGER     NOT NULL DEFAULT 0,
  completed_jobs INTEGER     NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_freelancer_available ON freelancer_profiles (is_available, rating DESC);

-- ── Reviews & ratings (seller / buyer / freelancer) ───────────

CREATE TABLE IF NOT EXISTS marketplace_reviews (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id  UUID                 REFERENCES marketplace_listings(id) ON DELETE SET NULL,
  reviewee_id UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reviewer_id UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role        TEXT        NOT NULL DEFAULT 'seller'
                CHECK (role IN ('seller','buyer','freelancer')),
  rating      INTEGER     NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (reviewer_id, reviewee_id, listing_id)        -- one review per txn
);
CREATE INDEX IF NOT EXISTS idx_mkt_reviews_reviewee ON marketplace_reviews (reviewee_id);

-- ── Saved listings (wishlist) ─────────────────────────────────

CREATE TABLE IF NOT EXISTS saved_listings (
  user_id    UUID        NOT NULL REFERENCES profiles(id)             ON DELETE CASCADE,
  listing_id UUID        NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, listing_id)
);

-- ── Reports / moderation queue ────────────────────────────────

CREATE TABLE IF NOT EXISTS listing_reports (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id  UUID        NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  reporter_id UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason      TEXT        NOT NULL,
  details     TEXT,
  status      TEXT        NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','reviewed','dismissed','actioned')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_listing_reports_status ON listing_reports (status, created_at);

-- ── Search analytics ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS marketplace_searches (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID                 REFERENCES profiles(id) ON DELETE SET NULL,
  query      TEXT        NOT NULL,
  category   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_mkt_searches_query ON marketplace_searches (lower(query));

-- ============================================================
-- Triggers — keep counters and cached ratings in sync
-- ============================================================

-- Save count
CREATE OR REPLACE FUNCTION sync_listing_save_count()
RETURNS TRIGGER AS $$
DECLARE
  lid UUID := COALESCE(NEW.listing_id, OLD.listing_id);
BEGIN
  UPDATE marketplace_listings
     SET save_count = (SELECT count(*) FROM saved_listings WHERE listing_id = lid)
   WHERE id = lid;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_listing_save_count ON saved_listings;
CREATE TRIGGER trg_listing_save_count
  AFTER INSERT OR DELETE ON saved_listings
  FOR EACH ROW EXECUTE FUNCTION sync_listing_save_count();

-- Freelancer rating aggregation
CREATE OR REPLACE FUNCTION sync_freelancer_rating()
RETURNS TRIGGER AS $$
DECLARE
  uid UUID := COALESCE(NEW.reviewee_id, OLD.reviewee_id);
BEGIN
  UPDATE freelancer_profiles
     SET rating = COALESCE((SELECT round(avg(rating)::numeric, 2)
                              FROM marketplace_reviews
                             WHERE reviewee_id = uid), 0),
         review_count = (SELECT count(*) FROM marketplace_reviews WHERE reviewee_id = uid)
   WHERE user_id = uid;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_freelancer_rating ON marketplace_reviews;
CREATE TRIGGER trg_freelancer_rating
  AFTER INSERT OR DELETE OR UPDATE ON marketplace_reviews
  FOR EACH ROW EXECUTE FUNCTION sync_freelancer_rating();

-- Touch updated_at on listing edits
CREATE OR REPLACE FUNCTION touch_listing_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_listing_touch ON marketplace_listings;
CREATE TRIGGER trg_listing_touch
  BEFORE UPDATE ON marketplace_listings
  FOR EACH ROW EXECUTE FUNCTION touch_listing_updated_at();

-- Atomic view increment (called via RPC to avoid read-modify-write races)
CREATE OR REPLACE FUNCTION increment_listing_view(p_listing_id UUID)
RETURNS void AS $$
  UPDATE marketplace_listings SET view_count = view_count + 1 WHERE id = p_listing_id;
$$ LANGUAGE sql;

-- Aggregate seller rating for any profile (used in listing/profile views)
CREATE OR REPLACE FUNCTION seller_rating(p_user_id UUID)
RETURNS TABLE (avg_rating NUMERIC, total INTEGER) AS $$
  SELECT COALESCE(round(avg(rating)::numeric, 2), 0)::numeric,
         count(*)::integer
    FROM marketplace_reviews
   WHERE reviewee_id = p_user_id;
$$ LANGUAGE sql STABLE;

-- ============================================================
-- Fraud prevention helper — only verified, active students post
-- ============================================================
CREATE OR REPLACE FUNCTION is_verified_student(p_user_id UUID)
RETURNS boolean AS $$
  SELECT COALESCE(
    (SELECT is_verified AND is_active FROM profiles WHERE id = p_user_id),
    false);
$$ LANGUAGE sql STABLE;

-- ============================================================
-- Row Level Security
-- ============================================================

ALTER TABLE marketplace_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_images       ENABLE ROW LEVEL SECURITY;
ALTER TABLE freelancer_profiles  ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplace_reviews  ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_listings       ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_reports      ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketplace_searches ENABLE ROW LEVEL SECURITY;

-- Listings: everyone authenticated reads approved+active listings (or own);
-- only VERIFIED students may insert; sellers manage their own rows.
DROP POLICY IF EXISTS mkt_listings_select ON marketplace_listings;
CREATE POLICY mkt_listings_select ON marketplace_listings
  FOR SELECT TO authenticated
  USING (
    (moderation = 'approved' AND status NOT IN ('removed'))
    OR seller_id = auth.uid()
  );

DROP POLICY IF EXISTS mkt_listings_insert ON marketplace_listings;
CREATE POLICY mkt_listings_insert ON marketplace_listings
  FOR INSERT TO authenticated
  WITH CHECK (seller_id = auth.uid() AND is_verified_student(auth.uid()));

DROP POLICY IF EXISTS mkt_listings_update ON marketplace_listings;
CREATE POLICY mkt_listings_update ON marketplace_listings
  FOR UPDATE TO authenticated
  USING (seller_id = auth.uid())
  WITH CHECK (seller_id = auth.uid());

DROP POLICY IF EXISTS mkt_listings_delete ON marketplace_listings;
CREATE POLICY mkt_listings_delete ON marketplace_listings
  FOR DELETE TO authenticated
  USING (seller_id = auth.uid());

-- Listing images
DROP POLICY IF EXISTS listing_images_select ON listing_images;
CREATE POLICY listing_images_select ON listing_images
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS listing_images_write ON listing_images;
CREATE POLICY listing_images_write ON listing_images
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM marketplace_listings l
                  WHERE l.id = listing_id AND l.seller_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM marketplace_listings l
                       WHERE l.id = listing_id AND l.seller_id = auth.uid()));

-- Freelancer profiles
DROP POLICY IF EXISTS freelancer_select ON freelancer_profiles;
CREATE POLICY freelancer_select ON freelancer_profiles
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS freelancer_write ON freelancer_profiles;
CREATE POLICY freelancer_write ON freelancer_profiles
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid() AND is_verified_student(auth.uid()));

-- Reviews
DROP POLICY IF EXISTS mkt_reviews_select ON marketplace_reviews;
CREATE POLICY mkt_reviews_select ON marketplace_reviews
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS mkt_reviews_insert ON marketplace_reviews;
CREATE POLICY mkt_reviews_insert ON marketplace_reviews
  FOR INSERT TO authenticated
  WITH CHECK (reviewer_id = auth.uid() AND reviewer_id <> reviewee_id);

DROP POLICY IF EXISTS mkt_reviews_update ON marketplace_reviews;
CREATE POLICY mkt_reviews_update ON marketplace_reviews
  FOR UPDATE TO authenticated
  USING (reviewer_id = auth.uid())
  WITH CHECK (reviewer_id = auth.uid());

DROP POLICY IF EXISTS mkt_reviews_delete ON marketplace_reviews;
CREATE POLICY mkt_reviews_delete ON marketplace_reviews
  FOR DELETE TO authenticated
  USING (reviewer_id = auth.uid());

-- Saved listings
DROP POLICY IF EXISTS saved_listings_write ON saved_listings;
CREATE POLICY saved_listings_write ON saved_listings
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Reports
DROP POLICY IF EXISTS listing_reports_insert ON listing_reports;
CREATE POLICY listing_reports_insert ON listing_reports
  FOR INSERT TO authenticated
  WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS listing_reports_select ON listing_reports;
CREATE POLICY listing_reports_select ON listing_reports
  FOR SELECT TO authenticated
  USING (reporter_id = auth.uid());

-- Search analytics: insert own searches
DROP POLICY IF EXISTS mkt_searches_insert ON marketplace_searches;
CREATE POLICY mkt_searches_insert ON marketplace_searches
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

-- ============================================================
-- Admin moderation — campus admins manage their university's
-- listings, reports and freelancer profiles.
-- ============================================================

CREATE OR REPLACE FUNCTION is_campus_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
     WHERE id = auth.uid()
       AND role IN ('admin','superadmin')
  );
$$ LANGUAGE sql STABLE;

-- Admins can see and moderate any listing
DROP POLICY IF EXISTS mkt_listings_admin_select ON marketplace_listings;
CREATE POLICY mkt_listings_admin_select ON marketplace_listings
  FOR SELECT TO authenticated
  USING (is_campus_admin());

DROP POLICY IF EXISTS mkt_listings_admin_update ON marketplace_listings;
CREATE POLICY mkt_listings_admin_update ON marketplace_listings
  FOR UPDATE TO authenticated
  USING (is_campus_admin())
  WITH CHECK (is_campus_admin());

-- Admins read & action the report queue
DROP POLICY IF EXISTS listing_reports_admin_select ON listing_reports;
CREATE POLICY listing_reports_admin_select ON listing_reports
  FOR SELECT TO authenticated
  USING (is_campus_admin());

DROP POLICY IF EXISTS listing_reports_admin_update ON listing_reports;
CREATE POLICY listing_reports_admin_update ON listing_reports
  FOR UPDATE TO authenticated
  USING (is_campus_admin())
  WITH CHECK (is_campus_admin());

-- Admins can read all searches (analytics)
DROP POLICY IF EXISTS mkt_searches_admin_select ON marketplace_searches;
CREATE POLICY mkt_searches_admin_select ON marketplace_searches
  FOR SELECT TO authenticated
  USING (is_campus_admin());

-- ============================================================
-- Analytics helpers (admin dashboard)
-- ============================================================

-- Listing counts grouped by category
CREATE OR REPLACE FUNCTION marketplace_category_counts()
RETURNS TABLE (category TEXT, total BIGINT) AS $$
  SELECT category, count(*)::bigint
    FROM marketplace_listings
   WHERE status = 'active'
   GROUP BY category
   ORDER BY count(*) DESC;
$$ LANGUAGE sql STABLE;

-- Top search terms
CREATE OR REPLACE FUNCTION top_marketplace_searches(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (query TEXT, total BIGINT) AS $$
  SELECT lower(query) AS query, count(*)::bigint
    FROM marketplace_searches
   GROUP BY lower(query)
   ORDER BY count(*) DESC
   LIMIT p_limit;
$$ LANGUAGE sql STABLE;

-- ============================================================
-- Storage bucket for listing images
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('listings', 'listings', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "listing media read" ON storage.objects;
CREATE POLICY "listing media read" ON storage.objects
  FOR SELECT TO public USING (bucket_id = 'listings');

DROP POLICY IF EXISTS "listing media write" ON storage.objects;
CREATE POLICY "listing media write" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'listings');

DROP POLICY IF EXISTS "listing media delete" ON storage.objects;
CREATE POLICY "listing media delete" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id = 'listings');
