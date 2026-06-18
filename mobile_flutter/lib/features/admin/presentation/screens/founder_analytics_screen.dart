import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';

class _AnalyticsData {
  final int totalCommunities;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final int verifiedReps;
  final int pendingVerification;
  final int rejectedVerification;
  final int totalStudents;
  final int newSignups;
  final int postsToday;

  _AnalyticsData({
    required this.totalCommunities,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.verifiedReps,
    required this.pendingVerification,
    required this.rejectedVerification,
    required this.totalStudents,
    required this.newSignups,
    required this.postsToday,
  });
}

final _analyticsProvider = FutureProvider.autoDispose<_AnalyticsData>((ref) async {
  final client = ref.read(supabaseProvider);

  final communities = await client.from('communities').select('id');
  final totalCommunities = (communities as List).length;

  final allRequests = await client.from('community_requests').select('status');
  final reqList = allRequests as List;
  final pendingRequests = reqList.where((r) => r['status'] == 'pending').length;
  final approvedRequests = reqList.where((r) => r['status'] == 'approved').length;
  final rejectedRequests = reqList.where((r) => r['status'] == 'rejected').length;

  final allVerif = await client.from('verification_requests').select('status');
  final verifList = allVerif as List;
  final verifiedReps = verifList.where((r) => r['status'] == 'approved').length;
  final pendingVerification = verifList.where((r) => r['status'] == 'pending').length;
  final rejectedVerification = verifList.where((r) => r['status'] == 'rejected').length;

  final profiles = await client.from('profiles').select('id, created_at');
  final profileList = profiles as List;
  final totalStudents = profileList.length;
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
  final newSignups = profileList.where((p) {
    final createdAt = p['created_at'] as String?;
    return createdAt != null && createdAt.compareTo(sevenDaysAgo) >= 0;
  }).length;

  final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
  final allPosts = await client.from('community_posts').select('created_at');
  final postsToday = (allPosts as List).where((p) {
    final createdAt = p['created_at'] as String? ?? '';
    return createdAt.startsWith(today);
  }).length;

  return _AnalyticsData(
    totalCommunities: totalCommunities,
    pendingRequests: pendingRequests,
    approvedRequests: approvedRequests,
    rejectedRequests: rejectedRequests,
    verifiedReps: verifiedReps,
    pendingVerification: pendingVerification,
    rejectedVerification: rejectedVerification,
    totalStudents: totalStudents,
    newSignups: newSignups,
    postsToday: postsToday,
  );
});

class _StatTileData {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  _StatTileData(this.label, this.value, this.color, this.icon);
}

class _AnalyticsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_StatTileData> tiles;

  const _AnalyticsSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: tiles.map((t) => Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(t.icon, size: 18, color: t.color),
                      const SizedBox(height: 6),
                      Text(t.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: t.color)),
                      const SizedBox(height: 2),
                      Text(t.label, style: const TextStyle(fontSize: 9, color: AppColors.grey2), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FounderAnalyticsScreen extends ConsumerWidget {
  const FounderAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(_analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Founder Analytics')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_analyticsProvider),
        child: analyticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AnalyticsSection(
                title: 'Communities',
                icon: Icons.groups_rounded,
                color: Theme.of(context).colorScheme.primary,
                tiles: [
                  _StatTileData('Total Communities', '${data.totalCommunities}', Theme.of(context).colorScheme.primary, Icons.groups_rounded),
                  _StatTileData('Pending Requests', '${data.pendingRequests}', AppColors.warning, Icons.hourglass_empty_rounded),
                  _StatTileData('Approved', '${data.approvedRequests}', AppColors.success, Icons.check_circle_rounded),
                  _StatTileData('Rejected', '${data.rejectedRequests}', AppColors.error, Icons.cancel_rounded),
                ],
              ),
              const SizedBox(height: 16),
              _AnalyticsSection(
                title: 'Representatives',
                icon: Icons.verified_user_rounded,
                color: const Color(0xFFFF6B35),
                tiles: [
                  _StatTileData('Verified', '${data.verifiedReps}', AppColors.success, Icons.verified_rounded),
                  _StatTileData('Pending', '${data.pendingVerification}', AppColors.warning, Icons.access_time_rounded),
                  _StatTileData('Rejected', '${data.rejectedVerification}', AppColors.error, Icons.cancel_rounded),
                ],
              ),
              const SizedBox(height: 16),
              _AnalyticsSection(
                title: 'Students',
                icon: Icons.people_rounded,
                color: const Color(0xFF10B981),
                tiles: [
                  _StatTileData('Total Registered', '${data.totalStudents}', const Color(0xFF10B981), Icons.people_rounded),
                  _StatTileData('New (7 days)', '${data.newSignups}', const Color(0xFF10B981), Icons.person_add_rounded),
                ],
              ),
              const SizedBox(height: 16),
              _AnalyticsSection(
                title: 'Engagement',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF8B5CF6),
                tiles: [
                  _StatTileData('Posts Today', '${data.postsToday}', const Color(0xFF8B5CF6), Icons.article_rounded),
                  _StatTileData('Active Communities', '${data.totalCommunities}', const Color(0xFF8B5CF6), Icons.groups_rounded),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
