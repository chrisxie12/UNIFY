import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/report_repository.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final SupabaseClient _client;

  ReportRepositoryImpl(this._client);

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    final response = await _client
        .from('reports')
        .insert(report.toInsertJson())
        .select()
        .single();
    return ReportModel.fromJson(response);
  }

  @override
  Future<List<ReportModel>> getReports({String? status}) async {
    final response = await _client
        .from('reports')
        .select('*')
        .order('created_at', ascending: false) as List;

    if (status != null && status != 'all') {
      return response
          .where((r) => r['status'] == status)
          .map((json) => ReportModel.fromJson(json))
          .toList();
    }

    return response.map((json) => ReportModel.fromJson(json)).toList();
  }

  @override
  Future<List<ReportModel>> getMyReports(String userId) async {
    final response = await _client
        .from('reports')
        .select('*')
        .order('created_at', ascending: false) as List;

    return response
        .where((r) => r['reporter_id'] == userId)
        .map((json) => ReportModel.fromJson(json))
        .toList();
  }

  @override
  Future<bool> updateReportStatus(String reportId, String status, {String? adminNotes, String? resolvedBy}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };
      if (adminNotes != null) updates['admin_notes'] = adminNotes;
      if (status == 'resolved' || status == 'dismissed') {
        updates['resolved_by'] = resolvedBy;
        updates['resolved_at'] = DateTime.now().toIso8601String();
      }
      await _client.from('reports').update(updates).filter('id', 'eq', reportId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
