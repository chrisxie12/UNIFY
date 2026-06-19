import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/poll_repository.dart';
import '../models/poll_model.dart';
import '../models/poll_option_model.dart';

class PollRepositoryImpl implements PollRepository {
  final SupabaseClient _client;

  PollRepositoryImpl(this._client);

  @override
  Future<List<PollModel>> getPolls(String communityId, {String? currentUserId}) async {
    final response = await _client
        .from('community_polls')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .eq('community_id', communityId)
        .limit(100)
        .order('created_at', ascending: false) as List;

    if (response.length == 100) {
      debugPrint('[PollRepositoryImpl] getPolls: result set truncated at 100, consider adding filters');
    }

    final polls = await Future.wait(response.map((json) async {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['creator_name'] = profile['display_name'];
        json['creator_avatar'] = profile['avatar_url'];
      }

      final optionsResponse = await _client
          .from('poll_options')
          .select('*')
          .filter('poll_id', 'eq', json['id'] as String)
          .order('created_at', ascending: true) as List;
      json['options'] = optionsResponse;

      return PollModel.fromJson(json);
    }).toList());

    if (currentUserId != null && polls.isNotEmpty) {
      final voteResponse = await _client
          .from('poll_votes')
          .select('poll_id, option_id')
          .filter('user_id', 'eq', currentUserId) as List;
      final voteMap = voteResponse
          .cast<Map<String, dynamic>>()
          .fold<Map<String, String>>({}, (map, v) {
            map[v['poll_id'] as String] = v['option_id'] as String;
            return map;
          });

      for (var i = 0; i < polls.length; i++) {
        polls[i] = PollModel(
          id: polls[i].id, communityId: polls[i].communityId,
          creatorId: polls[i].creatorId,
          creatorName: polls[i].creatorName, creatorAvatar: polls[i].creatorAvatar,
          question: polls[i].question, description: polls[i].description,
          pollType: polls[i].pollType, isAnonymous: polls[i].isAnonymous,
          isLocked: polls[i].isLocked, expiresAt: polls[i].expiresAt,
          totalVotes: polls[i].totalVotes, myVote: voteMap[polls[i].id],
          options: polls[i].options, createdAt: polls[i].createdAt,
        );
      }
    }

    return polls;
  }

  @override
  Future<PollModel> createPoll(Map<String, dynamic> pollData, List<String> optionLabels) async {
    final pollResponse = await _client
        .from('community_polls')
        .insert(pollData)
        .select()
        .single();

    final pollId = pollResponse['id'] as String;

    final options = await Future.wait(optionLabels.map((label) async {
      final optionResponse = await _client
          .from('poll_options')
          .insert({
            'poll_id': pollId,
            'label': label,
          })
          .select()
          .single();
      return PollOptionModel.fromJson(optionResponse);
    }).toList());

    return PollModel(
      id: pollResponse['id'] as String,
      communityId: pollResponse['community_id'] as String,
      creatorId: pollResponse['creator_id'] as String,
      question: pollResponse['question'] as String,
      description: pollResponse['description'] as String?,
      pollType: pollResponse['poll_type'] as String,
      isAnonymous: pollResponse['is_anonymous'] as bool? ?? false,
      isLocked: pollResponse['is_locked'] as bool? ?? false,
      expiresAt: pollResponse['expires_at'] != null ? DateTime.parse(pollResponse['expires_at'] as String) : null,
      totalVotes: pollResponse['total_votes'] as int? ?? 0,
      options: options,
      createdAt: DateTime.parse(pollResponse['created_at'] as String),
    );
  }

  @override
  Future<bool> vote(String pollId, String optionId, String userId) async {
    try {
      await _client.from('poll_votes').insert({
        'poll_id': pollId,
        'option_id': optionId,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('[PollRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unvote(String pollId, String userId) async {
    try {
      await _client.from('poll_votes').delete().filter('poll_id', 'eq', pollId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[PollRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> lockPoll(String pollId) async {
    try {
      await _client.from('community_polls').update({'is_locked': true}).filter('id', 'eq', pollId);
      return true;
    } catch (e) {
      debugPrint('[PollRepositoryImpl] Error: $e');
      return false;
    }
  }
}
