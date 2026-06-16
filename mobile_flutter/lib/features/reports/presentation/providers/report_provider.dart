import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/models/report_model.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(Supabase.instance.client);
});

final reportsProvider = FutureProvider.family<List<ReportModel>, String?>((ref, status) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getReports(status: status);
});

final myReportsProvider = FutureProvider.family<List<ReportModel>, String>((ref, userId) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getMyReports(userId);
});
