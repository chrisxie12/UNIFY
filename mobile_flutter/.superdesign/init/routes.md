# Routes (GoRouter Config)

**File**: `lib/core/router/app_router.dart`

## Auth Guard Logic
- `/`, `/get-started`, `/welcome`, `/auth*`, `/onboarding*` = auth pages
- If NOT logged in + not auth page → redirect to `/get-started`
- If logged in + auth page (not /onboarding) + onboarding incomplete → redirect to `/onboarding`
- If logged in + auth page (not /onboarding) + onboarding complete → redirect to `/app/feed`
- Admin paths (`/admin/*`, `/launch/*`, `/events/admin`) → check isAdmin, redirect to `/app/feed` if not

## Route Table

| Path | Widget | Layout | Notes |
|------|--------|--------|-------|
| `/` | SplashScreen | None (full screen) | 3s animated mesh gradient |
| `/welcome` | WelcomeScreen | None (full screen) | 60/40 split, first-visit only |
| `/get-started` | GetStartedScreen | None | Legacy — still referenced |
| `/auth` | AuthScreen | None | mode: signup/login via query param |
| `/onboarding` | OnboardingScreen | None | 7-step branching flow |
| `/onboarding-flow` | OnboardingFlowScreen | None | Legacy |
| `/onboarding-carousel` | OnboardingCarouselScreen | None | Legacy |
| `/admin` | MultiUniversityAdminScreen | Admin | 5-tab admin dashboard |
| `/admin/legacy` | AdminScreen | Admin | Old admin |
| `/admin/*` (12 routes) | Various | Admin | Universities, moderation, etc. |
| `/community/:id` | CommunityDetailScreen | MainShell | |
| `/post/:id` | PostDetailScreen | MainShell | |
| `/event/:id` | EventDetailScreen | MainShell | Enhanced event detail |
| `/events/*` (10 routes) | Various | MainShell | Tickets, check-in, dashboard |
| `/messaging/*` (5 routes) | Various | MainShell | Chat, search, create group |
| `/academic/*` (10 routes) | Various | MainShell | Courses, GPA, study planner |
| `/launch/*` (10 routes) | Various | Admin | Launch control, analytics |
| `/app/feed` | FeedScreen | MainShell Tab 0 | |
| `/app/communities` | CommunitiesScreen | MainShell Tab 1 | |
| `/app/messaging` | MessagingScreen | MainShell Tab 2 | |
| `/app/events` | EventsScreen | MainShell Tab 3 | |
| `/app/academic` | AcademicHubScreen | MainShell Tab 4 | |
| `/app/profile` | ProfileScreen | MainShell Tab 5 | + edit, privacy, settings |

## Key Pages for Design
1. **SplashScreen** (`/`) — Entry point, 3s animated gradient
2. **WelcomeScreen** (`/welcome`) — First impression, 60/40 split
3. **OnboardingScreen** (`/onboarding`) — 7-step branching form
4. **AuthScreen** (`/auth`) — Login/signup with Google + email
5. **FeedScreen** (`/app/feed`) — Main content feed (post-login)
6. **MainShell** — App shell with bottom pill nav
