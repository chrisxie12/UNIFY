import '../../data/models/post_model.dart';
import '../../data/models/post_comment_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> getPosts(String communityId, {String? currentUserId, bool? pinned});
  Future<PostModel> getPost(String postId, {String? currentUserId});
  Future<PostModel> createPost(PostModel post);
  Future<bool> deletePost(String postId);
  Future<bool> togglePin(String postId, bool isPinned);
  Future<bool> likePost(String postId, String userId);
  Future<bool> unlikePost(String postId, String userId);
  Future<bool> bookmarkPost(String postId, String userId);
  Future<bool> unbookmarkPost(String postId, String userId);
  Future<List<PostCommentModel>> getComments(String postId, {String? currentUserId});
  Future<PostCommentModel> createComment(PostCommentModel comment);
  Future<bool> deleteComment(String commentId);
  Future<bool> likeComment(String commentId, String userId);
  Future<bool> unlikeComment(String commentId, String userId);
}
