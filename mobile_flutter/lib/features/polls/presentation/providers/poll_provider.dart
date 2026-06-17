import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/poll_repository_impl.dart';
import '../../domain/repositories/poll_repository.dart';
import '../../data/models/poll_model.dart';

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return PollRepositoryImpl(ref.watch(supabaseProvider));
});

final communityPollsProvider = FutureProvider.family<List<PollModel>, String>((ref, communityId) async {
  final repo = ref.watch(pollRepositoryProvider);
  return repo.getPolls(communityId);
});
