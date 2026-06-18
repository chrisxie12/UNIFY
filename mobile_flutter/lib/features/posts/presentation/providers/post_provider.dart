import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/models/post_model.dart';
import '../../data/models/post_comment_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.watch(supabaseProvider));
});

final communityPostsProvider = FutureProvider.family<List<PostModel>, String>((ref, communityId) async {
  final repo = ref.watch(postRepositoryProvider);
  final userId = ref.read(supabaseProvider).auth.currentUser?.id;
  return repo.getPosts(communityId, currentUserId: userId);
});

final postDetailProvider = FutureProvider.family<PostModel, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  final userId = ref.read(supabaseProvider).auth.currentUser?.id;
  return repo.getPost(postId, currentUserId: userId);
});

final postCommentsProvider = FutureProvider.family<List<PostCommentModel>, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  final userId = ref.read(supabaseProvider).auth.currentUser?.id;
  return repo.getComments(postId, currentUserId: userId);
});
