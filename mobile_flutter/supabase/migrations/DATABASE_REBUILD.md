# UNIFY Database Rebuild Guide

From `supabase init` to running app in one session.

## Prerequisites

- Supabase project created (via CLI or Dashboard)
- `supabase` CLI installed and linked to your project
- Flutter SDK 3.41.7+, Dart 3.11.5+
- Firebase project (for push notifications — optional at build time)

## Migration Files

All migrations are in `mobile_flutter/supabase/migrations/` with Supabase-compatible
timestamp naming. Apply in order:

| #  | File | Tables | Est. Size |
|----|------|--------|-----------|
| 1  | `20260619000001_bootstrap.sql` | universities, profiles, auth triggers, seed data | ~5 KB |
| 2  | `20260619000002_community_core.sql` | communities, badges, leadership, verification, community requests, managers | ~15 KB |
| 3  | `20260619000003_content.sql` | posts, comments, events, polls, resources, discussions, snapshots, reports | ~25 KB |
| 4  | `20260619000004_events_ticketing.sql` | event tickets, saves, discussions, media, reminders, certificates, ALTER community_events | ~10 KB |
| 5  | `20260619000005_messaging.sql` | conversations, channels, messages, reactions, requests, polls, mentions, blocked users | ~15 KB |
| 6  | `20260619000006_academic_hub.sql` | courses, resources, assignments, submissions, GPA, study plans, exam timetables | ~12 KB |
| 7  | `20260619000007_admin_marketplace.sql` | universities (admin), faculties, departments, admin roles, administrators, audits, moderation, marketplace, opportunities | ~25 KB |
| 8  | `20260619000008_reputation_infra.sql` | reputation scores, achievements, skills, portfolios, notifications, launch infra (waitlist, invites, beta, feedback, analytics, ambassadors, faq, support) | ~30 KB |
| 9  | `20260619000009_production_fixes.sql` | device_tokens, push_queue, message_reports, missing RLS policies, RPCs, indexes, cron setup | ~15 KB |

## Quick Start

### Option A: Supabase CLI (recommended)

```bash
# 1. Init & link
supabase init
supabase link --project-ref <your-ref>

# 2. Apply migrations in order
for f in mobile_flutter/supabase/migrations/2026*.sql; do
  supabase db push --file "$f"
done
```

### Option B: Supabase Studio SQL Editor

1. Open your project dashboard → SQL Editor
2. Open each file from `mobile_flutter/supabase/migrations/`
3. Run them **in order** (migrations are dependency-ordered)
4. Run `step_fix_database_relationships.sql` after all migrations
   (or just run the migrations — they already have fixed FKs)

## Schema Collisions Resolved

| Collision | Resolution |
|-----------|-----------|
| **Academic Hub**: root `step12_academic_hub.sql` vs `mobile_flutter/step13_academic_hub.sql` | Use `mobile_flutter/step13` schema (matches Flutter code). Old tables (`gpa_entries`, `exam_schedule`, `study_tasks`) are dropped. |
| **Admin System**: `step16_admin_system.sql` vs `step16_multi_university_admin.sql` | Use `step16_multi_university_admin.sql` (more polished, consistent RLS naming). |
| **Events**: root `step8_events_polls.sql` vs `mobile_flutter/...` | Merged: columns from `step14_events_ticketing_platform.sql` added to `community_events`. |
| **Duplicate step directories** | Canonical source = `mobile_flutter/supabase/`. Root `supabase/` files are legacy and will be archived. |

## FK Fix Applied

All tables that previously referenced `users(id)` (which doesn't exist in `public` schema)
now reference `profiles(id)`. This includes:

- `conversations.created_by`
- `conversation_participants.user_id`
- `channels.created_by`
- `messages.sender_id`
- `message_reactions.user_id`
- `message_requests.from_user_id`, `to_user_id`
- `chat_poll_votes.user_id`
- `mentions.user_id`
- `blocked_users.blocker_id`, `blocked_id`
- `courses.lecturer_id`, `created_by`
- `academic_resources.verified_by`
- `assignments.created_by`
- `assignment_submissions.graded_by`
- `exam_timetables.created_by`
- `audit_logs.actor_id`
- `moderation_queue.reported_by`, `reviewed_by`
- `marketplace_reports.reported_by`, `reviewed_by`
- `opportunities.organizer_id`, `reviewed_by`
- `admin_announcements.sender_id`
- `message_reports.reporter_id`

## After Migrations

### 1. Deploy Edge Functions

```bash
supabase functions deploy send_push_notification --no-verify-jwt
supabase functions deploy daily-analytics --no-verify-jwt
```

### 2. Set Secrets

```bash
supabase secrets set FCM_SERVER_KEY=<your-firebase-server-key>
```

### 3. Set up pg_cron

The final migration includes pg_cron scheduling guide (commented out).
Uncomment and run when ready:

```sql
-- Schedule daily analytics aggregation
SELECT cron.schedule('daily-analytics', '0 2 * * *', 'SELECT aggregate_daily_analytics();');

-- Schedule weekly marketplace summary
SELECT cron.schedule('weekly-marketplace', '0 3 * * 0', 'SELECT aggregate_daily_analytics();');
```

### 4. Storage Buckets

Create these buckets in Supabase Dashboard → Storage:

| Bucket | Public | Purpose |
|--------|--------|---------|
| `avatars` | Yes | Profile photos |
| `community-covers` | Yes | Community cover images |
| `post-images` | Yes | Post/media attachments |
| `event-media` | Yes | Event photos & videos |
| `academic` | Yes | Course notes & resources |
| `marketplace` | Yes | Listing images |
| `snapshots` | Yes | Poll/snapshot media |
| `feedback` | Yes | User uploads |
| `opportunity` | Yes | Opportunity attachments |

### 5. Firebase (Optional)

```bash
# Download google-services.json & GoogleService-Info.plist from Firebase Console
# Place in android/app/ and ios/Runner/ respectively
```

### 6. Verify Build

```bash
cd mobile_flutter
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
flutter analyze
flutter build apk --debug
```

## File Archive

After confirming the new migrations work, legacy files can be archived:

- Root `supabase/` directory (except `.temp/` and `migrations/`) → `supabase/legacy/`
- `mobile_flutter/supabase/step*.sql` files → `mobile_flutter/supabase/legacy/`
