import '../models/report_model.dart';

abstract class ReportRepository {
  Future<ReportModel> createReport(ReportModel report);
  Future<List<ReportModel>> getReports({String? status});
  Future<List<ReportModel>> getMyReports(String userId);
  Future<bool> updateReportStatus(String reportId, String status, {String? adminNotes, String? resolvedBy});
}
