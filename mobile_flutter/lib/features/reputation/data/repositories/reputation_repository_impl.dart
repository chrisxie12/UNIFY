import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/reputation_repository.dart';
import '../models/reputation_models.dart';

class ReputationRepositoryImpl implements ReputationRepository {
  final SupabaseClient _client;

  ReputationRepositoryImpl(this._client);

  // ── Reputation Score ──────────────────────────────────────

  @override
  Future<ReputationScore?> getReputationScore(String userId) async {
    final data = await _client
        .from('reputation_scores')
        .select()
        .filter('user_id', 'eq', userId)
        .maybeSingle();
    if (data == null) return null;
    return ReputationScore.fromJson(data);
  }

  @override
  Future<List<ReputationEvent>> getReputationEvents(String userId, {int limit = 50}) async {
    final data = await _client
        .from('reputation_events')
        .select()
        .filter('user_id', 'eq', userId)
        .order('created_at', ascending: false)
        .limit(limit) as List;
    return data.map((j) => ReputationEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  // ── Achievements ──────────────────────────────────────────

  @override
  Future<List<AchievementDefinition>> getAchievementDefinitions() async {
    final data = await _client
        .from('achievement_definitions')
        .select()
        .limit(100)
        .order('points', ascending: false) as List;
    if (data.length == 100) {
      debugPrint('[ReputationRepositoryImpl] getAchievementDefinitions: result set truncated at 100');
    }
    return data.map((j) => AchievementDefinition.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final data = await _client
        .from('user_achievements')
        .select('*, achievement:achievement_id(*)')
        .filter('user_id', 'eq', userId)
        .order('unlocked_at', ascending: false)
        .limit(100) as List;
    return data.map((j) => UserAchievement.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> checkAndAwardAchievements(String userId) async {
    try {
      final allDefs = await getAchievementDefinitions();
      final userAchievements = await getUserAchievements(userId);
      final awardedSlugs = userAchievements.map((a) => a.achievement.slug).toSet();

      for (final def in allDefs) {
        if (awardedSlugs.contains(def.slug)) continue;
        final criteria = def.criteria;
        if (criteria == null) continue;

        final type = criteria['type'] as String?;
        bool earned = false;

        if (type == 'count') {
          final table = criteria['table'] as String?;
          if (table == null) continue;
          final threshold = criteria['threshold'] as int? ?? 1;
          dynamic query = _client.from(table).select();
          if (criteria.containsKey('where')) {
            final whereClause = criteria['where'] as String;
            final parts = whereClause.split(' ');
            if (parts.length >= 3) {
              query = query.filter(parts[0], parts[1], parts[2]);
            }
          }
          if (table != 'community_members' && table != 'event_tickets') {
            query = query.filter('user_id', 'eq', userId);
          }
          query = query.limit(100);
          final result = await query;
          final count = (result as List).length;
          if (count >= threshold) earned = true;
        }

        if (type == 'role') {
          final role = criteria['role'] as String?;
          if (role != null) {
            final result = await _client
                .from('user_leadership')
                .select('id')
                .filter('user_id', 'eq', userId)
                .filter('role_id', 'eq', role)
                .maybeSingle();
            if (result != null) earned = true;
          }
        }

        if (type == 'custom') {
          final description = criteria['description'] as String?;
          if (description == 'Reach 100 reputation score') {
            final score = await getReputationScore(userId);
            if (score != null && score.score >= 100) earned = true;
          }
        }

        if (earned) {
          await _client.from('user_achievements').insert({
            'user_id': userId, 'achievement_id': def.id,
          });
          if (def.points > 0) {
            await _addReputationPoints(userId, def.points, 'achievement_${def.slug}',
                referenceType: 'achievement', referenceId: def.id,
                description: 'Earned "${def.title}" achievement');
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  Future<void> _addReputationPoints(String userId, int points, String eventType,
      {String? referenceType, String? referenceId, String? description}) async {
    await _client.from('reputation_events').insert({
      'user_id': userId, 'event_type': eventType, 'points': points,
      'reference_type': referenceType, 'reference_id': referenceId,
      'description': description,
    });

    final existing = await _client
        .from('reputation_scores')
        .select('score')
        .filter('user_id', 'eq', userId)
        .maybeSingle();
    final newScore = (existing != null ? (existing['score'] as int? ?? 0) : 0) + points;
    final newLevel = _calculateLevel(newScore);

    await _client.from('reputation_scores').upsert({
      'user_id': userId, 'score': newScore, 'level': newLevel,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  String _calculateLevel(int score) {
    if (score >= 2500) return 'diamond';
    if (score >= 1000) return 'platinum';
    if (score >= 500) return 'gold';
    if (score >= 200) return 'silver';
    if (score >= 50) return 'bronze';
    return 'beginner';
  }

  // ── Skills ────────────────────────────────────────────────

  @override
  Future<List<UserSkill>> getUserSkills(String userId) async {
    final data = await _client
        .from('user_skills')
        .select('*, endorsement_count:skill_endorsements(count)')
        .filter('user_id', 'eq', userId)
        .order('skill_name', ascending: true)
        .limit(100) as List;
    return data.map((j) {
      final map = j as Map<String, dynamic>;
      final countResult = map['endorsement_count'] as Map<String, dynamic>?;
      if (countResult != null) map['endorsement_count'] = countResult['count'] as int? ?? 0;
      return UserSkill.fromJson(map);
    }).toList();
  }

  @override
  Future<UserSkill> addSkill(String userId, String skillName, {String proficiency = 'beginner'}) async {
    final data = await _client.from('user_skills').insert({
      'user_id': userId, 'skill_name': skillName, 'proficiency_level': proficiency,
    }).select().single();
    return UserSkill.fromJson(data);
  }

  @override
  Future<bool> updateSkillProficiency(String skillId, String proficiency) async {
    try {
      await _client.from('user_skills').update({'proficiency_level': proficiency}).filter('id', 'eq', skillId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> removeSkill(String skillId) async {
    try {
      await _client.from('user_skills').delete().filter('id', 'eq', skillId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Endorsements ──────────────────────────────────────────

  @override
  Future<List<SkillEndorsement>> getSkillEndorsements(String skillId) async {
    final data = await _client
        .from('skill_endorsements')
        .select('*, profiles!endorsed_by(display_name, avatar_url)')
        .filter('skill_id', 'eq', skillId)
        .order('created_at', ascending: false)
        .limit(100) as List;
    return data.map((j) {
      final map = j as Map<String, dynamic>;
      final profile = map['profiles'] as Map<String, dynamic>?;
      if (profile != null) {
        map['endorser_name'] = profile['display_name'];
        map['endorser_avatar'] = profile['avatar_url'];
      }
      return SkillEndorsement.fromJson(map);
    }).toList();
  }

  @override
  Future<bool> endorseSkill(String skillId, String endorserId, {String? message}) async {
    try {
      await _client.from('skill_endorsements').insert({
        'skill_id': skillId, 'endorsed_by': endorserId, 'message': message,
      });
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> removeEndorsement(String endorsementId) async {
    try {
      await _client.from('skill_endorsements').delete().filter('id', 'eq', endorsementId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Contributions ─────────────────────────────────────────

  @override
  Future<List<Contribution>> getUserContributions(String userId, {int limit = 50}) async {
    final data = await _client
        .from('contribution_log')
        .select()
        .filter('user_id', 'eq', userId)
        .order('created_at', ascending: false)
        .limit(limit) as List;
    return data.map((j) => Contribution.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> logContribution(String userId, String type,
      {String? referenceType, String? referenceId, String? label}) async {
    await _client.from('contribution_log').insert({
      'user_id': userId, 'contribution_type': type,
      'reference_type': referenceType, 'reference_id': referenceId, 'label': label,
    });
    // Award small rep points for contributions
    const pointValues = {'post': 5, 'resource': 10, 'event': 15, 'comment': 3, 'marketplace': 8, 'volunteer': 20};
    final points = pointValues[type] ?? 5;
    if (points > 0) {
      await _addReputationPoints(userId, points, 'contribution_$type',
          referenceType: referenceType, referenceId: referenceId,
          description: 'Contributed: ${_contributionLabel(type)}');
    }
  }

  String _contributionLabel(String type) {
    switch (type) {
      case 'post': return 'Created a post';
      case 'resource': return 'Uploaded a resource';
      case 'event': return 'Organized an event';
      case 'comment': return 'Posted a comment';
      case 'marketplace': return 'Listed an item';
      case 'volunteer': return 'Volunteer activity';
      default: return type;
    }
  }

  // ── Portfolio Projects ────────────────────────────────────

  @override
  Future<List<PortfolioProject>> getPortfolioProjects(String userId) async {
    final data = await _client
        .from('portfolio_projects')
        .select()
        .filter('user_id', 'eq', userId)
        .order('created_at', ascending: false)
        .limit(50) as List;
    return data.map((j) => PortfolioProject.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<PortfolioProject> addProject(PortfolioProject project) async {
    final data = await _client
        .from('portfolio_projects')
        .insert(project.toInsertJson())
        .select()
        .single();
    return PortfolioProject.fromJson(data);
  }

  @override
  Future<bool> updateProject(String projectId, Map<String, dynamic> updates) async {
    try {
      await _client.from('portfolio_projects').update(updates).filter('id', 'eq', projectId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteProject(String projectId) async {
    try {
      await _client.from('portfolio_projects').delete().filter('id', 'eq', projectId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Leadership History ────────────────────────────────────

  @override
  Future<List<LeadershipHistory>> getLeadershipHistory(String userId) async {
    final data = await _client
        .from('leadership_history')
        .select()
        .filter('user_id', 'eq', userId)
        .order('start_date', ascending: false)
        .limit(50) as List;
    return data.map((j) => LeadershipHistory.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<LeadershipHistory> addLeadershipEntry(LeadershipHistory entry) async {
    final data = await _client
        .from('leadership_history')
        .insert(entry.toInsertJson())
        .select()
        .single();
    return LeadershipHistory.fromJson(data);
  }

  @override
  Future<bool> updateLeadershipEntry(String entryId, Map<String, dynamic> updates) async {
    try {
      await _client.from('leadership_history').update(updates).filter('id', 'eq', entryId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteLeadershipEntry(String entryId) async {
    try {
      await _client.from('leadership_history').delete().filter('id', 'eq', entryId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Certificates ──────────────────────────────────────────

  @override
  Future<List<UserCertificate>> getUserCertificates(String userId) async {
    final data = await _client
        .from('user_certificates')
        .select()
        .filter('user_id', 'eq', userId)
        .order('created_at', ascending: false)
        .limit(50) as List;
    return data.map((j) => UserCertificate.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserCertificate> addCertificate(UserCertificate certificate) async {
    final data = await _client
        .from('user_certificates')
        .insert(certificate.toInsertJson())
        .select()
        .single();
    return UserCertificate.fromJson(data);
  }

  @override
  Future<bool> deleteCertificate(String certificateId) async {
    try {
      await _client.from('user_certificates').delete().filter('id', 'eq', certificateId);
      return true;
    } catch (e) {
      debugPrint('[ReputationRepositoryImpl] Error: $e');
      return false;
    }
  }

  // ── Summary ───────────────────────────────────────────────

  @override
  Future<ReputationSummary> getReputationSummary(String userId) async {
    final score = await getReputationScore(userId) ?? ReputationScore(userId: userId, updatedAt: DateTime.now());
    final achievements = await getUserAchievements(userId);
    final skills = await getUserSkills(userId);
    final contributions = await getUserContributions(userId, limit: 1000);
    final certs = await getUserCertificates(userId);
    final leadership = await getLeadershipHistory(userId);

    final contributionsByType = <String, int>{};
    for (final c in contributions) {
      contributionsByType[c.contributionType] = (contributionsByType[c.contributionType] ?? 0) + 1;
    }
    var totalEndorsements = 0;
    for (final skill in skills) {
      totalEndorsements += skill.endorsementCount;
    }

    return ReputationSummary(
      score: score,
      achievements: achievements,
      skills: skills,
      totalContributions: contributions.length,
      contributionsByType: contributionsByType,
      endorsementCount: totalEndorsements,
      certificateCount: certs.length,
      leadershipCount: leadership.length,
    );
  }
}
