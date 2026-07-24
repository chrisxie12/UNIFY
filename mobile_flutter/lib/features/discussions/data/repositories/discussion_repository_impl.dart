import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discussion_model.dart';
import '../models/discussion_repository.dart';

class DiscussionRepositoryImpl implements DiscussionRepository {
  final SupabaseClient _client;

  DiscussionRepositoryImpl(this._client);

  @override
  Future<List<DiscussionModel>> getDiscussions(String communityId, {String? currentUserId, String? sortBy}) async {
    final response = await _client
        .from('discussions')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .eq('community_id', communityId)
        .order('is_pinned', ascending: false)
        .order(sortBy == 'popular' ? 'likes_count' : 'created_at', ascending: false)
        .limit(50)
        as List;

    final discussions = response.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['author_name'] = profile['display_name'];
        json['author_avatar'] = profile['avatar_url'];
        json['author_is_verified_leader'] = profile['is_verified_leader'];
        json['author_leadership_role'] = profile['leadership_role'];
      }
      return DiscussionModel.fromJson(json);
    }).toList();

    if (currentUserId != null && discussions.isNotEmpty) {
      final likesResponse = await _client
          .from('discussion_likes')
          .select('discussion_id')
          .filter('user_id', 'eq', currentUserId)
          .limit(1000) as List;
      final likedIds = likesResponse
          .cast<Map<String, dynamic>>()
          .map((l) => l['discussion_id'] as String)
          .toSet();
      for (var i = 0; i < discussions.length; i++) {
        discussions[i] = discussions[i].copyWith(isLikedByMe: likedIds.contains(discussions[i].id));
      }
    }

    return discussions;
  }

  @override
  Future<DiscussionModel> getDiscussion(String discussionId, {String? currentUserId}) async {
    final response = await _client
        .from('discussions')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('id', 'eq', discussionId)
        .single();

    final profile = response['profiles'] as Map<String, dynamic>?;
    if (profile != null) {
      response['author_name'] = profile['display_name'];
      response['author_avatar'] = profile['avatar_url'];
      response['author_is_verified_leader'] = profile['is_verified_leader'];
      response['author_leadership_role'] = profile['leadership_role'];
    }

    final discussion = DiscussionModel.fromJson(response);

    if (currentUserId != null) {
      final likes = await _client
          .from('discussion_likes')
          .select('id')
          .filter('discussion_id', 'eq', discussionId)
          .filter('user_id', 'eq', currentUserId) as List;
      return discussion.copyWith(isLikedByMe: likes.isNotEmpty);
    }

    return discussion;
  }

  @override
  Future<DiscussionModel> createDiscussion(DiscussionModel discussion) async {
    final response = await _client
        .from('discussions')
        .insert(discussion.toInsertJson())
        .select()
        .single();
    return DiscussionModel.fromJson(response);
  }

  @override
  Future<List<DiscussionCommentModel>> getComments(String discussionId, {String? currentUserId}) async {
    final response = await _client
        .from('discussion_comments')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .eq('discussion_id', discussionId)
        .order('created_at', ascending: true)
        .limit(100)
        as List;

    final allComments = response.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['author_name'] = profile['display_name'];
        json['author_avatar'] = profile['avatar_url'];
        json['author_is_verified_leader'] = profile['is_verified_leader'];
        json['author_leadership_role'] = profile['leadership_role'];
      }
      return DiscussionCommentModel.fromJson(json);
    }).toList();

    final topLevel = allComments.where((c) => c.parentId == null).toList();
    final replyMap = <String, List<DiscussionCommentModel>>{};
    for (final reply in allComments.where((c) => c.parentId != null)) {
      replyMap.putIfAbsent(reply.parentId!, () => []).add(reply);
    }

    for (var i = 0; i < topLevel.length; i++) {
      topLevel[i] = DiscussionCommentModel(
        id: topLevel[i].id, discussionId: topLevel[i].discussionId,
        parentId: topLevel[i].parentId, authorId: topLevel[i].authorId,
        authorName: topLevel[i].authorName, authorAvatar: topLevel[i].authorAvatar,
        authorIsVerifiedLeader: topLevel[i].authorIsVerifiedLeader,
        authorLeadershipRole: topLevel[i].authorLeadershipRole,
        body: topLevel[i].body, likesCount: topLevel[i].likesCount,
        isLikedByMe: topLevel[i].isLikedByMe,
        replies: replyMap[topLevel[i].id],
        createdAt: topLevel[i].createdAt,
      );
    }

    if (currentUserId != null) {
      final likeResponse = await _client
          .from('discussion_comment_likes')
          .select('comment_id')
          .filter('user_id', 'eq', currentUserId)
          .limit(1000) as List;
      final likedIds = likeResponse.cast<Map<String, dynamic>>().map((l) => l['comment_id'] as String).toSet();

      void applyLikes(List<DiscussionCommentModel> comments) {
        for (var i = 0; i < comments.length; i++) {
          final c = comments[i];
          comments[i] = DiscussionCommentModel(
            id: c.id, discussionId: c.discussionId, parentId: c.parentId,
            authorId: c.authorId, authorName: c.authorName, authorAvatar: c.authorAvatar,
            authorIsVerifiedLeader: c.authorIsVerifiedLeader, authorLeadershipRole: c.authorLeadershipRole,
            body: c.body, likesCount: c.likesCount, isLikedByMe: likedIds.contains(c.id),
            replies: c.replies, createdAt: c.createdAt,
          );
          if (c.replies != null) applyLikes(c.replies!);
        }
      }
      applyLikes(topLevel);
    }

    return topLevel;
  }

  @override
  Future<DiscussionCommentModel> createComment(DiscussionCommentModel comment) async {
    final response = await _client
        .from('discussion_comments')
        .insert(comment.toInsertJson())
        .select()
        .single();
    return DiscussionCommentModel.fromJson(response);
  }

  @override
  Future<bool> likeDiscussion(String discussionId, String userId) async {
    try {
      await _client.from('discussion_likes').insert({
        'discussion_id': discussionId,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unlikeDiscussion(String discussionId, String userId) async {
    try {
      await _client.from('discussion_likes').delete().filter('discussion_id', 'eq', discussionId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> likeComment(String commentId, String userId) async {
    try {
      await _client.from('discussion_comment_likes').insert({
        'comment_id': commentId,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unlikeComment(String commentId, String userId) async {
    try {
      await _client.from('discussion_comment_likes').delete().filter('comment_id', 'eq', commentId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> pinDiscussion(String discussionId, bool isPinned) async {
    try {
      await _client.from('discussions').update({'is_pinned': isPinned}).filter('id', 'eq', discussionId);
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> lockDiscussion(String discussionId, bool isLocked) async {
    try {
      await _client.from('discussions').update({'is_locked': isLocked}).filter('id', 'eq', discussionId);
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteDiscussion(String discussionId) async {
    try {
      await _client.from('discussions').delete().filter('id', 'eq', discussionId);
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteComment(String commentId) async {
    try {
      await _client.from('discussion_comments').delete().filter('id', 'eq', commentId);
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> incrementViewCount(String discussionId) async {
    try {
      await _client.rpc('increment_discussion_view', params: {'p_discussion_id': discussionId});
      return true;
    } catch (e) {
      debugPrint('[DiscussionRepositoryImpl] Error: $e');
      return false;
    }
  }
}
