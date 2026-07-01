# Page Component Dependency Trees

## / (SplashScreen)
**File**: `lib/features/splash/splash_screen.dart`
**Layout**: None (full screen)

Dependencies:
- `lib/core/design/design_tokens.dart` (UnifyColors, UnifyAnim)
- `lib/core/widgets/unify_logo.dart` (UnifyLogo)
- `package:google_fonts/google_fonts.dart`
- `package:go_router/go_router.dart`
- `package:shared_preferences/shared_preferences.dart`
- `package:supabase_flutter/supabase_flutter.dart`

---

## /welcome (WelcomeScreen)
**File**: `lib/features/welcome/welcome_screen.dart`
**Layout**: None (full screen)

Dependencies:
- `lib/core/design/design_tokens.dart` (UnifyColors, UnifySpacing, UnifyRadius, UnifyShadows, UnifyTextStyle, UnifyAnim)
- `lib/core/widgets/unify_logo.dart` (UnifyLogo)
- `lib/core/widgets/unify_primary_button.dart` (UnifyPrimaryButton)
- `package:google_fonts/google_fonts.dart`
- `package:go_router/go_router.dart`
- `package:shared_preferences/shared_preferences.dart`

---

## /onboarding (OnboardingScreen)
**File**: `lib/features/onboarding/onboarding_screen.dart`
**Layout**: None (full screen)

Dependencies:
- `lib/core/design/design_tokens.dart`
- `lib/core/widgets/unify_logo.dart`
- `lib/core/widgets/unify_primary_button.dart`
- `lib/core/widgets/unify_secondary_button.dart`
- `lib/features/onboarding/steps/step_identity.dart` (StepIdentity)
  - `lib/core/design/design_tokens.dart`
  - `lib/features/onboarding/onboarding_screen.dart` (OnboardingData, UserIdentity)
- `lib/features/onboarding/steps/step_shs_personal_info.dart` (StepShsPersonalInfo)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_input_field.dart` (UnifyInputField)
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_shs_education.dart` (StepShsEducation)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_input_field.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_shs_university_interest.dart` (StepShsUniversityInterest)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_input_field.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_shs_goals.dart` (StepShsGoals)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_selection_card.dart` (UnifySelectionCard)
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_uni_selection.dart` (StepUniSelection)
  - `lib/core/design/design_tokens.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_uni_email_verify.dart` (StepUniEmailVerify)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_input_field.dart`
  - `lib/core/widgets/unify_primary_button.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_uni_academic_details.dart` (StepUniAcademicDetails)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_input_field.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_interests.dart` (StepInterests)
  - `lib/core/design/design_tokens.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/onboarding/steps/step_preview.dart` (StepPreview)
  - `lib/core/design/design_tokens.dart`
  - `lib/core/widgets/unify_logo.dart`
  - `lib/features/onboarding/onboarding_screen.dart`
- `package:flutter_riverpod/flutter_riverpod.dart`
- `package:go_router/go_router.dart`
- `package:shared_preferences/shared_preferences.dart`
- `package:supabase_flutter/supabase_flutter.dart`

---

## /auth (AuthScreen / UnifyAuthScreen)
**File**: `lib/features/auth/presentation/screens/unify_auth_screen.dart`
**Layout**: None (full screen)

Dependencies:
- `lib/core/design/design_tokens.dart`
- `lib/core/widgets/unify_logo.dart`
- `lib/core/widgets/unify_primary_button.dart`
- `lib/core/widgets/unify_secondary_button.dart`
- `lib/core/widgets/unify_input_field.dart`
- `lib/core/errors/error_mapper.dart`
- `lib/core/widgets/unify_snackbar.dart`
- `lib/features/auth/presentation/providers/survey_state_provider.dart`
- `package:flutter_riverpod/flutter_riverpod.dart`
- `package:go_router/go_router.dart`
- `package:supabase_flutter/supabase_flutter.dart`

---

## /app/feed (FeedScreen) — main screen after login
**File**: `lib/features/feed/presentation/screens/feed_screen.dart`
**Layout**: MainShell (pill bottom nav)

Dependencies (top-level only):
- `lib/core/widgets/main_shell.dart` (MainShell + _UnifyBottomNav)
  - `lib/core/extensions/theme_extensions.dart`
  - `lib/core/guards/admin_guard.dart`
  - `lib/core/widgets/offline_banner.dart`
  - Various notification/messaging providers
- Full app shell: Scaffold(extendBody) + OfflineBanner + floating pill with 6 tabs
