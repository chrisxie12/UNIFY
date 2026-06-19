import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/leadership_provider.dart';
import '../../data/models/announcement_request_model.dart';
import '../../data/models/community_request_model.dart';
import '../../data/models/user_badge_model.dart';

class ClassRepDashboardScreen extends ConsumerWidget {
  const ClassRepDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final leadershipAsync = ref.watch(userLeadershipProvider);
    final myRequestsAsync = ref.watch(myCommunityRequestsProvider);
    final announcementReqsAsync = ref.watch(myAnnouncementRequestsProvider);
    final badgesAsync = ref.watch(userBadgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leadership Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_rounded),
            tooltip: 'Request Verification',
            onPressed: () => context.push('/verification-request'),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            tooltip: 'Request Community',
            onPressed: () => context.push('/community-request'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(userLeadershipProvider);
          ref.invalidate(myCommunityRequestsProvider);
          ref.invalidate(myAnnouncementRequestsProvider);
          ref.invalidate(userBadgesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LeadershipHeader(
              profile: profileAsync.valueOrNull,
              leadership: leadershipAsync.valueOrNull ?? [],
              badges: badgesAsync.valueOrNull ?? [],
            ),
            const SizedBox(height: 20),

            Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ActionCard(
                  icon: Icons.group_add_rounded,
                  label: 'New\nCommunity',
                  color: context.primary,
                  onTap: () => context.push('/community-request'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _ActionCard(
                  icon: Icons.campaign_rounded,
                  label: 'New\nAnnouncement',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/announcement-request'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _ActionCard(
                  icon: Icons.verified_user_rounded,
                  label: 'Get\nVerified',
                  color: const Color(0xFF059669),
                  onTap: () => context.push('/verification-request'),
                )),
              ],
            ),
            const SizedBox(height: 24),

            Text('My Community Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 12),
            myRequestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) return const _EmptyCard('No community requests yet');
                return Column(
                  children: requests.take(3).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RequestSummaryCard(request: r),
                  )).toList(),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            ),
            const SizedBox(height: 20),

            Text('My Announcement Requests', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 12),
            announcementReqsAsync.when(
              data: (requests) {
                if (requests.isEmpty) return const _EmptyCard('No announcement requests yet');
                return Column(
                  children: requests.take(3).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AnnouncementSummaryCard(request: r),
                  )).toList(),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            ),
            const SizedBox(height: 24),

            Text('Your Badges', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 12),
            badgesAsync.when(
              data: (badges) {
                if (badges.isEmpty) return const _EmptyCard('No badges yet');
                return Wrap(
                  spacing: 8, runSpacing: 8,
                  children: badges.map((b) => _BadgeChip(badge: b.badge)).toList(),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Leadership Header ────────────────────────────────────────

class _LeadershipHeader extends StatelessWidget {
  final Profile? profile;
  final List<UserLeadershipModel> leadership;
  final List<UserBadgeModel> badges;

  const _LeadershipHeader({this.profile, required this.leadership, required this.badges});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primary, context.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: context.cardBg.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p?.initials ?? 'U',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p?.displayName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    if (leadership.isNotEmpty)
                      Text(leadership.first.role.title, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              if (badges.any((b) => b.badge.slug == 'class_rep'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFFFFD700)),
                      SizedBox(width: 4),
                      Text('CLASS REP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFFD700))),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (p != null) ...[
            Row(
              children: [
                _infoChip(context, Icons.school_rounded, p.programme ?? 'N/A'),
                const SizedBox(width: 8),
                _infoChip(context, Icons.grade_rounded, p.yearOfStudy != null ? 'Level ${p.yearOfStudy}' : 'N/A'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (p.department != null) _infoChip(context, Icons.account_tree_rounded, p.department!),
                if (p.department != null) const SizedBox(width: 8),
                if (p.faculty != null) _infoChip(context, Icons.business_rounded, p.faculty!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: context.cardBg.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// ── Action Card ──────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textPrimary, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Request Summary Card ─────────────────────────────────────

class _RequestSummaryCard extends StatelessWidget {
  final CommunityRequestModel request;
  const _RequestSummaryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.group_rounded, color: context.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.communityName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
                const SizedBox(height: 2),
                Text(_typeLabel(request.communityType), style: TextStyle(fontSize: 11, color: context.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(request.status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
    'class' => 'Class Community',
    'level' => 'Level Community',
    'course' => 'Course Community',
    'programme' => 'Programme Community',
    'department' => 'Department Community',
    'faculty' => 'Faculty Community',
    'hostel' => 'Hostel Community',
    'hall' => 'Hall Community',
    'residence' => 'Residence Community',
    'club' => 'Club',
    'university' => 'University Community',
    'church' => 'Church Community',
    'sports' => 'Sports Community',
    'entrepreneurship' => 'Entrepreneurship',
    'technology' => 'Technology',
    'gaming' => 'Gaming',
    'photography' => 'Photography',
    'music' => 'Music',
    'campus_jobs' => 'Campus Jobs',
    'scholarships' => 'Scholarships',
    _ => type,
  };
}

// ── Announcement Summary Card ────────────────────────────────

class _AnnouncementSummaryCard extends StatelessWidget {
  final AnnouncementRequestModel request;
  const _AnnouncementSummaryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };
    final catIcon = switch (request.category) {
      'lecture' => Icons.menu_book_rounded,
      'quiz' => Icons.quiz_rounded,
      'assignment' => Icons.assignment_rounded,
      'project' => Icons.build_rounded,
      'seminar' => Icons.groups_rounded,
      'workshop' => Icons.handyman_rounded,
      'exam' => Icons.fact_check_rounded,
      'emergency' => Icons.warning_amber_rounded,
      _ => Icons.campaign_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(catIcon, color: const Color(0xFF8B5CF6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(request.category[0].toUpperCase() + request.category.substring(1), style: TextStyle(fontSize: 11, color: context.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(request.status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final dynamic badge;
  const _BadgeChip({required this.badge});

  Color get _color {
    switch (badge.slug) {
      case 'verified_student':
        return AppColors.primary;
      case 'class_rep':
        return const Color(0xFFFFD700);
      case 'src_executive':
        return const Color(0xFF7C3AED);
      case 'admin':
        return const Color(0xFFDC2626);
      default:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (badge.slug) {
      case 'verified_student':
        return Icons.verified_rounded;
      case 'class_rep':
        return Icons.verified_rounded;
      case 'src_executive':
        return Icons.verified_rounded;
      case 'admin':
        return Icons.shield_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 5),
          Text(badge.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderCol),
      ),
      child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: context.textSecondary)),
    );
  }
}
