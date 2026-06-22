# Layout Components

## MainShell (App Shell with Bottom Nav)
- **File**: `lib/core/widgets/main_shell.dart`
- **Description**: Root shell after login. Contains StatefulNavigationShell + floating pill bottom nav bar with 6 tabs: Feed, Hubs, Messages, Events, Study, Profile

```dart
// 6-tab pill navigation
static const _tabs = [
  _TabItem(icon: CupertinoIcons.house,           label: 'Feed'),
  _TabItem(icon: CupertinoIcons.square_grid_2x2, label: 'Hubs'),
  _TabItem(icon: CupertinoIcons.chat_bubble,     label: 'Messages'),
  _TabItem(icon: CupertinoIcons.calendar,        label: 'Events'),
  _TabItem(icon: CupertinoIcons.book,            label: 'Study'),
  _TabItem(icon: CupertinoIcons.person,          label: 'Profile'),
];

// Layout:
// Scaffold(extendBody: true)
//   body: OfflineBanner(child: navigationShell)  ← main page content
//   bottomNavigationBar: _UnifyBottomNav (floating pill)
//     - Pill: 50px height, 24px horizontal padding, 16px top gap, 8px bottom gap
//     - bg: surfaceCard with 0.95-0.97 opacity, rounded 28px, 0.5px border
//     - Each tab: icon 22px, label 10px, animated color transition
//     - Badge count (notifications/messages) shown as red dot with count
```

### Auth Pages Layout (before login)
- **SplashScreen**: Full-screen mesh gradient, logo + text centered
- **WelcomeScreen**: 60/40 split — top 60% purple gradient with floating circles + logo, bottom 40% white rounded card with "Get Started" + "I already have an account"
- **OnboardingScreen**: Full white screen, top bar (back + progress + logo), page view for steps, bottom bar (continue/back buttons)
- **AuthScreen**: Full white screen, logo at top, form fields + buttons, toggle between sign up / sign in
