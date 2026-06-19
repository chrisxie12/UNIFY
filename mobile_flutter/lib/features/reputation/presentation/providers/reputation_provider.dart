import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/reputation_repository_impl.dart';
import '../../domain/repositories/reputation_repository.dart';
import '../../data/models/reputation_models.dart';

final reputationRepositoryProvider = Provider<ReputationRepository>((ref) {
  return ReputationRepositoryImpl(ref.watch(supabaseProvider));
});

final currentUserIdProvider2 = Provider<String?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

// ── Reputation Score ─────────────────────────────────────────

final reputationScoreProvider = FutureProvider.family<ReputationScore?, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getReputationScore(userId);
});

final reputationEventsProvider = FutureProvider.family<List<ReputationEvent>, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getReputationEvents(userId);
});

final reputationSummaryProvider = FutureProvider.family<ReputationSummary, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getReputationSummary(userId);
});

// ── Achievements ─────────────────────────────────────────────

final achievementDefinitionsProvider = FutureProvider<List<AchievementDefinition>>((ref) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getAchievementDefinitions();
});

final userAchievementsProvider = FutureProvider.family<List<UserAchievement>, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getUserAchievements(userId);
});

// ── Skills ───────────────────────────────────────────────────

final userSkillsProvider = FutureProvider.family<List<UserSkill>, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getUserSkills(userId);
});

// ── Portfolio Projects ───────────────────────────────────────

final portfolioProjectsProvider = FutureProvider.family<List<PortfolioProject>, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getPortfolioProjects(userId);
});

// ── Leadership History ───────────────────────────────────────

final leadershipHistoryProvider = FutureProvider.family<List<LeadershipHistory>, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getLeadershipHistory(userId);
});

// ── Certificates ─────────────────────────────────────────────

final userCertificatesProvider = FutureProvider.family<List<UserCertificate>, String>((ref, userId) async {
  final repo = ref.watch(reputationRepositoryProvider);
  return repo.getUserCertificates(userId);
});

// ── Notifier ─────────────────────────────────────────────────

class ReputationNotifier extends AsyncNotifier<void> {
  late ReputationRepository _repo;

  @override
  Future<void> build() async {
    _repo = ref.watch(reputationRepositoryProvider);
  }

  Future<bool> addSkill(String skillName, {String proficiency = 'beginner'}) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.addSkill(userId, skillName, proficiency: proficiency);
      ref.invalidate(userSkillsProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> removeSkill(String skillId) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.removeSkill(skillId);
      ref.invalidate(userSkillsProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> updateProficiency(String skillId, String proficiency) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.updateSkillProficiency(skillId, proficiency);
      ref.invalidate(userSkillsProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> endorseSkill(String skillId) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      return await _repo.endorseSkill(skillId, userId);
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> addProject(PortfolioProject project) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.addProject(project);
      ref.invalidate(portfolioProjectsProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.deleteProject(projectId);
      ref.invalidate(portfolioProjectsProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> addLeadershipEntry(LeadershipHistory entry) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.addLeadershipEntry(entry);
      ref.invalidate(leadershipHistoryProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> deleteLeadershipEntry(String entryId) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.deleteLeadershipEntry(entryId);
      ref.invalidate(leadershipHistoryProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> addCertificate(UserCertificate certificate) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.addCertificate(certificate);
      ref.invalidate(userCertificatesProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> deleteCertificate(String certificateId) async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.deleteCertificate(certificateId);
      ref.invalidate(userCertificatesProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }

  Future<bool> checkAndAwardAchievements() async {
    final userId = ref.read(currentUserIdProvider2);
    if (userId == null) return false;
    try {
      await _repo.checkAndAwardAchievements(userId);
      ref.invalidate(userAchievementsProvider(userId));
      ref.invalidate(reputationScoreProvider(userId));
      return true;
    } catch (e) {
      debugPrint('[ReputationNotifier] Error: $e');
      return false;
    }
  }
}

final reputationNotifierProvider = AsyncNotifierProvider<ReputationNotifier, void>(ReputationNotifier.new);
