# Launch Readiness Report — UNIFY Mobile

Generated: 2026-06-19
Flutter analyze: **0 errors, 0 warnings, 82 infos**
Database: 9 canonical migrations complete, root `supabase/legacy/` archived

---

## 1. Launch Blocker Ranking (by Impact)

### 🔴 P0 — App Crashes or Core Feature Broken

| # | Blocker | Files | Effort | Fix |
|---|---------|-------|--------|-----|
| 1 | **13 broken GoRouter routes cause runtime crashes** | `app_router.dart` missing: `/profile`, `/marketplace/search`, `/opportunities/search`, `/marketplace/sell`, `/marketplace/saved`, `/marketplace/mine`, `/opportunities/deadlines`, `/opportunities/saved`, `/marketplace/category/:key`, `/opportunities/type/:key`, `/marketplace`, `/opportunities` | 2h | Add all 13 missing routes + screens or redirect to existing pages |
| 2 | **FCM push notifications are completely stubbed — 0% functional** | `push_notification_service.dart` (all FCM code commented out), `pubspec.yaml` missing `firebase_messaging`, `main.dart` missing `Firebase.initializeApp()`, no `firebase_options.dart` | 4-6 days | Add deps, generate config, uncomment FCM code, wire auth lifecycle, implement background handler + deep link routing |
| 3 | **`create_notification` RPC parameter names wrong at 4 call sites** — admin-action notifications silently fail | `admin_screen.dart:588,661,672,1311` passes `p_message`/`p_ref_id`/`p_ref_type` instead of `p_body`/`p_reference_id`/`p_reference_type` | 10min | Fix param names in all 4 RPC calls |
| 4 | **`unreadCountStream` Realtime subscription has no `.eq('user_id', userId)` filter** — receives ALL users' events | `notification_repository_impl.dart:26-31` | 5min | Add `.eq('user_id', userId)` before `.stream()` |
| 5 | **`push_notification_queue` never populated** — `create_notification()` RPC doesn't insert into queue, so Edge Function has nothing to send | `migrations/20260619000003_content.sql:827` and `migrations/20260619000009_production_fixes.sql` | 30min | Add `INSERT INTO push_notification_queue` inside `create_notification()` RPC, or create a separate trigger |
| 6 | **Edge Function uses deprecated legacy FCM API** — `fcm.googleapis.com/fcm/send` with server key, may be disabled on new Firebase projects | `supabase/functions/send_push_notification/index.ts` | 2-4h | Migrate to FCM v1 HTTP API with OAuth2 Bearer token |

### 🟠 P1 — Data Integrity, Performance, and UX Failures

| # | Blocker | Files | Effort | Fix |
|---|---------|-------|--------|-----|
| 7 | **`AppEmptyWidget` is never used anywhere** — all ~87 empty states are bare `Text('No...')` widgets, many with non-theme colors | All screen files across events, academic, messaging, admin, marketplace, opportunities, community, profile, notifications | 4-6h | Replace all bare `Text('No...')` empty states with `AppEmptyWidget` |
| 8 | **~90% of screens use `CircularProgressIndicator` instead of shimmer** — layout jumps, poor perceived performance | ~50+ screens across events, academic, admin, marketplace, opportunities, messaging sub-screens | 6-8h | Replace with `UShimmerCard`/`UShimmerBox` from existing design system |
| 9 | **294 hardcoded `Color(0xFF...)` hex codes outside theme files** — won't adapt to dark mode | ~55 files, worst: `profile_screen.dart` (34), `multi_university_admin_screen.dart` (13), `components.dart` (12), `class_rep_dashboard_screen.dart` (11), `feed_screen.dart` (10) | 4-6h | Replace with `context.*` theme tokens; add 6 missing accessors: `brandOrange`, `gold`, `blueTint`, `blueLight`, `blueBorder`, `violet` |
| 10 | **~665 `AppColors.*` references still in use** — legacy static color class not yet migrated | ~60 files, worst: `ambassador_profile_screen.dart` (17), `ambassador_detail_screen.dart` (17), `ambassador_admin_screen.dart` (18), `community_card.dart` (10) | 4-6h | Replace with `context.*` tokens inside `build()` methods |
| 11 | **Admin notification queries unbounded** — no `.limit()` fetches ALL rows then filters client-side | `admin_notification_center_screen.dart`, `admin_screen.dart:84-93` | 20min | Add `.limit(50)` + server-side `.eq()` filter |
| 12 | **Global search community query missing `is_active` filter** — may show inactive/hidden communities | `search_provider.dart` | 5min | Add `.eq('is_active', true)` |
| 13 | **Global search has no university scoping** — shows results from all universities | `search_provider.dart`, all search screens | 30min | Add `.eq('university_id', userUniversityId)` or equivalent join filter |

### 🟡 P2 — Quality and Consistency

| # | Blocker | Files | Effort | Fix |
|---|---------|-------|--------|-----|
| 14 | **Community home screen error states** — all 5 tabs use bare `Text('Error loading...')` | `community_home_screen.dart` (all tabs) | 30min | Replace with `AppErrorWidget(e, onRetry: ...)` |
| 15 | **EventSearchScreen and AcademicSearchScreen missing debounce** — fires Supabase query on every keystroke | `event_search_screen.dart`, `academic_search_screen.dart` | 20min | Add 300ms debounce via `Timer` cancel/reschedule |
| 16 | **Global search opportunity tiles are unclickable** — `_OpportunityTile` has no `onTap` | `search_screen.dart` | 10min | Wire `onTap` to opportunity detail route |
| 17 | **Global search hard-limits to 5 results per scope** with no "see all" link | `search_screen.dart`, `search_provider.dart` | 1h | Add "View all X results" links that navigate to dedicated module search |
| 18 | **Streaming `.eq()` required for messaging** — Supabase 2.12.2 doesn't support `.eq()` on stream builder | Deferred to RLS but needs verification | 2h | Test messaging streams at scale; add server-side filter if RLS insufficient |
| 19 | **All 12 event screens lack shimmer loading** — bare `CircularProgressIndicator` | All event screens | 2h | Add `UShimmerCard` loading pattern |
| 20 | **All 15+ academic screens lack shimmer loading** — bare `CircularProgressIndicator` | All academic screens | 3h | Add `UShimmerCard` loading pattern |
| 21 | **Dark mode rendering issues in ~30+ screens** — uses `Colors.grey[200]`, `Colors.white`, hardcoded hex that won't adapt | community_home_screen, conversations_list_screen, messages_shell_screen, channel_view_screen, many admin screens | 3-5h | Replace with `context.*` theme tokens (covered by item 9) |

### 🟢 P3 — Nice-to-Have

| # | Blocker | Files | Effort | Fix |
|---|---------|-------|--------|-----|
| 22 | `flutter_dotenv` anonKey deprecation warning | `main.dart:21` | 5min | Use `publishableKey` instead |
| 23 | `groupValue`/`onChanged` deprecation on `Radio` — use `RadioGroup` | `verification_request_screen.dart`, `report_screen.dart` | 30min | Migrate to `RadioGroup` ancestor |
| 24 | `surfaceVariant` deprecation — use `surfaceContainerHighest` | `app_theme.dart:244` | 5min | Replace deprecated token |
| 25 | `value` → `initialValue` on `RadioListTile` / `DropdownButtonFormField` | `gpa_calculator_screen.dart`, `resource_upload_screen.dart`, `beta_admin_screen.dart` | 20min | Rename parameter |
| 26 | `activeColor` → `activeThumbColor` on `Switch` | `announcements_admin_screen.dart`, `app_version_admin_screen.dart` | 10min | Rename parameter |
| 27 | `prefer_const_constructors` (~50 infos) | Various | 30min | `dart fix --apply` (may need manual review) |
| 28 | `dangling_library_doc_comment` (1) | `system_models.dart` | 2min | Remove doc comment above `library` |
| 29 | `prefer_final_fields` (1) | `crash_reporting_service.dart` | 2min | Add `final` keyword |
| 30 | `prefer_typing_uninitialized_variables` (2) | `community_detail_screen.dart` | 5min | Add type annotations |
| 31 | `sort_child_properties_last` (2) | `message_bubble.dart` | 5min | Move `child:` parameter last |
| 32 | `non_constant_identifier_names` (1) | `create_group_screen.dart` | 5min | Rename `_TypeChip` to `_typeChip` |
| 33 | `unnecessary_import` (2) | `marketplace_repository_impl.dart`, `snapshots_repository_impl.dart` | 2min | Remove unused imports |
| 34 | `unnecessary_getters_setters` (1) | `message_model.dart` | 2min | Inline getter/setter |
| 35 | `depend_on_referenced_packages` (1) | `resource_upload_screen.dart` | 5min | Add `path_provider` to `pubspec.yaml` or remove import |

---

## 2. Internal Testing Checklist

### Prerequisites
- [ ] All 9 Supabase migrations applied (bootstrap → production_fixes)
- [ ] `flutter analyze` shows **0 errors, 0 warnings** (currently 82 infos)
- [ ] APK builds successfully: `flutter build apk --debug`
- [ ] Test accounts created: student, admin, super_admin

### Auth & Onboarding
- [ ] Email/password sign-up creates profile via auth trigger
- [ ] Onboarding carousel displays and completes
- [ ] Welcome screen confirms university assignment (GCTU)
- [ ] Sign-out and sign-in flow works end-to-end

### Feed (Tab 1)
- [ ] Feed loads with community posts
- [ ] Infinite scroll works (pagination)
- [ ] Bell icon shows unread notification badge count
- [ ] Search icon navigates to `/search`
- [ ] Pull-to-refresh works
- [ ] Error/loading/empty states render correctly

### Hubs / Communities (Tab 2)
- [ ] Communities list loads
- [ ] Join community works
- [ ] Community home 5-tab layout renders (Announcements, Discussions, Events, Resources, Members)
- [ ] Create post (text/image/poll) works
- [ ] Create event from community works
- [ ] Upload resource works
- [ ] Member list loads and search works
- [ ] All 5 tabs handle loading/error states correctly

### Messaging (Tab 3)
- [ ] Conversations list loads
- [ ] Send direct message to another user
- [ ] Create group chat with 2+ participants
- [ ] Messages send and appear in real-time
- [ ] Message reactions (emojis) work
- [ ] Message requests (DM non-connected users) work
- [ ] Student directory search works
- [ ] Read receipts display correctly
- [ ] Unread count shows on conversation list
- [ ] Channel view (Discord-style) works for communities

### Study / Academic Hub (Tab 4)
- [ ] Academic home loads with 6 action cards
- [ ] Course list with department/faculty/level filter chips
- [ ] Course detail 4-tab layout (Overview, Notes, Assignments, Exams)
- [ ] Notes repository with file type icons, filters
- [ ] Assignment hub with due date countdown
- [ ] Exam prep timetable with countdown widget
- [ ] GPA calculator with per-semester entry and CGPA rollup
- [ ] Study planner with progress bars and completion toggles
- [ ] Academic search works

### Events (Tab 5)
- [ ] Events discovery loads (Upcoming/Trending/Featured tabs)
- [ ] Scope filter chips (All/Community/Faculty/University/Campus)
- [ ] Create event form saves correctly
- [ ] Event detail with RSVP bottom sheet
- [ ] Register for event generates ticket with QR code
- [ ] My Tickets shows registered events
- [ ] Event search works with debounce
- [ ] Event discussions (Q&A) work
- [ ] Event media gallery loads

### Profile (Tab 6)
- [ ] Profile loads with user info, badges, stats
- [ ] Edit profile saves changes
- [ ] Settings screen: theme mode toggle (System/Light/Dark)
- [ ] Settings screen: theme preset picker (6 colors)
- [ ] Notification preferences screen accessible
- [ ] Sign-out works

### Admin Dashboard
- [ ] Multi-university admin dashboard loads 5 tabs
- [ ] Verification requests: approve/reject flow
- [ ] Moderation queue: review/dismiss actions
- [ ] Admin broadcast notification sends
- [ ] Analytics dashboard renders stats

### Global Search
- [ ] `/search` loads from feed/hubs search icon
- [ ] 5 parallel scope queries: Students, Communities, Events, Resources, Opportunities
- [ ] Debounce (300ms) prevents excessive queries
- [ ] Tapping student result doesn't crash (P0 — route needed)
- [ ] Tapping marketplace/opportunity search doesn't crash (P0)

### Crash / Regression
- [ ] Navigate all tabs without crash
- [ ] All 13 broken routes tested (expect navigation to work after fix)
- [ ] Offline state: app degrades gracefully (shows cached data or error message)
- [ ] Deep link: notification tap navigates to correct screen
- [ ] Hot restart from any screen works

---

## 3. Closed Beta Checklist

### Pre-Beta Infrastructure
- [ ] Crash reporting: Sentry project created, `SENTRY_DSN` configured in `.env`
- [ ] Push notifications: `firebase_messaging` deps added, FCM code uncommented, working end-to-end
- [ ] Push notifications: `push_notification_queue` populated by `create_notification()` RPC
- [ ] Push notifications: Edge Function migrated to FCM v1, `GOOGLE_APPLICATION_CREDENTIALS` set
- [ ] Push notification deep link routing: `_handleDeepLink()` implemented, routes by `click_action` payload
- [ ] Background message handler: `FirebaseMessaging.onBackgroundMessage` registered
- [ ] All 13 broken GoRouter routes fixed
- [ ] `flutter analyze`: 0 errors, 0 warnings
- [ ] `flutter build apk --release` builds successfully
- [ ] `supabase functions deploy send_push_notification --no-verify-jwt` deployed
- [ ] `supabase functions deploy daily-analytics --no-verify-jwt` deployed

### Beta Management Infrastructure
- [ ] Beta tester table (`beta_testers`) has data: testers assigned to `beta-1` cohort
- [ ] Feature flags table has 15 features, correct flags enabled for beta:
  - [ ] `communities` = TRUE
  - [ ] `messaging` = TRUE
  - [ ] `academic` = TRUE
  - [ ] `events` = TRUE
  - [ ] `opportunities` = FALSE
  - [ ] `marketplace` = FALSE
  - [ ] `reputation` = FALSE
- [ ] Feedback submission works end-to-end: user submits → saved to `feedback_items`
- [ ] Feedback admin queue: admins can view, respond, close feedback
- [ ] Invite code system: `invite_codes` generated, beta access gated
- [ ] Waitlist: user can join, status tracked

### Beta-Specific UX
- [ ] Update gate (`update_gate.dart`) shows "New version available" if build < min_supported
- [ ] System announcements dismissible
- [ ] FAQ page renders with searchable questions
- [ ] In-app feedback FAB or menu item accessible from any screen
- [ ] Version info visible: `app_versions` table -> build number check

### Notification Delivery (Beta Critical)
- [ ] In-app notification list renders for current user
- [ ] Unread count badge updates in real-time (fix `.eq('user_id')` stream filter)
- [ ] Mark individual notification as read
- [ ] Mark all notifications as read
- [ ] Admin-action notifications (approve community, verify leader) appear with correct body and reference_id (fix RPC param names)
- [ ] Notification preferences: toggle categories, persist to DB
- [ ] Notification preferences: master push toggle disables push for that user

### Quality Baseline
- [ ] Loading states: all list screens use shimmer (`UShimmerCard`) — no bare `CircularProgressIndicator`
- [ ] Empty states: all screens use `AppEmptyWidget` with contextual icon + action — no bare `Text('No...')`
- [ ] Error states: all screens use `AppErrorWidget` with retry — no `Text('Error loading...')`
- [ ] Dark mode: all screens render legibly — no invisible text or wrong-contrast backgrounds
- [ ] Hardcoded colors: 0 remaining `Color(0xFF...)` outside theme files (target)
- [ ] `AppColors.*` references: 0 remaining in `build()` methods (target)
- [ ] All deprecation warnings resolved (`surfaceVariant`, `groupValue`, `activeColor`, `value`, `anonKey`)
- [ ] `prefer_const_constructors` infos reduced (target: <20)
- [ ] Community home screen: all 5 tabs use `AppErrorWidget` for error states

### Performance
- [ ] All Supabase queries have `.limit()` (no unbounded selects)
- [ ] All streams have server-side `.eq()` filter (no cross-user data leakage)
- [ ] Search debounce implemented on all search screens
- [ ] Global search scoped to user's university
- [ ] Admin notification queries have `.limit(50)`
- [ ] Paginated queries use cursor-based or offset pagination (not client-side filtering of all rows)

### Security
- [ ] All tables have RLS enabled
- [ ] No `GRANT` to `anon` role (post_votes fix confirmed)
- [ ] `is_admin()` / `is_super_admin()` functions use `SECURITY DEFINER SET search_path = public`
- [ ] `device_tokens` RLS: users can only see/manage own tokens
- [ ] `push_notification_queue` RLS: users can only see own queue items
- [ ] `notifications` RLS: users can only see own notifications

---

## 4. App Store / Play Store Readiness Checklist

### Build & Signing
- [ ] Android: `key.properties` configured with release keystore
- [ ] Android: `flutter build appbundle --release` builds successfully
- [ ] Android: App signing configured in Google Play Console
- [ ] iOS: App Store Connect app entry created
- [ ] iOS: `flutter build ipa --release` builds successfully
- [ ] iOS: Provisioning profiles and certificates configured
- [ ] iOS: TestFlight build uploaded and distributed
- [ ] Version name and build number bumped in `pubspec.yaml`

### Store Presence
- [ ] App name: "UNIFY" (confirm no trademark conflicts)
- [ ] App icon: 1024×1024 adaptive icon (Android) + all iOS sizes
- [ ] Screenshots: 6+ feature screenshots per device size
  - [ ] Android: 5.5" (1080×1920), 7" (1080×1920), 10" (1920×1080)
  - [ ] iOS: 6.5" (1242×2688), 5.5" (1242×2208), 12.9" (2048×2732)
- [ ] Feature graphic: 1024×500 (Google Play)
- [ ] App description: concise, feature-focused, includes "GCTU" and "campus"
- [ ] Category: Education
- [ ] Content rating: Everyone (or PEGI 3 / 12+ if messaging content)
- [ ] Privacy policy URL (required for messaging features)
- [ ] Terms of service URL
- [ ] Support email: `support@unify.app` or similar
- [ ] Website: `https://unify.app` or campus landing page

### Legal & Compliance
- [ ] Privacy policy covers:
  - [ ] Data collection (email, student ID, profile info)
  - [ ] Message content storage (conversations and messages)
  - [ ] Location data (if any)
  - [ ] Device info (for push notifications)
  - [ ] Data deletion / account termination
- [ ] Terms of service covers:
  - [ ] Acceptable use (no harassment, no spam)
  - [ ] Content moderation policy
  - [ ] Copyright / DMCA compliance
  - [ ] Account suspension grounds
  - [ ] Limitation of liability
- [ ] COPPA compliance: app is 13+ (university students are 18+)
- [ ] GDPR compliance: data processing consent, right to deletion, data portability
- [ ] CCPA compliance: California users' right to know/delete
- [ ] Firebase Terms of Service accepted (FCM, Crashlytics, Analytics)
- [ ] Sentry DPA (Data Processing Agreement) signed if applicable

### Store Metadata
- [ ] Keywords: "GCTU, university, campus, student, Ghana, education, social"
- [ ] Short description (80 chars): "GCTU campus community — connect, study, and engage"
- [ ] Full description (4000 chars): feature highlights, target audience, requirements
- [ ] Promotional text: "Beta — join the GCTU campus community"
- [ ] App store category: Education (primary) / Social Networking (secondary)

### In-App Requirements
- [ ] App version checker: `app_versions` table -> display current version in settings
- [ ] Rate my app prompt (optional — can add post-launch)
- [ ] "Report a bug" / feedback accessible from settings (required for beta)
- [ ] Open-source licenses screen (for Flutter packages — required by some licenses)

### Pre-Submission Testing
- [ ] Google Play: Internal testing track opened with 20+ testers
- [ ] Apple: TestFlight with internal testers (up to 100)
- [ ] Crash-free session rate: >99.5%
- [ ] ANR rate (Android): <0.5%
- [ ] No fatal logs in 24-hour test period
- [ ] All 13 broken routes tested after fix (no navigation crashes)
- [ ] Offline: app shows cached content or friendly error (no blank white screen)
- [ ] Push notification: tester receives notification, tap opens correct screen
- [ ] Logout: device token deactivated on sign-out
- [ ] Fresh install: onboarding → sign-up → first community → first post → succeeds

### Post-Submission
- [ ] Google Play: App published to Production
- [ ] Apple: App approved and Released
- [ ] Edge Functions deployed to Supabase production project
- [ ] Firebase Console: Cloud Messaging enabled, Analytics enabled, Crashlytics enabled
- [ ] Sentry project configured with release tracking
- [ ] Monitoring: `push_notification_queue` error rate tracked
- [ ] Monitoring: `error_logs` table checked daily during first week
- [ ] Rollback plan: prior version APK/IPA available, feature flags can disable modules

---

## Audit Summary

| Category | Current State | Target | Effort |
|----------|--------------|--------|--------|
| **Push notifications** | ❌ 0% functional (stubbed no-op) | ✅ Working end-to-end | 4-6 days |
| **Navigation crashes** | ❌ 13 broken routes | ✅ 0 broken routes | 2h |
| **Empty states** | ❌ 87 bare Text('No...') | ✅ AppEmptyWidget everywhere | 4-6h |
| **Loading states** | ❌ ~90% CircularProgressIndicator | ✅ Shimmer on all list screens | 6-8h |
| **Hardcoded colors** | ❌ 294 hex + ~665 AppColors | ✅ context.* tokens everywhere | 6-10h |
| **Dark mode** | ❌ ~30 screens broken | ✅ All screens render legibly | (included in color fix) |
| **Notification RPC bugs** | ❌ 5 bugs (params + stream) | ✅ 0 bugs | 45min |
| **Search quality** | 🟡 Functional, 5 gaps | ✅ Debounced, scoped, no crash | 2h |
| **Admin query perf** | ❌ 2 unbounded queries | ✅ .limit(50) added | 20min |
| **Community home errors** | ❌ 5 raw Text errors | ✅ AppErrorWidget | 30min |
| **Deprecation warnings** | 🟡 9 deprecation infos | ✅ 0 deprecation infos | 1h |
| **Store metadata** | ❌ Not started | ✅ Complete | 2-4h |
| **Privacy/legal** | ❌ Not started | ✅ Published | 4-8h |

**Estimated effort to production-ready: 8-14 person-days** (parallelizable)
**Blocking path (must be done first):** Routes fix + notification bugs + push notification basics → then quality sweep.
