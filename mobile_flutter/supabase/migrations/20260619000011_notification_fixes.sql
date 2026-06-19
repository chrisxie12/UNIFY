-- ============================================================
-- UNIFY — Step 11: Notification System Fixes
--
-- 1. Fix notifications.type CHECK constraint (adds 6 missing types)
-- 2. Rewrite create_notification() with data param + preference enforcement
-- 3. Replace community_approved trigger with full decision trigger
-- 4. Wire notify_admin_new_request to submission tables
-- 5. Auto-create notification_preferences in handle_new_user()
-- 6. Back-fill preferences for existing users
-- ============================================================

BEGIN;

-- ── 1. Fix the type CHECK constraint ──────────────────────────────────────────
--
--  Migration 8 defined a constraint that excluded 6 types used by DB triggers
--  and app code.  Drop and recreate with the full set.

ALTER TABLE notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications
  ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    -- Original 15 types
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
    -- Previously missing — now added
    'verification_rejected',       -- verification trigger + admin action
    'community_approved',          -- community trigger (approved path)
    'community_rejected',          -- community trigger (rejected path)
    'community_changes_requested', -- admin requests more info
    'admin_request',               -- notify_admin_new_request fan-out
    'announcement_posted'          -- notify_new_post fan-out
  ));

-- ── 2. Rewrite create_notification() ─────────────────────────────────────────
--
--  Changes vs. original:
--    • p_data JSONB parameter (stored in notifications.data)
--    • Enforces notification_preferences before inserting
--    • Returns UUID (was TEXT) so callers get a typed value

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
      OR p_type = 'announcement_posted'             THEN 'communities'
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

-- ── 3. Replace narrow community trigger with full decision trigger ─────────────
--
--  Old: only fires on pending→approved
--  New: fires on pending→approved, pending→rejected, pending→changes_requested

CREATE OR REPLACE FUNCTION notify_community_request_reviewed()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_type  TEXT;
  v_title TEXT;
  v_body  TEXT;
BEGIN
  v_type := CASE NEW.status
    WHEN 'approved'          THEN 'community_approved'
    WHEN 'rejected'          THEN 'community_rejected'
    WHEN 'changes_requested' THEN 'community_changes_requested'
    ELSE NULL
  END;
  IF v_type IS NULL THEN RETURN NEW; END IF;

  v_title := CASE NEW.status
    WHEN 'approved'          THEN 'Community Approved'
    WHEN 'rejected'          THEN 'Community Request Rejected'
    WHEN 'changes_requested' THEN 'More Information Needed'
  END;

  v_body := CASE NEW.status
    WHEN 'approved'          THEN
      'Your community "' || NEW.community_name || '" has been approved!'
    WHEN 'rejected'          THEN
      'Your request for "' || NEW.community_name || '" was not approved.'
    WHEN 'changes_requested' THEN
      COALESCE(
        'Changes requested for "' || NEW.community_name || '": ' || NEW.admin_feedback,
        'Admin requested more information for "' || NEW.community_name || '".'
      )
  END;

  PERFORM create_notification(
    NEW.requester_id::TEXT, v_type, v_title, v_body,
    NEW.id::TEXT, 'community_request'
  );
  RETURN NEW;
END;
$$;

-- Drop the old narrow trigger and replace
DROP TRIGGER IF EXISTS community_approved_notification         ON community_requests;
DROP TRIGGER IF EXISTS community_request_reviewed_notification ON community_requests;

CREATE TRIGGER community_request_reviewed_notification
  AFTER UPDATE ON community_requests
  FOR EACH ROW
  WHEN (OLD.status = 'pending'
    AND NEW.status IN ('approved', 'rejected', 'changes_requested'))
  EXECUTE FUNCTION notify_community_request_reviewed();

-- ── 4. Wire notify_admin_new_request to submission tables ─────────────────────

DROP TRIGGER IF EXISTS admin_new_community_request     ON community_requests;
DROP TRIGGER IF EXISTS admin_new_verification_request  ON verification_requests;

CREATE TRIGGER admin_new_community_request
  AFTER INSERT ON community_requests
  FOR EACH ROW
  EXECUTE FUNCTION notify_admin_new_request('community_request');

CREATE TRIGGER admin_new_verification_request
  AFTER INSERT ON verification_requests
  FOR EACH ROW
  EXECUTE FUNCTION notify_admin_new_request('verification_request');

-- ── 5. Auto-create notification_preferences in handle_new_user() ──────────────

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, university_id, full_name, role)
  VALUES (
    NEW.id,
    (SELECT id FROM public.universities WHERE slug = 'gctu' LIMIT 1),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'student'
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- ── 6. Back-fill preferences for existing users who have no row ───────────────

INSERT INTO notification_preferences (user_id)
SELECT id FROM profiles
WHERE  id NOT IN (SELECT user_id FROM notification_preferences)
ON CONFLICT (user_id) DO NOTHING;

COMMIT;
