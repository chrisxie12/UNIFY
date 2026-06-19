import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/system_models.dart';
import '../../data/repositories/feature_flags_repository.dart';

final featureFlagsRepositoryProvider = Provider<FeatureFlagsRepository>((ref) {
  return FeatureFlagsRepository(ref.watch(supabaseProvider));
});

final allFeatureFlagsProvider =
    FutureProvider.autoDispose<List<FeatureFlag>>((ref) async {
  final repo = ref.watch(featureFlagsRepositoryProvider);
  return repo.getAll();
});

/// Whether a specific feature is enabled. Returns true if the flag row does
/// not exist (fail-open so missing flags don't break existing functionality).
final featureFlagEnabledProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, key) async {
  final flags = await ref.watch(allFeatureFlagsProvider.future);
  final match = flags.where((f) => f.key == key);
  if (match.isEmpty) return true;
  return match.first.enabled;
});
