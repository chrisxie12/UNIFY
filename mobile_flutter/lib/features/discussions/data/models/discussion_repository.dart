import 'discussion_model.dart';

abstract class DiscussionRepository {
  Future<List<DiscussionModel>> getDiscussions(String communityId, {String? currentUserId, String? sortBy});
  Future<DiscussionModel> getDiscussion(String discussionId, {String? currentUserId});
  Future<DiscussionModel> createDiscussion(DiscussionModel discussion);
  Future<List<DiscussionCommentModel>> getComments(String discussionId, {String? currentUserId});
  Future<DiscussionCommentModel> createComment(DiscussionCommentModel comment);
  Future<bool> likeDiscussion(String discussionId, String userId);
  Future<bool> unlikeDiscussion(String discussionId, String userId);
  Future<bool> likeComment(String commentId, String userId);
  Future<bool> unlikeComment(String commentId, String userId);
  Future<bool> pinDiscussion(String discussionId, bool isPinned);
  Future<bool> lockDiscussion(String discussionId, bool isLocked);
  Future<bool> deleteDiscussion(String discussionId);
  Future<bool> deleteComment(String commentId);
  Future<bool> incrementViewCount(String discussionId);
}
