-- =============================================================================
-- Activation Sprint — DB Infrastructure
-- Date: 2026-06-23
--
-- 1. Expand notification types for activation flow
-- 2. Security-definer RPCs: handle_onboarding_complete, send_reengagement
-- 3. Profile completeness SQL helper
-- =============================================================================

-- ── Expand notification type CHECK constraint ─────────────────────────────────

alter table if exists notifications
  drop constraint if exists notifications_type_check;

alter table if exists notifications
  add constraint notifications_type_check
  check (type in (
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
    'welcome',
    'activation_nudge',
    're_engagement'
  ));

-- ── RPC: handle_onboarding_complete ──────────────────────────────────────────
-- Called immediately after a user saves their onboarding profile.
-- Runs as security definer to bypass RLS for badge assignment.
-- Idempotent — safe to call multiple times.

create or replace function handle_onboarding_complete(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- 1. Assign Beta Tester badge (silently skip if already assigned)
  insert into user_badges (user_id, badge_slug)
  values (p_user_id, 'beta_tester')
  on conflict (user_id, badge_slug) do nothing;

  -- 2. Add to beta_testers cohort if not already there
  insert into beta_testers (user_id, cohort, status)
  values (p_user_id, 'beta-1', 'active')
  on conflict (user_id) do nothing;

  -- 3. Welcome notification sequence (3 notifications, ~sequential)
  insert into notifications (user_id, type, title, body)
  values
    (p_user_id, 'welcome',
     '👋 Welcome to UNIFY Beta!',
     'You are now part of our closed beta. Explore communities, join events, and help shape the future of campus life.'),
    (p_user_id, 'activation_nudge',
     '🏘️ Find your community',
     'Join a study group or class community to connect with classmates. Check out the Communities tab to get started.'),
    (p_user_id, 'activation_nudge',
     '📝 Make your first post',
     'Share a question, resource, or thought with your community. Your classmates want to hear from you.');
end;
$$;

grant execute on function handle_onboarding_complete(uuid) to authenticated;

-- ── RPC: send_reengagement_notifications ─────────────────────────────────────
-- Sends a re-engagement notification to every user who has had no
-- analytics event in the last N days. Called from the Founder Dashboard.
-- Returns the number of notifications sent.

create or replace function send_reengagement_notifications(p_threshold_days int default 3)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int := 0;
  v_user  record;
begin
  for v_user in
    select p.id
    from profiles p
    left join analytics_events ae
      on ae.user_id = p.id
      and ae.created_at >= (now() - (p_threshold_days || ' days')::interval)
    where p.role not in ('admin', 'superadmin')
      and p.created_at < (now() - (p_threshold_days || ' days')::interval)
    group by p.id
    having max(ae.created_at) is null
        or max(ae.created_at) < (now() - (p_threshold_days || ' days')::interval)
  loop
    insert into notifications (user_id, type, title, body)
    values (
      v_user.id,
      're_engagement',
      '👀 We miss you on UNIFY',
      'It''s been a few days. Catch up on what''s happening in your communities and check any new announcements.'
    );
    v_count := v_count + 1;
  end loop;

  return v_count;
end;
$$;

grant execute on function send_reengagement_notifications(int) to authenticated;

-- ── Profile completeness score ────────────────────────────────────────────────
-- Returns 0-100 score for a given user based on filled profile fields.

create or replace function get_profile_completeness(p_user_id uuid)
returns int
language sql
stable
security definer
set search_path = public
as $$
  select
    round(
      (
        case when full_name   is not null and full_name   <> '' then 1 else 0 end +
        case when email       is not null and email       <> '' then 1 else 0 end +
        case when student_id  is not null and student_id  <> '' then 1 else 0 end +
        case when programme   is not null and programme   <> '' then 1 else 0 end +
        case when level       is not null and level       <> '' then 1 else 0 end +
        case when phone       is not null and phone       <> '' then 1 else 0 end
      )::numeric / 6 * 100
    )::int
  from profiles
  where id = p_user_id;
$$;

grant execute on function get_profile_completeness(uuid) to authenticated;
