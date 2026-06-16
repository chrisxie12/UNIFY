-- ============================================================
-- UNIFY — STEP 7: COMMUNITY CONTENT (POSTS, COMMENTS, RESOURCES)
-- ============================================================
-- Adds:
--   1. community_id column on announcements
--   2. community_posts   (discussion threads)
--   3. community_comments (nested replies)
--   4. community_reactions (likes on posts + comments)
--   5. community_resources (file uploads)
--   6. Auto member_count trigger on community_members
--   7. Comment/reaction count triggers
--   8. RLS policies, indexes
-- ============================================================

-- ── 1. Link announcements to communities ────────────────────
ALTER TABLE announcements
  ADD COLUMN IF NOT EXISTS community_id UUID REFERENCES communities(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_announcements_community ON announcements(community_id);

-- ── 2. COMMUNITY POSTS (discussion threads) ─────────────────
CREATE TABLE community_posts (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id   UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  author_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title          TEXT,
  body           TEXT NOT NULL,
  is_pinned      BOOLEAN NOT NULL DEFAULT FALSE,
  reaction_count INTEGER NOT NULL DEFAULT 0,
  comment_count  INTEGER NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER community_posts_updated_at
  BEFORE UPDATE ON community_posts
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── 3. COMMUNITY COMMENTS (nested replies) ──────────────────
CREATE TABLE community_comments (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id        UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  parent_id      UUID REFERENCES community_comments(id) ON DELETE CASCADE,
  author_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  body           TEXT NOT NULL,
  reaction_count INTEGER NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER community_comments_updated_at
  BEFORE UPDATE ON community_comments
  FOR EACH ROW EXECUTE PROCEDURE handle_updated_at();

-- ── 4. COMMUNITY REACTIONS ──────────────────────────────────
CREATE TABLE community_reactions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id     UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  comment_id  UUID REFERENCES community_comments(id) ON DELETE CASCADE,
  type        TEXT NOT NULL DEFAULT 'like'
                CHECK (type IN ('like','love','fire','clap')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, post_id),
  UNIQUE (user_id, comment_id),
  CHECK ((post_id IS NULL) != (comment_id IS NULL))  -- exactly one must be set
);

-- ── 5. COMMUNITY RESOURCES ──────────────────────────────────
CREATE TABLE community_resources (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id   UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  uploader_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title          TEXT NOT NULL,
  description    TEXT,
  file_url       TEXT NOT NULL,
  file_type      TEXT NOT NULL,  -- pdf, docx, ppt, image, zip, other
  file_size      BIGINT,
  download_count INTEGER NOT NULL DEFAULT 0,
  category       TEXT NOT NULL DEFAULT 'general'
                   CHECK (category IN (
                     'lecture_notes','past_questions','assignments',
                     'projects','general'
                   )),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE community_posts      ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_comments   ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_reactions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_resources  ENABLE ROW LEVEL SECURITY;

-- ── community_posts ──────────────────────────────────────────
CREATE POLICY "posts_member_read" ON community_posts FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members
    WHERE community_id = community_posts.community_id AND user_id = auth.uid())
);
CREATE POLICY "posts_member_insert" ON community_posts FOR INSERT WITH CHECK (
  auth.uid() = author_id AND
  EXISTS (SELECT 1 FROM community_members
    WHERE community_id = community_posts.community_id AND user_id = auth.uid())
);
CREATE POLICY "posts_own_update" ON community_posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "posts_own_delete" ON community_posts FOR DELETE USING (auth.uid() = author_id);
CREATE POLICY "posts_mod_all" ON community_posts FOR ALL USING (
  EXISTS (SELECT 1 FROM community_members
    WHERE community_id = community_posts.community_id
      AND user_id = auth.uid()
      AND role IN ('owner','moderator'))
);
CREATE POLICY "posts_admin_all" ON community_posts FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ── community_comments ───────────────────────────────────────
CREATE POLICY "comments_member_read" ON community_comments FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM community_members cm
    JOIN community_posts cp ON cp.id = community_comments.post_id
    WHERE cm.community_id = cp.community_id AND cm.user_id = auth.uid()
  )
);
CREATE POLICY "comments_member_insert" ON community_comments FOR INSERT WITH CHECK (
  auth.uid() = author_id
);
CREATE POLICY "comments_own_delete" ON community_comments FOR DELETE USING (auth.uid() = author_id);
CREATE POLICY "comments_admin_all" ON community_comments FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin','superadmin'))
);

-- ── community_reactions ──────────────────────────────────────
CREATE POLICY "reactions_read"    ON community_reactions FOR SELECT USING (TRUE);
CREATE POLICY "reactions_own_all" ON community_reactions FOR ALL   USING (auth.uid() = user_id);

-- ── community_resources ──────────────────────────────────────
CREATE POLICY "resources_member_read" ON community_resources FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members
    WHERE community_id = community_resources.community_id AND user_id = auth.uid())
);
CREATE POLICY "resources_member_insert" ON community_resources FOR INSERT WITH CHECK (
  auth.uid() = uploader_id AND
  EXISTS (SELECT 1 FROM community_members
    WHERE community_id = community_resources.community_id AND user_id = auth.uid())
);
CREATE POLICY "resources_own_delete" ON community_resources FOR DELETE USING (auth.uid() = uploader_id);
CREATE POLICY "resources_mod_all" ON community_resources FOR ALL USING (
  EXISTS (SELECT 1 FROM community_members
    WHERE community_id = community_resources.community_id
      AND user_id = auth.uid()
      AND role IN ('owner','moderator'))
);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Auto-update communities.member_count
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE communities SET member_count = member_count + 1 WHERE id = NEW.community_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE communities SET member_count = GREATEST(0, member_count - 1) WHERE id = OLD.community_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER community_member_count_trigger
  AFTER INSERT OR DELETE ON community_members
  FOR EACH ROW EXECUTE PROCEDURE update_community_member_count();

-- Auto-update post.comment_count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_posts SET comment_count = GREATEST(0, comment_count - 1) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER community_comment_count_trigger
  AFTER INSERT OR DELETE ON community_comments
  FOR EACH ROW EXECUTE PROCEDURE update_post_comment_count();

-- Auto-update post/comment reaction_count
CREATE OR REPLACE FUNCTION update_reaction_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.post_id IS NOT NULL THEN
      UPDATE community_posts    SET reaction_count = reaction_count + 1 WHERE id = NEW.post_id;
    ELSE
      UPDATE community_comments SET reaction_count = reaction_count + 1 WHERE id = NEW.comment_id;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.post_id IS NOT NULL THEN
      UPDATE community_posts    SET reaction_count = GREATEST(0, reaction_count - 1) WHERE id = OLD.post_id;
    ELSE
      UPDATE community_comments SET reaction_count = GREATEST(0, reaction_count - 1) WHERE id = OLD.comment_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER community_reaction_count_trigger
  AFTER INSERT OR DELETE ON community_reactions
  FOR EACH ROW EXECUTE PROCEDURE update_reaction_count();

-- Resource download counter (callable from client)
CREATE OR REPLACE FUNCTION increment_resource_downloads(rid UUID)
RETURNS void AS $$
  UPDATE community_resources SET download_count = download_count + 1 WHERE id = rid;
$$ LANGUAGE sql SECURITY DEFINER;

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_community_posts_community ON community_posts(community_id);
CREATE INDEX idx_community_posts_author    ON community_posts(author_id);
CREATE INDEX idx_community_posts_pinned    ON community_posts(is_pinned DESC, created_at DESC);
CREATE INDEX idx_community_comments_post   ON community_comments(post_id);
CREATE INDEX idx_community_comments_parent ON community_comments(parent_id);
CREATE INDEX idx_community_reactions_post  ON community_reactions(post_id);
CREATE INDEX idx_community_reactions_comment ON community_reactions(comment_id);
CREATE INDEX idx_community_resources_community ON community_resources(community_id);
CREATE INDEX idx_community_resources_category  ON community_resources(category);
