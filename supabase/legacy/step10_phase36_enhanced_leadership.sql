-- ============================================================
-- UNIFY - STEP 10: Phase 3.6 - Enhanced Leadership & Admin
-- ============================================================
-- Adds:
--   1. New leadership roles (department_executive, faculty_executive, club_executive)
--   2. class_name field to community_requests
--   3. changes_requested notification helper
--   4. Admin notification trigger for new community requests
-- ============================================================

BEGIN;

-- ============================================================
-- 1. ADD NEW LEADERSHIP ROLES (if not already existing)
-- ============================================================
INSERT INTO leadership_roles (slug, title, description, is_elective, priority)
SELECT * FROM (VALUES
  ('department_executive', 'Department Executive',   'Department-level student executive',        TRUE, 12),
  ('faculty_executive',    'Faculty Executive',      'Faculty-level student executive',           TRUE, 11),
  ('club_executive',       'Club Executive',         'Student club or society executive member', TRUE, 7)
) AS v(slug, title, description, is_elective, priority)
WHERE NOT EXISTS (
  SELECT 1 FROM leadership_roles WHERE slug = v.slug
);

-- ============================================================
-- 2. ADD CORRESPONDING BADGES
-- ============================================================
INSERT INTO badges (name, slug, description, category, is_system)
SELECT * FROM (VALUES
  ('Department Executive',   'department_executive',  'Department-level student executive',     'leadership', TRUE),
  ('Faculty Executive',      'faculty_executive',     'Faculty-level student executive',        'leadership', TRUE),
  ('Club Executive',         'club_executive',        'Student club executive member',          'leadership', TRUE)
) AS v(name, slug, description, category, is_system)
WHERE NOT EXISTS (
  SELECT 1 FROM badges WHERE slug = v.slug
);

-- ============================================================
-- 3. ADD class_name COLUMN TO community_requests
-- ============================================================
ALTER TABLE community_requests
  ADD COLUMN IF NOT EXISTS class_name TEXT;

-- ============================================================
-- 4. NOTIFY ADMIN WHEN A NEW COMMUNITY REQUEST IS SUBMITTED
-- ============================================================
CREATE OR REPLACE FUNCTION notify_admin_new_request()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_admin RECORD;
BEGIN
  FOR v_admin IN
    SELECT id FROM profiles WHERE role IN ('admin', 'superadmin')
  LOOP
    PERFORM create_notification(
      v_admin.id,
      'admin_new_request',
      'New Community Request',
      CONCAT(NEW.community_name, ' (', NEW.community_type, ') - ', LEFT(NEW.purpose, 100)),
      NEW.id,
      'community_request'
    );
  END LOOP;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS admin_new_request_notification ON community_requests;
CREATE TRIGGER admin_new_request_notification
  AFTER INSERT ON community_requests
  FOR EACH ROW
  EXECUTE FUNCTION notify_admin_new_request();

-- ============================================================
-- 5. NOTIFY REQUESTER WHEN CHANGES ARE REQUESTED
-- ============================================================
CREATE OR REPLACE FUNCTION notify_changes_requested()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'changes_requested' AND OLD.status = 'pending' AND NEW.admin_feedback IS NOT NULL THEN
    PERFORM create_notification(
      NEW.requester_id,
      'community_changes_requested',
      'More Information Needed',
      CONCAT('Admin requested changes for "', NEW.community_name, '": ', NEW.admin_feedback),
      NEW.id,
      'community_request'
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS changes_requested_notification ON community_requests;
CREATE TRIGGER changes_requested_notification
  AFTER UPDATE ON community_requests
  FOR EACH ROW
  WHEN (NEW.status = 'changes_requested' AND OLD.status = 'pending')
  EXECUTE FUNCTION notify_changes_requested();

COMMIT;
