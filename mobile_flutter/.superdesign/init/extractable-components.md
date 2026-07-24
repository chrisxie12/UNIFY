# Extractable Components

## Layout Components

### BottomNav (appears on all post-login pages)
- **Source**: `lib/core/widgets/main_shell.dart` (class `_UnifyBottomNav`)
- **Category**: layout
- **Description**: Floating pill-style bottom navigation bar with 6 tabs (Feed, Hubs, Messages, Events, Study, Profile). 50px height, 28px border-radius, semi-transparent card background
- **Extractable props**:
  - activeIndex (number, default: 0) — which tab is selected
  - badges (number[], default: [0,0,0,0,0,0]) — badge counts per tab
- **Hardcoded**: All tab icons (CupertinoIcons), labels, animation values, pill dimensions

### MainShell (appears on all post-login pages)
- **Source**: `lib/core/widgets/main_shell.dart` (class `MainShell`)
- **Category**: layout
- **Description**: Root scaffold with OfflineBanner wrapping StatefulNavigationShell + floating pill bottom nav
- **Extractable props**: (none — pure wrapping layout)

## Basic Components (extractable)

### Logo (appears on splash, welcome, onboarding, auth)
- **Source**: `lib/core/widgets/unify_logo.dart`
- **Category**: basic
- **Description**: Two white person icons forming "U" in a blue circle
- **Extractable props**: size (number, default: 80), backgroundColor (string, default: #2563EB)
- **Hardcoded**: Icons.person, circle shape, offset values

### PrimaryButton (appears on welcome, onboarding, auth, and many others)
- **Source**: `lib/core/widgets/unify_primary_button.dart`
- **Category**: basic
- **Description**: Full-width solid button with press animation
- **Extractable props**: label (string), disabled (boolean, default: false), loading (boolean, default: false)
- **Hardcoded**: Height (52), border-radius (16), animation curves, font styles

### SecondaryButton (appears on onboarding, auth)
- **Source**: `lib/core/widgets/unify_secondary_button.dart`
- **Category**: basic
- **Description**: Full-width outlined button with press animation
- **Extractable props**: label (string), disabled (boolean, default: false)
- **Hardcoded**: Height (52), border-radius (16), 1.5px border, transparent bg

### InputField (appears on onboarding, auth)
- **Source**: `lib/core/widgets/unify_input_field.dart`
- **Category**: basic
- **Description**: Text input with filled grey background, SpaceGrotesk font
- **Extractable props**: label (string), hint (string, default: ""), type (string, default: "text")
- **Hardcoded**: Border radius (12), fill color (#F1F5F9), padding, focused border (2px #2563EB)

### SelectionCard (appears on onboarding goals)
- **Source**: `lib/core/widgets/unify_selection_card.dart`
- **Category**: basic
- **Description**: Selectable card with icon, title, subtitle, checkmark animation
- **Extractable props**: title (string), subtitle (string?), selected (boolean, default: false)
- **Hardcoded**: Layout (icon 48px, row with padding), border radius (12), checkmark circle (28px)
