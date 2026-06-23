-- =============================================================================
-- Retention Sprint — DB Infrastructure
-- Date: 2026-06-23
--
-- 1. SQL functions for DAU / session stats / dormant user detection
-- 2. community_engagement_scores view
-- 3. index additions for retention queries
-- =============================================================================

-- ── Daily active users for a given date ──────────────────────────────────────
-- Counts distinct users who fired any analytics event on that date.

create or replace function get_daily_active_users(p_date date default current_date)
returns bigint
language sql
stable
security definer
as $$
  select count(distinct user_id)
  from analytics_events
  where created_at::date = p_date
    and user_id is not null;
$$;

-- ── 7-day DAU series ─────────────────────────────────────────────────────────
-- Returns one row per day for the last N days with a distinct-user count.

create or replace function get_dau_series(p_days int default 7)
returns table(day date, active_users bigint)
language sql
stable
security definer
as $$
  select
    d::date as day,
    count(distinct ae.user_id) as active_users
  from generate_series(
    (current_date - ((p_days - 1) || ' days')::interval)::date,
    current_date,
    '1 day'
  ) as g(d)
  left join analytics_events ae
    on ae.created_at::date = g.d::date
    and ae.user_id is not null
  group by g.d
  order by g.d;
$$;

-- ── Average session duration (last 30 days) ───────────────────────────────────

create or replace function get_avg_session_seconds(p_days int default 30)
returns numeric
language sql
stable
security definer
as $$
  select round(avg(duration_seconds), 0)
  from user_sessions
  where duration_seconds is not null
    and started_at >= (now() - (p_days || ' days')::interval);
$$;

-- ── Dormant users: no analytics event in last N days ─────────────────────────
-- Returns profile rows for users who haven't fired any event recently.
-- Excludes the superadmin and users who signed up less than N days ago.

create or replace function get_dormant_users(p_threshold_days int default 3)
returns table(
  user_id      uuid,
  full_name    text,
  email        text,
  role         text,
  created_at   timestamptz,
  last_seen_at timestamptz
)
language sql
stable
security definer
as $$
  select
    p.id               as user_id,
    p.full_name,
    p.email,
    p.role,
    p.created_at,
    max(ae.created_at) as last_seen_at
  from profiles p
  left join analytics_events ae on ae.user_id = p.id
  where p.role not in ('superadmin', 'admin')
    and p.created_at < (now() - (p_threshold_days || ' days')::interval)
  group by p.id, p.full_name, p.email, p.role, p.created_at
  having max(ae.created_at) is null
      or max(ae.created_at) < (now() - (p_threshold_days || ' days')::interval)
  order by last_seen_at asc nulls first;
$$;

-- ── Community engagement score ────────────────────────────────────────────────
-- Weighted score: memberships (1pt) + recent events (10pt) + recent rsvps (3pt).
-- "Recent" = last 7 days for activity signals.

create or replace function get_community_engagement_scores()
returns table(
  community_id   uuid,
  community_name text,
  member_count   int,
  events_7d      bigint,
  rsvps_7d       bigint,
  score          numeric
)
language sql
stable
security definer
as $$
  select
    c.id                              as community_id,
    c.name                            as community_name,
    coalesce(c.member_count, 0)       as member_count,
    count(distinct ce.id)             as events_7d,
    coalesce(sum(er.rsvp_count), 0)   as rsvps_7d,
    (coalesce(c.member_count, 0) * 1
     + count(distinct ce.id) * 10
     + coalesce(sum(er.rsvp_count_agg.n), 0) * 3
    )::numeric                        as score
  from communities c
  left join community_events ce
    on ce.community_id = c.id
    and ce.created_at >= (now() - interval '7 days')
    and ce.is_cancelled = false
  left join lateral (
    select count(*) as n
    from event_rsvps er2
    join community_events ce2 on ce2.id = er2.event_id
    where ce2.community_id = c.id
      and er2.created_at >= (now() - interval '7 days')
  ) er_count on true
  left join lateral (select 0 as rsvp_count) er on true
  group by c.id, c.name, c.member_count
  order by score desc;
$$;

-- ── Grant execute to authenticated ───────────────────────────────────────────

grant execute on function get_daily_active_users(date) to authenticated;
grant execute on function get_dau_series(int) to authenticated;
grant execute on function get_avg_session_seconds(int) to authenticated;
grant execute on function get_dormant_users(int) to authenticated;
grant execute on function get_community_engagement_scores() to authenticated;

-- ── Performance indexes for retention queries ─────────────────────────────────

create index if not exists idx_analytics_events_date
  on analytics_events (created_at::date, user_id);

create index if not exists idx_analytics_events_name_date
  on analytics_events (event_name, created_at);

create index if not exists idx_user_sessions_started
  on user_sessions (started_at, user_id);
