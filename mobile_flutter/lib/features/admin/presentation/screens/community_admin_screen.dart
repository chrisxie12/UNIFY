import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

final _allCommunitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(supabaseProvider);
  final data = await client
      .from('communities')
      .select('*, profiles!communities_created_by_fkey(full_name)')
      .order('member_count', ascending: false) as List;
  return data.cast<Map<String, dynamic>>();
});

class CommunityAdminScreen extends ConsumerWidget {
  const CommunityAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesAsync = ref.watch(_allCommunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Management')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_allCommunitiesProvider),
        child: communitiesAsync.when(
          data: (communities) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: communities.length,
            itemBuilder: (_, i) => _CommunityCard(data: communities[i]),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _CommunityCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  const _CommunityCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = data['profiles'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.groups_rounded, color: context.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] as String? ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Text('${data['member_count'] ?? 0} members · by ${profile?['full_name'] ?? "Unknown"}',
                          style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: context.borderCol))),
            child: Row(
              children: [
                _actionBtn(context, 'Feature', context.primary, () => _toggleFeature(context, ref)),
                Container(width: 1, height: 36, color: context.borderCol),
                _actionBtn(context, 'Suspend', AppColors.error, () => _suspend(context, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFeature(BuildContext context, WidgetRef ref) async {
    final client = ref.read(supabaseProvider);
    final id = data['id'] as String;
    final isFeatured = data['is_featured'] as bool? ?? false;
    await client.from('communities').update({'is_featured': !isFeatured}).filter('id', 'eq', id);
    ref.invalidate(_allCommunitiesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isFeatured ? 'Unfeatured' : 'Featured'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _suspend(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suspend Community?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Suspend', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      final client = ref.read(supabaseProvider);
      final id = data['id'] as String;
      await client.from('communities').update({'is_active': false}).filter('id', 'eq', id);
      ref.invalidate(_allCommunitiesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community suspended'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
