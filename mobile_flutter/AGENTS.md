# UNIFY Mobile — Session State

## Goal
Complete full production-readiness audit and fix all errors/warnings for GCTU launch.

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

### Remaining / Next
- Download `google-services.json` → `android/app/` from Firebase Console.
- Download `GoogleService-Info.plist` → `ios/Runner/` from Firebase Console.
- Deploy Edge Functions: `supabase functions deploy send_push_notification --no-verify-jwt` and `supabase functions deploy daily-analytics --no-verify-jwt`.
- Set secrets: `supabase secrets set FCM_SERVER_KEY=<key>`.
- Run `step18_remaining_fixes.sql` in Supabase SQL Editor (GRANT revocation + indexes).
- Schedule cron jobs via Supabase Dashboard → Database → Cron Jobs (or use pg_cron).
- Run `flutter build apk --debug` to verify build.
- Real device testing for messaging (streaming may need `.eq()` filter on `SupabaseStreamBuilder`).
- `test/widget_test.dart` references `MyApp` (app entry is `UnifyApp` in `lib/app.dart`).

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
