import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/main_shell.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/get_started_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/communities/presentation/screens/communities_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';

// Notifies GoRouter whenever the Supabase auth state changes
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _refreshListenable = _GoRouterRefreshStream();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _refreshListenable,
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final loc = state.matchedLocation;

      const authPages = ['/', '/get-started', '/auth', '/onboarding'];
      final isAuthPage = authPages.any((p) => loc == p || loc.startsWith(p));

      if (!loggedIn && !isAuthPage) return '/get-started';
      if (loggedIn && isAuthPage && loc != '/onboarding') {
        try {
          final user = await ref.read(currentAppUserProvider.future);
          if (user != null && !user.onboardingComplete) return '/onboarding';
        } catch (_) {}
        return '/app/feed';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/get-started', builder: (_, __) => const GetStartedScreen()),
      GoRoute(
        path: '/auth',
        builder: (_, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'signup';
          return AuthScreen(mode: mode);
        },
      ),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),

      // StatefulShellRoute preserves each tab's scroll & nav state independently
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/feed', builder: (_, __) => const FeedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/communities', builder: (_, __) => const CommunitiesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/messaging', builder: (_, __) => const MessagingScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
