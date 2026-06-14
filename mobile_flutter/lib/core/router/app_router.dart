import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/supabase_provider.dart';
import '../widgets/main_shell.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/get_started_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/communities/presentation/screens/communities_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthed = session != null;
      final loc = state.uri.path;

      final publicRoutes = ['/', '/get-started', '/auth'];
      final isPublic = publicRoutes.any((r) => loc == r || loc.startsWith('$r?'));

      if (!isAuthed && !isPublic) return '/get-started';
      if (isAuthed && isPublic) return '/app/feed';
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
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/app/feed',
            pageBuilder: (_, __) => const NoTransitionPage(child: FeedScreen()),
          ),
          GoRoute(
            path: '/app/communities',
            pageBuilder: (_, __) => const NoTransitionPage(child: CommunitiesScreen()),
          ),
          GoRoute(
            path: '/app/messaging',
            pageBuilder: (_, __) => const NoTransitionPage(child: MessagingScreen()),
          ),
          GoRoute(
            path: '/app/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
