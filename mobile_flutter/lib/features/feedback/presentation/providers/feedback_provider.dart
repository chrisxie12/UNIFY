import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/feedback_models.dart';
import '../../data/repositories/feedback_repository_impl.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepositoryImpl>((ref) {
  return FeedbackRepositoryImpl(ref.watch(supabaseProvider));
});

/// Current user's own submissions.
final myFeedbackProvider =
    FutureProvider.autoDispose<List<FeedbackItem>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.read(feedbackRepositoryProvider).getMine(user.id);
});

/// Admin queue filtered by status (one of FeedbackStatus.*).
final feedbackQueueProvider =
    FutureProvider.autoDispose.family<List<FeedbackItem>, String>(
        (ref, status) async {
  return ref.read(feedbackRepositoryProvider).getAll(status: status);
});

/// Counts per status for the admin stat header.
final feedbackCountsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  return ref.read(feedbackRepositoryProvider).countsByStatus();
});
