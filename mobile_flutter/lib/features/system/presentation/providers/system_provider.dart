import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/analytics_service.dart';
import '../../data/models/system_models.dart';
import '../../data/repositories/system_repository_impl.dart';

/// Repository provider for the SYSTEM module.
final systemRepositoryProvider = Provider<SystemRepositoryImpl>((ref) {
  return SystemRepositoryImpl(ref.watch(supabaseProvider));
});

/// Active announcements for the current user, minus any they've dismissed.
final activeAnnouncementsProvider =
    FutureProvider.autoDispose<List<SystemAnnouncement>>((ref) async {
  final repo = ref.watch(systemRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  final active = await repo.getActiveAnnouncements();
  if (user == null) return active;

  final dismissed = await repo.getDismissedIds(user.id);
  if (dismissed.isEmpty) return active;

  final dismissedSet = dismissed.toSet();
  return active.where((a) => !dismissedSet.contains(a.id)).toList();
});

/// All announcements (admin view).
final allAnnouncementsProvider =
    FutureProvider.autoDispose<List<SystemAnnouncement>>((ref) async {
  final repo = ref.watch(systemRepositoryProvider);
  return repo.getAllAnnouncements();
});

/// All app versions (admin view).
final appVersionsProvider =
    FutureProvider.autoDispose<List<AppVersionInfo>>((ref) async {
  final repo = ref.watch(systemRepositoryProvider);
  return repo.getAppVersions();
});

/// Computes whether the running build needs an update for the current platform.
final appUpdateProvider =
    FutureProvider.autoDispose<AppUpdateStatus>((ref) async {
  final repo = ref.watch(systemRepositoryProvider);
  final latest = await repo.latestVersion(AnalyticsService.platform);

  if (latest == null) return AppUpdateStatus.none();

  final current = AppConstants.appBuildNumber;
  if (current < latest.minSupportedBuild) {
    return AppUpdateStatus(level: AppUpdateLevel.required, version: latest);
  }
  if (current < latest.buildNumber) {
    return AppUpdateStatus(level: AppUpdateLevel.optional, version: latest);
  }
  return AppUpdateStatus(level: AppUpdateLevel.none, version: latest);
});
