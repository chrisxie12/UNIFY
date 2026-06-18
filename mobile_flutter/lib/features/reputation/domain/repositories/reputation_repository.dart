import '../../data/models/reputation_models.dart';

abstract class ReputationRepository {
  // ── Reputation Score ──────────────────────────────────────
  Future<ReputationScore?> getReputationScore(String userId);
  Future<List<ReputationEvent>> getReputationEvents(String userId, {int limit = 50});

  // ── Achievements ──────────────────────────────────────────
  Future<List<AchievementDefinition>> getAchievementDefinitions();
  Future<List<UserAchievement>> getUserAchievements(String userId);
  Future<bool> checkAndAwardAchievements(String userId);

  // ── Skills ────────────────────────────────────────────────
  Future<List<UserSkill>> getUserSkills(String userId);
  Future<UserSkill> addSkill(String userId, String skillName, {String proficiency = 'beginner'});
  Future<bool> updateSkillProficiency(String skillId, String proficiency);
  Future<bool> removeSkill(String skillId);

  // ── Endorsements ──────────────────────────────────────────
  Future<List<SkillEndorsement>> getSkillEndorsements(String skillId);
  Future<bool> endorseSkill(String skillId, String endorserId, {String? message});
  Future<bool> removeEndorsement(String endorsementId);

  // ── Contributions ─────────────────────────────────────────
  Future<List<Contribution>> getUserContributions(String userId, {int limit = 50});
  Future<void> logContribution(String userId, String type, {String? referenceType, String? referenceId, String? label});

  // ── Portfolio Projects ────────────────────────────────────
  Future<List<PortfolioProject>> getPortfolioProjects(String userId);
  Future<PortfolioProject> addProject(PortfolioProject project);
  Future<bool> updateProject(String projectId, Map<String, dynamic> updates);
  Future<bool> deleteProject(String projectId);

  // ── Leadership History ────────────────────────────────────
  Future<List<LeadershipHistory>> getLeadershipHistory(String userId);
  Future<LeadershipHistory> addLeadershipEntry(LeadershipHistory entry);
  Future<bool> updateLeadershipEntry(String entryId, Map<String, dynamic> updates);
  Future<bool> deleteLeadershipEntry(String entryId);

  // ── Certificates ──────────────────────────────────────────
  Future<List<UserCertificate>> getUserCertificates(String userId);
  Future<UserCertificate> addCertificate(UserCertificate certificate);
  Future<bool> deleteCertificate(String certificateId);

  // ── Summary ───────────────────────────────────────────────
  Future<ReputationSummary> getReputationSummary(String userId);
}
