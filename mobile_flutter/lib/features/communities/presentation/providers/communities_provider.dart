import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../leadership/data/models/community_request_model.dart';
import '../../data/models/community_content_models.dart';
import '../../data/repositories/communities_repository_impl.dart';

final communitiesRepositoryProvider = Provider<CommunitiesRepositoryImpl>((ref) {
  return CommunitiesRepositoryImpl(ref.watch(supabaseProvider));
});

// ── University id for current user ──────────────────────────

final _myUniversityIdProvider = FutureProvider.autoDispose<String?>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;
  try {
    final p = await client
        .from('profiles')
        .select('university_id')
        .eq('id', user.id)
        .maybeSingle();
    return p?['university_id'] as String?;
  } catch (_) {
    return null;
  }
});

// ── Browse communities ───────────────────────────────────────

// Selected type-group filter in hub browser ('all' | 'academic' | 'clubs' | ...)
final hubFilterProvider = StateProvider<String>((ref) => 'all');

// Search query in hub browser
final hubSearchProvider = StateProvider<String>((ref) => '');

// Type groups for client-side filter
const _typeGroups = <String, List<String>>{
  'academic':    ['class', 'level', 'course', 'programme', 'department', 'faculty', 'university'],
  'clubs':       ['club'],
  'sports':      ['sports'],
  'residential': ['hostel', 'hall', 'residence'],
  'social':      ['church', 'photography', 'music'],
  'tech':        ['technology', 'entrepreneurship', 'gaming', 'campus_jobs', 'scholarships'],
};

final allCommunitiesProvider = FutureProvider.autoDispose<List<CommunityModel>>((ref) async {
  final uniIdAsync = ref.watch(_myUniversityIdProvider);
  final universityId = uniIdAsync.valueOrNull;
  final filter = ref.watch(hubFilterProvider);
  final search = ref.watch(hubSearchProvider);

  return ref.read(communitiesRepositoryProvider).getCommunities(
    universityId: universityId,
    types: filter == 'all' ? null : _typeGroups[filter],
    search: search.isEmpty ? null : search,
  );
});

// ── My memberships ───────────────────────────────────────────

final myCommunitiesProvider = FutureProvider.autoDispose<List<CommunityModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(communitiesRepositoryProvider).getMyMemberships(user.id);
});

// ── Community detail ─────────────────────────────────────────

final communityDetailProvider = FutureProvider.autoDispose.family<CommunityModel?, String>(
  (ref, id) => ref.read(communitiesRepositoryProvider).getCommunityById(id),
);

// ── User role in community (null = not a member) ─────────────

final communityRoleProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, communityId) async {
    ref.watch(authStateProvider);
    final client = ref.watch(supabaseProvider);
    final user = client.auth.currentUser;
    if (user == null) return null;
    return ref
        .read(communitiesRepositoryProvider)
        .getUserRole(communityId, user.id);
  },
);

// ── Members list ─────────────────────────────────────────────

final communityMembersProvider =
    FutureProvider.autoDispose.family<List<CommunityMemberProfile>, String>(
  (ref, communityId) =>
      ref.read(communitiesRepositoryProvider).getMembers(communityId),
);

// ── Community posts ──────────────────────────────────────────

final communityPostsProvider =
    FutureProvider.autoDispose.family<List<CommunityPostModel>, String>(
  (ref, communityId) =>
      ref.read(communitiesRepositoryProvider).getPosts(communityId),
);

// ── Community resources ──────────────────────────────────────

final communityResourcesProvider =
    FutureProvider.autoDispose.family<List<CommunityResourceModel>, String>(
  (ref, communityId) =>
      ref.read(communitiesRepositoryProvider).getResources(communityId),
);

// ── Community announcements ──────────────────────────────────

final communityAnnouncementsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, communityId) => ref
      .read(communitiesRepositoryProvider)
      .getCommunityAnnouncements(communityId),
);

// ── Join / Leave notifier ────────────────────────────────────

class CommunityMembershipNotifier
    extends AutoDisposeFamilyAsyncNotifier<String?, String> {
  @override
  Future<String?> build(String arg) async {
    final client = ref.watch(supabaseProvider);
    final user = client.auth.currentUser;
    if (user == null) return null;
    return ref.read(communitiesRepositoryProvider).getUserRole(arg, user.id);
  }

  Future<void> join() async {
    final client = ref.read(supabaseProvider);
    final user = client.auth.currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(communitiesRepositoryProvider)
          .joinCommunity(arg, user.id);
      return 'member';
    });
    ref.invalidate(communityDetailProvider(arg));
    ref.invalidate(myCommunitiesProvider);
  }

  Future<void> leave() async {
    final client = ref.read(supabaseProvider);
    final user = client.auth.currentUser;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(communitiesRepositoryProvider)
          .leaveCommunity(arg, user.id);
      return null;
    });
    ref.invalidate(communityDetailProvider(arg));
    ref.invalidate(myCommunitiesProvider);
  }
}

final communityMembershipProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityMembershipNotifier, String?, String>(
  CommunityMembershipNotifier.new,
);
