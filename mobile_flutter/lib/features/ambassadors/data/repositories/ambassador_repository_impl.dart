import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ambassador_models.dart';

class AmbassadorRepository {
  final SupabaseClient _client;

  AmbassadorRepository(this._client);

  static const String _join =
      '*, profiles!ambassadors_user_id_fkey(full_name, avatar_url)';

  // ── Ambassadors ────────────────────────────────────────────

  Future<List<Ambassador>> getAmbassadors({String? status}) async {
    final data = await _client
        .from('ambassadors')
        .select(_join)
        .order('joined_at', ascending: false);

    final list = (data as List)
        .map((row) => Ambassador.fromJson(row as Map<String, dynamic>))
        .toList();

    if (status != null && status.isNotEmpty) {
      return list.where((a) => a.status == status).toList();
    }
    return list;
  }

  Future<Ambassador> getAmbassador(String id) async {
    final data =
        await _client.from('ambassadors').select(_join).eq('id', id).single();
    return Ambassador.fromJson(data);
  }

  Future<Ambassador?> myAmbassadorProfile(String userId) async {
    final data = await _client
        .from('ambassadors')
        .select(_join)
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Ambassador.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final data = await _client
        .from('profiles')
        .select('id, full_name, email, programme')
        .or('full_name.ilike.%$q%,email.ilike.%$q%')
        .limit(15);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Ambassador> createAmbassador({
    required String userId,
    String? universityName,
    String? faculty,
    String? department,
    String? bio,
    String? contact,
  }) async {
    final result = await _client
        .from('ambassadors')
        .insert({
          'user_id': userId,
          'university_name': universityName,
          'faculty': faculty,
          'department': department,
          'bio': bio,
          'contact': contact,
          'status': 'active',
        })
        .select(_join)
        .single();
    return Ambassador.fromJson(result);
  }

  Future<void> setAmbassadorStatus(String id, String status) async {
    await _client.from('ambassadors').update({'status': status}).eq('id', id);
  }

  // ── Events ─────────────────────────────────────────────────

  Future<List<AmbassadorEvent>> getEvents(String ambassadorId) async {
    final data = await _client
        .from('ambassador_events')
        .select('*')
        .eq('ambassador_id', ambassadorId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => AmbassadorEvent.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<AmbassadorEvent> addEvent({
    required String ambassadorId,
    required String title,
    String? description,
    DateTime? eventDate,
    int attendance = 0,
  }) async {
    final result = await _client
        .from('ambassador_events')
        .insert({
          'ambassador_id': ambassadorId,
          'title': title,
          'description': description,
          'event_date': eventDate == null
              ? null
              : '${eventDate.year.toString().padLeft(4, '0')}-'
                  '${eventDate.month.toString().padLeft(2, '0')}-'
                  '${eventDate.day.toString().padLeft(2, '0')}',
          'attendance': attendance,
        })
        .select()
        .single();
    return AmbassadorEvent.fromJson(result);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('ambassador_events').delete().eq('id', id);
  }

  // ── Stats ──────────────────────────────────────────────────

  Future<Map<String, int>> stats() async {
    final data = await _client
        .from('ambassadors')
        .select('status, referral_count, events_organized');

    final rows = (data as List).cast<Map<String, dynamic>>();
    var active = 0;
    var totalReferrals = 0;
    var totalEvents = 0;
    for (final r in rows) {
      if ((r['status'] as String? ?? '') == 'active') active++;
      totalReferrals += r['referral_count'] as int? ?? 0;
      totalEvents += r['events_organized'] as int? ?? 0;
    }
    return {
      'active': active,
      'totalReferrals': totalReferrals,
      'totalEvents': totalEvents,
    };
  }
}
