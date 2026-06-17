import '../../data/models/poll_model.dart';

abstract class PollRepository {
  Future<List<PollModel>> getPolls(String communityId, {String? currentUserId});
  Future<PollModel> createPoll(Map<String, dynamic> pollData, List<String> optionLabels);
  Future<bool> vote(String pollId, String optionId, String userId);
  Future<bool> unvote(String pollId, String userId);
  Future<bool> lockPoll(String pollId);
}
