-- ============================================================
-- STEP 19 — Beta Launch: feature_flags table
-- ============================================================
-- All other step-19 tables (beta_testers, feedback_items, etc.)
-- were already created in step13_launch_infrastructure.sql.
-- This file adds the only missing piece: runtime feature flags.

-- 1. feature_flags — admin toggles without app-store deployment
create table if not exists feature_flags (
  id          uuid primary key default gen_random_uuid(),
  key         text not null unique,
  label       text not null,
  description text not null default '',
  enabled     boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table feature_flags enable row level security;

-- Anyone authenticated can read flags (needed for gating decisions).
create policy "Anyone can read feature_flags"
  on feature_flags for select
  using (true);

-- Only super-admins can toggle flags.
create policy "Super admins can toggle feature_flags"
  on feature_flags for update
  using (is_super_admin());

-- Seed defaults for all known feature toggles.
insert into feature_flags (key, label, description, enabled) values
  ('communities',      'Communities',        'Community creation, feed, and interaction',                         true),
  ('messaging',        'Messaging',          'Direct messages, group chats, and channels',                        true),
  ('marketplace',      'Marketplace',        'Buy, sell, and list items on campus',                               false),
  ('academic',         'Academic Hub',       'Courses, notes, GPA, study planner, assignments, exams',             false),
  ('events',           'Events & Ticketing', 'Event discovery, RSVP, ticketing, check-in, and gallery',           false),
  ('opportunities',    'Opportunities',      'Job listings, internships, and campus opportunities',                false),
  ('referrals',        'Referrals',          'Invite friends and earn rewards',                                   true),
  ('ambassadors',      'Ambassadors',        'Campus ambassador program',                                         true),
  ('feedback',         'Feedback',           'In-app feedback submission and admin queue',                         true),
  ('beta_access',      'Beta Access',       'Waitlist, invite codes, and beta-tester management',                 true),
  ('analytics',        'Usage Analytics',    'DAU/WAU/MAU tracking, retention, and feature-adoption metrics',     true),
  ('announcements',    'Announcements',      'Admin broadcast and system announcements',                           true),
  ('support_center',   'Support Center',     'FAQ, help articles, support tickets, and abuse reporting',          true),
  ('reputation',       'Reputation System',  'Reputation scores, skills, and badges',                             false),
  ('global_search',    'Global Search',      'Cross-module full-text search',                                     true)
on conflict (key) do nothing;
