import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/get-started',
      builder: (_, __) => const GetStartedScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (_, state) {
        final mode = state.uri.queryParameters['mode'] ?? 'signup';
        return AuthScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
);
