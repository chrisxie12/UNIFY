import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import '../widgets/main_shell.dart';
import '../widgets/not_found_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../guards/admin_guard.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/communities/presentation/screens/community_detail_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/messaging/presentation/screens/message_requests_screen.dart';
import '../../features/messaging/presentation/screens/student_directory_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/messaging/presentation/screens/create_group_screen.dart';
import '../../features/messaging/presentation/screens/channel_view_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/privacy_settings_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../../features/reputation/presentation/screens/reputation_dashboard_screen.dart';
import '../../features/reputation/presentation/screens/skills_management_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/admin/presentation/screens/multi_university_admin_screen.dart';
import '../../features/admin/presentation/screens/university_management_screen.dart';
import '../../features/admin/presentation/screens/moderation_center_screen.dart';
import '../../features/admin/presentation/screens/verification_management_screen.dart';
import '../../features/admin/presentation/screens/opportunities_admin_screen.dart';
import '../../features/admin/presentation/screens/communication_center_screen.dart';
import '../../features/admin/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/admin/presentation/screens/audit_logs_screen.dart';
import '../../features/admin/presentation/screens/admin_management_screen.dart';
import '../../features/admin/presentation/screens/community_admin_screen.dart';
import '../../features/admin/presentation/screens/marketplace_admin_screen.dart';
import '../../features/admin/presentation/screens/events_admin_screen.dart';
import '../../features/admin/presentation/screens/academic_admin_screen.dart';
import '../../features/admin/presentation/screens/feature_flags_screen.dart';
import '../../features/leadership/presentation/screens/community_request_screen.dart';
import '../../features/leadership/presentation/screens/class_rep_dashboard_screen.dart';
import '../../features/leadership/presentation/screens/announcement_request_screen.dart';
import '../../features/verification/presentation/screens/verification_request_screen.dart';
import '../../features/communities/presentation/screens/community_members_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../features/posts/presentation/screens/post_detail_screen.dart';
import '../../features/polls/presentation/screens/create_poll_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/my_tickets_screen.dart';
import '../../features/events/presentation/screens/ticket_screen.dart';
import '../../features/events/presentation/screens/qr_checkin_screen.dart';
import '../../features/events/presentation/screens/organizer_dashboard_screen.dart';
import '../../features/events/presentation/screens/admin_event_dashboard_screen.dart';
import '../../features/events/presentation/screens/event_discussion_screen.dart';
import '../../features/events/presentation/screens/event_media_gallery_screen.dart';
import '../../features/events/presentation/screens/student_event_profile_screen.dart';
import '../../features/events/presentation/screens/event_search_screen.dart';
import '../../features/resources/presentation/screens/resource_upload_screen.dart';
import '../../features/admin/presentation/screens/admin_notification_center_screen.dart';
import '../../features/academic/presentation/screens/course_list_screen.dart';
import '../../features/academic/presentation/screens/course_page_screen.dart';
import '../../features/academic/presentation/screens/notes_repository_screen.dart';
import '../../features/academic/presentation/screens/assignment_hub_screen.dart';
import '../../features/academic/presentation/screens/exam_prep_center_screen.dart';
import '../../features/academic/presentation/screens/gpa_calculator_screen.dart';
import '../../features/academic/presentation/screens/study_planner_screen.dart';
import '../../features/academic/presentation/screens/academic_search_screen.dart';
// ── Launch infrastructure (Step 13) ──────────────────────────
import '../../features/admin/presentation/screens/launch_control_screen.dart';
import '../../features/growth/presentation/screens/beta_admin_screen.dart';
import '../../features/growth/presentation/screens/referral_admin_screen.dart';
import '../../features/growth/presentation/screens/my_referrals_screen.dart';
import '../../features/feedback/presentation/screens/feedback_screen.dart';
import '../../features/feedback/presentation/screens/feedback_admin_screen.dart';
import '../../features/support/presentation/screens/support_center_screen.dart';
import '../../features/support/presentation/screens/help_article_screen.dart';
import '../../features/support/presentation/screens/support_admin_screen.dart';
import '../../features/system/presentation/screens/announcements_admin_screen.dart';
import '../../features/system/presentation/screens/app_version_admin_screen.dart';
import '../../features/ops/presentation/screens/usage_analytics_screen.dart';
import '../../features/ops/presentation/screens/feature_adoption_screen.dart';
import '../../features/ops/presentation/screens/system_health_screen.dart';
import '../../features/ops/presentation/screens/launch_readiness_screen.dart';
import '../../features/ambassadors/presentation/screens/ambassador_admin_screen.dart';
import '../../features/ambassadors/presentation/screens/ambassador_detail_screen.dart';
import '../../features/ambassadors/presentation/screens/ambassador_profile_screen.dart';
import '../../features/snapshots/presentation/screens/story_viewer_screen.dart';
import '../../features/snapshots/presentation/screens/story_create_screen.dart';
import '../../features/snapshots/data/models/snapshot_models.dart';
import '../../features/settings/presentation/screens/beta_info_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/terms_of_service_screen.dart';

// ── Admin path detection ──────────────────────────────────────────────────────
//
// Returns true for every route that must be restricted to admin users.

bool _isAdminPath(String loc) =>
    loc == '/admin' ||
    loc.startsWith('/admin/') ||
    loc == '/launch' ||
    loc.startsWith('/launch/') ||
    loc == '/events/admin';

// ── GoRouter refresh stream ───────────────────────────────────────────────────

// Notifies GoRouter on auth state changes AND when the user profile loads.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Ref ref) {
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        notifyListeners();
      });
    } catch (_) {
      _authSub = null;
    }
    ref.listen<AsyncValue<AppUser?>>(currentAppUserProvider, (_, __) {
      notifyListeners();
    });
  }

  dynamic _authSub;

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _GoRouterRefreshStream(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    errorBuilder: (context, state) => NotFoundScreen(
      message: state.error?.toString(),
    ),
    redirect: (context, state) {
      bool loggedIn = false;
      try {
        loggedIn = Supabase.instance.client.auth.currentSession != null;
      } catch (_) {
        // Supabase not initialized — treat as logged-out.
      }
      final loc = state.matchedLocation;

      // ── Auth guard ──────────────────────────────────────────────────────
      final isAuthPage = loc == '/' ||
          loc == '/get-started' ||
          loc == '/welcome' ||
          loc.startsWith('/auth');
          // Onboarding now requires a session for Edge Function calls.

      if (!loggedIn && !isAuthPage) return '/get-started';
      if (loggedIn && isAuthPage && loc != '/onboarding') {
        final userAsync = ref.read(currentAppUserProvider);
        if (userAsync.isLoading) return null;
        final user = userAsync.valueOrNull;
        if (user != null && !user.onboardingComplete) return '/onboarding';
        return '/app/feed';
      }

      // ── Admin route guard ───────────────────────────────────────────────
      // Protect every /admin/* and /launch/* path. Non-admin users are
      // sent to /app/feed and a snackbar is queued via the provider.
      if (loggedIn && _isAdminPath(loc)) {
        final userAsync = ref.read(currentAppUserProvider);
        if (userAsync.isLoading) return null; // defer until profile loads
        final user = userAsync.valueOrNull;
        if (user == null || !user.isAdmin) {
          ref.read(adminAccessDeniedProvider.notifier).state = true;
          return '/app/feed';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/get-started', builder: (_, __) => const AuthScreen(mode: 'signup')),
      GoRoute(
        path: '/auth',
        builder: (_, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'signup';
          return AuthScreen(mode: mode);
        },
      ),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const MultiUniversityAdminScreen()),
      GoRoute(path: '/admin/legacy', builder: (_, __) => const AdminScreen()),
      GoRoute(path: '/admin/analytics', builder: (_, __) => const AnalyticsDashboardScreen()),
      GoRoute(path: '/admin/notifications', builder: (_, __) => const AdminNotificationCenterScreen()),
      GoRoute(path: '/admin/universities', builder: (_, __) => const UniversityManagementScreen()),
      GoRoute(path: '/admin/moderation', builder: (_, __) => const ModerationCenterScreen()),
      GoRoute(path: '/admin/verification', builder: (_, __) => const VerificationManagementScreen()),
      GoRoute(path: '/admin/opportunities', builder: (_, __) => const OpportunitiesAdminScreen()),
      GoRoute(path: '/admin/communication', builder: (_, __) => const CommunicationCenterScreen()),
      GoRoute(path: '/admin/audit-logs', builder: (_, __) => const AuditLogsScreen()),
      GoRoute(path: '/admin/admins', builder: (_, __) => const AdminManagementScreen()),
      GoRoute(path: '/admin/communities', builder: (_, __) => const CommunityAdminScreen()),
      GoRoute(path: '/admin/marketplace', builder: (_, __) => const MarketplaceAdminScreen()),
      GoRoute(path: '/admin/events', builder: (_, __) => const EventsAdminScreen()),
      GoRoute(path: '/admin/academic', builder: (_, __) => const AcademicAdminScreen()),
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
      GoRoute(path: '/stories/create', builder: (_, __) => const StoryCreateScreen()),
      GoRoute(
        path: '/stories/view',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final groups = extra['groups'] as List<SnapshotGroup>? ?? [];
          final index = extra['index'] as int? ?? 0;
          return StoryViewerScreen(groups: groups, initialGroupIndex: index);
        },
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/notifications/preferences', builder: (_, __) => const NotificationPreferencesScreen()),
      GoRoute(
        path: '/post/:id',
        builder: (_, state) => PostDetailScreen(postId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (_, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/events/create', builder: (_, __) => const CreateEventScreen()),
      GoRoute(
        path: '/events/:id/edit',
        builder: (_, state) => CreateEventScreen(communityId: state.pathParameters['id']),
      ),
      GoRoute(path: '/events/my-tickets', builder: (_, __) => const MyTicketsScreen()),
      GoRoute(path: '/events/search', builder: (_, __) => const EventSearchScreen()),
      GoRoute(
        path: '/events/ticket/:id',
        builder: (_, state) => TicketScreen(ticketId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/checkin',
        builder: (_, state) => QRCheckInScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/dashboard',
        builder: (_, state) => OrganizerDashboardScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/discussions',
        builder: (_, state) => EventDiscussionScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/media',
        builder: (_, state) => EventMediaGalleryScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/events/activity', builder: (_, __) => const StudentEventProfileScreen()),
      GoRoute(
        path: '/events/admin',
        builder: (_, __) => const AdminEventDashboardScreen(),
      ),
      GoRoute(
        path: '/community/:id/create-post',
        builder: (_, state) => CreatePostScreen(communityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/community/:id/create-poll',
        builder: (_, state) => CreatePollScreen(communityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/community/:id/upload-resource',
        builder: (_, state) => ResourceUploadScreen(communityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/community/:id/members',
        builder: (_, state) => CommunityMembersScreen(communityId: state.pathParameters['id']!),
      ),

      GoRoute(path: '/messaging/requests', builder: (_, __) => const MessageRequestsScreen()),
      GoRoute(path: '/messaging/search', builder: (_, __) => const StudentDirectoryScreen()),
      GoRoute(
        path: '/messaging/chat/:id',
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(path: '/messaging/create-group', builder: (_, __) => const CreateGroupScreen()),
      GoRoute(
        path: '/messaging/channel-view/:id',
        builder: (_, state) => ChannelViewScreen(conversationId: state.pathParameters['id']!),
      ),

      GoRoute(path: '/academic/courses', builder: (_, __) => const CourseListScreen()),
      GoRoute(
        path: '/academic/course/:id',
        builder: (_, state) => CoursePageScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/academic/course/:id/notes',
        builder: (_, state) => NotesRepositoryScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/academic/assignments', builder: (_, __) => const AssignmentHubScreen()),
      GoRoute(path: '/academic/exam-prep', builder: (_, __) => const ExamPrepCenterScreen()),
      GoRoute(path: '/academic/exams', builder: (_, __) => const ExamPrepCenterScreen()),
      GoRoute(path: '/academic/gpa', builder: (_, __) => const GPACalculatorScreen()),
      GoRoute(path: '/academic/study-planner', builder: (_, __) => const StudyPlannerScreen()),
      GoRoute(path: '/academic/planner', builder: (_, __) => const StudyPlannerScreen()),
      GoRoute(
        path: '/academic/resources',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NotesRepositoryScreen(filterType: extra?['type'] as String?);
        },
      ),
      GoRoute(path: '/academic/search', builder: (_, __) => const AcademicSearchScreen()),

      GoRoute(path: '/reputation', builder: (_, __) => const ReputationDashboardScreen()),
      GoRoute(
        path: '/reputation/skills',
        builder: (_, __) => const SkillsManagementScreen(),
      ),

      // ── Launch Control (admin ops) ───────────────────────────
      GoRoute(path: '/launch', builder: (_, __) => const LaunchControlScreen()),
      GoRoute(path: '/launch/readiness', builder: (_, __) => const LaunchReadinessScreen()),
      GoRoute(path: '/launch/analytics', builder: (_, __) => const UsageAnalyticsScreen()),
      GoRoute(path: '/launch/adoption', builder: (_, __) => const FeatureAdoptionScreen()),
      GoRoute(path: '/launch/health', builder: (_, __) => const SystemHealthScreen()),
      GoRoute(path: '/launch/beta', builder: (_, __) => const BetaAdminScreen()),
      GoRoute(path: '/launch/referrals', builder: (_, __) => const ReferralAdminScreen()),
      GoRoute(path: '/launch/ambassadors', builder: (_, __) => const AmbassadorAdminScreen()),
      GoRoute(path: '/launch/announcements', builder: (_, __) => const AnnouncementsAdminScreen()),
      GoRoute(path: '/launch/feedback', builder: (_, __) => const FeedbackAdminScreen()),
      GoRoute(path: '/launch/support', builder: (_, __) => const SupportAdminScreen()),
      GoRoute(path: '/launch/app-versions', builder: (_, __) => const AppVersionAdminScreen()),
      GoRoute(path: '/launch/feature-flags', builder: (_, __) => const FeatureFlagsScreen()),
      GoRoute(
        path: '/launch/ambassador/:id',
        builder: (_, state) =>
            AmbassadorDetailScreen(ambassadorId: state.pathParameters['id']!),
      ),

      // ── Launch — student facing ──────────────────────────────
      GoRoute(path: '/referrals', builder: (_, __) => const MyReferralsScreen()),
      GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
      GoRoute(path: '/beta-info', builder: (_, __) => const BetaInfoScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsOfServiceScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportCenterScreen()),
      GoRoute(path: '/ambassador', builder: (_, __) => const AmbassadorProfileScreen()),
      GoRoute(
        path: '/support/article/:id',
        builder: (_, state) =>
            HelpArticleScreen(articleId: state.pathParameters['id']!),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/feed', builder: (_, __) => const FeedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/explore',
              builder: (_, __) => const ExploreScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/messaging', builder: (_, __) => const MessagingScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/profile',
              builder: (_, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return ProfileScreen(viewUserId: extra?['viewUserId'] as String?);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'privacy',
                  builder: (_, __) => const PrivacySettingsScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (_, __) => const SettingsScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
