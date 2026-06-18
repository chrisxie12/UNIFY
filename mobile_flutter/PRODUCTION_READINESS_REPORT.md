# UNIFY Production Readiness Report — GCTU Launch

**Date:** June 18, 2026
**Scope:** Full pre-launch audit of all platform modules
**Target:** Launch at Ghana Communication Technology University (GCTU)

---

## Executive Summary

UNIFY has a solid architectural foundation: Clean Architecture with Riverpod, Supabase backend with RLS, 6-tab navigation, and 7 fully-built feature modules (Discussions, Messaging, Academic Hub, Events & Ticketing, Multi-University Admin, Reputation, Notifications).

**Launch-readiness score: 45/100** — Production use requires significant investment in 8 critical areas before a public launch.

### Critical Blockers (Must Fix Before Launch)

| # | Area | Issue | Risk |
|---|------|-------|------|
| 1 | Push Notifications | **Not implemented** — no FCM, no device tokens, no push delivery | Users won't receive any notifications |
| 2 | Offline Support | **Minimal** — only feed page 1 cached, no offline queue | App is unusable without connectivity |
| 3 | Global Search | **Stub** — search screen shows "Search results will appear here" | Main navigation feature doesn't work |
| 4 | Security | **`message_reports` table missing** — `reportMessage()` always crashes | Message reporting broken at runtime |
| 5 | Security | **37 SECURITY DEFINER functions without search_path** | SQL injection / privilege escalation risk |
| 6 | Performance | **Messaging streams unfiltered** — streams ALL conversations/messages | Bandwidth blowout + data leak at scale |
| 7 | Analytics | **No analytics tracking** — zero event tracking, screen views | Cannot measure DAU/MAU/retention |
| 8 | Analytics | **`analytics_snapshots` never populated** — DAU/MAU always `0` | Analytics dashboard is blank |
| 9 | Error Monitoring | **All crash handlers are stubs** — errors silently swallowed | Cannot diagnose production crashes |
| 10 | Accessibility | **Zero Semantics widgets** — completely invisible to screen readers | Legal liability, excludes users |
| 11 | Accessibility | **No text scaling** — all font sizes hardcoded | Illegible for users who increase font size |

---

## 1. Push Notifications

### Current State
- `notifications` table exists with RLS ✅
- `create_notification` RPC function exists ✅
- Server-side trigger calls exist (community approval, verification) ✅
- `NotificationModel` + repository + provider + screen ✅
- **Missing:** Firebase Messaging, device tokens, push delivery, permission requests ❌
- **Missing:** Local notification display (foreground notifications) ❌
- **Missing:** Background message handler ❌
- **Missing:** Push notification routing (tap-to-navigate) ❌

### Risk Assessment
**Critical.** Without push notifications, users must open the app and pull-to-refresh to see any updates. Real-time messaging, event reminders, deadline alerts — all are non-functional.

### Recommended Implementation (7-10 days)
1. `step17` SQL already provides `device_tokens` and `push_notification_queue` tables
2. Add `firebase_messaging`, `firebase_core`, `flutter_local_notifications` to pubspec
3. Create `PushNotificationService` class (permission, token registration, handlers)
4. Create Supabase Edge Function to process `push_notification_queue` → FCM
5. Wire `NotificationScreen` to stream provider for real-time updates
6. Wire nav bar badge to real unread count

---

## 2. Global Search

### Current State
- **Global Search screen is a stub** — renders "Search results will appear here" ❌
- Separate search implementations exist per entity ✅:
  - Events: `searchEventsProvider` — good, server-side `ilike`, `.limit(20)`
  - Academic: `searchResourcesProvider` / `searchCoursesProvider` — good
  - Users: `searchUsersProvider` — good
  - Communities: **client-side filtering** — fetches ALL communities then filters ❌
- No cross-entity search ❌
- No full-text search indexes for events, communities, or users ❌ (SQL patch adds these)

### Risk Assessment
**High.** The `/search` route is in the nav bar. Users who tap it see a non-functional screen. This is a critical UX failure.

### Recommended Implementation (3-5 days)
1. Replace `SearchScreen` with real cross-entity search using `FutureProvider` + `.limit(20)` on each entity
2. Fix `community_repository_impl.dart` `searchCommunities()` to use server-side `ilike` + `limit()`
3. Apply `step17` SQL for GIN indexes on events, communities, profiles
4. Use Supabase full-text search (`to_tsvector`/`to_tsquery`) instead of `ilike` for better performance

---

## 3. Real-Time Features

### Current State
- Messaging uses `.stream()` on Supabase — **but unfiltered** ❌
- Notifications use `FutureProvider` — no streaming ❌
- Events use `FutureProvider` — no real-time RSVP/ticket updates ❌
- No typing indicators (stubbed with `Stream.value(0)`) ❌
- No presence/online status ❌
- No Supabase Realtime channel subscriptions ❌

### Risk Assessment
**High.** Streaming entire `conversations` and `messages` tables without user filtering is a performance and security concern at scale. With 1,000+ concurrent users, every client receives every message update.

### Recommended Implementation (5-7 days)
1. Restructure messaging streams to use `.select().eq().stream()` pattern
2. Convert notification providers to `StreamProvider` (real-time unread count)
3. Add `StreamProvider` for event RSVP updates
4. Fix `typingStatus()` with proper filtering
5. Add Supabase Realtime channel for user presence/last_seen

---

## 4. Offline Support

### Current State
- Hive initialized ✅
- Feed caching exists (first page only) ✅
- **No cache expiry enforcement** — `cacheExpiry` constant defined but never checked ❌
- `profileCacheBox` declared in constants but **never used** ❌
- **No connectivity monitoring** — `connectivity_plus` not in pubspec ❌
- **No offline queue** for messages/posts ❌
- **No retry logic** on network failure ❌
- `NetworkFailure` class exists but never thrown ❌
- `cached_network_image` used in 3 files (feed, profile, announcements) — mostly without `memCacheWidth`/`memCacheHeight` ❌

### Risk Assessment
**Critical.** At GCTU, students may have unreliable mobile data. Without offline support, the app is completely unusable without connectivity. Messages typed offline will be lost. Feed content will show blank screens.

### Recommended Implementation (7-10 days)
1. Add `connectivity_plus` package for network monitoring
2. Create `ConnectivityService` / `connectivityProvider` (Riverpod)
3. Implement offline-first pattern for key screens:
   - Feed: extend existing Hive cache with expiry check
   - Messages: Hive box per conversation with sync queue
   - Academic resources: cache recent downloads
   - Opportunities: cache saved/bookmarked
4. Add `ConnectivityBuilder` widget for offline banner
5. Fix all `cached_network_image` with `memCacheWidth`/`memCacheHeight`
6. Implement `retry` pattern on Supabase queries

---

## 5. Performance Optimization

### Current State

#### Pagination (Good)
- Feed: cursor-based with `loadMore()` ✅
- All search: `.limit(20)` ✅
- Community listing: `.limit(40)` ✅

#### Critical: Unbounded Queries (No `.limit()`)
**20+ queries fetch ALL rows** — major performance risk at scale:

| File | Method | Risk |
|------|--------|------|
| `community_repository_impl.dart:77` | `searchCommunities()` | ALL communities |
| `community_repository_impl.dart:121` | `getRecommendedCommunities()` | ALL communities |
| `communities_repository_impl.dart` | `getMembers()`, `getPosts()`, `getComments()`, `getResources()` | ALL rows per community |
| `academic_repository_impl.dart` | `getCourses()`, `getResources()`, `getAssignments()`, `getGPARecords()`, `getStudyPlans()` | ALL rows |
| `notification_repository_impl.dart:14` | `getNotifications()` | ALL, then `take(50)` in Dart |
| `event_repository_impl.dart` | `getEvents()`, `getSavedEvents()`, `getDiscussions()`, `getMedia()` | ALL rows |
| `admin_repository_impl.dart` | `getDashboardCounts()` | ALL rows for counting |
| `messaging_repository_impl.dart` | `messageRequests()`, `unreadCounts()` | ALL rows |

#### SELECT * (Anti-pattern)
~70+ occurrences of bare `.select()` or `.select('*')` instead of specific columns.

#### Risk Assessment
**High.** At 10,000+ students with 100+ communities, unbounded queries will cause multi-second load times, high bandwidth costs, and potential OOM crashes on low-end devices.

### Recommended Implementation (5-7 days)
1. Add `.limit()` to all 20+ unbounded queries (page size 20-40)
2. Replace all `SELECT *` with specific column selects in high-frequency queries
3. Add pagination (`ScrollController` + `loadMore`) to all ListViews with 10+ items
4. Implement `count_rows()` RPC (included in step17 SQL) for efficient counting
5. Apply step17 SQL performance indexes

---

## 6. Security Audit

### Risk Levels Found

#### CRITICAL (Fix Immediately)
1. **`message_reports` table DDL missing** — `reportMessage()` always fails at runtime with "relation does not exist"
2. **`GRANT ALL ON post_votes TO anon`** — unauthenticated users can vote
3. **`poll_options INSERT WITH CHECK (true)`** — any user can add options to any poll
4. **`conversations INSERT WITH CHECK (true)`** — unlimited conversation creation
5. **37 SECURITY DEFINER functions without `search_path`** — privilege escalation risk

#### HIGH
6. **No rate limiting anywhere** — no spam/abuse throttling
7. **No CAPTCHA/reCAPTCHA integration** — automated signup attacks possible
8. **`gpa_courses` and `study_plan_items`** — RLS enabled but zero policies (data accessible to all)
9. **`getDashboardCounts`** — fetches ALL rows, no university scope filtering
10. **`assignments` and `courses` INSERT** — any authenticated user, no instructor check

#### MEDIUM
11. Missing DELETE policy on `academic_resources`
12. Missing INSERT/UPDATE/DELETE on `exam_timetables`
13. Missing SELECT policy on `resource_downloads`
14. Weak password validation (min 6 chars, no complexity)
15. Schema mismatch: `completeOnboarding` writes `display_name` (column is `full_name`)
16. Admin audit logging not consistently implemented in repository

### Recommended Implementation (7-10 days)
1. Apply `step17` SQL — fixes all CRITICAL RLS issues, missing tables, and search path
2. Implement rate limiting via Supabase Edge Functions or middleware
3. Add Turnstile/reCAPTCHA to signup
4. Fix `completeOnboarding` schema mismatch in `auth_repository_impl.dart`
5. Strengthen password validation (min 8 chars, complexity requirements)
6. Implement consistent audit logging in `admin_repository_impl.dart`
7. Password strength requirements in `auth_screen.dart`

---

## 7. Analytics Infrastructure

### Current State
- `analytics_snapshots` table exists with schema ✅
- `AnalyticsSnapshotModel` + provider + dashboard screen ✅
- **Zero client-side event tracking** — no Firebase Analytics, Mixpanel, etc. ❌
- **`analytics_snapshots` never populated** — DAU/MAU/comments/posts all `0` ❌
- `reputation_events` table has detailed action logs but **no aggregation** ❌
- `FounderAnalyticsScreen` re-queries all tables on each load (no caching) ❌
- No screen view tracking ❌

### Risk Assessment
**High.** Without analytics, there is no way to measure:
- Daily/Monthly active users (required for investors and stakeholders)
- Feature adoption (which features do students actually use?)
- Retention (are students coming back?)
- Community growth (are new communities being formed?)
- Marketing ROI (is GCTU promotion working?)

### Recommended Implementation (3-5 days)
1. Apply `step17` `aggregate_daily_analytics()` RPC function
2. Schedule daily cron job (pg_cron or external) to run `aggregate_daily_analytics()`
3. Add `firebase_analytics` or PostHog for client-side event tracking
4. Create `AnalyticsService` with methods: `logEvent()`, `logScreenView()`, `setUserId()`
5. Add `NavigatorObserver` to GoRouter for automatic screen view tracking
6. Key events to track: `sign_up`, `create_community`, `create_post`, `send_message`, `rsvp_event`, `save_opportunity`

---

## 8. Error Monitoring

### Current State
- `bootstrap.dart` has 3 error handlers — ALL are **stubs** with TODO comments ❌
- No Sentry, Firebase Crashlytics, or any crash reporting SDK ❌
- `failures.dart` (Failure sealed class) — defined but **never used** ❌
- Many repositories use `catch (_) {}` — silently swallows errors (~50 occurrences) ❌
- `debugPrint` is the only logging mechanism ❌

### Risk Assessment
**Critical.** When the app crashes in production, there is no way to:
- Know it happened
- Diagnose what caused it
- Prioritize fixes
- Track crash-free user rate

At GCTU launch, 500+ students using the app simultaneously will encounter bugs. Without crash reporting, every bug is invisible.

### Recommended Implementation (2-3 days)
1. Add `sentry_flutter` to pubspec.yaml
2. Initialize Sentry in `main.dart` before `Supabase.initialize()`
3. Wire `bootstrap.dart` error handlers to Sentry
4. Create `LogService` with info/warn/error levels and Sentry integration
5. Move from `catch (_) {}` to `catch (e, s) { LogService.error(e, s); }` in repositories
6. Add `FlutterError.onError` handler for widget build errors

---

## 9. Accessibility

### Current State
- **Zero `Semantics` widgets** anywhere in the codebase ❌
- **No keyboard navigation** — no `FocusNode`, `FocusTraversalGroup` ❌
- **No text scaling support** — all font sizes hardcoded ❌
- **7+ IconButtons without `semanticLabel`** ❌
- **`AppButton` uses `GestureDetector`** instead of `ElevatedButton` ❌
- **Color contrast issues** — `grey3` (#9CA3AF) at 2.9:1 fails WCAG AA ❌
- **No dark mode** — `scaffoldBackgroundColor: AppColors.white` ❌
- **Good practice:** `VerifiedBadge` has `Tooltip` ✅, form fields have labels ✅

### Risk Assessment
**High.** Inaccessible apps exclude users with disabilities, may violate accessibility regulations, and provide poor UX for all users who rely on assistive technology.

### Recommended Implementation (5-7 days)
1. Add `Semantics` wrapper to main navigation items
2. Add `semanticLabel` to all IconButtons
3. Replace `GestureDetector` in `AppButton` with `ElevatedButton` / `Material.button`
4. Implement `MediaQuery.textScaleFactor` support — create scalable text extensions
5. Fix color contrast: `grey3` to darker shade for hint text
6. Add dark mode theme in `app_theme.dart`
7. Add `FocusNode` + `FocusTraversalGroup` to forms

---

## 10. Architecture & Code Quality

### Strengths
- Clean Architecture (data/domain/presentation layers) ✅
- Riverpod state management with proper patterns ✅
- Supabase with RLS ✅
- 6-theme preset system ✅
- GoRouter with auth redirect ✅
- Multi-university admin with RBAC ✅
- Context extension (`context.primary`) ✅
- Cursor-based pagination in feed ✅

### Weaknesses
- No test coverage (only placeholder `widget_test.dart`) ❌
- `.env` file with real credentials committed to version control ❌
- `Supabase.initialize()` silently catches errors in `main.dart` ❌
- No internationalization support ❌
- No privacy policy / terms of service screens ❌
- Hardcoded `Color` values in multiple screens instead of theme ❌

---

## 11. Database Scaling Assessment

### Capacity (with step17 indexes applied)

| Metric | Current Capacity | Bottleneck | Mitigation |
|--------|-----------------|------------|------------|
| Users | ~100,000 | Profile queries, search | GIN index on profiles |
| Communities | ~5,000 | Unbounded queries | Add `.limit()` everywhere |
| Posts/Comments | ~500,000 | Community post queries | Composite index on (community_id, created_at) |
| Messages | ~1,000,000 | Unfiltered streams | Filter by user_id before stream |
| Events | ~10,000 | Search | GIN index added in step17 |
| Concurrent Users | ~500 | Unfiltered messaging streams | Filter streams by user/conversation |

### Scaling Risks
1. **Streaming ALL messages to ALL users** — must filter by `conversation_participants` before `.stream()`
2. **Unbounded queries (20+) without `.limit()`** — will timeout or OOM at 10k+ user scale
3. **No database connection pooling configuration** — Supabase connection limit (default 15-30 for tier)
4. **No caching layer** — every page load hits the database
5. **No read-replica strategy** — Supabase Postgres is single-writer

### Scaling Recommendations
1. **Immediate:** Apply all `.limit()` fixes and filtered streams
2. **Short-term (post-launch):** Add read-replica or Supabase with connection pooling
3. **Medium-term:** Implement Redis cache for hot data (communities, profiles)
4. **Long-term:** Consider sharding by university_id for multi-terabyte scale

---

## 12. Risk Assessment Matrix

| Risk | Probability | Impact | Score | Mitigation |
|------|------------|--------|-------|------------|
| App crashes silently in production (no error reporting) | High | Critical | 16 | Add Sentry (2 days) |
| Users can't receive push notifications | High | Critical | 16 | FCM integration (7 days) |
| Global search screen shows placeholder | High | High | 12 | Implement cross-entity search (3 days) |
| Stream bandwidth blowout from unfiltered messaging | Medium | Critical | 12 | Filter streams by user (3 days) |
| Analytics dashboard shows zeros | High | High | 12 | Cron job for aggregation (1 day) |
| Offline data loss due to network failure | Medium | High | 9 | Offline queue + connectivity (7 days) |
| message_reports crash at runtime | Medium | Critical | 9 | Already fixed in step17 SQL |
| Security definer functions vulnerable | Medium | Critical | 9 | Already fixed in step17 SQL |
| Screen reader users cannot use app | High | High | 12 | Add Semantics widgets (5 days) |
| SQL injection via search_path functions | Medium | Critical | 9 | search_path fix in step17 SQL |
| Spam/bot signups (no CAPTCHA) | High | Medium | 8 | Add Turnstile (2 days) |
| Rate limiting abuse | Medium | Medium | 6 | Edge Function throttling (3 days) |
| User cannot change font size | High | Medium | 8 | Add textScaleFactor support (2 days) |
| DAU/MAU unknown at launch | High | Medium | 8 | Add Firebase Analytics (3 days) |
| `post_votes` anon access | Low | Critical | 6 | Revoke anon grant (0.5 day) |
| Missing RLS policies on 2 tables | Low | High | 6 | Already fixed in step17 SQL |
| Test coverage at 0% | High | Medium | 8 | Add critical path tests (7 days) |
| `.env` credentials in version control | High | Medium | 8 | Add to .gitignore immediately |

*Risk Score = Probability (1-4) × Impact (1-4)*

---

## 13. Launch Checklists

### Pre-Launch: Beta Testing Checklist (1-2 weeks)

- [ ] **Invite 20-50 GCTU students** for closed beta
- [ ] **User signup flow**: Email verification, onboarding, profile creation
- [ ] **Feed**: Cached content, pull-to-refresh, cursor pagination
- [ ] **Communities**: Create, browse, join, post, comment
- [ ] **Messaging**: Send/receive DMs, create groups, reactions
- [ ] **Academic**: Browse courses, resources, assignments, GPA calculator
- [ ] **Events**: Create, RSVP, tickets, check-in, discover
- [ ] **Notifications**: In-app list works (push not yet)
- [ ] **Profile**: Edit, privacy settings, reputation
- [ ] **Search**: Event search, academic search, user search
- [ ] **Admin**: University management, verification, moderation
- [ ] **Collect feedback**: Bug reports, feature requests, UX issues
- [ ] **Monitor**: Manually check analytics dashboard (even if zeros)
- [ ] **Stress test**: 20 concurrent users creating content simultaneously

### Production Checklist (Before Public Launch)

#### Critical (Must Complete)
- [ ] Sentry or Firebase Crashlytics integrated and verified
- [ ] Push notifications working (FCM + device tokens + delivery)
- [ ] All unbounded queries have `.limit()`
- [ ] Messaging streams filtered by user_id
- [ ] `step17` SQL applied to production database
- [ ] Global search screen functional (not stub)
- [ ] Offline banner shown when no connectivity
- [ ] Analytics cron job running daily
- [ ] `.env` removed from version control
- [ ] `Semantics` widgets added to main navigation
- [ ] All `IconButton`s have `semanticLabel`
- [ ] `AppButton` uses `ElevatedButton` (not `GestureDetector`)

#### High Priority
- [ ] `aggregate_daily_analytics()` scheduled with pg_cron
- [ ] Rate limiting on auth endpoints (max 5 signups/IP/hour)
- [ ] CAPTCHA on signup form
- [ ] Password strength validation (8+ chars, mixed case, number)
- [ ] `failures.dart` classes used in all repositories
- [ ] `catch (_) {}` replaced with proper error handling
- [ ] `completeOnboarding` schema mismatch fixed
- [ ] Color contrast meets WCAG AA (fix `grey3` at minimum)
- [ ] `cached_network_image` with `memCacheWidth`/`memCacheHeight`
- [ ] Privacy policy and terms of service screens added
- [ ] Hive cache expiry enforced (not just defined)
- [ ] Profile picture caching fixed (`profileCacheBox` implemented)
- [ ] `message_reports` table DDL confirmed (in step17)

#### Medium Priority
- [ ] Client analytics (Firebase Analytics) set up
- [ ] Screen view tracking via NavigatorObserver
- [ ] Dark mode theme support
- [ ] Shimmer skeletons on all list screens
- [ ] `SELECT *` replaced with specific columns in hot paths
- [ ] Scroll pagination on all 49+ ListViews
- [ ] Push notification routing (tap-to-navigate)
- [ ] Notification streaming (convert to StreamProvider)
- [ ] Admin audit logging consistent across all operations
- [ ] `UNIQUE(user_id, role_id)` constraint fixed for multi-university admins
- [ ] Internationalization with flutter_localizations

### Deployment Checklist

#### Pre-Deployment
- [ ] Flutter `flutter analyze`: 0 errors
- [ ] Flutter `flutter build apk --debug`: builds successfully
- [ ] Dart `dart format` run on all changed files
- [ ] Version number bumped in pubspec.yaml (1.0.0-beta.1)
- [ ] All `print()` and `debugPrint()` statements removed from production code
- [ ] `.env` removed from build (use CI/CD secrets)
- [ ] App icon and splash screen configured for GCTU branding
- [ ] Android: app bundle signed with release keystore
- [ ] iOS: Provisioning profile and certificates up to date
- [ ] Deep link configuration for push notification routing
- [ ] `AndroidManifest.xml` internet permission confirmed
- [ ] `Info.plist` camera/mic permissions if needed

#### Database Deployment
- [ ] Run step1-step17 SQL sequentially on production Supabase instance
- [ ] Verify RLS policies with `SELECT * FROM pg_policies`
- [ ] Create Supabase Edge Function for push notification sending
- [ ] Schedule pg_cron for `aggregate_daily_analytics()` at midnight daily
- [ ] Configure Supabase Auth settings (min password length, email confirmations)
- [ ] Set up Supabase storage buckets for avatars, evidence, resources
- [ ] Configure CORS if using custom domain
- [ ] Take initial database backup

#### CI/CD Pipeline
- [ ] Automated `flutter analyze` on PR
- [ ] Automated `flutter test` on PR (after adding tests)
- [ ] APK build on merge to main
- [ ] Sentry release tracking configured
- [ ] Environment variable injection (not checked-in `.env`)

### Monitoring Checklist (Post-Launch)

#### First 24 Hours
- [ ] Check Sentry for any new errors
- [ ] Verify push notification delivery rate > 90%
- [ ] Check analytics: signups, DAU, events created, messages sent
- [ ] Monitor Supabase dashboard for database CPU/memory/connections
- [ ] Check app store review status (if Play Store / App Store)
- [ ] Verify email delivery (welcome emails, verification emails)
- [ ] Check user feedback channels (in-app feedback, social media)

#### First Week
- [ ] Review crash-free user rate in Sentry (>99.5% target)
- [ ] Check DAU trend (expecting growth curve)
- [ ] Review slow queries in Supabase query performance
- [ ] Monitor database storage growth
- [ ] Check push notification opt-in rate
- [ ] Review community creation rate
- [ ] Verify analytics_snapshots data is populated

#### Ongoing
- [ ] Weekly: Review error trends in Sentry
- [ ] Weekly: Check DAU/MAU ratio (engagement)
- [ ] Monthly: Review database storage and performance
- [ ] Monthly: Review active communities and events
- [ ] Quarterly: Full RLS and security audit
- [ ] Quarterly: Review and update dependency versions
- [ ] Per-release: Flutter analyze and build verification

---

## 14. Implementation Roadmap

### Phase 1: Launch Blockers (Week 1 — MUST DO)

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1 | Security | Apply step17 SQL to production. Fix RLS gaps. Revoke `anon` grants. |
| 2 | Error Monitoring | Add Sentry. Wire bootstrap.dart handlers. |
| 3 | Performance | Add `.limit()` to all 20+ unbounded queries. Filter messaging streams. |
| 4 | Search | Fix stub search screen. Implement cross-entity search. |
| 5 | Accessibility | Add Semantics to nav. Fix all IconButton labels. |

### Phase 2: Core Experience (Week 2)

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1-2 | Push Notifications | FCM integration + device tokens + push service |
| 3-4 | Offline Support | Connectivity service + Hive caching for messages/feed |
| 5 | Analytics | Firebase Analytics + cron job for snapshot aggregation |

### Phase 3: Polish (Week 3)

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1-2 | Testing | Critical path tests (auth, messaging, events, admin) |
| 3 | Dark Mode | Dark theme implementation |
| 4 | Rate Limiting | Auth rate limiting + CAPTCHA |
| 5 | Final Audit | Full flutter analyze, build verification, deployment prep |

---

## 15. Risk Assessment by Module

| Module | Readiness | Critical Issues | Effort to Fix |
|--------|-----------|-----------------|---------------|
| Auth & Onboarding | 70% | Schema mismatch, weak password, no CAPTCHA | 1 day |
| Feed & Announcements | 60% | No offline cache beyond page 1, no shimmer on other screens | 2 days |
| Communities | 50% | Unbounded queries, client-side search, no streaming | 3 days |
| Discussions / Posts | 55% | No streaming, no offline | 2 days |
| Messaging | 40% | **Unfiltered streams**, no offline queue, no push | 5 days |
| Academic Hub | 45% | Unbounded queries, missing RLS policies | 2 days |
| Events & Ticketing | 50% | No streaming, no push reminders, unbounded queries | 3 days |
| Notifications | 20% | **No push**, no streaming, client-side filtering | 5 days |
| Reputation | 60% | Underutilized for analytics | 1 day |
| Admin System | 55% | Audit logging inconsistent, no rate limiting | 3 days |
| Search | 10% | **Global search is a stub** | 3 days |
| Multi-University | 50% | Missing audit logging, role constraint issue | 2 days |

---

## 16. Team Estimates

| Role | Week 1 | Week 2 | Week 3 | Total |
|------|--------|--------|--------|-------|
| Flutter Developer | Full-time | Full-time | Full-time | 3 weeks |
| Backend/Supabase | Full-time | Part-time | Part-time | 2 weeks |
| QA / Testing | Part-time | Full-time | Full-time | 2.5 weeks |
| DevOps / CI/CD | Part-time | Part-time | — | 1 week |
| **Total** | **3 FTE** | **3 FTE** | **2.5 FTE** | **3 weeks** |

---

## 17. Conclusion

UNIFY is structurally well-architected but is **not ready for production launch at GCTU**. The audit identified **11 critical issues** that must be resolved before public release.

**Minimum timeline to production readiness: 3 weeks with a team of 2-3 developers.**

The `step17_production_readiness.sql` patch resolves 7 of the 11 critical database-level issues. The remaining require Flutter/Dart code changes.

### Top 5 Actions After This Report
1. Apply `step17` SQL to production database (security + performance + missing table)
2. Add Sentry (critical for knowing about production crashes)
3. Add `.limit()` to all unbounded queries (critical for scaling to 100+ users)
4. Fix the global search stub (critical UX issue)
5. Filter messaging streams (critical for security + bandwidth)

**Launch-readiness score: 45/100 — Target: 85/100 before public launch.**
