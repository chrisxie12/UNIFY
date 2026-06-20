import '../../data/models/event_model.dart';

abstract class EventRepository {
  // ── Discovery ─────────────────────────────────────────────
  Future<List<EventModel>> getEvents(String communityId, {String? currentUserId});
  Future<List<EventModel>> getUpcomingEvents({String? currentUserId, int limit = 20});
  Future<List<EventModel>> getTrendingEvents({String? currentUserId, int limit = 20});
  Future<List<EventModel>> getFeaturedEvents({String? currentUserId, int limit = 20});
  Future<List<EventModel>> getEventsByScope(String scope, {String? currentUserId, String? university, String? faculty, String? department});
  Future<List<EventModel>> getSavedEvents(String userId);
  Future<List<EventModel>> searchEvents(String query, {String? currentUserId});
  Future<EventModel> getEvent(String eventId, {String? currentUserId, String? userId});

  // ── CRUD ──────────────────────────────────────────────────
  Future<EventModel> createEvent(Map<String, dynamic> insertData);
  Future<bool> updateEvent(String eventId, Map<String, dynamic> updates);
  Future<bool> deleteEvent(String eventId);
  Future<bool> approveEvent(String eventId);
  Future<bool> rejectEvent(String eventId, {String? reason});
  Future<bool> featureEvent(String eventId);

  // ── RSVP / Registration ───────────────────────────────────
  Future<bool> rsvpEvent(String eventId, String userId, String status);
  Future<bool> cancelRsvp(String eventId, String userId);

  // ── Tickets & Check-in ────────────────────────────────────
  Future<EventTicketModel?> registerForEvent(String eventId, String userId);
  Future<EventTicketModel?> getMyTicket(String eventId, String userId);
  Future<List<EventTicketModel>> getMyTickets(String userId);
  Future<List<EventTicketModel>> getEventTickets(String eventId);
  Future<bool> checkInAttendee(String ticketId, String organizerId);
  Future<EventAttendanceAnalytics> getAttendanceAnalytics(String eventId);

  // ── Saves ─────────────────────────────────────────────────
  Future<bool> saveEvent(String eventId, String userId);
  Future<bool> unSaveEvent(String eventId, String userId);
  Future<bool> isEventSaved(String eventId, String userId);

  // ── Discussions ───────────────────────────────────────────
  Future<List<EventDiscussion>> getEventDiscussions(String eventId);
  Future<EventDiscussion> postDiscussion(String eventId, String userId, String content, {String? parentId});
  Future<bool> deleteDiscussion(String discussionId, String userId);

  // ── Media ─────────────────────────────────────────────────
  Future<List<EventMedia>> getEventMedia(String eventId);
  Future<EventMedia> uploadEventMedia(String eventId, String userId, String mediaType, String url, {String? caption});
  Future<bool> deleteMedia(String mediaId, String userId);

  // ── Reminders ─────────────────────────────────────────────
  Future<bool> setReminder(String eventId, String userId, DateTime remindAt);
  Future<bool> cancelReminder(String reminderId);

  // ── Certificates ──────────────────────────────────────────
  Future<List<EventCertificate>> getUserCertificates(String userId);
}
