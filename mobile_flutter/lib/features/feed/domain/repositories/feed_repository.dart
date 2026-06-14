import '../entities/announcement_entity.dart';

abstract interface class FeedRepository {
  /// Fetch announcements, cursor-based pagination.
  /// [after] is the publishedAt of the last item (for next page).
  Future<List<AnnouncementEntity>> getAnnouncements({
    int pageSize = 20,
    DateTime? after,
  });

  /// Force-refresh bypassing cache
  Future<List<AnnouncementEntity>> refreshAnnouncements({int pageSize = 20});

  /// Create a new announcement (admin only)
  Future<AnnouncementEntity> createAnnouncement({
    required String title,
    required String body,
    required String category,
    required String universityId,
    required String authorId,
  });

  /// Update an existing announcement (admin only)
  Future<AnnouncementEntity> updateAnnouncement({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Publish / un-publish an announcement (admin only)
  Future<void> togglePublish(String id, {required bool publish});

  /// Mark an announcement as read for the current user
  Future<void> markAsRead(String announcementId, String userId);
}
