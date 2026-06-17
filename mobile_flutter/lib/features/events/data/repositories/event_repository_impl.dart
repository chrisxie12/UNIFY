import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final SupabaseClient _client;

  EventRepositoryImpl(this._client);

  @override
  Future<List<EventModel>> getEvents(String communityId, {String? currentUserId}) async {
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .order('event_date', ascending: true) as List;

    final filtered = response.where((e) {
      final json = e as Map<String, dynamic>;
      return json['community_id'] == communityId;
    }).toList();

    final events = filtered.map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        json['creator_name'] = profile['display_name'];
        json['creator_avatar'] = profile['avatar_url'];
      }
      return EventModel.fromJson(json);
    }).toList();

    if (currentUserId != null && events.isNotEmpty) {
      final rsvpResponse = await _client
          .from('event_rsvps')
          .select('event_id, status')
          .filter('user_id', 'eq', currentUserId) as List;
      final rsvpMap = rsvpResponse
          .cast<Map<String, dynamic>>()
          .fold<Map<String, String>>({}, (map, r) {
            map[r['event_id'] as String] = r['status'] as String;
            return map;
          });

      for (var i = 0; i < events.length; i++) {
        events[i] = EventModel(
          id: events[i].id, communityId: events[i].communityId,
          creatorId: events[i].creatorId,
          creatorName: events[i].creatorName, creatorAvatar: events[i].creatorAvatar,
          title: events[i].title, description: events[i].description,
          location: events[i].location, eventDate: events[i].eventDate,
          endDate: events[i].endDate, coverUrl: events[i].coverUrl,
          eventType: events[i].eventType, rsvpCount: events[i].rsvpCount,
          maxAttendees: events[i].maxAttendees, isVirtual: events[i].isVirtual,
          meetingLink: events[i].meetingLink,
          myRsvpStatus: rsvpMap[events[i].id],
          createdAt: events[i].createdAt, updatedAt: events[i].updatedAt,
        );
      }
    }

    return events;
  }

  @override
  Future<EventModel> getEvent(String eventId, {String? currentUserId}) async {
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('id', 'eq', eventId)
        .single();

    final profile = response['profiles'] as Map<String, dynamic>?;
    if (profile != null) {
      response['creator_name'] = profile['display_name'];
      response['creator_avatar'] = profile['avatar_url'];
    }

    final event = EventModel.fromJson(response);

    if (currentUserId != null) {
      final rsvps = await _client
          .from('event_rsvps')
          .select('status')
          .filter('event_id', 'eq', eventId)
          .filter('user_id', 'eq', currentUserId) as List;

      if (rsvps.isNotEmpty) {
        final status = (rsvps.first as Map<String, dynamic>)['status'] as String;
        return EventModel(
          id: event.id, communityId: event.communityId,
          creatorId: event.creatorId,
          creatorName: event.creatorName, creatorAvatar: event.creatorAvatar,
          title: event.title, description: event.description,
          location: event.location, eventDate: event.eventDate,
          endDate: event.endDate, coverUrl: event.coverUrl,
          eventType: event.eventType, rsvpCount: event.rsvpCount,
          maxAttendees: event.maxAttendees, isVirtual: event.isVirtual,
          meetingLink: event.meetingLink, myRsvpStatus: status,
          createdAt: event.createdAt, updatedAt: event.updatedAt,
        );
      }
    }

    return event;
  }

  @override
  Future<EventModel> createEvent(Map<String, dynamic> insertData) async {
    final response = await _client
        .from('community_events')
        .insert(insertData)
        .select()
        .single();
    return EventModel.fromJson(response);
  }

  @override
  Future<bool> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      await _client.from('community_events').update(updates).filter('id', 'eq', eventId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _client.from('community_events').delete().filter('id', 'eq', eventId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> rsvpEvent(String eventId, String userId, String status) async {
    try {
      await _client.from('event_rsvps').delete().filter('event_id', 'eq', eventId).filter('user_id', 'eq', userId);
      await _client.from('event_rsvps').insert({
        'event_id': eventId,
        'user_id': userId,
        'status': status,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> cancelRsvp(String eventId, String userId) async {
    try {
      await _client.from('event_rsvps').delete().filter('event_id', 'eq', eventId).filter('user_id', 'eq', userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
