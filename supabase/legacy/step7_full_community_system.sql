-- ============================================================
-- UNIFY - STEP 7: FULL COMMUNITY SYSTEM
-- ============================================================
-- Adds:
--   1. student_id to profiles
--   2. Enhanced verification positions
--   3. Community discussions (Reddit-style threaded)
--   4. Community resources (file uploads)
--   5. Reports (trust & safety)
--   6. Notifications
--   7. Community member counts via trigger
-- ============================================================

-- ============================================================
-- 1. PROFILE ENHANCEMENTS
-- ============================================================
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS student_id TEXT;

-- ============================================================
-- 2. ENHANCED VERIFICATION POSITIONS
-- ============================================================
ALTER TABLE verification_requests
  ADD COLUMN IF NOT EXISTS student_id TEXT,
  DROP CONSTRAINT IF EXISTS verification_requests_position_check;

ALTER TABLE verification_requests
  ADD CONSTRAINT verification_requests_position_check
  CHECK (position IN (
    'class_representative',
    'assistant_class_representative',
    'course_representative',
    'src_executive',
    'department_executive',
    'hall_executive',
    'student',
    'administrator'
  ));

-- ============================================================
-- 3. COMMUNITY DISCUSSIONS (Reddit-style threaded)
-- ============================================================
CREATE TABLE IF NOT EXISTS discussions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id  UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  author_id     UUID NOT NULL REFERENCES profiles(id),
  title         TEXT NOT NULL,
  body          TEXT NOT NULL,
  is_pinned     BOOLEAN NOT NULL DEFAULT FALSE,
  is_locked     BOOLEAN NOT NULL DEFAULT FALSE,
  tags          TEXT[] DEFAULT '{}',
  likes_count   INTEGER NOT NULL DEFAULT 0,
  comments_count INTEGER NOT NULL DEFAULT 0,
  view_count    INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discussions_community ON discussions(community_id);
CREATE INDEX IF NOT EXISTS idx_discussions_author    ON discussions(author_id);
CREATE INDEX IF NOT EXISTS idx_discussions_pinned    ON discussions(community_id, is_pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_discussions_created   ON discussions(community_id, created_at DESC);

-- Discussion comments (supports nested replies via parent_id)
CREATE TABLE IF NOT EXISTS discussion_comments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  parent_id     UUID REFERENCES discussion_comments(id) ON DELETE CASCADE,
  author_id     UUID NOT NULL REFERENCES profiles(id),
  body          TEXT NOT NULL,
  likes_count   INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discussion_comments_discussion ON discussion_comments(discussion_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_parent     ON discussion_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_discussion_comments_author     ON discussion_comments(author_id);

-- Discussion likes
CREATE TABLE IF NOT EXISTS discussion_likes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (discussion_id, user_id)
);

-- Discussion comment likes
CREATE TABLE IF NOT EXISTS discussion_comment_likes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id    UUID NOT NULL REFERENCES discussion_comments(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (comment_id, user_id)
);

-- ============================================================
-- 4. COMMUNITY RESOURCES
-- ============================================================
CREATE TABLE IF NOT EXISTS community_resources (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id  UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  uploader_id   UUID NOT NULL REFERENCES profiles(id),
  title         TEXT NOT NULL,
  description   TEXT,
  file_type     TEXT NOT NULL CHECK (file_type IN (
                  'pdf', 'docx', 'ppt', 'pptx',
                  'image', 'zip', 'video', 'audio', 'other'
                )),
  file_url      TEXT NOT NULL,
  file_size     BIGINT,
  resource_type TEXT NOT NULL DEFAULT 'other' CHECK (resource_type IN (
                  'lecture_note', 'past_question', 'assignment',
                  'project', 'textbook', 'study_guide', 'other'
                )),
  download_count INTEGER NOT NULL DEFAULT 0,
  is_approved   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_community_resources_community ON community_resources(community_id);
CREATE INDEX IF NOT EXISTS idx_community_resources_type      ON community_resources(community_id, resource_type);

-- ============================================================
-- 5. REPORTS (Trust & Safety)
-- ============================================================
CREATE TABLE IF NOT EXISTS reports (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id     UUID NOT NULL REFERENCES profiles(id),
  report_type     TEXT NOT NULL CHECK (report_type IN (
                    'post', 'comment', 'user', 'community', 'discussion', 'resource'
                  )),
  target_id       UUID NOT NULL,
  target_owner_id UUID REFERENCES profiles(id),
  reason          TEXT NOT NULL,
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved', 'dismissed')),
  resolved_by     UUID REFERENCES profiles(id),
  resolved_at     TIMESTAMPTZ,
  admin_notes     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_status     ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_type       ON reports(report_type);

-- ============================================================
-- 6. NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type            TEXT NOT NULL CHECK (type IN (
                    'community_approved', 'community_rejected',
                    'announcement_posted', 'discussion_reply',
                    'discussion_mention', 'resource_uploaded',
                    'verification_approved', 'verification_rejected',
                    'moderator_action', 'report_update',
                    'community_invite', 'announcement_request_approved',
                    'announcement_request_rejected', 'new_follower'
                  )),
  title           TEXT NOT NULL,
  body            TEXT,
  reference_id    UUID,
  reference_type  TEXT,
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user       ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread     ON notifications(user_id, is_read) WHERE NOT is_read;

-- ============================================================
-- 7. COMMUNITY MEMBER COUNT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE communities SET member_count = member_count + 1 WHERE id = NEW.community_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE communities SET member_count = member_count - 1 WHERE id = OLD.community_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS community_members_count_trigger ON community_members;
CREATE TRIGGER community_members_count_trigger
  AFTER INSERT OR DELETE ON community_members
  FOR EACH ROW EXECUTE FUNCTION update_community_member_count();


-- ============================================================
-- 8. RLS POLICIES
-- ============================================================

-- Discussions
ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Discussions: members can read, members can create, admin/mod can pin/lock/delete
CREATE POLICY "discussions_read_members" ON discussions FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = discussions.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

CREATE POLICY "discussions_insert_members" ON discussions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
);

CREATE POLICY "discussions_update_own_mod" ON discussions FOR UPDATE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = discussions.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

CREATE POLICY "discussions_delete_own_mod" ON discussions FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = discussions.community_id AND user_id = auth.uid() AND role IN ('owner', 'manager', 'moderator') AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussion comments: members can read, members can create, own delete
CREATE POLICY "discussion_comments_read" ON discussion_comments FOR SELECT USING (
  EXISTS (SELECT 1 FROM discussions d JOIN community_members cm ON d.community_id = cm.community_id WHERE d.id = discussion_comments.discussion_id AND cm.user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

CREATE POLICY "discussion_comments_insert" ON discussion_comments FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members cm JOIN discussions d ON cm.community_id = d.community_id WHERE d.id = NEW.discussion_id AND cm.user_id = auth.uid())
);

CREATE POLICY "discussion_comments_delete" ON discussion_comments FOR DELETE USING (
  author_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers cm JOIN discussions d ON cm.community_id = d.community_id WHERE d.id = discussion_comments.discussion_id AND cm.user_id = auth.uid() AND cm.is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Discussion likes
CREATE POLICY "discussion_likes_manage" ON discussion_likes FOR ALL USING (auth.uid() = user_id);

-- Resources: members can read, members can upload, mod can approve/delete
CREATE POLICY "resources_read_members" ON community_resources FOR SELECT USING (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = community_resources.community_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

CREATE POLICY "resources_insert_members" ON community_resources FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM community_members WHERE community_id = NEW.community_id AND user_id = auth.uid())
);

CREATE POLICY "resources_update_mod" ON community_resources FOR UPDATE USING (
  uploader_id = auth.uid()
  OR EXISTS (SELECT 1 FROM community_managers WHERE community_id = community_resources.community_id AND user_id = auth.uid() AND is_active = TRUE)
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Reports: users can create, admins can see all
CREATE POLICY "reports_insert_own" ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "reports_select_admin" ON reports FOR SELECT USING (
  auth.uid() = reporter_id
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);
CREATE POLICY "reports_update_admin" ON reports FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'superadmin'))
);

-- Notifications: users see own, system inserts for others
CREATE POLICY "notifications_select_own" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notifications_update_own" ON notifications FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "notifications_insert_system" ON notifications FOR INSERT WITH CHECK (TRUE);

-- ============================================================
-- 9. FUNCTION: Create notification helper
-- ============================================================
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_body TEXT DEFAULT NULL,
  p_reference_id UUID DEFAULT NULL,
  p_reference_type TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO notifications (user_id, type, title, body, reference_id, reference_type)
  VALUES (p_user_id, p_type, p_title, p_body, p_reference_id, p_reference_type)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- ============================================================
-- 10. DEFAULT NOTIFICATIONS FOR EXISTING TRIGGER POINTS
-- ============================================================

-- Notify when community request is approved
CREATE OR REPLACE FUNCTION notify_community_approved()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    PERFORM create_notification(
      NEW.requester_id,
      'community_approved',
      'Community Approved',
      CONCAT('Your community "', NEW.community_name, '" has been approved!'),
      NEW.id,
      'community_request'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS community_approved_notification ON community_requests;
CREATE TRIGGER community_approved_notification
  AFTER UPDATE ON community_requests
  FOR EACH ROW
  WHEN (NEW.status = 'approved' AND OLD.status = 'pending')
  EXECUTE FUNCTION notify_community_approved();

-- Notify when verification is approved/rejected
CREATE OR REPLACE FUNCTION notify_verification_reviewed()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.user_id, 'verification_approved', 'Verification Approved', 'Your leadership verification has been approved!', NEW.id, 'verification_request');
  ELSIF NEW.status = 'rejected' AND OLD.status = 'pending' THEN
    PERFORM create_notification(NEW.user_id, 'verification_rejected', 'Verification Rejected', CONCAT('Your verification was rejected', CASE WHEN NEW.admin_notes IS NOT NULL THEN CONCAT(': ', NEW.admin_notes) ELSE '.' END), NEW.id, 'verification_request');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS verification_reviewed_notification ON verification_requests;
CREATE TRIGGER verification_reviewed_notification
  AFTER UPDATE ON verification_requests
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected'))
  EXECUTE FUNCTION notify_verification_reviewed();

-- ============================================================
-- 11. DISCUSSION LIKE COUNT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_discussion_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE discussions SET likes_count = likes_count + 1 WHERE id = NEW.discussion_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE discussions SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.discussion_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS discussion_likes_count_trigger ON discussion_likes;
CREATE TRIGGER discussion_likes_count_trigger
  AFTER INSERT OR DELETE ON discussion_likes
  FOR EACH ROW EXECUTE FUNCTION update_discussion_likes_count();

-- Discussion comment count trigger
CREATE OR REPLACE FUNCTION update_discussion_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE discussions SET comments_count = comments_count + 1 WHERE id = NEW.discussion_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE discussions SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.discussion_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS discussion_comments_count_trigger ON discussion_comments;
CREATE TRIGGER discussion_comments_count_trigger
  AFTER INSERT OR DELETE ON discussion_comments
  FOR EACH ROW EXECUTE FUNCTION update_discussion_comments_count();


-- View count increment function (no .in_() dependency on client side)
CREATE OR REPLACE FUNCTION increment_discussion_view(p_discussion_id UUID)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  UPDATE discussions SET view_count = view_count + 1 WHERE id = p_discussion_id;
END;
$$;

-- Resource download count increment function
CREATE OR REPLACE FUNCTION increment_resource_download(p_resource_id UUID)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  UPDATE community_resources SET download_count = download_count + 1 WHERE id = p_resource_id;
END;
$$;
