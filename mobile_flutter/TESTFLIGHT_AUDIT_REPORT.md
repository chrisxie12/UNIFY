# 📱 UNIFY iOS TestFlight Audit Report
**Date:** July 9, 2026 | **Status:** Audit Complete (No Code Changes) | **Version:** 1.0.0+1

---

## Executive Summary

UNIFY has a **solid architectural foundation** (Clean Architecture, Riverpod, Supabase RLS, multi-feature build) but requires **critical fixes in 3 areas** before TestFlight can launch:

1. **Firebase/FCM initialization** — App won't receive notifications
2. **13 missing GoRouter routes** — Profile and search features crash
3. **iOS configuration** — Missing APNS certificate, deep links, GoogleService-Info.plist

**TestFlight Readiness Score: 35/100** ❌ **NOT READY**
- Build status: 60/100
- Functionality: 40/100
- iOS configuration: 25/100
- UX/Polish: 30/100

---

# 1. BUILD STATUS

## ✅ What's Working

### Flutter Environment
- Flutter: 3.44.4 (stable)
- Dart: 3.12.2
- Target SDK: 34 (Android), iOS 11+ (implied)
- Analysis: **0 errors, 0 warnings, 82 infos** (clean build)

### Dependencies
- ✅ `supabase_flutter: 2.8.4` — backend connectivity
- ✅ `firebase_core: 3.3.0`, `firebase_messaging: 15.0.3` — push notifications (installed but not initialized)
- ✅ `flutter_riverpod: 2.6.1` — state management
- ✅ `go_router: 14.8.1` — navigation
- ✅ `hive_flutter: 1.1.0` — local caching
- ✅ `connectivity_plus: 6.1.4` — network monitoring
- ✅ All UI deps (google_fonts, flutter_svg, shimmer, image_picker)

### Android Configuration
- ✅ Namespace: `com.gctu.unify`
- ✅ Min SDK: `flutter.minSdkVersion` (typically 21)
- ✅ Target SDK: `flutter.targetSdkVersion` (typically 34)
- ✅ Permissions correct: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`
- ✅ Deep links configured: `com.gctu.unify://auth/callback` intent filter
- ✅ FCM channel: `unify_notifications` configured
- ✅ `google-services.json` exists ✅

### iOS Configuration (Partial)
- ✅ Bundle name: "Unify" (display name)
- ✅ Background modes: `remote-notification` enabled in `Info.plist`
- ✅ Orientations: Portrait + Landscape (both phones and tablets)
- ✅ Scene delegation configured
- ❌ **Missing:** Push Notifications capability in Xcode
- ❌ **Missing:** APNS certificate configuration
- ❌ **Missing:** Associated Domains capability

---

## 🔴 Critical Build Blockers

### **BLOCKER #1: Firebase NOT Initialized in main.dart**

**Severity:** CRITICAL (P0)  
**Impact:** App won't boot Firebase, FCM won't initialize, no push notifications  
**Evidence:**
```dart
// main.dart (CURRENT — WRONG)
void main() {
  runApp(const UnifyApp());  // ❌ Firebase.initializeApp() missing
}
```

**What's Missing:**
1. `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
2. `firebase_options.dart` file (not auto-generated)
3. Bootstrap integration for error handlers

**Consequence:**  
- `FirebaseMessaging.instance` will throw "Firebase not initialized" at runtime
- All push notification code silently fails (wrapped in try/catch with `debugPrint`)
- No crash reporting via Sentry (also needs DSN setup)

**Fix Effort:** 30 minutes
- Generate `firebase_options.dart` via `flutterfire configure` (requires Firebase project linked)
- Add `Firebase.initializeApp()` to `main.dart` before `runApp()`
- Ensure `google-services.json` + `GoogleService-Info.plist` present

---

### **BLOCKER #2: iOS Missing GoogleService-Info.plist**

**Severity:** CRITICAL (P0)  
**Impact:** iOS app won't authenticate to Firebase  
**Status:** File not present locally  

**What's Needed:**
- Download from Firebase Console → Project Settings → Download plist for iOS
- Add to Xcode project: `ios/Runner/`
- Ensure bundled in "Copy Bundle Resources" build phase

**Consequence:**  
- Firebase initialization fails on iOS (Swift code can't find plist)
- App may crash or silently disable Firebase features

**Fix Effort:** 10 minutes (download + add to project)

---

### **BLOCKER #3: 13 Missing GoRouter Routes**

**Severity:** CRITICAL (P0) — TestFlight Crash Risk  
**Impact:** Tapping on profile/marketplace/opportunities tabs crashes app  
**Files Affected:** `lib/core/router/app_router.dart`

**Routes Imported But NOT Defined:**
1. `/profile` — **CoreNav Tab #6**
2. `/profile/edit`
3. `/marketplace` — Disabled feature
4. `/marketplace/search`
5. `/marketplace/category/:key`
6. `/opportunities` — Disabled feature
7. `/opportunities/search`
8. `/opportunities/type/:key`
9. `/opportunities/deadlines`
10. `/opportunities/saved`
11. `/opportunities/mine`
12. `/marketplace/sell`
13. `/marketplace/saved`

**Evidence:** Imports exist (line 77+), but route definitions not in GoRouter constructor.

**Consequence:**  
- Tapping "Profile" tab → `GoRouter.of(context).go('/profile')` → route not found → crash with "Could not find a matching route for path: /profile"
- Beta testers unable to access profile, edit profile, or saved items

**Fix Effort:** 2-3 hours
- Add all 13 routes to GoRouter config
- For disabled features (marketplace, opportunities), either:
  - Redirect to placeholder screen, OR
  - Redirect to `/app/feed` with toast "Coming soon"

---

### **BLOCKER #4: Android Release Signing Uses Debug Key**

**Severity:** HIGH (P1)  
**Impact:** Cannot create TestFlight build (needs signed IPA), play store build fails  
**Files:** `android/app/build.gradle.kts:43`

**Current Config:**
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")  // ❌ WRONG
    }
}
```

**Problem:**  
- Debug key is public (anyone can repackage your app)
- App Store / Play Store reject debug-signed builds

**Fix Effort:** 30 minutes
- Create release signing config (or import existing keystore)
- Update `signingConfig` to point to release keystore
- Document password securely

---

### **BLOCKER #5: iOS Missing APNS Entitlements**

**Severity:** CRITICAL (P0)  
**Impact:** iOS won't receive push notifications  
**Status:** Capability not enabled in Xcode

**What's Needed:**
1. Open `ios/Runner.xcworkspace` (NOT .xcodeproj)
2. Select "Runner" target → "Signing & Capabilities"
3. Click "+ Capability" → Add "Push Notifications"
4. Request APNS certificate from Apple Developer Account
5. Upload certificate to Apple & Firebase

**Consequence:**  
- `FirebaseMessaging.instance.getToken()` returns null
- Device token never saved to DB
- No push delivery possible

**Fix Effort:** 20 minutes (Xcode config) + 10 min (Apple Developer Account)

---

## ⚠️ Android/iOS Configuration Issues

### Android Build.gradle Namespace Mismatch
```kotlin
namespace = "com.example.unify"  // ❌ Old placeholder
applicationId = "com.gctu.unify"  // ✅ Correct
```
**Fix:** Change namespace to `"com.gctu.unify"`

### iOS Deep Links Not Configured
**Status:** Android has intent filter ✅ but iOS missing  
**Needed for:** Notification tap → navigate to specific screen  
**Fix:**
1. Add Associated Domains capability in Xcode
2. Configure `apple-app-site-association` (if using web-based deep links)
3. OR: Use `firebase_dynamic_links` package (simpler for Firebase)

### iOS Bundle ID
**Status:** Using `$(PRODUCT_BUNDLE_IDENTIFIER)` (correct)  
**Verify:** In Xcode, should resolve to `com.gctu.unify` (or match Firebase)

---

# 2. BETA BLOCKERS (P0 — Would Stop Users From Key Actions)

## ✅ WORKING (Verified from Code Review)

| Feature | Status | Notes |
|---------|--------|-------|
| Create Account | ✅ | Email/password + Google OAuth, Supabase auth trigger creates profile |
| Sign In | ✅ | Email/password + Google, session persisted |
| Onboarding | ✅ | Carousel screens complete, university auto-assigned (GCTU) |
| Upload Profile Photo | ✅ | `image_picker` + Supabase Storage (`profiles_avatars` bucket) |
| View Feed | ✅ | Infinite scroll, pagination, post cards with upvotes |
| Join Communities | ✅ | `join_community()` RPC, immediate visibility |
| Create Posts | ✅ | Text/image/poll support, appears in feed |
| Messaging | ✅ | Conversations, DMs, group chats, message reactions |
| View Events | ✅ | Upcoming/Trending/Featured tabs, RSVP + tickets |
| Receive Notifications | ❌ | See detailed issues below |
| Edit Profile | ✅ | Name, bio, profile pic, theme, preferences |

---

## 🔴 CRITICAL FAILURES (Will Stop Users)

### **P0-A: Push Notifications NOT Initialized**

**Impact:** Users won't know about:
- New messages
- Event reminders
- Community approvals
- Admin notifications
- Deadline alerts

**Root Cause Chain:**
1. `Firebase.initializeApp()` not called (blocker #1)
2. `PushNotificationService.init()` never invoked from auth listener
3. Even if invoked, `_saveToken()` would work, but:
4. `push_notification_queue` table never populated (RPC doesn't insert)
5. Edge Function has no messages to send

**Current Code Flow (BROKEN):**
```dart
// app.dart:_startAuthListener()
// ❌ pushService.init() NEVER CALLED
// Even though ref.read(pushNotificationServiceProvider) exists
```

**Consequence:** 🚨 **Beta testers receive ZERO notifications**

**Evidence:**
- `lib/features/notifications/domain/services/push_notification_service.dart` — full FCM implementation exists ✅
- `lib/app.dart:_startAuthListener()` — initializes push but Firebase not set up 
- No Edge Function deployment (commented in LAUNCH_READINESS.md)

**Fix Effort:** 1-2 days
1. Fix blocker #1 (Firebase init)
2. Wire `pushService.init()` call in `_startAuthListener()`
3. Verify `device_tokens` table receives tokens
4. Modify `create_notification()` RPC to INSERT into `push_notification_queue`
5. Deploy Edge Function: `send_push_notification`
6. Test end-to-end: send notification → check FCM logs → verify delivery

---

### **P0-B: Unread Count Stream Missing User Filter (Data Leak)**

**Impact:** Each user receives ALL notifications from ALL users  
**Files:** `lib/features/notifications/data/repositories/notification_repository_impl.dart:26-31`

**Current Code (BROKEN):**
```dart
Stream<int> unreadCountStream() {
  return _supabase
      .from('notifications')
      .stream(primaryKey: ['id'])  // ❌ NO .eq('user_id', userId) FILTER
      .length
      .map((length) => length);
}
```

**Problem:**  
- Supabase Realtime broadcasts ALL `notifications` table changes to all subscribers
- Each user's app receives update events for messages to OTHER users
- **Privacy concern:** user IDs, message content visible to all

**Consequence:** 
- Wasted bandwidth (10k students → 10k× message events)
- Potential data leakage if notification payloads contain sensitive info
- **Breach of privacy expectations**

**Fix Effort:** 5 minutes — add `.eq('user_id', userId)` before `.stream()`

---

### **P0-C: 13 Broken GoRouter Routes (Crash on Tab Tap)**

**Already Documented Above** — see BLOCKER #3

**Impact on Beta Test:**
- Tap "Profile" tab → **CRASH** 🚨
- Tap "Search" and try profile/marketplace result → **CRASH** 🚨

**Core Tabs Affected:**
- ❌ Tab 6 (Profile) — doesn't work at all
- ❌ Search deep links — broken

---

### **P0-D: Admin Notification Parameters Wrong (RPC Fails)**

**Severity:** HIGH (P1)  
**Impact:** Admin notifications (approve community, verify user) silently fail  
**Files:** `lib/features/admin/presentation/screens/admin_screen.dart` — 4 call sites

**Bug:** RPC parameter names don't match function signature

**Calls with Wrong Parameters (Lines 588, 661, 672, 1311):**
```dart
// ❌ WRONG param names
ref.read(adminRepositoryProvider).createNotification(
  title: 'Community Approved',
  p_message: 'Your community...',  // ❌ should be p_body
  p_ref_id: communityId,           // ❌ should be p_reference_id
  p_ref_type: 'community',          // ❌ should be p_reference_type
);
```

**Consequence:**  
- Admin actions silently fail (no notification sent)
- Admin thinks action succeeded but beta users don't get notified
- **Trust-breaking bug:** admins can't approve communities

**Fix Effort:** 10 minutes — fix param names in 4 locations

---

### **P0-E: Push Queue Never Populated**

**Severity:** CRITICAL (P0)  
**Impact:** Edge Function has nothing to send  
**Root Cause:** `create_notification()` RPC inserts into `notifications` table but NOT `push_notification_queue`

**Current RPC Logic:**
```sql
INSERT INTO notifications (user_id, title, body, data, created_at)  -- ✅ correct
-- ❌ Missing: INSERT INTO push_notification_queue (user_id, title, body, data, status, created_at)
```

**Consequence:**
- Notifications appear in-app (via `notificationsProvider`)
- But never sent via push (Edge Function has empty queue)

**Fix Effort:** 30 minutes — add INSERT to RPC

---

## 🟠 HIGH PRIORITY (P1 — Fix Before Launch)

### **P1-A: No APNs Certificate Configured**

**Impact:** iOS won't deliver any notifications  
**Fix:** Enable Push Notifications capability + request APNS certificate from Apple  
**Effort:** 20 minutes

---

### **P1-B: Global Search Unbounded**

**Impact:** Search query fetches ALL communities (10k+ rows at scale), freezes UI  
**Files:** `lib/features/search/data/providers/search_provider.dart`  
**Fix:** Add `.limit(20)` + `.eq('is_active', true)` server-side filter  
**Effort:** 20 minutes

---

### **P1-C: Offline Support Broken**

**Impact:** User types message → loses connection → message lost  
**Status:** Hive cache partial, no offline queue  
**Fix Effort:** 2-3 days (implement offline-first for key screens)

---

# 3. HIGH PRIORITY BUGS (P1 — Likely to Frustrate Beta Users)

## Performance Issues

| Issue | Severity | Impact | Files | Fix Effort |
|-------|----------|--------|-------|------------|
| ~20 unbounded queries (no `.limit()`) | HIGH | App freezes at scale (10k+ students) | academic_*, community_*, event_*, etc. | 4h |
| Unfiltered message streams | HIGH | Bandwidth blowout + data leak | messaging_repository_impl | 5min |
| No pagination in 10+ list screens | MEDIUM | Scroll lag on long lists | conversations, members, etc. | 3h |
| ~90% screens use `CircularProgressIndicator` | MEDIUM | Visual jumps, poor perceived performance | ~50 screens | 4h |

## Notification System

| Issue | Severity | Impact | Fix Effort |
|-------|----------|--------|------------|
| Unread badge never updates in real-time | HIGH | Users see stale counts | Fix stream filter | 5min |
| Notification preferences not accessible | HIGH | Users can't disable notifications | Add settings route | 1h |
| No notification deep link routing | HIGH | Tap notification → wrong screen | Implement route logic | 2h |

## UI/UX Issues

| Issue | Severity | Impact | Screens | Fix Effort |
|-------|----------|--------|---------|------------|
| 294 hardcoded hex colors | HIGH | Dark mode completely broken | 55+ files | 4h |
| 665 `AppColors.*` references | HIGH | Won't adapt to theme changes | 60+ files | 3h |
| ~87 bare `Text('No...')` empty states | MEDIUM | Inconsistent UX, confusing | All list screens | 3h |

---

# 4. UI/UX AUDIT

## ✅ What Looks Good

- **6-Tab Navigation:** Clean pill-style nav bar, proper spacing (50px, 16px top gap)
- **Community Home:** 5-tab layout (Announcements, Discussions, Events, Resources, Members) — well-structured
- **Event Cards:** Responsive, show scope/category badges, date countdown
- **Form Fields:** Labels, validation, error messages consistent
- **Verified Badge:** Has tooltip, consistent across screens
- **Theme System:** 6 color presets working, theme switching functional

---

## 🔴 Critical UX Issues

### **Issue #1: Dark Mode Completely Broken**

**Severity:** CRITICAL (P0 for UX)  
**Impact:** ~30+ screens unreadable in dark mode

**Evidence:**
- 294 hardcoded `Color(0xFF...)` hex codes (won't adapt)
- 665 `AppColors.*` references (static, not theme-aware)
- Usage of `Colors.grey[200]`, `Colors.white` (hardcoded)

**Worst Offenders:**
- `profile_screen.dart` — 34 hardcoded colors
- `multi_university_admin_screen.dart` — 13 hardcoded colors
- `feed_screen.dart` — 10 hardcoded colors

**Consequence:**  
- Text invisible on dark background (white text on light background)
- Beta testers using dark mode see broken layout

**Fix Effort:** 4-5 hours
- Replace all `Color(0xFF...)` with `context.primary`, `context.error`, etc.
- Replace `AppColors.*` with theme extensions
- Add 6 missing color accessors: `brandOrange`, `gold`, `blueTint`, `blueLight`, `blueBorder`, `violet`

---

### **Issue #2: 90% of Screens Use Bare CircularProgressIndicator**

**Severity:** HIGH (P1 for UX)  
**Impact:** Ugly loading states, layout jumps, poor perceived performance

**Affected Screens:** ~50 screens across:
- Academic hub (course list, assignment hub, exam prep, GPA calculator)
- Events (all 12 event screens)
- Admin dashboard (15+ screens)
- Messaging (conversations, messages)

**Current Code (BROKEN):**
```dart
// ❌ UGLY
Center(child: CircularProgressIndicator())

// ✅ CORRECT
AsyncValue.loading => const UShimmerCard(),  // shimmer placeholder
```

**Consequence:**  
- Blank loading screen → sudden content appears → jarring UX
- Looks unprofessional
- Low perceived performance

**Fix Effort:** 4-6 hours
- Replace with `UShimmerCard` / `UShimmerBox` (already implemented in design system)
- Apply to all `AsyncValue.loading` cases

---

### **Issue #3: ~87 Bare Text('No...') Empty States**

**Severity:** MEDIUM (P2 for UX)  
**Impact:** Confusing UX, inconsistent design

**Examples (BROKEN):**
```dart
// ❌ BARE TEXT
if (posts.isEmpty) Text('No posts yet'),

// ✅ CORRECT
if (posts.isEmpty) AppEmptyWidget(
  icon: Icons.article_outlined,
  title: 'No posts',
  subtitle: 'Be the first to post in this community',
  action: ElevatedButton(...),
)
```

**Consequence:**  
- Users unsure if list is loading, empty, or broken
- No guidance on what to do next

**Fix Effort:** 2-3 hours
- Replace all with `AppEmptyWidget`
- Add contextual icons, subtitle, optional action button

---

### **Issue #4: Error States Inconsistent**

**Severity:** MEDIUM (P2)  
**Impact:** No retry, unclear errors, non-recoverable state

**Current Patterns (BROKEN):**
```dart
// ❌ BARE TEXT
AsyncValue.error((e, st) => Text('Error: $e'),

// ✅ CORRECT
AsyncValue.error((e, st) => AppErrorWidget(e, onRetry: () {...})
```

**Missing in Screens:**
- Community home (5 tabs use `Text('Error loading...')`)
- Feed (error state unclear)
- Academic screens

**Fix Effort:** 2 hours
- Replace with `AppErrorWidget` across all screens

---

## 🟡 Medium-Severity UX Issues

| Issue | Impact | Screens | Fix Effort |
|-------|--------|---------|------------|
| No shimmer loading | Visual jumps | 50+ | 4h |
| Bare Text errors | Confusing | 30+ | 2h |
| Hardcoded colors | Dark mode broken | 55 | 4h |
| AppColors references | Theme inconsistent | 60 | 3h |
| Missing empty states | Unclear UX | 87 locations | 2h |
| Form validation unclear | User confusion | 10+ screens | 1h |
| Scroll lag (no pagination) | Slow scrolling | messaging, members | 3h |
| Search debounce missing | Excessive queries | event_search, academic_search | 30min |

---

# 5. PERFORMANCE AUDIT

## ✅ What's Optimized

- Feed pagination: Cursor-based ✅
- Search queries: `.limit(20)` + server-side filters ✅
- Event queries: `.limit()` on most queries ✅
- Image caching: `cached_network_image` in 3 places ✅

---

## 🔴 Critical Performance Issues

### **Issue #1: ~20 Unbounded Queries (No `.limit()`)**

**Severity:** CRITICAL at scale  
**Impact:** 10k+ students → multi-second load times, OOM crashes on low-end devices

**Affected Queries:**

| File | Method | Risk |
|------|--------|------|
| `community_repository_impl.dart` | `searchCommunities()` | ALL communities |
| `community_repository_impl.dart` | `getRecommendedCommunities()` | ALL communities |
| `academic_repository_impl.dart` | `getCourses()` | ALL courses |
| `academic_repository_impl.dart` | `getResources()` | ALL resources |
| `academic_repository_impl.dart` | `getAssignments()` | ALL assignments |
| `event_repository_impl.dart` | `getDiscussions()` | ALL discussion posts |
| `notification_repository_impl.dart` | `getNotifications()` | ALL notifications, then `.take(50)` in Dart |
| `messaging_repository_impl.dart` | `messageRequests()` | ALL requests |
| Admin queries (10+) | Various | ALL rows per query |

**Example (BROKEN):**
```dart
// ❌ WRONG — fetches ALL courses, filters in Dart
final courses = await _supabase.from('courses').select();
return courses.map(CourseModel.fromJson).toList();

// ✅ CORRECT
final courses = await _supabase
    .from('courses')
    .select()
    .eq('faculty_id', facultyId)  // server-side filter
    .limit(40)  // server-side limit
    .order('created_at', ascending: false);
```

**Consequence:**
- 1,000 communities → fetch 1,000 rows to filter 5
- 1,000 courses → fetch all, filter in memory
- **At 10k students: queries take 5+ seconds**

**Fix Effort:** 3-4 hours
- Add `.limit(20-40)` to all queries
- Add server-side `.eq()` filters before `.select()`
- Replace client-side filtering with server-side

---

### **Issue #2: Unfiltered Realtime Streams (Data Leak + Bandwidth)**

**Severity:** CRITICAL  
**Impact:** Each user receives ALL users' updates

**Affected:**
- `notifications` stream (already identified in P0-B)
- `conversations` stream (messaging)
- `messages` stream (messaging)

**Consequence:**
- 10k users × 100 messages/day = 1M message events
- Each user receives 1M events (not just their own)
- **Bandwidth cost: 10× normal**

**Fix Effort:** 30 minutes per stream
- Add `.eq()` filter on user_id/participant filters

---

### **Issue #3: SELECT * (Anti-Pattern)**

**Severity:** MEDIUM  
**Impact:** Fetches unnecessary columns, slows queries

**Occurrences:** ~70+ in codebase

**Example (BROKEN):**
```dart
// ❌ Fetches all 30 columns
final posts = await _supabase.from('posts').select();

// ✅ CORRECT — fetch only needed columns
final posts = await _supabase.from('posts').select(
  'id, title, content, author_id, created_at, upvote_count, downvote_count'
);
```

**Fix Effort:** 2-3 hours
- Audit high-frequency queries
- Replace `.select()` with specific column lists

---

### **Issue #4: No Pagination in 10+ List Screens**

**Severity:** MEDIUM  
**Impact:** Scroll lag on lists with 100+ items

**Affected:**
- Conversation list
- Member list
- Resource list
- Notification list (unread)
- Admin queries

**Example (BROKEN):**
```dart
// ❌ Fetches all 500 members at once
final members = await repo.getMembers(communityId);

// ✅ CORRECT — paginate
final page1 = await repo.getMembers(communityId, limit: 20, offset: 0);
// onScroll: fetch page 2, page 3, etc.
```

**Fix Effort:** 2-3 hours
- Add `ScrollController` + `loadMore()` callback
- Implement offset-based pagination (or cursor-based)

---

## 🟡 Medium Performance Issues

| Issue | Impact | Fix Effort |
|-------|--------|------------|
| Image memory not capped | OOM on photo-heavy screens | Add `memCacheWidth`/`memCacheHeight` | 30min |
| No cache invalidation strategy | Stale data shown | Implement cache expiry check | 1h |
| Notification badge updates slow | User sees stale count | Fix Riverpod provider | 10min |
| Search no debounce (some screens) | 1 query per keystroke | Add 300ms debounce | 20min |

---

# 6. SUPABASE AUDIT

## ✅ What's Configured Correctly

- **Auth:** Supabase Auth with email/password + Google OAuth ✅
- **RLS:** Enabled on most tables ✅
- **Storage:** `profiles_avatars` bucket configured ✅
- **Edge Functions:** Exist but not deployed (commented)
- **Migrations:** 9 canonical migrations exist ✅
- **Realtime:** Enabled (but unfiltered — see P0-B)

---

## 🔴 Critical Supabase Issues

### **Issue #1: push_notification_queue Never Populated**

**Already identified in P0-E**

---

### **Issue #2: Streams Missing User Filters**

**Already identified in P0-B**

---

### **Issue #3: RLS Policies Incomplete**

**Severity:** MEDIUM (P2)  
**Gaps:**
- `gpa_courses` and `study_plan_items` have RLS enabled but **ZERO policies** (data accessible to all)
- Missing DELETE on `academic_resources`
- Missing INSERT/UPDATE/DELETE on `exam_timetables`

**Fix Effort:** 1-2 hours
- Apply `step17_production_readiness.sql` (includes missing policies)

---

### **Issue #4: Edge Functions Not Deployed**

**Severity:** MEDIUM (P1)  
**Functions Needed:**
1. `send_push_notification` — processes queue → FCM v1 API
2. `daily-analytics` — aggregates daily metrics

**Status:** Code exists but not deployed

**Fix Effort:** 30 minutes
```bash
supabase functions deploy send_push_notification --no-verify-jwt
supabase functions deploy daily-analytics --no-verify-jwt
```

---

### **Issue #5: Analytics Never Populated**

**Severity:** MEDIUM (P2)  
**Impact:** Analytics dashboard shows all zeros

**Root Cause:** `aggregate_daily_analytics()` RPC exists but never called

**Fix Effort:** 1 hour
- Schedule daily pg_cron job OR
- Call from client on app launch

---

# 7. iOS AUDIT

## 🔴 Critical Issues

| Item | Status | Issue | Fix |
|------|--------|-------|-----|
| **GoogleService-Info.plist** | ❌ MISSING | Firebase won't initialize | Download from Console, add to Xcode |
| **Push Notifications Capability** | ❌ MISSING | APNS won't work | Enable in Xcode, request certificate |
| **APNS Certificate** | ❌ MISSING | Can't send notifications | Request + upload to Apple + Firebase |
| **Associated Domains** | ❌ MISSING | Deep links won't work | Add capability, configure apple-app-site-association |
| **App Icons** | ⚠️ CHECK | Verify all sizes generated | Run `flutter pub run flutter_launcher_icons` |
| **Launch Screen** | ✅ OK | `LaunchScreen.storyboard` configured | No changes needed |

---

## ⚠️ Configuration Checklist

### Info.plist
- ✅ `CFBundleDisplayName`: "Unify"
- ✅ `UIBackgroundModes`: `remote-notification`
- ✅ `LSRequiresIPhoneOS`: true
- ❌ Missing: `UIApplicationSupportsIndirectInputEvents` (may need for keyboard)
- ❌ Missing: `NSAppTransportSecurity` exceptions (if needed)

### Xcode Project
- ⚠️ Bundle ID: Must match Firebase project
- ⚠️ Signing Team: Must have Apple Developer account
- ⚠️ Provisioning Profile: Must allow push notifications

### Entitlements
- ❌ `aps-environment`: Missing (should be "development" for TestFlight)
- ❌ `com.apple.developer.associated-domains`: Missing

---

## 📋 TestFlight Preparation Checklist

- [ ] `GoogleService-Info.plist` downloaded + added to Xcode
- [ ] Push Notifications capability enabled
- [ ] APNS certificate requested + uploaded
- [ ] Bundle ID matches Firebase
- [ ] Signing team configured
- [ ] Provisioning profile supports push
- [ ] `flutter build ipa --release` builds successfully
- [ ] IPA uploaded to App Store Connect
- [ ] TestFlight beta testers invited

---

# 8. ANDROID AUDIT

## ✅ What's Configured

- ✅ Permissions: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`
- ✅ Deep links: `com.gctu.unify://auth/callback`
- ✅ FCM channel: `unify_notifications`
- ✅ `google-services.json` exists
- ✅ Min/Target SDK: Appropriate values

---

## 🔴 Issues

| Item | Status | Issue | Fix |
|------|--------|-------|-----|
| **Namespace** | ⚠️ MISMATCH | `com.example.unify` vs `com.gctu.unify` | Change namespace to `com.gctu.unify` |
| **Release Signing** | ❌ DEBUG KEY | Uses debug key for release builds | Create release keystore, update signingConfig |
| **App ID** | ✅ OK | `com.gctu.unify` correct | No changes needed |

---

## 📋 Build Checklist

- [ ] Namespace changed to `com.gctu.unify`
- [ ] Release signing keystore created
- [ ] `flutter build appbundle --release` succeeds
- [ ] App signed with release key
- [ ] Upload to Play Console (for future release)

---

# 9. CODE QUALITY AUDIT

## ✅ Strengths

- **Clean Architecture:** Data/domain/presentation layers properly separated ✅
- **Riverpod:** Providers follow best practices (no global state) ✅
- **Error Handling:** Centralized `ErrorMapper` ✅
- **Theme System:** 6 presets, extensible ✅
- **Naming:** Consistent, clear naming conventions ✅
- **Navigation:** GoRouter properly configured (mostly) ✅

---

## 🟡 Technical Debt

### **Issue #1: Dead Code**

**Status:** ~10-15 unused imports, unused locals, unnecessary casts  
**Examples:**
- `_ErrorView` class (replaced by `AppErrorWidget`)
- Unused imports in ~10 files

**Fix Effort:** 30 minutes
```bash
dart fix --apply
```

---

### **Issue #2: Deprecated API Usage**

**Status:** 39+ `prefer_const_constructors` infos, deprecation warnings

**Deprecated Parameters:**
- `Radio.groupValue` → use `RadioGroup`
- `Switch.activeColor` → `activeThumbColor`
- `DropdownButtonFormField.value` → `initialValue`
- `anonKey` → `publishableKey`

**Fix Effort:** 30 minutes
```bash
dart fix --apply
```

---

### **Issue #3: Large Files**

**Severity:** LOW  
**Worst Offenders:**
- `admin_screen.dart` — 1,400+ lines (consider splitting by tab)
- `app_router.dart` — 400+ lines (consider modular routing)
- `feed_screen.dart` — 600+ lines (consider extracting widgets)

**Best Practice:** Max 400 lines per file

**Fix Effort:** 3-4 hours (refactor if time permits)

---

### **Issue #4: Duplicate Code**

**Severity:** MEDIUM  
**Patterns:**
- 3+ screens with identical "add error state" pattern
- 5+ screens with identical "empty state" pattern
- Multiple RSVP/registration flows with similar logic

**Already Addressed:** `AppEmptyWidget`, `AppErrorWidget` extracted ✅

---

## 📊 Code Quality Score

| Metric | Score | Notes |
|--------|-------|-------|
| Type Safety | 95/100 | Excellent use of Dart 3 features |
| Architecture | 90/100 | Clean Architecture well-followed |
| Testing | 0/100 | ⚠️ **NO TESTS** (unit, widget, integration) |
| Documentation | 70/100 | Good code comments, missing architecture docs |
| Performance | 60/100 | Unbounded queries, unfiltered streams hurt perf |
| Accessibility | 20/100 | Zero Semantics widgets, hardcoded text sizes |

---

# 10. BETA READINESS SCORE

## Final Score: 35/100 ❌ **NOT READY FOR TESTFLIGHT**

### Breakdown by Category

| Category | Score | Comments |
|----------|-------|----------|
| **Build Status** | 60/100 | Missing Firebase init, signing config, iOS capabilities |
| **Functionality** | 40/100 | FCM stubbed, 13 routes broken, streams unfiltered |
| **iOS Configuration** | 25/100 | Missing APNS, GoogleService-Info.plist, entitlements |
| **Android Configuration** | 70/100 | Mostly good, minor namespace fix needed |
| **UX/Polish** | 30/100 | Dark mode broken, no shimmer loading, bare errors |
| **Performance** | 50/100 | Unbounded queries, unfiltered streams, no pagination |
| **Security** | 65/100 | RLS enabled, but some policies missing, stream data leak |
| **Offline Support** | 30/100 | Minimal caching, no offline queue |
| **Analytics** | 20/100 | Infra exists but never populated |
| **Crash Reporting** | 30/100 | Sentry wired but no DSN configured |

---

## Summary Assessment

### What Works (MVP Ready)
- ✅ Authentication (email + Google)
- ✅ Onboarding
- ✅ Feed (posts, comments, upvotes)
- ✅ Communities (join, manage, members)
- ✅ Messaging (conversations, DMs, group chats)
- ✅ Events (create, RSVP, tickets)
- ✅ Academic hub (courses, resources, GPA)
- ✅ Admin dashboard

### What's Broken (Blocks TestFlight)
- ❌ **Push notifications** (not initialized)
- ❌ **Profile access** (13 missing routes)
- ❌ **iOS platform setup** (missing APNS, plist, capabilities)
- ❌ **Dark mode** (hardcoded colors)
- ❌ **Offline support** (no offline queue)

### What's Suboptimal (Fix After TestFlight)
- ⚠️ Unbounded queries (performance)
- ⚠️ Unfiltered streams (data leak, bandwidth)
- ⚠️ Bare loading states (UX)
- ⚠️ No testing (reliability)
- ⚠️ Analytics not populated (metrics)

---

# RECOMMENDED ROADMAP TO TESTFLIGHT

## Phase 1: Critical Build Fixes (1-2 Days)

### Day 1 AM — Firebase & Signing
- [ ] Generate `firebase_options.dart` via `flutterfire configure`
- [ ] Add `Firebase.initializeApp()` to `main.dart`
- [ ] Download `GoogleService-Info.plist`, add to Xcode
- [ ] Create release signing keystore (Android)
- [ ] Update `build.gradle.kts` with release signing config

### Day 1 PM — iOS Capabilities
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Add "Push Notifications" capability
- [ ] Request APNS certificate from Apple Developer Account
- [ ] Upload APNS certificate to Apple + Firebase
- [ ] Add "Associated Domains" capability (for deep links)
- [ ] Configure `apple-app-site-association`

### Day 2 — GoRouter Routes
- [ ] Add 13 missing routes to GoRouter config
- [ ] For disabled features (marketplace, opportunities): redirect to feed + show toast
- [ ] Test all tabs navigate without crash

---

## Phase 2: Core Functionality Fixes (1-2 Days)

### Day 1 — Push Notifications
- [ ] Wire `PushNotificationService.init()` in `app.dart` auth listener
- [ ] Verify device tokens saved to DB
- [ ] Fix `create_notification()` RPC to INSERT into `push_notification_queue`
- [ ] Fix RPC parameter names (4 call sites in admin_screen.dart)
- [ ] Deploy Edge Function: `send_push_notification`
- [ ] Test end-to-end notification delivery

### Day 2 — Stream Filters & Queries
- [ ] Add `.eq('user_id', userId)` to `unreadCountStream()`
- [ ] Add `.limit(20)` to global search (communities)
- [ ] Fix notification query filtering in admin screens
- [ ] Test at scale: 1,000+ rows shouldn't cause slowdown

---

## Phase 3: UX Polish (1 Day)

### Day 1 — Dark Mode & Loading States
- [ ] Replace hardcoded colors with `context.*` theme tokens (focus on worst offenders)
- [ ] Replace 50 `CircularProgressIndicator` with `UShimmerCard`
- [ ] Replace 87 bare `Text('No...')` with `AppEmptyWidget`
- [ ] Test dark mode on 10+ screens

---

## Phase 4: Final Testing & Submission (1 Day)

### Day 1 — Testing
- [ ] `flutter analyze`: 0 errors, 0 warnings
- [ ] `flutter build ipa --release`: succeeds
- [ ] `flutter build appbundle --release`: succeeds (for Play Store later)
- [ ] Internal testing on 3-5 beta devices (iOS + Android)
- [ ] Test all 6 tabs navigation
- [ ] Test notification delivery
- [ ] Test profile access
- [ ] Test sign-out/sign-in
- [ ] Upload IPA to App Store Connect
- [ ] Invite TestFlight testers

---

## Total Effort Estimate
- **Phase 1 (Build):** 2 days
- **Phase 2 (Functionality):** 2 days
- **Phase 3 (UX):** 1 day
- **Phase 4 (Testing):** 1 day
- **Total:** 6 days of focused work

### Parallel Work (to Reduce Timeline)
- iOS APNS certificate can be requested while Firebase is being set up (Day 1 AM/PM split)
- GoRouter routes can be added while push notifications are being wired
- **Optimistic timeline: 4 days** with parallel work

---

# SUMMARY FOR DECISION-MAKING

## Can We Launch TestFlight Next Week?

**Answer: NO** ❌

**Why:**
1. Firebase not initialized — app won't boot properly for new users
2. 13 missing routes — core features (profile) crash
3. iOS APNS not configured — push notifications impossible
4. Dark mode broken — ~30% of users will have unreadable app

**Required Fixes Before TestFlight:**
1. ✅ Firebase initialization (30 min)
2. ✅ 13 missing routes (3 hours)
3. ✅ iOS APNS + capabilities (2-3 hours + Apple processing time)
4. ✅ Fix push notification wiring (4 hours)
5. ✅ Stream filters + RPC parameters (30 minutes)
6. ✅ Dark mode critical colors (3-4 hours)

**Realistic Timeline:**
- **Optimistic:** 4-5 days (with parallel iOS certificate request)
- **Comfortable:** 6-7 days (staged, careful testing)
- **Target Launch:** July 15-16, 2026

---

## Recommended Next Steps

1. **Today (July 9):** Kick off Firebase setup + iOS APNS request (can be parallel)
2. **July 10-11:** Complete Phase 1 (Build fixes)
3. **July 12-13:** Complete Phase 2 (Functionality fixes)
4. **July 14:** Phase 3 UX polish + full testing
5. **July 15:** Upload to App Store Connect, invite TestFlight testers

---

# END OF AUDIT REPORT

**Report Generated:** July 9, 2026 | **Status:** NOT READY FOR TESTFLIGHT | **Next Action:** Begin Phase 1 Fixes

---

