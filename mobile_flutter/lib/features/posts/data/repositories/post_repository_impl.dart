import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';
import '../models/post_comment_model.dart';

class PostRepositoryImpl implements PostRepository {
  final SupabaseClient _client;

  PostRepositoryImpl(this._client);

  @override
  Future<List<PostModel>> getPosts(String communityId, {String? currentUserId, bool? pinned}) async {
    final response = await _client
        .from('community_posts')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .eq('community_id', communityId)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false)
        .limit(50)
        as List;

    final filtered = response.where((p) {
      final json = p as Map<String, dynamic>;
      if (pinned != null && json['is_pinned'] != pinned) return false;
      return true;
    }).toList();

    final posts = filtered.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['author_name'] = profile['display_name'];
        json['author_avatar'] = profile['avatar_url'];
        json['author_is_verified_leader'] = profile['is_verified_leader'];
        json['author_leadership_role'] = profile['leadership_role'];
      }
      return PostModel.fromJson(json);
    }).toList();

    if (currentUserId != null && posts.isNotEmpty) {
      final votesResponse = await _client
          .from('post_votes')
          .select('post_id, vote_type')
          .filter('user_id', 'eq', currentUserId)
          .limit(1000) as List;
      final voteMap = votesResponse
          .cast<Map<String, dynamic>>()
          .fold<Map<String, String>>({}, (map, v) {
            map[v['post_id'] as String] = v['vote_type'] as String;
            return map;
          });

      final bookmarksResponse = await _client
          .from('post_bookmarks')
          .select('post_id')
          .filter('user_id', 'eq', currentUserId)
          .limit(1000) as List;
      final bookmarkedIds = bookmarksResponse
          .cast<Map<String, dynamic>>()
          .map((b) => b['post_id'] as String)
          .toSet();

      for (var i = 0; i < posts.length; i++) {
        posts[i] = posts[i].copyWith(
          myVote: voteMap[posts[i].id],
          isBookmarkedByMe: bookmarkedIds.contains(posts[i].id),
        );
      }
    }

    return posts;
  }

  @override
  Future<PostModel> getPost(String postId, {String? currentUserId}) async {
    final response = await _client
        .from('community_posts')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('id', 'eq', postId)
        .single();

    final profile = response['profiles'] as Map<String, dynamic>?;
    if (profile != null) {
      response['author_name'] = profile['display_name'];
      response['author_avatar'] = profile['avatar_url'];
      response['author_is_verified_leader'] = profile['is_verified_leader'];
      response['author_leadership_role'] = profile['leadership_role'];
    }

    final post = PostModel.fromJson(response);

    if (currentUserId != null) {
      final votes = await _client
          .from('post_votes')
          .select('vote_type')
          .filter('post_id', 'eq', postId)
          .filter('user_id', 'eq', currentUserId) as List;
      final bookmarks = await _client
          .from('post_bookmarks')
          .select('id')
          .filter('post_id', 'eq', postId)
          .filter('user_id', 'eq', currentUserId) as List;

      final myVote = votes.isNotEmpty
          ? (votes.first as Map<String, dynamic>)['vote_type'] as String
          : null;

      return post.copyWith(
        myVote: myVote,
        isBookmarkedByMe: bookmarks.isNotEmpty,
      );
    }

    return post;
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    final response = await _client
        .from('community_posts')
        .insert(post.toInsertJson())
        .select()
        .single();
    return PostModel.fromJson(response);
  }

  @override
  Future<bool> deletePost(String postId) async {
    try {
      await _client.from('community_posts').delete().filter('id', 'eq', postId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> togglePin(String postId, bool isPinned) async {
    try {
      await _client.from('community_posts').update({'is_pinned': isPinned}).filter('id', 'eq', postId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> upvotePost(String postId, String userId) async {
    try {
      await _client.from('post_votes').upsert({
        'post_id': postId,
        'user_id': userId,
        'vote_type': 'upvote',
      }, onConflict: 'post_id,user_id');
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> downvotePost(String postId, String userId) async {
    try {
      await _client.from('post_votes').upsert({
        'post_id': postId,
        'user_id': userId,
        'vote_type': 'downvote',
      }, onConflict: 'post_id,user_id');
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> removeVote(String postId, String userId) async {
    try {
      await _client.from('post_votes').delete().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> bookmarkPost(String postId, String userId) async {
    try {
      await _client.from('post_bookmarks').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unbookmarkPost(String postId, String userId) async {
    try {
      await _client.from('post_bookmarks').delete().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<List<PostCommentModel>> getComments(String postId, {String? currentUserId}) async {
    final response = await _client
        .from('post_comments')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .eq('post_id', postId)
        .limit(100)
        .order('created_at', ascending: true) as List;

    if (response.length == 100) {
      debugPrint('[PostRepositoryImpl] getComments: result set truncated at 100, consider adding filters');
    }

    final allComments = response.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['author_name'] = profile['display_name'];
        json['author_avatar'] = profile['avatar_url'];
        json['author_is_verified_leader'] = profile['is_verified_leader'];
        json['author_leadership_role'] = profile['leadership_role'];
      }
      return PostCommentModel.fromJson(json);
    }).toList();

    final topLevel = allComments.where((c) => c.parentId == null).toList();
    final replyMap = <String, List<PostCommentModel>>{};
    for (final reply in allComments.where((c) => c.parentId != null)) {
      replyMap.putIfAbsent(reply.parentId!, () => []).add(reply);
    }

    for (var i = 0; i < topLevel.length; i++) {
      topLevel[i] = PostCommentModel(
        id: topLevel[i].id, postId: topLevel[i].postId,
        parentId: topLevel[i].parentId, authorId: topLevel[i].authorId,
        authorName: topLevel[i].authorName, authorAvatar: topLevel[i].authorAvatar,
        authorIsVerifiedLeader: topLevel[i].authorIsVerifiedLeader,
        authorLeadershipRole: topLevel[i].authorLeadershipRole,
        body: topLevel[i].body, likesCount: topLevel[i].likesCount,
        isLikedByMe: topLevel[i].isLikedByMe,
        isBestAnswer: topLevel[i].isBestAnswer,
        replies: replyMap[topLevel[i].id],
        createdAt: topLevel[i].createdAt, updatedAt: topLevel[i].updatedAt,
      );
    }

    if (currentUserId != null) {
      final likeResponse = await _client
          .from('comment_likes')
          .select('comment_id')
          .filter('user_id', 'eq', currentUserId)
          .limit(1000) as List;
      final likedIds = likeResponse.cast<Map<String, dynamic>>().map((l) => l['comment_id'] as String).toSet();

      void applyLikes(List<PostCommentModel> comments) {
        for (var i = 0; i < comments.length; i++) {
          final c = comments[i];
          comments[i] = PostCommentModel(
            id: c.id, postId: c.postId, parentId: c.parentId,
            authorId: c.authorId, authorName: c.authorName, authorAvatar: c.authorAvatar,
            authorIsVerifiedLeader: c.authorIsVerifiedLeader, authorLeadershipRole: c.authorLeadershipRole,
            body: c.body, likesCount: c.likesCount, isLikedByMe: likedIds.contains(c.id),
            isBestAnswer: c.isBestAnswer,
            replies: c.replies, createdAt: c.createdAt, updatedAt: c.updatedAt,
          );
          if (c.replies != null) applyLikes(c.replies!);
        }
      }
      applyLikes(topLevel);
    }

    return topLevel;
  }

  @override
  Future<PostCommentModel> createComment(PostCommentModel comment) async {
    final response = await _client
        .from('post_comments')
        .insert(comment.toInsertJson())
        .select()
        .single();
    return PostCommentModel.fromJson(response);
  }

  @override
  Future<bool> deleteComment(String commentId) async {
    try {
      await _client.from('post_comments').delete().filter('id', 'eq', commentId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> likeComment(String commentId, String userId) async {
    try {
      await _client.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unlikeComment(String commentId, String userId) async {
    try {
      await _client.from('comment_likes').delete().filter('comment_id', 'eq', commentId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> markBestAnswer(String postId, String commentId) async {
    try {
      final post = await getPost(postId);
      if (post.bestAnswerId != null) {
        await _client.from('post_comments').update({'is_best_answer': false}).filter('id', 'eq', post.bestAnswerId);
      }
      await _client.from('post_comments').update({'is_best_answer': true}).filter('id', 'eq', commentId);
      await _client.from('community_posts').update({'best_answer_id': commentId}).filter('id', 'eq', postId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unmarkBestAnswer(String postId, String commentId) async {
    try {
      await _client.from('post_comments').update({'is_best_answer': false}).filter('id', 'eq', commentId);
      await _client.from('community_posts').update({'best_answer_id': null}).filter('id', 'eq', postId);
      return true;
    } catch (e) {
      debugPrint('[PostRepositoryImpl] Error: $e');
      return false;
    }
  }
}
