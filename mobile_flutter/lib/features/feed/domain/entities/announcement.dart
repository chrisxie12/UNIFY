import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  final String id;
  final String title;
  final String body;
  final String category;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final String universityId;
  final bool isPinned;
  final bool isUrgent;
  final String? imageUrl;
  final int viewCount;
  final DateTime createdAt;
  final bool isRead;
  final bool authorIsVerifiedLeader;
  final String? authorLeadershipRole;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    this.authorIsVerifiedLeader = false,
    this.authorLeadershipRole,
    required this.universityId,
    this.isPinned = false,
    this.isUrgent = false,
    this.imageUrl,
    this.viewCount = 0,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, title, isRead, viewCount, authorIsVerifiedLeader];
}
