import '../entities/announcement.dart';

abstract class FeedRepository {
  /// Returns a page of announcements ranked by engagement + recency.
  /// Pass [cursor] = (hotScore, createdAt) of the last item for subsequent pages.
  /// Pinned items always appear first regardless of score.
  Future<List<Announcement>> getFeed({(double score, DateTime createdAt)? cursor, int limit = 20});

  Future<void> markRead(String announcementId);
  Future<void> refresh();
}
