import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/reputation_models.dart';
import '../providers/reputation_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_loading_widget.dart';

class ReputationDashboardScreen extends ConsumerWidget {
  final String? targetUserId;

  const ReputationDashboardScreen({super.key, this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = targetUserId ?? ref.watch(currentUserIdProvider2) ?? '';
    final summaryAsync = ref.watch(reputationSummaryProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reputation'),
        actions: [
          if (targetUserId == null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Check achievements',
              onPressed: () => ref.read(reputationNotifierProvider.notifier).checkAndAwardAchievements(),
            ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => _DashboardContent(summary: summary, ref: ref, userId: userId),
        loading: () => const AppLoadingWidget.card(),
        error: (err, _) => AppErrorWidget(err),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final ReputationSummary summary;
  final WidgetRef ref;
  final String userId;

  const _DashboardContent({
    required this.summary, required this.ref, required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final score = summary.score;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TrustScoreCard(score: score),
          const SizedBox(height: 20),
          _StatsRow(summary: summary),
          const SizedBox(height: 20),
          _AchievementsSection(achievements: summary.achievements),
          const SizedBox(height: 20),
          _SkillsPreview(skills: summary.skills, ref: ref, userId: userId),
          const SizedBox(height: 20),
          _ContributionsSection(summary: summary),
          const SizedBox(height: 20),
          _ActivitySection(userId: userId, ref: ref),
        ],
      ),
    );
  }
}

class _TrustScoreCard extends StatelessWidget {
  final ReputationScore score;

  const _TrustScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            score.levelLabel,
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.cardBg, fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.score} pts',
            style: theme.textTheme.displaySmall?.copyWith(
              color: context.cardBg, fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score.levelProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score.level == 'diamond'
                ? 'Maximum level reached!'
                : 'Progress to next level',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ReputationSummary summary;

  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = [
      _StatItem(icon: Icons.emoji_events_rounded, label: 'Achievements', value: '${summary.achievements.length}'),
      _StatItem(icon: Icons.handyman_rounded, label: 'Skills', value: '${summary.skills.length}'),
      _StatItem(icon: Icons.thumb_up_rounded, label: 'Endorsements', value: '${summary.endorsementCount}'),
      _StatItem(icon: Icons.history_rounded, label: 'Contributions', value: '${summary.totalContributions}'),
      _StatItem(icon: Icons.workspace_premium_rounded, label: 'Certificates', value: '${summary.certificateCount}'),
      _StatItem(icon: Icons.groups_rounded, label: 'Leadership', value: '${summary.leadershipCount}'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stats.map((s) => SizedBox(
        width: (MediaQuery.of(context).size.width - 48) / 3,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(s.icon, color: theme.colorScheme.primary, size: 22),
                const SizedBox(height: 4),
                Text(s.value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(s.label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.label, required this.value});
}

class _AchievementsSection extends StatelessWidget {
  final List<UserAchievement> achievements;

  const _AchievementsSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Achievements', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('${achievements.length}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 8),
        if (achievements.isEmpty)
          const AppEmptyWidget(
            icon: Icons.emoji_events_outlined,
            title: 'No achievements yet',
            subtitle: 'Participate to earn badges',
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final a = achievements[i];
                return Container(
                  width: 90,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_rounded, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(height: 4),
                      Text(a.achievement.title, style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SkillsPreview extends StatelessWidget {
  final List<UserSkill> skills;
  final WidgetRef ref;
  final String userId;

  const _SkillsPreview({required this.skills, required this.ref, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Skills', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Manage'),
              onPressed: () => context.push('/reputation/skills'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (skills.isEmpty)
          const AppEmptyWidget(
            icon: Icons.psychology_rounded,
            title: 'No skills added yet. Tap Manage to add your skills.',
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills.take(10).map((s) => Chip(
              label: Text('${s.skillName}  •  ${s.proficiencyLabel}', style: theme.textTheme.bodySmall),
              avatar: Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
      ],
    );
  }
}

class _ContributionsSection extends StatelessWidget {
  final ReputationSummary summary;

  const _ContributionsSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contributions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (summary.contributionsByType.isEmpty)
          const AppEmptyWidget(
            icon: Icons.history_rounded,
            title: 'No contributions yet',
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: summary.contributionsByType.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(_contributionIcon(e.key), style: theme.textTheme.bodyMedium),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / summary.totalContributions,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${e.value}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
      ],
    );
  }

  String _contributionIcon(String type) {
    switch (type) {
      case 'post': return '📝 Posts';
      case 'resource': return '📁 Resources';
      case 'event': return '🎉 Events';
      case 'comment': return '💬 Comments';
      case 'marketplace': return '🛒 Marketplace';
      case 'volunteer': return '🤝 Volunteer';
      default: return type;
    }
  }
}

class _ActivitySection extends ConsumerWidget {
  final String userId;
  final WidgetRef ref;

  const _ActivitySection({required this.userId, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(reputationEventsProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        eventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return const AppEmptyWidget(
                icon: Icons.history_rounded,
                title: 'No activity yet',
              );
            }
            return Column(
              children: events.take(10).map((e) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: e.points > 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(
                    e.points > 0 ? Icons.add_rounded : Icons.remove_rounded,
                    size: 16,
                    color: e.points > 0 ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(e.eventLabel, style: theme.textTheme.bodyMedium),
                subtitle: Text(_timeAgo(e.createdAt), style: theme.textTheme.bodySmall),
                trailing: Text('+${e.points}', style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green, fontWeight: FontWeight.bold,
                )),
              )).toList(),
            );
          },
          loading: () => const AppLoadingWidget.list(itemCount: 3),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}
