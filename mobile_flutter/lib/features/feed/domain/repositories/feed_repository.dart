import '../entities/announcement.dart';

abstract class FeedRepository {
  /// Returns a page of announcements. Pass [cursor] (created_at of last item)
  /// for subsequent pages. Returns items ordered newest-first.
  Future<List<Announcement>> getFeed({String? cursor, int limit = 20});

  Future<void> markRead(String announcementId);
  Future<void> refresh();
}
