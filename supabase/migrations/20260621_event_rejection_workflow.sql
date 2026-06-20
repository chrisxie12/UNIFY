-- =============================================================================
-- Requester Notification & Workflow Completion Sprint
-- Date: 2026-06-21
--
-- Adds rejection_reason to community_events so admins can record why an event
-- was not approved instead of deleting it. The is_cancelled flag is used to
-- signal an admin-rejected state (is_approved=false, is_cancelled=true).
-- =============================================================================

alter table community_events
  add column if not exists rejection_reason text;

comment on column community_events.rejection_reason is
  'Admin-provided reason when is_approved=false and is_cancelled=true (admin reject).';
