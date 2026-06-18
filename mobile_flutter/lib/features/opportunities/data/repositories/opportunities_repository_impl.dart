import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/opportunity_models.dart';

class OpportunitiesRepositoryImpl {
  final SupabaseClient _client;
  OpportunitiesRepositoryImpl(this._client);

  static const _boxName = AppConstants.opportunitiesBox;
  static const _feedCacheKey = 'feed';

  // ── Browse / search ──────────────────────────────────────────

  Future<List<OpportunityModel>> getOpportunities({
    required OpportunityFilter filter,
    String? universityId,
    String? userId,
    int limit = 40,
    int offset = 0,
    bool useCache = true,
  }) async {
    final isDefaultFeed = filter.type == null &&
        (filter.query == null || filter.query!.isEmpty) &&
        !filter.fundedOnly &&
        !filter.remoteOnly &&
        !filter.verifiedOnly &&
        filter.field == null &&
        offset == 0;

    try {
      var q = _client
          .from('opportunities')
          .select('*')
          .eq('status', 'published');

      // Campus-scoped OR global (university_id null)
      if (universityId != null) {
        q = q.or('university_id.is.null,university_id.eq.$universityId');
      }
      if (filter.type != null) q = q.eq('type', filter.type!.key);
      if (filter.fundedOnly) q = q.eq('is_funded', true);
      if (filter.remoteOnly) q = q.eq('is_remote', true);
      if (filter.verifiedOnly) q = q.eq('is_verified', true);
      if (filter.field != null && filter.field!.isNotEmpty) {
        q = q.contains('fields', [filter.field!]);
      }
      if (filter.query != null && filter.query!.trim().isNotEmpty) {
        final t = filter.query!.trim();
        q = q.or('title.ilike.%$t%,organization.ilike.%$t%,summary.ilike.%$t%');
      }

      final data = await switch (filter.sort) {
        'deadline' => q
            .order('deadline', ascending: true, nullsFirst: false)
            .range(offset, offset + limit - 1),
        'popular' =>
          q.order('view_count', ascending: false).range(offset, offset + limit - 1),
        _ => q
            .order('is_featured', ascending: false)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1),
      };

      final saved = userId != null ? await _savedIds(userId) : <String>{};
      final stages = userId != null ? await _stages(userId) : <String, String>{};
      final items = (data as List)
          .map((r) => OpportunityModel.fromJson(r as Map<String, dynamic>,
              savedIds: saved, stages: stages))
          .toList();

      if (isDefaultFeed) await _saveCache(items);
      return items;
    } catch (e) {
      // Offline fallback for the default feed
      if (isDefaultFeed && useCache) {
        final cached = await _loadCache();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<List<OpportunityModel>> getFeatured({
    String? universityId,
    int limit = 8,
  }) async {
    var q = _client
        .from('opportunities')
        .select('*')
        .eq('status', 'published')
        .eq('is_featured', true);
    if (universityId != null) {
      q = q.or('university_id.is.null,university_id.eq.$universityId');
    }
    final data = await q.order('created_at', ascending: false).limit(limit);
    return (data as List)
        .map((r) => OpportunityModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Personalised recommendations: matches the student's field of study
  /// (programme) and level, newest first, excluding expired.
  Future<List<OpportunityModel>> getRecommendations({
    required String userId,
    String? programme,
    String? level,
    String? universityId,
    int limit = 12,
  }) async {
    var q = _client
        .from('opportunities')
        .select('*')
        .eq('status', 'published');
    if (universityId != null) {
      q = q.or('university_id.is.null,university_id.eq.$universityId');
    }
    // Match on field tags OR target levels when we know the student's profile.
    final ors = <String>[];
    if (programme != null && programme.isNotEmpty) {
      ors.add('fields.cs.{$programme}');
    }
    if (level != null && level.isNotEmpty) {
      ors.add('levels.cs.{$level}');
    }
    if (ors.isNotEmpty) q = q.or(ors.join(','));

    final data = await q
        .order('is_verified', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    final saved = await _savedIds(userId);
    final stages = await _stages(userId);
    return (data as List)
        .map((r) => OpportunityModel.fromJson(r as Map<String, dynamic>,
            savedIds: saved, stages: stages))
        .toList();
  }

  Future<OpportunityModel?> getOpportunity(String id, {String? userId}) async {
    final data = await _client
        .from('opportunities')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    final saved = userId != null ? await _savedIds(userId) : <String>{};
    final stages = userId != null ? await _stages(userId) : <String, String>{};
    return OpportunityModel.fromJson(data, savedIds: saved, stages: stages);
  }

  Future<void> recordView(String id) async {
    try {
      await _client.rpc('increment_opportunity_view', params: {'p_id': id});
    } catch (_) {/* best-effort */}
  }

  // ── Saves ────────────────────────────────────────────────────

  Future<Set<String>> _savedIds(String userId) async {
    final data = await _client
        .from('opportunity_saves')
        .select('opportunity_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['opportunity_id'] as String).toSet();
  }

  Future<Map<String, String>> _stages(String userId) async {
    final data = await _client
        .from('opportunity_applications')
        .select('opportunity_id, stage')
        .eq('user_id', userId);
    return {
      for (final r in (data as List))
        r['opportunity_id'] as String: r['stage'] as String,
    };
  }

  Future<bool> toggleSave(String opportunityId, String userId) async {
    final existing = await _client
        .from('opportunity_saves')
        .select('opportunity_id')
        .eq('user_id', userId)
        .eq('opportunity_id', opportunityId)
        .maybeSingle();
    if (existing != null) {
      await _client
          .from('opportunity_saves')
          .delete()
          .eq('user_id', userId)
          .eq('opportunity_id', opportunityId);
      return false;
    }
    await _client
        .from('opportunity_saves')
        .insert({'user_id': userId, 'opportunity_id': opportunityId});
    return true;
  }

  Future<List<OpportunityModel>> getSaved(String userId) async {
    final data = await _client
        .from('opportunity_saves')
        .select('opportunity_id, opportunities(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final stages = await _stages(userId);
    return (data as List)
        .map((e) => e['opportunities'])
        .whereType<Map<String, dynamic>>()
        .map((r) => OpportunityModel.fromJson(r,
            savedIds: {r['id'] as String}, stages: stages))
        .toList();
  }

  // ── Application tracking ─────────────────────────────────────

  Future<List<TrackedApplication>> getApplications(String userId) async {
    final data = await _client
        .from('opportunity_applications')
        .select('*, opportunities(*)')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return (data as List)
        .map((r) => TrackedApplication.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> setStage({
    required String userId,
    required String opportunityId,
    required ApplicationStage stage,
    String? notes,
  }) async {
    await _client.from('opportunity_applications').upsert({
      'user_id': userId,
      'opportunity_id': opportunityId,
      'stage': stage.key,
      if (notes != null) 'notes': notes,
      if (stage == ApplicationStage.applied)
        'applied_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,opportunity_id');
  }

  Future<void> removeApplication(String userId, String opportunityId) async {
    await _client
        .from('opportunity_applications')
        .delete()
        .eq('user_id', userId)
        .eq('opportunity_id', opportunityId);
  }

  // ── Deadline reminders (push-notification readiness) ─────────

  Future<void> setReminder({
    required String userId,
    required String opportunityId,
    required DateTime remindAt,
  }) async {
    await _client.from('opportunity_reminders').upsert({
      'user_id': userId,
      'opportunity_id': opportunityId,
      'remind_at': remindAt.toIso8601String(),
    }, onConflict: 'user_id,opportunity_id,remind_at');
  }

  Future<void> clearReminders(String userId, String opportunityId) async {
    await _client
        .from('opportunity_reminders')
        .delete()
        .eq('user_id', userId)
        .eq('opportunity_id', opportunityId);
  }

  Future<bool> hasReminder(String userId, String opportunityId) async {
    final r = await _client
        .from('opportunity_reminders')
        .select('id')
        .eq('user_id', userId)
        .eq('opportunity_id', opportunityId)
        .maybeSingle();
    return r != null;
  }

  /// Upcoming deadlines for opportunities the student has saved or is tracking
  /// (drives the in-app deadline reminder list / local notification scheduling).
  Future<List<OpportunityModel>> getUpcomingDeadlines(String userId) async {
    final saved = await getSaved(userId);
    final tracked = await getApplications(userId);
    final byId = <String, OpportunityModel>{};
    for (final o in saved) {
      if (o.deadline != null && !o.isExpired) byId[o.id] = o;
    }
    for (final t in tracked) {
      final o = t.opportunity;
      if (o != null && o.deadline != null && !o.isExpired) byId[o.id] = o;
    }
    final list = byId.values.toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    return list;
  }

  // ── Reports ──────────────────────────────────────────────────

  Future<void> report({
    required String opportunityId,
    required String reporterId,
    required String reason,
  }) async {
    await _client.from('opportunity_reports').insert({
      'opportunity_id': opportunityId,
      'reporter_id': reporterId,
      'reason': reason,
    });
  }

  // ── Search analytics ─────────────────────────────────────────

  Future<void> logSearch(String? userId, String query, {String? type}) async {
    if (query.trim().isEmpty) return;
    try {
      await _client.from('opportunity_searches').insert({
        if (userId != null) 'user_id': userId,
        'query': query.trim(),
        if (type != null) 'type': type,
      });
    } catch (_) {/* best-effort */}
  }

  // ── Admin: management ────────────────────────────────────────

  Future<String> createOpportunity(Map<String, dynamic> payload) async {
    final row = await _client
        .from('opportunities')
        .insert(payload)
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> updateOpportunity(String id, Map<String, dynamic> patch) async {
    await _client.from('opportunities').update(patch).eq('id', id);
  }

  Future<void> deleteOpportunity(String id) async {
    await _client.from('opportunities').delete().eq('id', id);
  }

  Future<List<OpportunityReportItem>> getReportQueue() async {
    final data = await _client
        .from('opportunity_reports')
        .select('*, opportunities(id, title), '
            'profiles!opportunity_reports_reporter_id_fkey(full_name)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => OpportunityReportItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolveReport(String reportId, String status) async {
    await _client
        .from('opportunity_reports')
        .update({'status': status}).eq('id', reportId);
  }

  Future<OpportunityStats> getStats() async {
    Future<int> count(String column, dynamic value) async {
      final rows = await _client
          .from('opportunities')
          .select('id')
          .eq(column, value);
      return (rows as List).length;
    }

    final typeCounts = <String, int>{};
    try {
      final tc = await _client.rpc('opportunity_type_counts');
      for (final r in (tc as List)) {
        typeCounts[r['type'] as String] = (r['total'] as num).toInt();
      }
    } catch (_) {/* ignore */}

    final topSearches = <String, int>{};
    try {
      final ts = await _client.rpc('top_opportunity_searches');
      for (final r in (ts as List)) {
        topSearches[r['query'] as String] = (r['total'] as num).toInt();
      }
    } catch (_) {/* ignore */}

    final pendingReports = (await _client
            .from('opportunity_reports')
            .select('id')
            .eq('status', 'pending') as List)
        .length;

    // Closing within 7 days
    final soon = DateTime.now().add(const Duration(days: 7));
    final closing = (await _client
            .from('opportunities')
            .select('id')
            .eq('status', 'published')
            .gte('deadline', DateTime.now().toIso8601String())
            .lte('deadline', soon.toIso8601String()) as List)
        .length;

    return OpportunityStats(
      published: await count('status', 'published'),
      closingSoon: closing,
      pendingReports: pendingReports,
      typeCounts: typeCounts,
      topSearches: topSearches,
    );
  }

  // ── Offline cache (Hive) ─────────────────────────────────────

  Future<void> _saveCache(List<OpportunityModel> items) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_feedCacheKey,
          jsonEncode(items.map((o) => o.toCache()).toList()));
    } catch (_) {/* non-fatal */}
  }

  Future<List<OpportunityModel>?> _loadCache() async {
    try {
      final box = await Hive.openBox(_boxName);
      final raw = box.get(_feedCacheKey) as String?;
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => OpportunityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
