import '../../data/models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents(String communityId, {String? currentUserId});
  Future<EventModel> getEvent(String eventId, {String? currentUserId});
  Future<EventModel> createEvent(Map<String, dynamic> insertData);
  Future<bool> updateEvent(String eventId, Map<String, dynamic> updates);
  Future<bool> deleteEvent(String eventId);
  Future<bool> rsvpEvent(String eventId, String userId, String status);
  Future<bool> cancelRsvp(String eventId, String userId);
}
