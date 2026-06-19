# UNIFY Mobile — Session State

## Goal
Make UNIFY fully reproducible from a fresh Supabase project. Compete canonical `supabase_rebuild.sql` + `DATABASE_REBUILD.md` so any developer can go from `supabase init` to running app in one session.

## Progress

### Completed — Full Production Readiness
- **Stages 1-8** — Applied all step SQL to Supabase, fixed 55 unbounded queries (`.limit()`), fixed messaging streams (users→profiles), created Global Search (5 parallel `ilike` queries, 300ms debounce), created FCM Push Notification Service (graceful no-op), created Sentry Crash Reporting (graceful no-op), created Offline Caching (connectivity_plus + Hive with 6h TTL), added Accessibility Semantics to nav bar + AppButton.
- **Native configs** — AndroidManifest.xml permissions added, google-services plugin v4.4.2 in build.gradle.kts, app ID changed to `com.gctu.unify`, iOS Info.plist `UIBackgroundModes` with `remote-notification`.
- **Code hygiene** — `dart fix --apply` (596 fixes), manual cleanup of ~30 unused imports, ~15 unused locals, 7 unnecessary casts, 9 null assertions, 6 deprecated APIs. `flutter analyze`: **0 errors, 0 warnings, 13 infos**.
- **Edge Functions** — `send_push_notification` created (reads queue, calls FCM v1, updates status), `daily-analytics` created (calls `aggregate_daily_analytics()`).
- **Step18 SQL** — GRANT revocation, missing indexes, pg_cron scheduling guide.

### Done — Discussion Overhaul
- **Supabase SQL** — step8 (posts, comments, events, polls, RSVPs, RLS, triggers), step10 (Phase 3.6 roles/badges), step11 (post_votes, best_answer_id, upvote/downvote counts, auto-count trigger).
- **Data models** — PostModel (upvoteCount, downvoteCount, netVoteCount, myVote, bestAnswerId), PostCommentModel (isBestAnswer, nested replies), EventModel (RSVP, formatted getters), PollModel (options, expiry), PollOptionModel, CommunityResourceModel.
- **Repositories** — PostRepositoryImpl (upvotePost/downvotePost/removeVote, markBestAnswer/unmarkBestAnswer via post_votes table), EventRepositoryImpl, PollRepositoryImpl, CommunityRepositoryImpl (recommendation scoring).
- **Riverpod providers** — All repository providers + communityPostsProvider, postDetailProvider, postCommentsProvider, communityEventsProvider, communityPollsProvider, recommendedCommunitiesProvider, communityMembersProvider, isCommunityManagerProvider, themeNotifierProvider, themePresetProvider.
- **Widgets** — PostCard (upvote/downvote arrows, net score, Answered badge), EventCard (RSVP connected), PollCard (radio/checkbox, progress bars), ResourceCard (file type icon).
- **Screens** — CreatePostScreen, CreatePollScreen, ResourceUploadScreen, CommunityMembersScreen, FounderAnalyticsScreen, RepresentativeDetailScreen, AdminScreen, AdminNotificationCenterScreen.
- **CommunityHomeScreen** — 5-tab: Announcements, Discussions (PostCards + PollCards), Events (RSVP bottom sheet), Resources (filter chips), Members (search). FAB spawns create menu.
- **PostDetailScreen** — upvote/downvote, "Mark as Best Answer", threaded comments.
- **Nav bar** — 50px pill, 16px top gap, icon 22, label 10, 0.5px border.
- **Theme colour migration** — Replaced `Color(0xFF0066FF)` with `Theme.of(context).colorScheme.primary` across ~26 files. Fixed `undefined_identifier`, `const_eval_method_invocation`, and `const_with_non_const` errors. **0 errors**.

### Done — Messaging & Campus Chat System
- **Supabase SQL (step12)** — 12 tables: `conversations`, `conversation_participants`, `channels`, `messages`, `message_attachments`, `message_reactions`, `message_requests`, `chat_polls`, `chat_poll_votes`, `message_read_receipts`, `mentions`, `blocked_users`. Full RLS policies + performance indexes.
- **Data models** — `ConversationModel`, `MessageModel`, `ChannelModel`, `MessageRequest`, `ChatPoll`, `ChatPollVote`, `MessageReaction`, `MessageAttachment`.
- **Repository** — `MessagingRepositoryImpl` (10+ methods): send/edit/delete messages, add/remove reactions, pin messages, mark as read, create/vote polls, manage conversations, manage requests, search users, unread counts, typing indicators, reporting.
- **Riverpod providers** — `messagingRepositoryProvider`, `currentUserIdProvider`, `conversationsProvider` (stream), `messagesProvider` (stream), `channelsProvider`, `messageRequestsProvider`, `unreadCountProvider`, `searchUsersProvider`, `MessagingNotifier`.
- **Screens** — MessagingScreen (tab), ChatScreen (bubbles/reactions/polls/attachments), ChannelViewScreen (Discord-style), MessageRequestsScreen, StudentDirectoryScreen, CreateGroupScreen.
- **Router** — All messaging routes in `app_router.dart`.

### Done — Academic Hub
- **Supabase SQL (step13)** — `step13_academic_hub.sql` — 11 tables: `courses`, `academic_resources`, `resource_ratings`, `assignments`, `assignment_submissions`, `gpa_records`, `gpa_courses`, `study_plans`, `study_plan_items`, `exam_timetables`, `resource_bookmarks`. RLS by university/faculty/department scoping.
- **Data models** — `CourseModel`, `AcademicResourceModel`, `AssignmentModel`, `GPARecord`, `GPACourse`, `StudyPlanModel`, `StudyPlanItem`, `ResourceRating`, `ExamTimetable`.
- **Repository** — `AcademicRepositoryImpl`: getCourses/getCourse/createCourse, getResources/uploadResource/deleteResource, getAssignments/createAssignment/submitAssignment/deleteAssignment, getGPARecords/saveGPARecord/deleteGPARecord, getStudyPlans/createStudyPlan/toggleStudyItem/deleteStudyPlan, getExamTimetables/addExamTimetable, searchResources/searchCourses, rateResource/getRatings/getAverageRating, incrementDownload/incrementView.
- **Riverpod providers** — `academicRepositoryProvider`, `coursesProvider`, `courseProvider` (family), `coursesByDepartmentProvider`, `resourcesByCourseProvider`, `resourcesByTypeProvider`, `searchResourcesProvider`, `searchCoursesProvider`, `assignmentsProvider`, `gpaRecordsProvider`, `studyPlansProvider`, `examTimetablesProvider`.
- **Screens built:**
  - **`AcademicHubScreen`** — 6 quick-action cards (Courses, Notes, Assignments, Exam Prep, GPA, Study Planner), search bar, recent activity
  - **`CourseListScreen`** — department/faculty/level filter chips, animated course cards with resource/assignment counts, shimmer loading
  - **`CoursePageScreen`** — 4-tab layout (Overview, Notes, Assignments, Exams), course info header with credits/lecturer stats
  - **`NotesRepositoryScreen`** — resource list with file type icons, verified badges, ratings, filter sheet; supports courseId and type filtering
  - **`AssignmentHubScreen`** — upcoming/past tabs, due date countdown, submission status chips
  - **`ExamPrepCenterScreen`** — timetable list, countdown widget, course cards filtered by date
  - **`GPACalculatorScreen`** — per-semester GPA with grade dropdowns, credit inputs, CGPA rollup, visual progress
  - **`StudyPlannerScreen`** — plan cards with progress bars, expandable task items with completion toggles
  - **`AcademicSearchScreen`** — 🔍 courses/resources search with type tabs, result cards
- **Nav bar integration** — 5th tab "Study" (book icon) in the pill nav bar at index 3
- **Router integration** — All academic routes: `/academic`, `/academic/courses`, `/academic/course/:id`, `/academic/course/:id/notes`, `/academic/resources`, `/academic/assignments`, `/academic/exam-prep`, `/academic/gpa`, `/academic/study-planner`, `/academic/search`
- **Verification** — `flutter analyze`: **0 errors**. `flutter build apk --debug`: **APK builds successfully**.

### Done — Events & Ticketing Platform
- **Supabase SQL (step14)** — `step14_events_ticketing_platform.sql`: enhances `community_events` (category, capacity, registration_type, scope, university, faculty, department, organizer_type, attendee_count, is_featured, is_approved), new tables: `event_tickets` (QR code, check-in), `event_saves` (bookmarks), `event_discussions` (Q&A, threaded), `event_media` (photo/video gallery), `event_reminders` (push notification scheduling), `event_certificates` (future). Full RLS + indexes.
- **Data models** — `EventModel` (enhanced with category, scope, capacity, registrationType, isFeatured, isApproved, isSaved, myTicket*, myAttendanceStatus getters), `EventTicketModel` (ticket_number, qr_code, attended, checked_in_at), `EventSave`, `EventDiscussion` (threaded replies, formattedDate), `EventMedia` (photo/video), `EventReminder`, `EventCertificate`, `EventAttendanceAnalytics`.
- **Repository** — `EventRepositoryImpl` (30+ methods): discovery (getUpcomingEvents, getTrendingEvents, getFeaturedEvents, getEventsByScope, getSavedEvents, searchEvents), CRUD (create/update/delete/approve/feature), RSVP (rsvpEvent/cancelRsvp), ticketing (registerForEvent/getMyTicket/getMyTickets/getEventTickets/checkInAttendee/getAttendanceAnalytics), saves (saveEvent/unSaveEvent/isEventSaved), discussions (get/post/delete), media (get/upload/delete), reminders (set/cancel), certificates (getUserCertificates).
- **Riverpod providers** — `eventRepositoryProvider`, `currentUserIdProvider`, `upcomingEventsProvider`, `trendingEventsProvider`, `featuredEventsProvider`, `communityEventsProvider`, `eventsByScopeProvider`, `savedEventsProvider`, `searchEventsProvider`, `eventDetailProvider`, `myTicketsProvider`, `myTicketProvider`, `eventTicketsProvider`, `attendanceAnalyticsProvider`, `eventDiscussionsProvider`, `eventMediaProvider`, `userCertificatesProvider`.
- **Screens built (12):**
  - **`EventsScreen`** — main discovery tab with 3-tab layout (Upcoming/Trending/Featured), scope filter chips (All/Community/Faculty/University/Campus), EventCards
  - **`CreateEventScreen`** — full form: title, description, venue, date picker, time picker, event type, category, scope, capacity, virtual toggle, contact info
  - **`EventDetailScreen`** — enhanced: sliver cover image, date badge, category/scope badges, info card, description, capacity bar, RSVP bottom sheet, register button (auto-generates ticket), quick links (Discuss/Media/Share/Remind), attendee preview
  - **`MyTicketsScreen`** — user's ticket list with attended/pending status
  - **`TicketScreen`** — full ticket card with QR code display (generated from hash), ticket number, registration timestamp, venue, check-in status
  - **`QRCheckInScreen`** — organizer check-in: manual ticket code entry, verification result, live attendee list with check-in status
  - **`OrganizerDashboardScreen`** — event summary, analytics cards (registered/checked-in/rate/no-shows), action grid (edit/check-in/export/announcement), registrant list
  - **`AdminEventDashboardScreen`** — pending approval queue (approve/reject), all events list with feature/remove actions
  - **`EventDiscussionScreen`** — threaded Q&A: post comments, reply to comments, delete own comments, reply indicator bar
  - **`EventMediaGalleryScreen`** — photos grid + videos list with tab switching, photo viewer dialog
  - **`StudentEventProfileScreen`** — stats row (registered/attended/missed), registered events list, certificates list, saved events list
  - **`EventSearchScreen`** — live search by title/description/location with results list
- **Nav bar integration** — 6th tab "Events" (calendar icon, index 3) in pill nav bar
- **Router integration** — 12 new routes: `/events`, `/events/create`, `/events/:id/edit`, `/events/my-tickets`, `/events/search`, `/events/ticket/:id`, `/events/:id/checkin`, `/events/:id/dashboard`, `/events/:id/discussions`, `/events/:id/media`, `/events/activity`, `/events/admin`
- **Verification** — `flutter analyze`: **0 errors, 0 warnings**. `flutter build apk --debug`: **APK builds successfully**.

### Done — Session 2026-06-19 (Launch Readiness Sprint)
- **5 parallel audits completed**: FCM push notifications, notification delivery, Global Search, branding/colors, theme/dark mode/loading/empty states.
- **`LAUNCH_READINESS.md` written** — contains 4 deliverables:
  1. **35-item launch blocker ranking** (P0-P3) — 6 P0 (app-crashing), 8 P1 (data/UX failures), 8 P2 (quality gaps), 13 P3 (nice-to-haves)
  2. **Internal Testing Checklist** — 30+ items across all 6 nav tabs + admin + search
  3. **Closed Beta Checklist** — 40+ items: infra, beta management, notification delivery, quality baseline, performance, security
  4. **App Store / Play Store Readiness Checklist** — build/signing, store presence, legal, metadata, pre-submission testing, monitoring
- **Key finding: FCM push notifications are 0% functional** — all code commented out, `firebase_messaging` dep missing, `firebase_options.dart` missing, edge function uses deprecated legacy API, `push_notification_queue` never populated by `create_notification()` RPC.
- **Key finding: 13 broken GoRouter routes** — will cause runtime navigation crashes on `/profile`, marketplace, and opportunities routes.
- **Key finding: `AppEmptyWidget` defined but never used** — ~87 bare `Text('No...')` empty states.
- **Key finding: ~90% of screens use `CircularProgressIndicator`** instead of existing shimmer design system.
- **Key finding: 294 hardcoded hex colors + ~665 `AppColors.*` references** still outside theme files.
- **Estimated effort to production-ready: 8-14 person-days** (parallelizable).

### Done — Session 2026-06-19 (Database Recovery Sprint)
- **9 canonical numbered migrations created** in `mobile_flutter/supabase/migrations/`:
  - `20260619000001_bootstrap.sql` — universities, profiles, announcements, auth triggers, seed GCTU, RLS
  - `20260619000002_community_core.sql` — badges, leadership, communities, managers, verification, community_requests
  - `20260619000003_content.sql` — posts, comments, votes, events, polls, discussions, snapshots, reports, notifications (with auto-count triggers)
  - `20260619000004_events_ticketing.sql` — ALTER community_events (scope/capacity/etc.), tickets, saves, discussions, media, reminders, certificates, RLS
  - `20260619000005_messaging.sql` — conversations, channels, messages, reactions, requests, polls, read receipts, mentions, blocks. **All FKs reference `profiles(id)`**.
  - `20260619000006_academic_hub.sql` — courses, resources, assignments, GPA records, study plans, exam timetables. **All FKs reference `profiles(id)`**.
  - `20260619000007_admin_marketplace.sql` — universities (admin), faculties, departments, admin_roles, administrators, audit_logs, moderation_queue, announcements, opportunities, marketplace_reports, analytics_snapshots, RLS, helper functions (`is_admin`, `is_super_admin`, `get_user_admin_scope`, `log_admin_action`)
  - `20260619000008_reputation_infra.sql` — reputation scores/events, achievements, skills, portfolios, certificates, feature_flags, waitlist, invite codes, beta testers, feedback, system announcements, referrals, analytics_events, user sessions, ambassadors, FAQ, help_articles, support_tickets, abuse_reports, health metrics, error_logs, app_versions, notification_preferences, notification_logs, analytics RPCs
  - `20260619000009_production_fixes.sql` — message_reports, device_tokens, push_notification_queue, missing RLS policies (gpa_courses, study_plan_items, resource_downloads, exam_timetables, academic_resources DELETE, event_media UPDATE, poll_options INSERT, conversations INSERT), GIN search indexes, 25+ missing FK indexes, RPCs (increment_resource_view, get_unread_count, create_notification, seller_rating, marketplace/opportunity RPCs, retention_summary, launch_readiness, system_health, aggregate_daily_analytics with dynamic marketplace lookup), GRANT cleanup (revoke anon on post_votes), no-policy checker, pg_cron guide
- **Schema collision resolved** — Old academic hub (`gpa_entries`, `exam_schedule`, `study_tasks`) archived. New schema (`gpa_records`, `exam_timetables`, `study_plan_items`) is canonical.
- **Root `supabase/` archived** — 27 legacy files (step1–step20, old migrations, schema.sql) moved to `supabase/legacy/`. Only `.temp/` (local CLI config) remains.
- **`DATABASE_REBUILD.md` written** — covers migration ordering, quick start (CLI + SQL Editor), schema collision table, FK fix confirmation (inline in migrations 5/6), edge function deploy, secrets, pg_cron, storage buckets, Firebase setup, verify build.
- **`flutter analyze`**: **0 errors, 0 warnings, 82 infos** (all info-level, no errors or warnings).

### Remaining / Next (Post-Database-Recovery)
- Download `google-services.json` + `GoogleService-Info.plist` from Firebase Console.
- Deploy Edge Functions: `supabase functions deploy send_push_notification --no-verify-jwt` and `daily-analytics --no-verify-jwt`.
- Set FCM secrets: `supabase secrets set FCM_SERVER_KEY=<key>`.
- Apply all 9 migrations via `supabase migration up` or Supabase SQL Editor in order.
- Real device testing for messaging (streaming may need `.eq()` filter on `SupabaseStreamBuilder`).
- Run `flutter build apk --debug` to verify build.

## Key decisions
- **FCM + Sentry + connectivity_plus deps** use try/catch graceful degradation — app works without native configs.
- **Stream vs Select:** Messaging uses Supabase `.stream()`. Filtering with `.eq()` on stream builder not available in supabase 2.12.2 — deferred to RLS.
- **google-services.json + GoogleService-Info.plist** are NOT committed — each developer downloads from Firebase Console.
- **Edge Functions** use `--no-verify-jwt` because they're called by cron/backend, not by authenticated clients.
- **Theme colours:** `Theme.of(context).colorScheme.primary` in build methods; `AppColors.primary` in static/helper contexts.
- **Supabase query chaining:** `.select()` → `PostgrestFilterBuilder` (`.eq()`/`.ilike()`/`.or()`). `.order()` → `PostgrestTransformBuilder` (no filter methods). Apply filters BEFORE `.order()`.

## Relevant Files (Messaging)
- `supabase/step12_messaging_system.sql` — Full schema + RLS
- `lib/features/messaging/data/models/conversation_model.dart`
- `lib/features/messaging/data/models/message_model.dart`
- `lib/features/messaging/data/models/channel_model.dart`
- `lib/features/messaging/domain/repositories/messaging_repository.dart`
- `lib/features/messaging/data/repositories/messaging_repository_impl.dart`
- `lib/features/messaging/presentation/providers/messaging_provider.dart`
- `lib/features/messaging/presentation/screens/messaging_screen.dart`
- `lib/features/messaging/presentation/screens/chat_screen.dart`
- `lib/features/messaging/presentation/screens/channel_view_screen.dart`
- `lib/features/messaging/presentation/screens/message_requests_screen.dart`
- `lib/features/messaging/presentation/screens/student_directory_screen.dart`
- `lib/features/messaging/presentation/screens/create_group_screen.dart`

## Relevant Files (Academic Hub)
- `supabase/step13_academic_hub.sql` — Full schema + RLS
- `lib/features/academic/data/models/academic_models.dart`
- `lib/features/academic/domain/repositories/academic_repository.dart`
- `lib/features/academic/data/repositories/academic_repository_impl.dart`
- `lib/features/academic/presentation/providers/academic_provider.dart`
- `lib/features/academic/presentation/screens/academic_hub_screen.dart`
- `lib/features/academic/presentation/screens/course_page_screen.dart`
- `lib/features/academic/presentation/screens/course_list_screen.dart`
- `lib/features/academic/presentation/screens/notes_repository_screen.dart`
- `lib/features/academic/presentation/screens/assignment_hub_screen.dart`
- `lib/features/academic/presentation/screens/exam_prep_center_screen.dart`
- `lib/features/academic/presentation/screens/gpa_calculator_screen.dart`
- `lib/features/academic/presentation/screens/study_planner_screen.dart`
- `lib/features/academic/presentation/screens/academic_search_screen.dart`

## Relevant Files (Events & Ticketing)
- `supabase/step14_events_ticketing_platform.sql` — Full schema + RLS
- `lib/features/events/data/models/event_model.dart` — All event & ticketing models
- `lib/features/events/domain/repositories/event_repository.dart` — Abstract repository
- `lib/features/events/data/repositories/event_repository_impl.dart` — Full Supabase repo
- `lib/features/events/presentation/providers/event_provider.dart` — All providers
- `lib/features/events/presentation/widgets/event_card.dart` — Event card widget
- `lib/features/events/presentation/screens/events_screen.dart` — Discovery tab
- `lib/features/events/presentation/screens/create_event_screen.dart` — Event creation
- `lib/features/events/presentation/screens/event_detail_screen.dart` — Event detail (enhanced)
- `lib/features/events/presentation/screens/my_tickets_screen.dart` — User tickets
- `lib/features/events/presentation/screens/ticket_screen.dart` — Single ticket w/ QR
- `lib/features/events/presentation/screens/qr_checkin_screen.dart` — Check-in
- `lib/features/events/presentation/screens/organizer_dashboard_screen.dart` — Org dashboard
- `lib/features/events/presentation/screens/admin_event_dashboard_screen.dart` — Admin
- `lib/features/events/presentation/screens/event_discussion_screen.dart` — Discussion
- `lib/features/events/presentation/screens/event_media_gallery_screen.dart` — Media gallery
- `lib/features/events/presentation/screens/student_event_profile_screen.dart` — Profile
- `lib/features/events/presentation/screens/event_search_screen.dart` — Search

### Done — Multi-University Administration System
- **Supabase SQL (step16)** — `universities`, `faculties`, `departments`, `admin_roles`, `university_administrators`, `audit_logs`, `moderation_queue`, `admin_announcements`, `admin_announcement_recipients`, `opportunities`, `marketplace_reports`, `analytics_snapshots`. Full RLS by role scope + helper functions (`is_admin`, `is_super_admin`, `get_user_admin_scope`, `log_admin_action`).
- **Data models (11)** — `UniversityModel`, `FacultyModel`, `DepartmentModel`, `AdminRoleModel`, `AdministratorModel`, `AuditLogModel`, `ModerationItemModel`, `AdminAnnouncementModel`, `OpportunityModel`, `MarketplaceReportModel`, `AnalyticsSnapshotModel`.
- **Repository** — `AdminRepositoryImpl` (40+ methods): CRUD for universities/faculties/departments, admin assignment, verification approve/reject, badge assign/revoke, moderation queue, marketplace reports, opportunities approval, analytics snapshots, audit logs, announcements, dashboard counts.
- **Riverpod providers** — `adminRepositoryProvider`, `currentUserIdProvider`, `universitiesProvider`, `facultiesProvider`, `departmentsProvider`, `adminRolesProvider`, `administratorsProvider`, `moderationQueueProvider`, `pendingModerationProvider`, `marketplaceReportsProvider`, `opportunitiesProvider`, `auditLogsProvider`, `adminAnnouncementsProvider`, `latestAnalyticsProvider`, `dashboardCountsProvider`, `currentUserAdminRoleProvider`, `adminVerificationRequestsProvider`, `pendingVerificationRequestsProvider`.
- **Screens (15)** — `MultiUniversityAdminScreen` (5-tab dashboard), `UniversityManagementScreen` (CRUD), `ModerationCenterScreen`, `VerificationManagementScreen`, `OpportunitiesAdminScreen`, `CommunicationCenterScreen`, `AnalyticsDashboardScreen`, `AuditLogsScreen`, `AdminManagementScreen`, `CommunityAdminScreen`, `MarketplaceAdminScreen`, `EventsAdminScreen`, `AcademicAdminScreen`.
- **Router** — 14 new admin routes under `/admin/*`: `/admin`, `/admin/universities`, `/admin/moderation`, `/admin/verification`, `/admin/opportunities`, `/admin/communication`, `/admin/audit-logs`, `/admin/admins`, `/admin/communities`, `/admin/marketplace`, `/admin/events`, `/admin/academic`, `/admin/analytics`, `/admin/legacy`.
- **Reusable widgets** — `AdminStatTile`, `AdminSectionCard`, `AdminActionCard`, `StatusBadge`, `timeAgo()`.
- **Verification** — `flutter analyze`: **0 errors, 0 warnings** on admin feature files.

## Relevant Files (Production Readiness — New/Modified)
- `supabase/functions/send_push_notification/index.ts` — Edge Function: reads queue, calls FCM v1, updates status
- `supabase/functions/daily-analytics/index.ts` — Edge Function: calls `aggregate_daily_analytics()`
- `supabase/step18_remaining_fixes.sql` — GRANT revocation, missing indexes, pg_cron scheduling guide
- `scripts/setup_firebase.sh` — Step-by-step Firebase config guide
- `lib/core/services/push_notification_service.dart` — FCM init, permission, token registration, foreground/background handling
- `lib/core/services/push_notification_provider.dart` — Push notification Riverpod provider
- `lib/core/services/connectivity_service.dart` — Connectivity monitoring + provider
- `lib/core/services/cache_service.dart` — Hive-based offline cache with 6h TTL
- `lib/core/services/core_service_providers.dart` — Core service Riverpod providers
- `lib/core/services/crash_reporting_service.dart` — Sentry init + error capture (graceful no-op)
- `lib/core/services/bootstrap.dart` — App startup: Firebase, Sentry, error handlers
- `lib/core/widgets/main_shell.dart` — Accessibility Semantics on nav bar
- `lib/core/widgets/app_button.dart` — Accessibility Semantics
- `lib/main.dart` — Env var null safety

## Critical context
- Flutter SDK 3.41.7, Dart 3.11.5
- supabase_flutter 2.14.2, supabase 2.12.2 — `.in_()` NOT available
- SupabaseStreamBuilder in supabase 2.12.2 — `.eq()` not available on stream builder (use `.select().eq().stream()` or filter at query level before `.stream()`)
- Supabase query chaining: `.select()` → `PostgrestFilterBuilder` (has `.eq()`/`.ilike()`/`.or()`). `.order()` → `PostgrestTransformBuilder` (NO filter methods). Apply filters BEFORE `.order()`.
- JDK 21.0.10 at `C:\Program Files\Android\Android Studio\jbr`
- `$env:JAVA_HOME` must be set before `flutter build`
- Theme: `ThemePreset` (6 presets), `ThemeNotifier` (Riverpod, persisted), `context.primary` extension
- `auth.uid()` returns a UUID matching `auth.users.id` — this is the value stored in all `created_by`, `user_id`, `author_id` columns
- `push_notification_queue` table: `id UUID, user_id UUID, title TEXT, body TEXT, data JSONB, status TEXT, created_at TIMESTAMPTZ`
- `device_tokens` table: `token TEXT, user_id UUID, platform TEXT, is_active BOOLEAN, created_at TIMESTAMPTZ`
- **`users(id)` does not exist in `public` schema** — all FKs in step12 (messaging) + step13 (academic) reference `users(id)` but the correct target is `profiles(id)`. This is the ROOT CAUSE of all PGRST200 relationship errors (including `message_requests.from_user_id`). Fix in `step_fix_database_relationships.sql`.
- **All 123 tables are documented in SQL** — Full audit confirmed every Flutter-referenced table has `CREATE TABLE` in at least one of the 30 SQL files. No undocumented tables exist. However, the **dual supabase directory** (root + `mobile_flutter/`) creates schema collision, especially for academic hub tables (old: `gpa_entries`/`exam_schedule`/`study_tasks` vs new: `gpa_records`/`exam_timetables`/`study_plan_items`).

### Done — Session 2026-06-19 (Audit + Fix)
- **Full audit delivered** — 14-module scoring, top-20 issues, GCTU launch verdict (🟡 CONDITIONAL PASS).
- **Academic hub fixed** — 90→0 errors across 8 screen files + 1 widget file + repository + providers. Fixed model references (`ResourceModel`→`AcademicResourceModel`, `title`→`name`, `isDone`→`isSubmitted`, `dueAt`→`dueDate`, `comment`→`review`, `ResourceType`→string, `ResourceVerification`→string, `examsProvider`→`examTimetablesProvider`, etc.). Added `getResource()` to repository, `myAssignmentsProvider`, `resourceDetailProvider`, `academicStatsProvider`, `facultiesProvider`, `departmentsProvider`, `offlineResourcesProvider` to provider layer.
- **`step16_admin_system.sql` created** — 12 tables (universities, faculties, departments, admin_roles, university_administrators, audit_logs, moderation_queue, admin_announcements, admin_announcement_recipients, opportunities, marketplace_reports, analytics_snapshots), 30+ RLS policies, 4 helper functions (is_admin, is_super_admin, get_user_admin_scope, log_admin_action), seeded admin roles, ALTER TABLE for verification_requests.
- **`flutter analyze`** — **0 errors, 0 warnings, 39 infos** (down from 90 errors + 3 warnings + 35 infos).
- **`flutter build apk --debug`** — builds successfully.
- **Remaining infos**: 35 `prefer_const_constructors`, 2 `dangling_library_doc_comments`, 2 deprecated Radio groupValue/onChanged in verification_request_screen, 1 deprecated anonKey in main.dart.

### Done — Session 2026-06-19 (Error Handling & User Feedback Overhaul)
- **Centralized `ErrorMapper`** (`lib/core/errors/error_mapper.dart`): maps all exception types (Auth, Postgrest, Network, Format, Storage, Permission, Duplicate, FK, RLS) to user-friendly messages. Technical details logged via `debugPrint`. Handles 15+ auth sub-conditions, 10+ database error codes.
- **`UnifySnackbar`** (`lib/core/widgets/unify_snackbar.dart`): branded snackbar variants (success/error/warning/info) with UNIFY design colors, floating rounded cards, icon + text layout, dismiss action, optional retry button.
- **`AppErrorWidget`** (`lib/core/widgets/app_error_widget.dart`): drop-in replacement for `Center(child: Text('Error: $e'))` in Riverpod `AsyncValue.when(error:)` callbacks. Shows error icon, user-friendly message, optional retry button.
- **`AppEmptyWidget`** (`lib/core/widgets/app_empty_widget.dart`): contextual empty state with icon, title, subtitle, optional action button — replaces bare `'No data'` text.
- **~105 raw exception leak points eliminated** across 89 files:
  - ~88 `Text('Error: $e')` / `Text('$e')` / `Text('Could not load: $e')` patterns → `AppErrorWidget(e)` or `ErrorMapper.toUserMessage(e)`
  - ~38 `SnackBar(content: Text('Error: $e'))` patterns → `UnifySnackbar.error(context, ErrorMapper.toUserMessage(e))`
  - ~113 silent `catch (_) {}` blocks in 25 repository/provider/service files → now log via `debugPrint('[ClassName] Error: $e')`
- **`flutter analyze`**: **0 errors, 0 warnings, 87 infos** (down from ~90+ raw exception exposures). All infos are pre-existing `prefer_const_constructors` / `deprecated_member_use` / `use_build_context_synchronously`.
- **Remaining infos**: 87 total — all info-level, no errors or warnings. Pre-existing issues: `prefer_const_constructors` (~50), `deprecated_member_use` (~15), `use_build_context_synchronously` (~4), `dangling_library_doc_comments` (~1), `prefer_final_fields` (~1), etc.

### Done — Session 2026-06-19 (Database Relationship Audit)
- **Full database relationship audit** — Cross-referenced all 7 SQL migration files against 150+ Flutter Supabase queries across the codebase.
- **Root cause of PGRST200** — `message_requests.from_user_id` FK references `users(id)` but `users` table doesn't exist in `public` schema → FK silently dropped → PostgREST has no relationship metadata → **every relational select on messaging/academic tables fails**.
- **`step_fix_database_relationships.sql` created** — 500+ line migration that:
  - Recreates all 25+ broken FKs from `users(id)` to `profiles(id)` across messaging + academic tables
  - Adds missing FK on `marketplace_reports.listing_id`
  - Adds `message_requests.preview_content` column (Flutter code inserts it but it's not in schema)
  - Creates 18 missing RPC functions (`create_notification`, `get_unread_count`, `analytics_overview`, `dau_series`, etc.)
  - Adds 20+ missing FK-column indexes
  - Makes `aggregate_daily_analytics` marketplace table dynamic
  - Verifies total FK count in public schema

## Database Relationship Audit Report
### 🔴 Critical — Causes Runtime Failures

| # | Issue | Impact | Fix |
|---|-------|--------|-----|
| 1 | **25+ FKs reference `users(id)` instead of `profiles(id)`** in step12+step13 | All relational selects on messaging & academic tables return PGRST200 | `step_fix_database_relationships.sql` section 1 |
| 2 | **29 explicit `!fkey` relational selects** depend on missing FKs | `profiles!message_requests_from_user_id_fkey(...)` etc. all fail | Section 1 (same fix) |
| 3 | **`message_requests.preview_content` missing** | Insert at `messaging_repository_impl.dart:221` silently drops column or errors | Section 1d |
| 4 | **~20 tables have NO SQL in repo** (community_posts, notifications, community_events, etc.) | Flutter code queries tables that may not exist in DB or may have wrong schema | Requires manual DDL export |
| 5 | **`marketplace_reports.listing_id` has NO FK** | Orphaned reports when listings deleted | Section 2 |
| 6 | **`message_reports.message_id` + `conversation_id` have NO FKs** | Orphaned reports, no cascade delete | Section 2 |
| 7 | **18 RPC functions called from Flutter but not defined** | `create_notification`, `get_unread_count`, `analytics_overview`, etc. → runtime 400 errors | Section 4 |

### 🟠 High — Will Fail at Scale

| # | Issue | Impact | Fix |
|---|-------|--------|-----|
| 8 | **No FK column indexes** on 20+ FK columns | Sequential scans on every join as data grows → severe perf degradation | Section 3 |
| 9 | **Missing RLS policies** on gpa_courses, study_plan_items, resource_downloads (fixed in step17) | Data leaks or write denials | Already fixed |
| 10 | **step16_admin_system.sql + step16_multi_university_admin.sql are DUPLICATE** | Second file may error on CREATE TABLE for existing tables (uses IF NOT EXISTS, but DROP/CREATE cycle would lose data) | Section 6 (documented) |
| 11 | **`aggregate_daily_analytics` references `marketplace_items`** hardcoded | Wrong table name → 0 marketplace count | Section 5 (dynamic lookup) |
| 12 | **`moderation_queue.target_id` has NO FK** (polymorphic, but no CHECK constraint) | Can store garbage UUIDs | Section 2 (added CHECK) |

### 🟡 Medium — Technical Debt

| # | Issue | Impact | Fix |
|---|-------|--------|-----|
| 13 | **Conversation participants RLS check uses correlated subquery** | Per-row subquery on every SELECT → slow at scale | Add materialized view or use `auth.uid()` IN filter |
| 14 | **No `updated_at` trigger on any table** | Many tables have `updated_at` column but no auto-update trigger | Add `moddatetime` trigger |
| 15 | **Duplicate FK indexes** (e.g., `idx_conversation_participants_user` defined in step12, step17, step18) | Wasted space, minor insert perf hit | Deduplicate |
| 16 | **`count_rows()` RPC uses dynamic SQL** | SQL injection risk via `quote_ident` bypass | Use fixed queries instead |
| 17 | **39 `prefer_const_constructors` infos** | Code hygiene | Fix with `dart fix --apply` |

### 🟢 Low — Nice-to-Have

| # | Issue | Impact | Fix |
|---|-------|--------|-----|
| 18 | Add `on_delete CASCADE` to all polymorphic FKs where appropriate | Cleaner data lifecycle | Manual review |
| 19 | Create consolidated `schema.sql` from all step files | Single source of truth | Manual |
| 20 | Add `created_at`/`updated_at` audit columns consistently | Missing on some tables | Manual |

## Immediate Action Required
1. **Run `step_fix_database_relationships.sql` in Supabase SQL Editor** — This fixes the PGRST200 error and all broken FKs referencing `users(id)`.
2. **Consolidate all 30 SQL files into `mobile_flutter/supabase/migrations/`** — Create canonical numbered sequence (`001_*.sql` → `NNN_*.sql`), resolving schema collision between old and new academic hub variants.
3. **Run `flutter analyze` and `flutter build apk --debug`** to verify.

## Relevant Files (Database Recovery Sprint)
- `mobile_flutter/supabase/step12_messaging_system.sql` — Messaging schema (12 tables, broken FKs to `users(id)`)
- `mobile_flutter/supabase/step13_academic_hub.sql` — Academic hub (new schema: `gpa_records`, `exam_timetables`, `study_plan_items` — Flutter-compatible)
- `mobile_flutter/supabase/step15_reputation_identity.sql` — Reputation + identity (correct FKs to `profiles(id)`)
- `mobile_flutter/supabase/step16_admin_system.sql` — Admin tables
- `mobile_flutter/supabase/step17_production_readiness.sql` — Missing tables + RLS fixes
- `mobile_flutter/supabase/step18_remaining_fixes.sql` — Indexes + cron
- `mobile_flutter/supabase/step_fix_database_relationships.sql` — FK fix for `users(id)`→`profiles(id)`
- `supabase/` (root) — ~21 files (legacy, will be archived after consolidation)
- `mobile_flutter/supabase/migrations/` — **Canonical target directory** (to be created)

## Relevant Files (Database Audit)
- `supabase/step_fix_database_relationships.sql` — Complete fix migration
- `supabase/step12_messaging_system.sql` — Source of broken FKs (references `users(id)`)
- `supabase/step13_academic_hub.sql` — Source of broken FKs (references `users(id)`)
- `supabase/step15_reputation_identity.sql` — Correct FK pattern (references `profiles(id)`)
- `supabase/step16_admin_system.sql` — Admin tables (correct FKs)
- `supabase/step16_multi_university_admin.sql` — Duplicate of step16
- `supabase/step17_production_readiness.sql` — Missing tables + RLS fixes
- `supabase/step18_remaining_fixes.sql` — Indexes + cron

## Relevant Files (Error Handling)
- `lib/core/errors/error_mapper.dart` — Centralized exception-to-user-message mapper (Auth, DB, Network, etc.)
- `lib/core/widgets/unify_snackbar.dart` — Branded snackbar (success/error/warning/info) with optional retry
- `lib/core/widgets/app_error_widget.dart` — Drop-in replacement for `Text('Error: $e')` in `.when(error:)`
- `lib/core/widgets/app_empty_widget.dart` — Contextual empty state with icon + action

### Done — Session 2026-06-19 (Quality Sprint — Error Cleanup + Unbounded Queries)
- **10 bare `Text('$e')` error screens eliminated** — Replaced with `AppErrorWidget(e, onRetry: ...)` in profile, events, and messaging screens (`profile_screen.dart`, `events_screen.dart`, `event_search_screen.dart`, `my_tickets_screen.dart`, `admin_event_dashboard_screen.dart`, `event_media_gallery_screen.dart`, `organizer_dashboard_screen.dart`, `conversations_list_screen.dart`, `message_requests_screen.dart`, `messages_shell_screen.dart`, `channel_view_screen.dart`, `student_directory_screen.dart`).
- **3 critical unbounded queries fixed** — `getDiscussions`, `getComments`, `getPosts` now use `.eq()` server-side filter + `.limit(50-100)` instead of fetching ALL rows and filtering client-side.
- **`searchCommunities` fixed** — Uses `.ilike()` + `.eq('is_active', true)` instead of client-side filtering of all communities.
- **Profile save success snackbar** — `edit_profile_screen.dart` now shows `UnifySnackbar.success('Profile updated!')` before popping.
- **2 bare `SnackBar` calls eliminated** — Profile share action + event detail reminders now use `UnifySnackbar`.
- **Branding consistency** — Replaced `AppColors.primary`/`AppColors.error`/`AppColors.success`/`AppColors.warning` with `context.primary`/`context.error`/`context.success`/`context.warning` in profile screen & edit profile screen (~12 references).
- **2 `withOpacity` → `withValues` fixes** in `app_error_widget.dart` and `app_empty_widget.dart`.
- **Dead code cleanup** — Removed `_ErrorView` class (replaced by `AppErrorWidget`).
- **`flutter analyze`** — **0 errors, 0 warnings, 89 infos** (down from 93).

### Done — Session 2026-06-19 (Quality Sprint 2 — Full Audit + 82 Fixes)
- **16 critical unbounded queries fixed** — Added `.limit(100)` + server-side `.eq()` filters to ambassador, growth, system, post, poll, resource, reputation, report, leadership, feedback repos. Eliminated all client-side filtering patterns.
- **6 raw exception paths fixed** — `qr_checkin_screen.dart`, `organizer_dashboard_screen.dart`, `onboarding_screen.dart`, `auth_screen.dart`, `resource_upload_screen.dart` now use `AppErrorWidget`/`UnifySnackbar`/`ErrorMapper`.
- **Feed search button fixed** — `feed_screen.dart:125` `onPressed: () {}` → `context.push('/search')`.
- **~40 hardcoded colors replaced** — Across messaging, academic, profile, feedback, admin screens: `AppColors.*` → `context.*` theme extension.
- **6 `withOpacity` → `withValues(alpha:)` fixes** — All remaining deprecated opacity calls in messaging widgets eliminated. **0 withOpacity calls remain** in the entire lib/ tree.
- **2 unused imports removed** — `splash_screen.dart` (theme_extensions), `feed_provider.dart` (dart:convert).
- **`flutter analyze`** — **0 errors, 0 warnings, 82 infos** (down from 93).
- **Events schema verified fully consistent** — No mismatches between Dart model fields, repository column names, and SQL schema across all 7 event tables.
- **Database relationship fix SQL confirmed** — `step_fix_database_relationships.sql` (644 lines) covers all 25+ broken FKs, indexes, RPC functions, and migration fixes.
- **Notification infrastructure audited** — Graceful no-op pattern intentional. 6 issues documented for post-launch.
- **Global search audited** — Feed search dead link fixed. 2 orphaned search screens documented. Debounce gap documented.
