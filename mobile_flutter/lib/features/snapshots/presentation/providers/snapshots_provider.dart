import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/snapshot_models.dart';
import '../../data/repositories/snapshots_repository_impl.dart';

final snapshotsRepositoryProvider = Provider<SnapshotsRepositoryImpl>((ref) {
  return SnapshotsRepositoryImpl(ref.watch(supabaseProvider));
});

// ── Current user's university (for scoping / scaling) ─────────

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

/// True when the current user is a verified leader (their stories are official).
final _amVerifiedLeaderProvider = FutureProvider.autoDispose<bool>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return false;
  try {
    final p = await client
        .from('profiles')
        .select('is_verified_leader')
        .eq('id', user.id)
        .maybeSingle();
    return p?['is_verified_leader'] as bool? ?? false;
  } catch (_) {
    return false;
  }
});

final amVerifiedLeaderProvider = _amVerifiedLeaderProvider;

// ── Snapshot feed (grouped stories) ──────────────────────────

final snapshotFeedProvider =
    FutureProvider.autoDispose<List<SnapshotGroup>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  final universityId = ref.watch(_myUniversityIdProvider).valueOrNull;
  return ref.read(snapshotsRepositoryProvider).getFeedGroups(
        universityId: universityId,
        userId: user.id,
      );
});

// ── Community snapshot feed ──────────────────────────────────

final communitySnapshotsProvider =
    FutureProvider.autoDispose.family<List<SnapshotGroup>, String>(
  (ref, communityId) async {
    ref.watch(authStateProvider);
    final client = ref.watch(supabaseProvider);
    final user = client.auth.currentUser;
    if (user == null) return [];
    return ref.read(snapshotsRepositoryProvider).getCommunitySnapshotGroups(
          communityId,
          userId: user.id,
        );
  },
);

// ── Trending snapshots ───────────────────────────────────────

final trendingSnapshotsProvider =
    FutureProvider.autoDispose<List<SnapshotModel>>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(snapshotsRepositoryProvider).getTrending();
});

// ── Per-snapshot analytics (leaders) ─────────────────────────

final snapshotAnalyticsProvider =
    FutureProvider.autoDispose.family<SnapshotAnalytics, String>(
  (ref, snapshotId) =>
      ref.read(snapshotsRepositoryProvider).getAnalytics(snapshotId),
);
