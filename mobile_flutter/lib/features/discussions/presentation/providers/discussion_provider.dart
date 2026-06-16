import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/discussion_repository_impl.dart';
import '../../data/models/discussion_model.dart';
import '../../data/models/discussion_repository.dart';

final discussionRepositoryProvider = Provider<DiscussionRepository>((ref) {
  return DiscussionRepositoryImpl(Supabase.instance.client);
});

final discussionsProvider = FutureProvider.family<List<DiscussionModel>, String>((ref, communityId) async {
  final repo = ref.watch(discussionRepositoryProvider);
  return repo.getDiscussions(communityId);
});

final discussionDetailProvider = FutureProvider.family<DiscussionModel, String>((ref, discussionId) async {
  final repo = ref.watch(discussionRepositoryProvider);
  return repo.getDiscussion(discussionId);
});

final discussionCommentsProvider = FutureProvider.family<List<DiscussionCommentModel>, String>((ref, discussionId) async {
  final repo = ref.watch(discussionRepositoryProvider);
  return repo.getComments(discussionId);
});
