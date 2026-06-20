import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final SupabaseClient _client;

  EventRepositoryImpl(this._client);

  Future<void> _logAction(String actorId, String action, String entityType, String? entityId) async {
    try {
      await _client.rpc('log_admin_action', params: {
        'actor_id': actorId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'university_id': null,
        'details': {},
      });
    } catch (_) {
      try {
        await _client.from('audit_logs').insert({
          'actor_id': actorId,
          'action': action,
          'entity_type': entityType,
          'entity_id': entityId,
          'details': {},
        });
      } catch (_) {}
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  List<EventModel> _parseEvents(dynamic response) {
    final data = response as List;
    final events = data.map((json) {
      final map = json as Map<String, dynamic>;
      final profile = map['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        map['creator_name'] = profile['display_name'];
        map['creator_avatar'] = profile['avatar_url'];
      }
      return EventModel.fromJson(map);
    }).toList();
    return events;
  }

  Future<void> _attachRsvpStatus(List<EventModel> events, String userId) async {
    if (events.isEmpty || userId.isEmpty) return;
    final rsvpResponse = await _client
        .from('event_rsvps')
        .select('event_id, status')
        .filter('user_id', 'eq', userId) as List;
    final rsvpMap = rsvpResponse
        .cast<Map<String, dynamic>>()
        .fold<Map<String, String>>({}, (map, r) {
      map[r['event_id'] as String] = r['status'] as String;
      return map;
    });
    for (var i = 0; i < events.length; i++) {
      final status = rsvpMap[events[i].id];
      if (status != null) {
        events[i] = _withRsvp(events[i], status);
      }
    }
  }

  Future<void> _attachSaveStatus(List<EventModel> events, String userId) async {
    if (events.isEmpty || userId.isEmpty) return;
    final savedResponse = await _client
        .from('event_saves')
        .select('event_id')
        .filter('user_id', 'eq', userId) as List;
    final savedIds = savedResponse
        .cast<Map<String, dynamic>>()
        .map((r) => r['event_id'] as String)
        .toSet();
    for (var i = 0; i < events.length; i++) {
      if (savedIds.contains(events[i].id)) {
        events[i] = _withSave(events[i], true);
      }
    }
  }

  Future<void> _attachTicketInfo(List<EventModel> events, String userId) async {
    if (events.isEmpty || userId.isEmpty) return;
    final ticketResponse = await _client
        .from('event_tickets')
        .select('event_id, id, qr_code, attended')
        .filter('user_id', 'eq', userId) as List;
    final ticketMap = ticketResponse
        .cast<Map<String, dynamic>>()
        .fold<Map<String, Map<String, dynamic>>>({}, (map, t) {
      map[t['event_id'] as String] = t;
      return map;
    });
    for (var i = 0; i < events.length; i++) {
      final ticket = ticketMap[events[i].id];
      if (ticket != null) {
        events[i] = _withTicket(events[i], ticket);
      }
    }
  }

  EventModel _withRsvp(EventModel e, String status) {
    return EventModel(
      id: e.id, communityId: e.communityId, creatorId: e.creatorId,
      creatorName: e.creatorName, creatorAvatar: e.creatorAvatar,
      title: e.title, description: e.description, location: e.location,
      eventDate: e.eventDate, eventTime: e.eventTime, endDate: e.endDate, endTime: e.endTime,
      coverUrl: e.coverUrl, eventType: e.eventType, rsvpCount: e.rsvpCount,
      maxAttendees: e.maxAttendees, isVirtual: e.isVirtual, meetingLink: e.meetingLink,
      myRsvpStatus: status, createdAt: e.createdAt, updatedAt: e.updatedAt,
      category: e.category, capacity: e.capacity, registrationType: e.registrationType,
      ticketType: e.ticketType, contactInfo: e.contactInfo, scope: e.scope,
      university: e.university, faculty: e.faculty, department: e.department,
      organizerType: e.organizerType, attendeeCount: e.attendeeCount,
      isFeatured: e.isFeatured, isApproved: e.isApproved, isCancelled: e.isCancelled,
    );
  }

  EventModel _withSave(EventModel e, bool saved) {
    return EventModel(
      id: e.id, communityId: e.communityId, creatorId: e.creatorId,
      creatorName: e.creatorName, creatorAvatar: e.creatorAvatar,
      title: e.title, description: e.description, location: e.location,
      eventDate: e.eventDate, eventTime: e.eventTime, endDate: e.endDate, endTime: e.endTime,
      coverUrl: e.coverUrl, eventType: e.eventType, rsvpCount: e.rsvpCount,
      maxAttendees: e.maxAttendees, isVirtual: e.isVirtual, meetingLink: e.meetingLink,
      myRsvpStatus: e.myRsvpStatus, createdAt: e.createdAt, updatedAt: e.updatedAt,
      category: e.category, capacity: e.capacity, registrationType: e.registrationType,
      ticketType: e.ticketType, contactInfo: e.contactInfo, scope: e.scope,
      university: e.university, faculty: e.faculty, department: e.department,
      organizerType: e.organizerType, attendeeCount: e.attendeeCount,
      isFeatured: e.isFeatured, isApproved: e.isApproved, isCancelled: e.isCancelled,
      isSaved: saved,
    );
  }

  EventModel _withTicket(EventModel e, Map<String, dynamic> ticket) {
    return EventModel(
      id: e.id, communityId: e.communityId, creatorId: e.creatorId,
      creatorName: e.creatorName, creatorAvatar: e.creatorAvatar,
      title: e.title, description: e.description, location: e.location,
      eventDate: e.eventDate, eventTime: e.eventTime, endDate: e.endDate, endTime: e.endTime,
      coverUrl: e.coverUrl, eventType: e.eventType, rsvpCount: e.rsvpCount,
      maxAttendees: e.maxAttendees, isVirtual: e.isVirtual, meetingLink: e.meetingLink,
      myRsvpStatus: e.myRsvpStatus, createdAt: e.createdAt, updatedAt: e.updatedAt,
      category: e.category, capacity: e.capacity, registrationType: e.registrationType,
      ticketType: e.ticketType, contactInfo: e.contactInfo, scope: e.scope,
      university: e.university, faculty: e.faculty, department: e.department,
      organizerType: e.organizerType, attendeeCount: e.attendeeCount,
      isFeatured: e.isFeatured, isApproved: e.isApproved, isCancelled: e.isCancelled,
      myTicketId: ticket['id'] as String?,
      myTicketQrCode: ticket['qr_code'] as String?,
      myAttendanceStatus: ticket['attended'] as bool? ?? false,
    );
  }

  // ── Discovery ─────────────────────────────────────────────

  @override
  Future<List<EventModel>> getEvents(String communityId, {String? currentUserId}) async {
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('community_id', 'eq', communityId)
        .order('event_date', ascending: true)
        .limit(50) as List;
    return _parseEvents(response);
  }

  @override
  Future<List<EventModel>> getUpcomingEvents({String? currentUserId, int limit = 20}) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('event_date', 'gte', today)
        .filter('is_cancelled', 'eq', false)
        .order('event_date', ascending: true)
        .limit(limit) as List;
    final events = _parseEvents(response);
    if (currentUserId != null && currentUserId.isNotEmpty) {
      await _attachRsvpStatus(events, currentUserId);
      await _attachSaveStatus(events, currentUserId);
      await _attachTicketInfo(events, currentUserId);
    }
    return events;
  }

  @override
  Future<List<EventModel>> getTrendingEvents({String? currentUserId, int limit = 20}) async {
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('is_cancelled', 'eq', false)
        .order('attendee_count', ascending: false)
        .limit(limit) as List;
    final events = _parseEvents(response);
    if (currentUserId != null && currentUserId.isNotEmpty) {
      await _attachRsvpStatus(events, currentUserId);
      await _attachSaveStatus(events, currentUserId);
    }
    return events;
  }

  @override
  Future<List<EventModel>> getFeaturedEvents({String? currentUserId, int limit = 20}) async {
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('is_featured', 'eq', true)
        .filter('is_cancelled', 'eq', false)
        .order('event_date', ascending: true)
        .limit(limit) as List;
    final events = _parseEvents(response);
    if (currentUserId != null && currentUserId.isNotEmpty) {
      await _attachRsvpStatus(events, currentUserId);
      await _attachSaveStatus(events, currentUserId);
    }
    return events;
  }

  @override
  Future<List<EventModel>> getEventsByScope(String scope, {String? currentUserId, String? university, String? faculty, String? department}) async {
    dynamic query = _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('scope', 'eq', scope)
        .filter('is_cancelled', 'eq', false)
        .filter('is_approved', 'eq', true);
    if (university != null) query = query.filter('university', 'eq', university);
    if (faculty != null) query = query.filter('faculty', 'eq', faculty);
    if (department != null) query = query.filter('department', 'eq', department);
    query = query.order('event_date', ascending: true).limit(50);
    final events = _parseEvents(await query);
    if (currentUserId != null && currentUserId.isNotEmpty) {
      await _attachRsvpStatus(events, currentUserId);
      await _attachSaveStatus(events, currentUserId);
    }
    return events;
  }

  @override
  Future<List<EventModel>> getSavedEvents(String userId, {int limit = 50}) async {
    final response = await _client
        .from('event_saves')
        .select('event_id, community_events!inner(*, profiles(display_name, avatar_url, is_verified_leader, leadership_role))')
        .filter('user_id', 'eq', userId)
        .order('saved_at', ascending: false)
        .limit(limit) as List;
    return response.map((json) {
      final map = json as Map<String, dynamic>;
      final eventMap = map['community_events'] as Map<String, dynamic>;
      final profile = eventMap['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        eventMap['creator_name'] = profile['display_name'];
        eventMap['creator_avatar'] = profile['avatar_url'];
      }
      return EventModel.fromJson(eventMap);
    }).toList();
  }

  @override
  Future<List<EventModel>> searchEvents(String query, {String? currentUserId}) async {
    final response = await _client
        .from('community_events')
        .select('*, profiles(display_name, avatar_url, is_verified_leader, leadership_role)')
        .filter('is_cancelled', 'eq', false)
        .or('title.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%')
        .order('event_date', ascending: true)
        .limit(20) as List;
    final events = _parseEvents(response);
    if (currentUserId != null && currentUserId.isNotEmpty) {
      await _attachRsvpStatus(events, currentUserId);
    }
    return events;
  }

  @override
  Future<EventModel> getEvent(String eventId, {String? currentUserId, String? userId}) async {
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
    var event = EventModel.fromJson(response);
    if (currentUserId != null || userId != null) {
      final uid = currentUserId ?? userId!;
      final rsvps = await _client
          .from('event_rsvps')
          .select('status')
          .filter('event_id', 'eq', eventId)
          .filter('user_id', 'eq', uid)
          .limit(1) as List;
      if (rsvps.isNotEmpty) {
        final status = (rsvps.first as Map<String, dynamic>)['status'] as String;
        event = _withRsvp(event, status);
      }
      final saved = await _client
          .from('event_saves')
          .select('event_id')
          .filter('event_id', 'eq', eventId)
          .filter('user_id', 'eq', uid)
          .maybeSingle();
      if (saved != null) {
        event = _withSave(event, true);
      }
      final ticket = await _client
          .from('event_tickets')
          .select('id, qr_code, attended')
          .filter('event_id', 'eq', eventId)
          .filter('user_id', 'eq', uid)
          .maybeSingle();
      if (ticket != null) {
        event = _withTicket(event, ticket);
      }
    }
    return event;
  }

  // ── CRUD ──────────────────────────────────────────────────

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
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _client.from('community_events').delete().filter('id', 'eq', eventId);
      await _logAction(_client.auth.currentUser?.id ?? '', 'delete_event', 'event', eventId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> approveEvent(String eventId) async {
    try {
      await _client.from('community_events').update({'is_approved': true}).filter('id', 'eq', eventId);
      await _logAction(_client.auth.currentUser?.id ?? '', 'approve_event', 'event', eventId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> featureEvent(String eventId) async {
    try {
      await _client.from('community_events').update({'is_featured': true}).filter('id', 'eq', eventId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── RSVP / Registration ───────────────────────────────────

  @override
  Future<bool> rsvpEvent(String eventId, String userId, String status) async {
    try {
      await _client.from('event_rsvps').delete().filter('event_id', 'eq', eventId).filter('user_id', 'eq', userId);
      await _client.from('event_rsvps').insert({
        'event_id': eventId, 'user_id': userId, 'status': status,
      });
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelRsvp(String eventId, String userId) async {
    try {
      await _client.from('event_rsvps').delete().filter('event_id', 'eq', eventId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Tickets & Check-in ────────────────────────────────────

  @override
  Future<EventTicketModel?> registerForEvent(String eventId, String userId) async {
    try {
      final ticketNumber = 'TKT-${eventId.substring(0, 8).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
      final qrCode = 'QR-$eventId-$userId-${DateTime.now().millisecondsSinceEpoch}';
      final response = await _client.from('event_tickets').insert({
        'ticket_number': ticketNumber,
        'event_id': eventId,
        'user_id': userId,
        'qr_code': qrCode,
      }).select().single();
      return EventTicketModel.fromJson(response);
    } catch (e) {
      debugPrint('[EventRepositoryImpl] registerForEvent error: $e');
      return null;
    }
  }

  @override
  Future<EventTicketModel?> getMyTicket(String eventId, String userId) async {
    final response = await _client
        .from('event_tickets')
        .select('*, community_events!inner(title, event_date, event_time, location)')
        .filter('event_id', 'eq', eventId)
        .filter('user_id', 'eq', userId)
        .maybeSingle();
    if (response == null) return null;
    final eventData = response['community_events'] as Map<String, dynamic>?;
    if (eventData != null) {
      response['event_title'] = eventData['title'];
      response['event_date'] = eventData['event_date'];
      response['event_time'] = eventData['event_time'];
      response['event_venue'] = eventData['location'];
    }
    return EventTicketModel.fromJson(response);
  }

  @override
  Future<List<EventTicketModel>> getMyTickets(String userId) async {
    final response = await _client
        .from('event_tickets')
        .select('*, community_events!inner(title, event_date, event_time, location)')
        .filter('user_id', 'eq', userId)
        .order('registration_timestamp', ascending: false)
        .limit(50) as List;
    return response.map((json) {
      final map = json as Map<String, dynamic>;
      final eventData = map['community_events'] as Map<String, dynamic>?;
      if (eventData != null) {
        map['event_title'] = eventData['title'];
        map['event_date'] = eventData['event_date'];
        map['event_time'] = eventData['event_time'];
        map['event_venue'] = eventData['location'];
      }
      return EventTicketModel.fromJson(map);
    }).toList();
  }

  @override
  Future<List<EventTicketModel>> getEventTickets(String eventId) async {
    final response = await _client
        .from('event_tickets')
        .select('*, profiles(display_name)')
        .filter('event_id', 'eq', eventId)
        .order('registration_timestamp', ascending: true)
        .limit(200) as List;
    return response.map((json) {
      final map = json as Map<String, dynamic>;
      return EventTicketModel.fromJson(map);
    }).toList();
  }

  @override
  Future<bool> checkInAttendee(String ticketId, String organizerId) async {
    try {
      await _client.from('event_tickets').update({
        'attended': true,
        'checked_in_at': DateTime.now().toIso8601String(),
        'checked_in_by': organizerId,
      }).filter('id', 'eq', ticketId).filter('attended', 'eq', false);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<EventAttendanceAnalytics> getAttendanceAnalytics(String eventId) async {
    final tickets = await _client
        .from('event_tickets')
        .select('id, attended')
        .filter('event_id', 'eq', eventId)
        .limit(5000) as List;
    final total = tickets.length;
    final checkedIn = tickets.where((t) => (t as Map<String, dynamic>)['attended'] as bool).length;
    return EventAttendanceAnalytics(
      totalRegistrations: total,
      totalCheckIns: checkedIn,
      attendanceRate: total > 0 ? (checkedIn / total) * 100 : 0,
      noShows: total - checkedIn,
    );
  }

  // ── Saves ─────────────────────────────────────────────────

  @override
  Future<bool> saveEvent(String eventId, String userId) async {
    try {
      await _client.from('event_saves').insert({
        'event_id': eventId, 'user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> unSaveEvent(String eventId, String userId) async {
    try {
      await _client.from('event_saves').delete().filter('event_id', 'eq', eventId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> isEventSaved(String eventId, String userId) async {
    final response = await _client
        .from('event_saves')
        .select('event_id')
        .filter('event_id', 'eq', eventId)
        .filter('user_id', 'eq', userId)
        .maybeSingle();
    return response != null;
  }

  // ── Discussions ───────────────────────────────────────────

  @override
  Future<List<EventDiscussion>> getEventDiscussions(String eventId) async {
    final response = await _client
        .from('event_discussions')
        .select('*, profiles(display_name, avatar_url), replies:event_discussions!parent_id(*)')
        .filter('event_id', 'eq', eventId)
        .filter('parent_id', 'is', null)
        .order('created_at', ascending: true)
        .limit(50) as List;
    return response.map((json) {
      final map = json as Map<String, dynamic>;
      final profile = map['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        map['user_name'] = profile['display_name'];
        map['user_avatar'] = profile['avatar_url'];
      }
      final replies = map['replies'] as List?;
      if (replies != null) {
        map['replies'] = replies.map((r) {
          final rMap = r as Map<String, dynamic>;
          final rProfile = rMap['profiles'] as Map<String, dynamic>?;
          if (rProfile != null) {
            rMap['user_name'] = rProfile['display_name'];
            rMap['user_avatar'] = rProfile['avatar_url'];
          }
          return rMap;
        }).toList();
      }
      return EventDiscussion.fromJson(map);
    }).toList();
  }

  @override
  Future<EventDiscussion> postDiscussion(String eventId, String userId, String content, {String? parentId}) async {
    final data = <String, dynamic>{
      'event_id': eventId, 'user_id': userId, 'content': content,
    };
    if (parentId != null) data['parent_id'] = parentId;
    final response = await _client.from('event_discussions').insert(data).select().single();
    final profile = await _client.from('profiles').select('display_name, avatar_url').filter('id', 'eq', userId).single();
    response['user_name'] = profile['display_name'];
    response['user_avatar'] = profile['avatar_url'];
    return EventDiscussion.fromJson(response);
  }

  @override
  Future<bool> deleteDiscussion(String discussionId, String userId) async {
    try {
      await _client.from('event_discussions').delete().filter('id', 'eq', discussionId).filter('user_id', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Media ─────────────────────────────────────────────────

  @override
  Future<List<EventMedia>> getEventMedia(String eventId) async {
    final response = await _client
        .from('event_media')
        .select('*, profiles(display_name)')
        .filter('event_id', 'eq', eventId)
        .order('created_at', ascending: false)
        .limit(50) as List;
    return response.map((json) {
      final map = json as Map<String, dynamic>;
      final profile = map['profiles'] as Map<String, dynamic>?;
      if (profile != null) map['uploader_name'] = profile['display_name'];
      return EventMedia.fromJson(map);
    }).toList();
  }

  @override
  Future<EventMedia> uploadEventMedia(String eventId, String userId, String mediaType, String url, {String? caption}) async {
    final data = <String, dynamic>{
      'event_id': eventId, 'uploaded_by': userId, 'media_type': mediaType, 'url': url,
    };
    if (caption != null) data['caption'] = caption;
    final response = await _client.from('event_media').insert(data).select().single();
    return EventMedia.fromJson(response);
  }

  @override
  Future<bool> deleteMedia(String mediaId, String userId) async {
    try {
      await _client.from('event_media').delete().filter('id', 'eq', mediaId).filter('uploaded_by', 'eq', userId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Reminders ─────────────────────────────────────────────

  @override
  Future<bool> setReminder(String eventId, String userId, DateTime remindAt) async {
    try {
      await _client.from('event_reminders').insert({
        'event_id': eventId, 'user_id': userId, 'remind_at': remindAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelReminder(String reminderId) async {
    try {
      await _client.from('event_reminders').delete().filter('id', 'eq', reminderId);
      return true;
    } catch (e) {
      debugPrint('[EventRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Certificates ──────────────────────────────────────────

  @override
  Future<List<EventCertificate>> getUserCertificates(String userId) async {
    final response = await _client
        .from('event_certificates')
        .select('*, community_events!inner(title)')
        .filter('user_id', 'eq', userId)
        .order('issued_at', ascending: false)
        .limit(50) as List;
    return response.map((json) {
      final map = json as Map<String, dynamic>;
      final eventData = map['community_events'] as Map<String, dynamic>?;
      if (eventData != null) map['event_title'] = eventData['title'];
      return EventCertificate.fromJson(map);
    }).toList();
  }
}
