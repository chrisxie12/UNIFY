-- ============================================================
-- UNIFY — Step 17: Notification Phase 3
--
-- A. Drop migration 3 duplicate community_approved trigger
-- B. Drop old 6-arg create_notification overloads
-- C. Recreate verification_reviewed trigger using 7-arg RPC
-- D. Add leadership notification types to CHECK constraint
-- E. Add request_type column to verification_requests
-- F. Add leadership-specific triggers
-- G. Update create_notification() to map leadership types
-- ============================================================

BEGIN;

-- ── A. Drop migration 3 duplicate trigger ─────────────────────────
-- Migration 11 already dropped and replaced community_approved_notification
-- but migration 3's notify_community_approved() function may still exist.
DROP TRIGGER IF EXISTS community_approved_notification ON community_requests;
DROP FUNCTION IF EXISTS notify_community_approved();

-- ── B. Drop old 6-arg create_notification overloads ──────────────
-- The correct version is the 7-arg one from migration 11.
-- Drop the 6-arg versions from migrations 3 and 9.
DROP FUNCTION IF EXISTS create_notification(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);

-- ── C. Recreate verify_reviewed_notification using 7-arg RPC ─────
-- Migration 3's version called the old 6-arg RPC; replace it to use
-- the preference-enforcing 7-arg version. Column for rejection notes
-- is admin_notes (per migration 2 schema).

DROP TRIGGER IF EXISTS verification_reviewed_notification ON verification_requests;
DROP FUNCTION IF EXISTS notify_verification_reviewed();

CREATE OR REPLACE FUNCTION notify_verification_reviewed() RETURNS TRIGGER AS $$
BEGIN
  -- Only fire for verification-type requests (not leadership)
  IF NEW.request_type = 'leadership' THEN
    RETURN NEW;
  END IF;

  IF NEW.status = 'approved' THEN
    PERFORM create_notification(
      NEW.user_id::TEXT,
      'verification_approved',
      'Verification Approved',
      'Your verification request has been approved.',
      NEW.id::TEXT,
      'verification_request',
      jsonb_build_object('request_id', NEW.id, 'reviewed_by', NEW.reviewed_by)
    );
  ELSIF NEW.status = 'rejected' THEN
    PERFORM create_notification(
      NEW.user_id::TEXT,
      'verification_rejected',
      'Verification Not Approved',
      COALESCE(NEW.admin_notes, 'Your verification request was not approved.'),
      NEW.id::TEXT,
      'verification_request',
      jsonb_build_object('request_id', NEW.id, 'rejection_reason', NEW.admin_notes)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER verification_reviewed_notification
  AFTER UPDATE ON verification_requests
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected'))
  EXECUTE FUNCTION notify_verification_reviewed();

-- ── D. Add leadership notification types to CHECK constraint ──────
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'new_message',
  'community_announcement',
  'community_join_request',
  'community_approval',
  'marketplace_inquiry',
  'marketplace_sale',
  'event_registration',
  'event_reminder',
  'event_checkin_confirmation',
  'opportunity_deadline_reminder',
  'scholarship_alert',
  'academic_resource_upload',
  'verification_approved',
  'role_assigned',
  'admin_broadcast',
  'verification_rejected',
  'community_approved',
  'community_rejected',
  'community_changes_requested',
  'admin_request',
  'announcement_posted',
  'leadership_request_submitted',
  'leadership_approved',
  'leadership_rejected'
));

-- ── E. Add request_type column to verification_requests ───────────
ALTER TABLE verification_requests
  ADD COLUMN IF NOT EXISTS request_type TEXT NOT NULL DEFAULT 'verification'
  CHECK (request_type IN ('verification', 'leadership'));

-- ── F. Leadership-specific triggers ──────────────────────────────

-- F1. Notify admins when a leadership request is submitted
CREATE OR REPLACE FUNCTION notify_leadership_request_submitted() RETURNS TRIGGER AS $$
DECLARE
  v_admin RECORD;
  v_name  TEXT;
BEGIN
  -- Only for leadership type
  IF NEW.request_type != 'leadership' THEN
    RETURN NEW;
  END IF;

  -- Get requester name
  SELECT full_name INTO v_name FROM profiles WHERE id = NEW.user_id;

  -- Notify all admins/superadmins
  FOR v_admin IN
    SELECT id FROM profiles WHERE role IN ('admin', 'superadmin')
  LOOP
    PERFORM create_notification(
      v_admin.id::TEXT,
      'admin_request',
      'Leadership Request',
      COALESCE(v_name, 'A user') || ' submitted a leadership request.',
      NEW.id::TEXT,
      'verification_request',
      jsonb_build_object('request_id', NEW.id, 'request_type', 'leadership', 'user_id', NEW.user_id)
    );
  END LOOP;

  -- Notify the requester
  PERFORM create_notification(
    NEW.user_id::TEXT,
    'leadership_request_submitted',
    'Leadership Request Submitted',
    'Your leadership request has been submitted for review.',
    NEW.id::TEXT,
    'verification_request',
    jsonb_build_object('request_id', NEW.id)
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER leadership_request_submitted_notification
  AFTER INSERT ON verification_requests
  FOR EACH ROW
  WHEN (NEW.request_type = 'leadership')
  EXECUTE FUNCTION notify_leadership_request_submitted();

-- F2. Notify user when leadership request is reviewed
CREATE OR REPLACE FUNCTION notify_leadership_reviewed() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.request_type != 'leadership' THEN
    RETURN NEW;
  END IF;

  IF NEW.status = 'approved' THEN
    PERFORM create_notification(
      NEW.user_id::TEXT,
      'leadership_approved',
      'Leadership Role Approved',
      'Congratulations! Your leadership request has been approved.',
      NEW.id::TEXT,
      'verification_request',
      jsonb_build_object('request_id', NEW.id, 'reviewed_by', NEW.reviewed_by)
    );
    -- Also fire role_assigned
    PERFORM create_notification(
      NEW.user_id::TEXT,
      'role_assigned',
      'Role Assigned',
      'A leadership role has been assigned to your profile.',
      NEW.id::TEXT,
      'verification_request',
      jsonb_build_object('request_id', NEW.id)
    );
  ELSIF NEW.status = 'rejected' THEN
    PERFORM create_notification(
      NEW.user_id::TEXT,
      'leadership_rejected',
      'Leadership Request Not Approved',
      'Your leadership request was not approved at this time.',
      NEW.id::TEXT,
      'verification_request',
      jsonb_build_object('request_id', NEW.id)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER leadership_reviewed_notification
  AFTER UPDATE ON verification_requests
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') AND NEW.request_type = 'leadership')
  EXECUTE FUNCTION notify_leadership_reviewed();

-- ── G. Update create_notification() to include leadership types ───
-- Recreate the 7-arg function (from migration 11) with leadership types
-- added to the preference category CASE statement.
-- Leadership types map to 'communities' preference category.

CREATE OR REPLACE FUNCTION create_notification(
  p_user_id        TEXT,
  p_type           TEXT,
  p_title          TEXT,
  p_body           TEXT    DEFAULT NULL,
  p_reference_id   TEXT    DEFAULT NULL,
  p_reference_type TEXT    DEFAULT NULL,
  p_data           JSONB   DEFAULT '{}'::jsonb
)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_id       UUID;
  v_prefs    RECORD;
  v_category TEXT;
BEGIN
  -- Map notification type → preference category
  -- NULL means "always deliver" (e.g. verification status, role grants)
  v_category := CASE
    WHEN p_type = 'new_message'
                                                   THEN 'messages'
    WHEN p_type LIKE 'community%'
      OR p_type = 'announcement_posted'
      OR p_type IN ('leadership_request_submitted',
                    'leadership_approved',
                    'leadership_rejected')          THEN 'communities'
    WHEN p_type LIKE 'marketplace%'                THEN 'marketplace'
    WHEN p_type LIKE 'event%'                      THEN 'events'
    WHEN p_type IN ('opportunity_deadline_reminder',
                    'scholarship_alert')            THEN 'opportunities'
    WHEN p_type = 'academic_resource_upload'       THEN 'academic_resources'
    WHEN p_type LIKE 'admin%'                      THEN 'admin_notices'
    ELSE NULL
  END;

  -- Enforce preferences when a row exists for this user
  IF v_category IS NOT NULL THEN
    SELECT * INTO v_prefs
    FROM   notification_preferences
    WHERE  user_id = p_user_id::UUID;

    IF FOUND THEN
      IF v_category = 'messages'           AND NOT v_prefs.messages           THEN RETURN NULL; END IF;
      IF v_category = 'communities'        AND NOT v_prefs.communities        THEN RETURN NULL; END IF;
      IF v_category = 'marketplace'        AND NOT v_prefs.marketplace        THEN RETURN NULL; END IF;
      IF v_category = 'events'             AND NOT v_prefs.events             THEN RETURN NULL; END IF;
      IF v_category = 'opportunities'      AND NOT v_prefs.opportunities      THEN RETURN NULL; END IF;
      IF v_category = 'academic_resources' AND NOT v_prefs.academic_resources THEN RETURN NULL; END IF;
      IF v_category = 'admin_notices'      AND NOT v_prefs.admin_notices      THEN RETURN NULL; END IF;
    END IF;
  END IF;

  INSERT INTO notifications (
    user_id, type, title, body, reference_id, reference_type, data
  )
  VALUES (
    p_user_id::UUID, p_type, p_title, p_body,
    p_reference_id, p_reference_type,
    COALESCE(p_data, '{}'::jsonb)
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

COMMIT;
