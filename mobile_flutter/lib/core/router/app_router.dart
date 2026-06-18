import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/main_shell.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/get_started_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/onboarding_carousel_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/communities/presentation/screens/communities_screen.dart';
import '../../features/communities/presentation/screens/community_detail_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/privacy_settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/leadership/presentation/screens/community_request_screen.dart';
import '../../features/leadership/presentation/screens/class_rep_dashboard_screen.dart';
import '../../features/leadership/presentation/screens/announcement_request_screen.dart';
import '../../features/verification/presentation/screens/verification_request_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_home_screen.dart';
import '../../features/marketplace/presentation/screens/category_listings_screen.dart';
import '../../features/marketplace/presentation/screens/listing_detail_screen.dart';
import '../../features/marketplace/presentation/screens/create_listing_screen.dart';
import '../../features/marketplace/presentation/screens/saved_listings_screen.dart';
import '../../features/marketplace/presentation/screens/my_listings_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_search_screen.dart';
import '../../features/marketplace/presentation/screens/freelancers_screen.dart';
import '../../features/marketplace/presentation/screens/freelancer_detail_screen.dart';
import '../../features/marketplace/presentation/screens/freelancer_profile_screen.dart';
import '../../features/marketplace/presentation/screens/seller_profile_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_admin_screen.dart';
import '../../features/opportunities/presentation/screens/opportunities_home_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_type_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import '../../features/opportunities/presentation/screens/saved_opportunities_screen.dart';
import '../../features/opportunities/presentation/screens/application_tracker_screen.dart';
import '../../features/opportunities/presentation/screens/deadlines_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_search_screen.dart';
import '../../features/opportunities/presentation/screens/opportunities_admin_screen.dart';

// Notifies GoRouter on auth state changes AND when the user profile loads.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Ref ref) {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
    ref.listen<AsyncValue<AppUser?>>(currentAppUserProvider, (_, __) {
      notifyListeners();
    });
  }

  late final dynamic _authSub;

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _GoRouterRefreshStream(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final loc = state.matchedLocation;

      // Explicit checks — startsWith('/') would match every path
      final isAuthPage = loc == '/' ||
          loc == '/get-started' ||
          loc == '/welcome' ||
          loc.startsWith('/auth') ||
          loc.startsWith('/onboarding');

      if (!loggedIn && !isAuthPage) return '/get-started';
      if (loggedIn && isAuthPage && loc != '/onboarding') {
        final userAsync = ref.read(currentAppUserProvider);
        if (userAsync.isLoading) return null;
        final user = userAsync.valueOrNull;
        if (user != null && !user.onboardingComplete) return '/onboarding';
        return '/app/feed';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const OnboardingCarouselScreen()),
      GoRoute(path: '/get-started', builder: (_, __) => const GetStartedScreen()),
      GoRoute(
        path: '/auth',
        builder: (_, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'signup';
          return AuthScreen(mode: mode);
        },
      ),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
      GoRoute(
        path: '/community/:id',
        builder: (_, state) => CommunityDetailScreen(
          communityId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(path: '/community-request', builder: (_, __) => const CommunityRequestScreen()),
      GoRoute(path: '/verification-request', builder: (_, __) => const VerificationRequestScreen()),
      GoRoute(path: '/announcement-request', builder: (_, __) => const AnnouncementRequestScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const ClassRepDashboardScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),

      // ── Marketplace ──────────────────────────────────────────
      GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceHomeScreen()),
      GoRoute(path: '/marketplace/search', builder: (_, __) => const MarketplaceSearchScreen()),
      GoRoute(path: '/marketplace/sell', builder: (_, __) => const CreateListingScreen()),
      GoRoute(path: '/marketplace/saved', builder: (_, __) => const SavedListingsScreen()),
      GoRoute(path: '/marketplace/mine', builder: (_, __) => const MyListingsScreen()),
      GoRoute(path: '/marketplace/admin', builder: (_, __) => const MarketplaceAdminScreen()),
      GoRoute(path: '/marketplace/freelancers', builder: (_, __) => const FreelancersScreen()),
      GoRoute(
        path: '/marketplace/freelancer-profile',
        builder: (_, __) => const FreelancerProfileScreen(),
      ),
      GoRoute(
        path: '/marketplace/category/:key',
        builder: (_, state) =>
            CategoryListingsScreen(categoryKey: state.pathParameters['key']!),
      ),
      GoRoute(
        path: '/marketplace/listing/:id',
        builder: (_, state) =>
            ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/marketplace/freelancer/:id',
        builder: (_, state) =>
            FreelancerDetailScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/marketplace/seller/:id',
        builder: (_, state) =>
            SellerProfileScreen(sellerId: state.pathParameters['id']!),
      ),

      // ── Opportunities Hub ────────────────────────────────────
      GoRoute(path: '/opportunities', builder: (_, __) => const OpportunitiesHomeScreen()),
      GoRoute(path: '/opportunities/search', builder: (_, __) => const OpportunitySearchScreen()),
      GoRoute(path: '/opportunities/saved', builder: (_, __) => const SavedOpportunitiesScreen()),
      GoRoute(path: '/opportunities/tracker', builder: (_, __) => const ApplicationTrackerScreen()),
      GoRoute(path: '/opportunities/deadlines', builder: (_, __) => const DeadlinesScreen()),
      GoRoute(path: '/opportunities/admin', builder: (_, __) => const OpportunitiesAdminScreen()),
      GoRoute(
        path: '/opportunities/type/:key',
        builder: (_, state) =>
            OpportunityTypeScreen(typeKey: state.pathParameters['key']!),
      ),
      GoRoute(
        path: '/opportunities/detail/:id',
        builder: (_, state) =>
            OpportunityDetailScreen(opportunityId: state.pathParameters['id']!),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/feed', builder: (_, __) => const FeedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/communities',
              builder: (_, __) => const CommunitiesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/messaging', builder: (_, __) => const MessagingScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'privacy',
                  builder: (_, __) => const PrivacySettingsScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
