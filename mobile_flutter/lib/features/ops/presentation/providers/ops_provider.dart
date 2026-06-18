import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/ops_models.dart';
import '../../data/repositories/ops_repository_impl.dart';

final opsRepositoryProvider = Provider<OpsRepository>((ref) {
  return OpsRepository(ref.watch(supabaseProvider));
});

final opsOverviewProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(opsRepositoryProvider).overview();
});

final dauSeriesProvider =
    FutureProvider.autoDispose<List<DauPoint>>((ref) async {
  return ref.read(opsRepositoryProvider).dauSeries(days: 14);
});

final featureAdoptionProvider =
    FutureProvider.autoDispose<List<FeatureAdoption>>((ref) async {
  return ref.read(opsRepositoryProvider).featureAdoption(days: 30);
});

final retentionProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(opsRepositoryProvider).retention();
});

final launchReadinessProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(opsRepositoryProvider).launchReadiness();
});

final systemHealthProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(opsRepositoryProvider).systemHealth();
});

final recentErrorsProvider =
    FutureProvider.autoDispose<List<ErrorLogEntry>>((ref) async {
  return ref.read(opsRepositoryProvider).recentErrors(limit: 20);
});
