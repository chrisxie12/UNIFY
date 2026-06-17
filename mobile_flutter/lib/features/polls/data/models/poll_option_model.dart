class PollOptionModel {
  final String id;
  final String pollId;
  final String label;
  final int voteCount;
  final DateTime createdAt;

  const PollOptionModel({
    required this.id,
    required this.pollId,
    required this.label,
    this.voteCount = 0,
    required this.createdAt,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      label: json['label'] as String,
      voteCount: json['vote_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'label': label,
      'vote_count': voteCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'poll_id': pollId,
      'label': label,
    };
  }
}
