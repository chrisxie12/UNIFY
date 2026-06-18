import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ops_models.dart';

/// Repository for OPS analytics, system health and launch readiness.
///
/// All analytics figures come from pre-built Postgres RPCs; recent errors are
/// read directly from the error_logs table.
class OpsRepository {
  final SupabaseClient _client;

  OpsRepository(this._client);

  // ── Usage analytics ────────────────────────────────────────

  /// {dau, wau, mau, avg_session_seconds, sessions_7d, new_users_7d,
  ///  new_users_30d, total_users}
  Future<Map<String, dynamic>> overview() async {
    final res = await _client.rpc('analytics_overview');
    return (res as Map).cast<String, dynamic>();
  }

  Future<List<DauPoint>> dauSeries({int days = 14}) async {
    final res = await _client.rpc('dau_series', params: {'days': days});
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(DauPoint.fromJson).toList();
  }

  Future<List<FeatureAdoption>> featureAdoption({int days = 30}) async {
    final res = await _client.rpc('feature_adoption', params: {'days': days});
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(FeatureAdoption.fromJson).toList();
  }

  /// {cohort_size, returned_d1, returned_d7}
  Future<Map<String, dynamic>> retention() async {
    final res = await _client.rpc('retention_summary');
    return (res as Map).cast<String, dynamic>();
  }

  // ── Launch readiness ───────────────────────────────────────

  Future<Map<String, dynamic>> launchReadiness() async {
    final res = await _client.rpc('launch_readiness');
    return (res as Map).cast<String, dynamic>();
  }

  // ── System health ──────────────────────────────────────────

  Future<Map<String, dynamic>> systemHealth() async {
    final res = await _client.rpc('system_health');
    return (res as Map).cast<String, dynamic>();
  }

  Future<List<ErrorLogEntry>> recentErrors({int limit = 20}) async {
    final res = await _client
        .from('error_logs')
        .select('*')
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List)
        .map((row) => ErrorLogEntry.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
