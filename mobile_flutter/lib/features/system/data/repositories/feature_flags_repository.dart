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
  }
}
