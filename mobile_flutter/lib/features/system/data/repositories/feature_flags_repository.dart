import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/system_models.dart';

class FeatureFlagsRepository {
  final SupabaseClient _client;
  FeatureFlagsRepository(this._client);

  Future<List<FeatureFlag>> getAll() async {
    final data = await _client
        .from('feature_flags')
        .select('id, key, label, description, enabled')
        .order('label');
    return (data as List).map((j) => FeatureFlag.fromJson(j)).toList();
  }

  Future<void> toggle(String id, bool enabled) async {
    await _client
        .from('feature_flags')
        .update({'enabled': enabled, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
    await _logAction(
      _client.auth.currentUser?.id ?? '',
      enabled ? 'enable_feature_flag' : 'disable_feature_flag',
      'feature_flag',
      id,
    );
  }

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
}
