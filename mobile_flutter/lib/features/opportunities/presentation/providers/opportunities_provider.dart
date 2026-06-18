import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/opportunity_models.dart';
import '../../data/repositories/opportunities_repository_impl.dart';

final opportunitiesRepositoryProvider =
    Provider<OpportunitiesRepositoryImpl>((ref) {
  return OpportunitiesRepositoryImpl(ref.watch(supabaseProvider));
});

// ── Current student profile bits (scoping + recommendations) ─

class _StudentContext {
  final String? universityId;
  final String? programme;
  final String? level;
  const _StudentContext({this.universityId, this.programme, this.level});
}

final _studentContextProvider =
    FutureProvider.autoDispose<_StudentContext>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return const _StudentContext();
  try {
    final p = await client
        .from('profiles')
        .select('university_id, programme, level')
        .eq('id', user.id)
        .maybeSingle();
    return _StudentContext(
      universityId: p?['university_id'] as String?,
      programme: p?['programme'] as String?,
      level: p?['level'] as String?,
    );
  } catch (_) {
    return const _StudentContext();
  }
});

// ── Browse filter ────────────────────────────────────────────

final opportunityFilterProvider =
    StateProvider.autoDispose<OpportunityFilter>(
        (ref) => const OpportunityFilter());

// ── Feed / browse results ────────────────────────────────────

final opportunitiesProvider =
    FutureProvider.autoDispose<List<OpportunityModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  final filter = ref.watch(opportunityFilterProvider);
  final ctx = ref.watch(_studentContextProvider).valueOrNull;
  return ref.read(opportunitiesRepositoryProvider).getOpportunities(
        filter: filter,
        universityId: ctx?.universityId,
        userId: user?.id,
      );
});

// ── Featured ─────────────────────────────────────────────────

final featuredOpportunitiesProvider =
    FutureProvider.autoDispose<List<OpportunityModel>>((ref) async {
  final ctx = ref.watch(_studentContextProvider).valueOrNull;
  return ref
      .read(opportunitiesRepositoryProvider)
      .getFeatured(universityId: ctx?.universityId);
});

// ── Personalised recommendations ─────────────────────────────

final recommendedOpportunitiesProvider =
    FutureProvider.autoDispose<List<OpportunityModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  final ctx = ref.watch(_studentContextProvider).valueOrNull;
  return ref.read(opportunitiesRepositoryProvider).getRecommendations(
        userId: user.id,
        programme: ctx?.programme,
        level: ctx?.level,
        universityId: ctx?.universityId,
      );
});

// ── Detail ───────────────────────────────────────────────────

final opportunityDetailProvider =
    FutureProvider.autoDispose.family<OpportunityModel?, String>((ref, id) {
  ref.watch(authStateProvider);
  final user = ref.watch(supabaseProvider).auth.currentUser;
  return ref
      .read(opportunitiesRepositoryProvider)
      .getOpportunity(id, userId: user?.id);
});

// ── Saved ────────────────────────────────────────────────────

final savedOpportunitiesProvider =
    FutureProvider.autoDispose<List<OpportunityModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(opportunitiesRepositoryProvider).getSaved(user.id);
});

// ── Application tracker ───────────────────────────────────────

final applicationsProvider =
    FutureProvider.autoDispose<List<TrackedApplication>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(opportunitiesRepositoryProvider).getApplications(user.id);
});

// ── Upcoming deadlines (reminder list) ───────────────────────

final upcomingDeadlinesProvider =
    FutureProvider.autoDispose<List<OpportunityModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref
      .read(opportunitiesRepositoryProvider)
      .getUpcomingDeadlines(user.id);
});

// ── Reminder state for a single opportunity ──────────────────

final reminderStateProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, opportunityId) async {
  final user = ref.watch(supabaseProvider).auth.currentUser;
  if (user == null) return false;
  return ref
      .read(opportunitiesRepositoryProvider)
      .hasReminder(user.id, opportunityId);
});

// ── Admin: reports + analytics ───────────────────────────────

final opportunityReportQueueProvider =
    FutureProvider.autoDispose<List<OpportunityReportItem>>((ref) {
  ref.watch(authStateProvider);
  return ref.read(opportunitiesRepositoryProvider).getReportQueue();
});

final opportunityStatsProvider =
    FutureProvider.autoDispose<OpportunityStats>((ref) {
  ref.watch(authStateProvider);
  return ref.read(opportunitiesRepositoryProvider).getStats();
});

// ── Save toggle controller ───────────────────────────────────

class OpportunitySaveController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<bool> toggle(String opportunityId) async {
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return false;
    final saved = await ref
        .read(opportunitiesRepositoryProvider)
        .toggleSave(opportunityId, user.id);
    ref.invalidate(savedOpportunitiesProvider);
    ref.invalidate(opportunityDetailProvider(opportunityId));
    return saved;
  }
}

final opportunitySaveControllerProvider =
    NotifierProvider.autoDispose<OpportunitySaveController, void>(
  OpportunitySaveController.new,
);
