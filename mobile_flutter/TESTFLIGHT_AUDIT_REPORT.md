# UNIFY iOS TestFlight Audit Report
**Date:** July 11, 2026 | **Status:** Audit Complete | **Version:** 1.0.0+1

---

## 1. Hardcoded API Keys / Secrets

### 🔴 CRITICAL: Firebase API keys in source code (implicit exposure risk)
- **File:** `lib/firebase_options.dart:52-68`
- **Issue:** The FlutterFire CLI generated file embeds Firebase API keys (`apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket`, `iosClientId`, `iosBundleId`) as constants in source code
- **Risk:** These are intentionally public per Firebase design (API keys are not secrets). However, the `iosClientId` (`752669005350-bfqtdv4q2arsut5084sinp3hr9h9o5ae.apps.googleusercontent.com`) is exposed for Google Sign-In OAuth
- **Severity:** LOW — Firebase API keys are designed to be public
- **Recommendation:** Ensure `google-services.json` and `GoogleService-Info.plist` are NOT committed to git

### 🔴 CRITICAL: Supabase anon key in source-controlled `.env` file
- **File:** `assets/.env:2`
- **Issue:** Supabase anon key stored in tracked asset:
  ```
  SUPABASE_URL=https://tuepkmjedmbxdlriform.supabase.co
  SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  ```
- **Risk:** Public anon key (by design), but if the project is open-source or shared, anyone can make anonymous Supabase queries up to RLS limits
- **Severity:** LOW (RLS is the actual security boundary)
- **Recommendation:** Exclude `assets/.env` from git and use `--dart-define` for CI builds

### 🟡 MEDIUM: Vercel OIDC token committed
- **File:** `.env.local:2`
- **Issue:** Full Vercel OIDC JWT token with `owner:ctwumgyan-7759s-project:unify-web` scope
- **Risk:** This is a short-lived deployment token but should NOT be in source control
- **Severity:** MEDIUM
- **Recommendation:** Add `.env.local` to `.gitignore`

---

## 2. Supabase RLS Bypass / Query Injection

### 🟡 MEDIUM: `!inner` hints bypass soft joins
- **Files:**
  - `lib/features/admin/data/repositories/admin_repository_impl.dart:328` — `admin_roles!inner(role)`
  - `lib/features/admin/data/repositories/admin_repository_impl.dart:444` — `fk_reported_by!inner`
  - `lib/features/events/data/repositories/event_repository_impl.dart:273,500,519,748` — `community_events!inner(*)`
- **Issue:** `!inner` forces an INNER JOIN, which acts as a filter: if the joined row doesn't exist, the parent row is excluded. This is legitimate but can be used (in combination with RLS bypass) to enumerate data
- **Severity:** LOW — these are all within the app's legitimate data model. RLS still applies

### 🟢 LOW: `.rpc()` calls safe (no user-provided SQL injection)
- **Files:** 28 `.rpc()` calls across the codebase (admin, events, messaging, academic, marketplace, opportunities, etc.)
- **Verification:** All `.rpc()` calls pass fixed function names and structured params (`{'p_resource_id': resourceId}`). No raw SQL string concatenation with user input. **No injection risk.**
- **Severity:** NONE

---

## 3. Insecure Data Storage

### 🟢 LOW: Hive caches non-sensitive data
- **File:** `lib/core/services/cache_service.dart`
- **Boxes used:** `feed_cache`, `profile_cache`, `opportunities_cache`, `academic_cache`, `offline_resources`, `launch_cache`
- **Data stored:** Cached API responses (JSON-encoded), typed as plain `String`
- **No tokens, passwords, or credentials stored** in Hive
- **Severity:** NONE

### 🟢 LOW: SharedPreferences stores non-sensitive data
- **Files:**
  - `lib/core/providers/theme_provider.dart:18,30` — theme preset name (string like `"ocean"`)
  - `lib/core/providers/theme_mode_provider.dart:19,30` — theme mode string (`"system"`, `"light"`, `"dark"`)
  - `lib/features/welcome/welcome_screen.dart:36` — `hasSeenWelcome` boolean
  - `lib/features/splash/splash_screen.dart:58` — same
  - `lib/features/onboarding/onboarding_screen.dart:225` — `onboarding_complete` boolean
  - `lib/features/search/presentation/providers/search_provider.dart:214-237` — recent search history strings
- **Issue:** No sensitive data (no tokens, passwords, or personal data beyond user preferences)
- **Severity:** NONE

### 🟢 LOW: `debugPrint` used extensively (no credential logging)
- **Pattern:** `debugPrint('[ClassName] Error: $e')` used across all repository/provider/service files (~250 occurrences)
- **Verification:** No credentials, tokens, or passwords are logged. Error messages contain exception descriptions and object IDs only
- **Severity:** NONE

---

## 4. Insecure HTTP Connections

### 🟢 LOW: Only 1 `http://` reference (SVG namespace)
- **File:** `lib/features/profile/presentation/screens/profile_screen.dart:994`
- **Code:** `'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'`
- **Issue:** This is a hardcoded SVG namespace URI used for rendering inline SVG icons. It is NOT a network request
- **Severity:** NONE

### ✅ No insecure HTTP network calls found
- All Supabase calls use HTTPS (Supabase client enforces it)
- All storage URLs use HTTPS
- No `http://` URL strings in network request code
- **Severity:** NONE

---

## 5. Deep Link / URL Scheme Security

### 🟡 MEDIUM: Android deep link not verified
- **File:** `android/app/src/main/AndroidManifest.xml:32`
- **Code:** `<intent-filter android:autoVerify="false">`
- **Issue:** `autoVerify=false` means Android does not verify domain ownership. Any app can declare the same intent filter on a rooted device
- **Impact:** On Android 12+, unverified deep links show a disambiguation dialog instead of routing directly to the app. Phishing risk (another app could register `com.gctu.unify://auth/callback`)
- **Severity:** MEDIUM

### 🔴 CRITICAL: iOS has NO deep link handling at all
- **File:** `ios/Runner/AppDelegate.swift:1-16`
- **Issue:** Standard Flutter `FlutterAppDelegate` with NO custom URL scheme handling. No `CFBundleURLTypes` in `ios/Runner/Info.plist`
- **Result:** Google OAuth deep link callback (`com.gctu.unify://auth/callback`) works on Android (manifest intent filter) but **will NOT work on iOS**
- **Impact:** Google Sign-In will fail on iOS — the OAuth flow completes in Safari but the app never receives the callback
- **Severity:** 🔴 CRITICAL

### 🔴 CRITICAL: Push notification deep link routing uses hardcoded paths
- **File:** `lib/features/notifications/domain/services/push_notification_service.dart:124-178`
- **Issue:** `routeFromData()` switches on notification type and builds routes like `/messaging/chat/$convId` directly without validation of `convId` format
- **Risk:** If a malicious notification payload contains `conversation_id: '../../../admin'`, it could redirect to an admin route. However, GoRouter has path validation and admin routes are protected by `AdminGuard`
- **Severity:** LOW (guarded by AdminGuard)

### 🟢 LOW: Push notification routes reference unverified GoRouter paths
- **Paths like** `/event/$eventId` (line 140) vs app router uses `/events/:id` — possible navigation error but no security risk

---

## 6. Input Validation / Path Traversal

### 🟡 MEDIUM: File upload paths use user-controlled extension without sanitization
- **Files (7 upload sites use the same pattern):**
  - `lib/features/verification/presentation/screens/verification_request_screen.dart:87-89`
  - `lib/features/academic/presentation/screens/resource_upload_screen.dart:253-259`
  - `lib/features/posts/presentation/screens/create_post_screen.dart:257-258`
  - `lib/features/messaging/data/repositories/messaging_repository_impl.dart:445-446`
  - `lib/features/snapshots/data/repositories/snapshot_repository.dart:161-162`
  - `lib/features/onboarding/steps/step_profile_photo.dart:28-30`
  - `lib/features/snapshots/presentation/screens/snapshot_composer_screen.dart:139`
- **Pattern:**
  ```dart
  final ext = imageFile.path.split('.').last;
  final path = 'verification/${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
  ```
- **Risk:** Image file extensions are taken directly from the filename. A file named `malicious.php;.png` could potentially bypass extension checks on some storage providers. However, Supabase Storage enforces content-type based on file magic bytes, and the path is namespaced by user ID
- **Severity:** LOW (Supabase Storage muxes by MIME detection, not extension)
- **Recommendation:** Whitelist allowed extensions (`jpg`, `jpeg`, `png`, `gif`, `webp`, `pdf`, `doc`, `docx`)
- **Safe patterns:** All upload paths are namespaced by user ID (`${user.id}/...`) which prevents path traversal

---

## 7. Debug Mode Checks

### 🟢 LOW: `kDebugMode` used safely
- **File:** `lib/bootstrap.dart:21,28,67`
- **Usage:**
  - Line 21: Only presents Flutter errors visually in debug mode
  - Line 28: Only prints `[PlatformError]` in debug mode
  - Line 67: Only prints `[ZonedError]` in debug mode
- **Assessment:** These are standard patterns. In release mode, errors go to Sentry (crash reporting) but are not printed. **No security risk.**
- **Severity:** NONE

### 🟢 LOW: `assert()` used correctly
- **Files:**
  - `lib/features/messaging/presentation/widgets/typing_indicator.dart:105` — `assert(typingCount > 0)`
  - `lib/core/widgets/main_shell.dart:200` — `assert(badges.length == MainShell._tabs.length)`
- **Assessment:** Both are compile-time sanity checks for internal widget logic. No security-sensitive assertions. **No issue.**
- **Severity:** NONE

---

## 8. Environment Configuration

### 🔴 CRITICAL: `Supabase.initialize()` NEVER CALLED
- **File:** `lib/main.dart:6-16`
- **Issue:** The app initializes Firebase but **never calls `Supabase.initialize(url: ..., anonKey: ...)`**
- **Evidence:**
  - Previous version (commit `3517c12`) had proper initialization with dotenv
  - Commit `50ea10f` ("dee") replaced main.dart with a 900-line prototype stub
  - Current working tree has a simplified version with only `Firebase.initializeApp()`
  - `flutter_dotenv: ^5.2.1` in `pubspec.yaml:45` but never imported or used
  - `assets/.env` exists with credentials but never loaded
- **Impact:** Any access to `Supabase.instance.client` (used in 49+ files) will throw `LateInitializationError`. **App will crash on startup for any feature that requires Supabase**
- **Severity:** 🔴 CRITICAL — P0 BLOCKER

### 🟡 MEDIUM: No environment separation (dev/staging/prod)
- **Issue:** No flavor configuration (no `FlavorConfig`, no `--dart-define` for Supabase in current code). The app hardcodes one environment
- **Impact:** Cannot test against staging DB without modifying `assets/.env`. Risk of testing against production data
- **Severity:** MEDIUM
- **Recommendation:** Add `--dart-define` support for `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SENTRY_DSN` with `.env` fallback

---

## 9. Analytics / Tracking Consent

### 🔴 CRITICAL: No GDPR/opt-in consent before analytics logging
- **File:** `lib/core/services/analytics_service.dart:66-82`
- **Issue:** `AnalyticsService.log()` is called on:
  - `app_launched` — at app startup (`lib/app.dart:33`)
  - `user_signed_up` — on sign-up (`lib/features/auth/presentation/providers/auth_provider.dart:29`)
  - `user_logged_in` — on login (`lib/features/auth/presentation/providers/auth_provider.dart:38`)
  - `user_logged_out` — on logout (`lib/features/auth/presentation/providers/auth_provider.dart:51`)
  - `password_reset` — on password reset (`lib/features/auth/presentation/providers/auth_provider.dart:56`)
  - `community_joined` / `community_left` / `post_created` / `message_sent` / `event_rsvp` / `profile_completed` / `app_launched`
- **Impact:** **GDPR violation for EU users.** App Store requires explicit opt-in before tracking. EU users' data sent to Supabase `analytics_events` table without consent
- **Severity:** 🔴 CRITICAL — REJECTED BY APP REVIEW

### 🟡 MEDIUM: Session tracking without consent
- **File:** `lib/core/services/analytics_service.dart:34-63`
- **Issue:** `startSession()` / `endSession()` track user sessions in `user_sessions` table with `user_id`, `app_version`, `platform`, `duration_seconds`. No opt-in mechanism.
- **Impact:** Violates GDPR Article 7 (consent) and ePrivacy Directive. Apple App Store requires consent for analytics
- **Severity:** MEDIUM
- **Recommendation:** Gate all analytics behind a consent dialog on first launch

---

## 10. Release Build Settings

### 🔴 CRITICAL: Android release signed with debug key
- **File:** `android/app/build.gradle.kts:44`
- **Code:** `signingConfig = signingConfigs.getByName("debug")`
- **Issue:** Release builds use the public Android debug keystore. Any developer can repackage and sign the app
- **Impact:**
  - Google Play Store will reject (debug-signed APKs/AABs not allowed)
  - Anyone can tamper with the APK and re-sign it
  - Users who sideload from untrusted sources won't be able to verify authenticity
- **Severity:** 🔴 CRITICAL — P0 BLOCKER

### 🟡 MEDIUM: Android namespace mismatch
- **File:** `android/app/src/main/kotlin/com/example/unify/MainActivity.kt:1`
- **Code:** `package com.example.unify`
- **Issue:** Namespace in `AndroidManifest.xml` is `com.gctu.unify` (line 15 of build.gradle.kts) but Kotlin file uses `com.example.unify`
- **Impact:** Minor — the actual namespace is set in build.gradle.kts which takes precedence, but this is confusing
- **Severity:** LOW

### 🟡 MEDIUM: iOS `CFBundleName` lowercase
- **File:** `ios/Runner/Info.plist:18`
- **Code:** `<string>unify</string>`
- **Issue:** Bundle name is lowercase `unify` while display name is `Unify` (line 10). Minor inconsistency
- **Severity:** LOW

---

## 11. Error Messages Leaking Internals

### 🔴 CRITICAL: Startup error widget leaks full exception + stack trace
- **File:** `lib/bootstrap.dart:74-119`
- **Code:** `_StartupErrorApp` renders `'$error'` and `'${stackTrace ?? ''}'` to the user
- **Issue:** If the app fails to start, the error screen displays the **full exception message and stack trace** in release builds (the comment in line 75-76 says "Exception *messages* survive minification")
- **Impact:** Sensitive information (file paths, Dart runtime internals, database error messages) visible to end users. Could leak Supabase table names, column names, or internal app structure
- **Severity:** 🔴 CRITICAL — PRIVACY LEAK

### 🔴 CRITICAL: Build error widget leaks exception details
- **File:** `lib/bootstrap.dart:36-49`
- **Code:** `ErrorWidget.builder` renders `details.exception` and `details.stack` to users
- **Issue:** Release builds show `'Build error:\n${details.exception}\n\n${details.stack ?? ''}'` in red text
- **Impact:** Same as above — internal details exposed to end users
- **Severity:** 🔴 CRITICAL

### 🟡 MEDIUM: Snackbar leaks raw error on photo upload failure
- **File:** `lib/features/onboarding/steps/step_profile_photo.dart:38`
- **Code:** `SnackBar(content: Text('Upload failed: $e'))`
- **Issue:** Caught exception `$e` is shown directly to user. Could expose Supabase storage error details
- **Severity:** MEDIUM

### 🟡 MEDIUM: Snackbar leaks error on chat open failure
- **File:** `lib/features/messaging/presentation/screens/student_directory_screen.dart:121`
- **Code:** `SnackBar(content: Text('Could not open chat: $e'))`
- **Issue:** Raw exception shown to user
- **Severity:** MEDIUM

### 🟢 LOW: Most error sites use `AppErrorWidget` or `ErrorMapper`
- 88+ error sites properly mapped via `ErrorMapper.toUserMessage(e)` ✅
- Support center (`lib/features/support/presentation/screens/support_center_screen.dart:626`) uses `ErrorMapper.toUserMessage(error)` ✅
- Representative detail screen (`lib/features/admin/presentation/screens/representative_detail_screen.dart:161`) uses `ErrorMapper.toUserMessage(e)` ✅

---

## 12. Firebase Configuration Check

### 🔴 CRITICAL: Firebase properly initialized but Supabase not initialized
- **Files:**
  - `lib/firebase_options.dart` — **Valid Firebase options** with real project IDs (`unify-b92fd`), real API keys, real iOS client ID
  - `lib/main.dart:10-12` — `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` — **CORRECT**
- **Issue:** `Supabase.initialize()` is never called. `lib/bootstrap.dart:54` calls `Hive.initFlutter()` but no Supabase init
- **Firebase options status:** All values are **real** (not placeholders)
  - `apiKey` (Android): `AIzaSyCaQNgkoosm_DoyBSK1EWuHH-H9FAlFQRs`
  - `apiKey` (iOS): `AIzaSyA3Zbz9BMDw7SU5nHtPrE8UHSAfw67rXGk`
  - `projectId`: `unify-b92fd`
  - `iosClientId`: `752669005350-bfqtdv4q2arsut5084sinp3hr9h9o5ae.apps.googleusercontent.com` (for Google Sign-In)
- **Firebase native configs:**
  - `android/app/google-services.json` — **exists** ✅
  - `ios/Runner/GoogleService-Info.plist` — **exists** ✅
- **Sentry:** `CrashReportingService` in `lib/core/services/crash_reporting_service.dart:3-26` is a **graceful no-op** — never initialized with a DSN. All errors silently dropped in production
- **Single environment:** No dev/prod Firebase separation. Same Firebase project for all builds

### 🟡 MEDIUM: Missing `flutter_dotenv` import in main.dart
- **File:** `lib/main.dart` — no `flutter_dotenv` import
- **Impact:** `assets/.env` file exists with Supabase credentials but is never loaded
- **Severity:** MEDIUM (critical because Supabase.initialize is also missing)

---

## Summary of Findings

### 🔴 CRITICAL (P0 — Blocks TestFlight)

| # | Issue | File | Line(s) |
|---|-------|------|---------|
| 1 | `Supabase.initialize()` never called — app crashes on any Supabase access | `lib/main.dart` | 6-16 |
| 2 | iOS deep link handling completely missing — Google Sign-In will fail on iOS | `ios/Runner/AppDelegate.swift`, `ios/Runner/Info.plist` | 1-16 |
| 3 | Error widget leaks stack traces to end users | `lib/bootstrap.dart` | 36-49, 74-119 |
| 4 | Analytics events fire without user consent — GDPR violation for App Store | `lib/core/services/analytics_service.dart` | 66-82 |
| 5 | Android release build signed with debug key — Play Store rejection | `android/app/build.gradle.kts` | 44 |
| 6 | Uncommitted working tree vs HEAD mismatch — `main.dart` was replaced by `50ea10f` | Working tree dirty | — |

### 🟡 MEDIUM (P1 — Fix Before Launch)

| # | Issue | File | Line(s) |
|---|-------|------|---------|
| 7 | No environment separation (dev/staging/prod) | Entire codebase | — |
| 8 | Vercel OIDC token committed | `.env.local` | 2 |
| 9 | Android deep link `autoVerify=false` — disambiguation dialog | `AndroidManifest.xml` | 32 |
| 10 | 2 bare `SnackBar(content: Text('$e'))` — error details leaked | `step_profile_photo.dart:38`, `student_directory_screen.dart:121` | — |
| 11 | File upload extension whitelist missing (7 upload sites) | Various | — |

### 🟢 LOW (P2 — Nice to Have)

| # | Issue | File | Line(s) |
|---|-------|------|---------|
| 12 | Firebase API keys in source code (by design, but track) | `firebase_options.dart` | 52-68 |
| 13 | Supabase anon key in tracked `assets/.env` | `assets/.env` | 2 |
| 14 | Android Kotlin package mismatch (`com.example.unify` vs `com.gctu.unify`) | `MainActivity.kt` | 1 |
| 15 | iOS bundle name lowercase (`unify` vs `Unify`) | `Info.plist` | 18 |
| 16 | Push notification deep link routing unvalidated payload paths | `push_notification_service.dart` | 124-178 |
| 17 | `Sentry DSN` empty — crash reporting silently disabled | `CrashReportingService` | 3-26 |

---

## Most Critical Code Fix Needed

**`lib/main.dart`** — Missing Supabase initialization. The previous version (commit `3517c12`) had correct initialization:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await bootstrap(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
        authFlowType: AuthFlowType.pkce,
      ),
    );
    return const UnifyApp();
  }, sentryDsn: dotenv.env['SENTRY_DSN']);
}
```
This was removed in commit `50ea10f` and not fully restored.

---

## Readiness Verdict

**❌ NOT READY FOR TESTFLIGHT**

6 Critical (P0) blockers exist, any one of which would prevent a successful beta:

1. `Supabase.initialize()` missing → app crashes on startup when any feature queries Supabase
2. iOS deep links missing → Google Sign-In fails on iOS (OAuth callback never received)
3. Stack trace leak in error widget → App Store privacy violation
4. No analytics consent → GDPR violation, App Store rejection
5. Debug-signed release build → Play Store rejection
6. No Supabase credentials loaded → all 49+ `Supabase.instance.client` calls fail

**Estimated effort to fix P0 items:** 1-2 days
**Estimated effort to fix P0 + P1 items:** 3-4 days
