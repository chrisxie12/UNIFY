import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../feed/domain/entities/announcement_entity.dart';
import '../../../feed/data/models/announcement_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// ── Admin announcements provider ─────────────────────────────────────────

final adminAnnouncementsProvider =
    FutureProvider<List<AnnouncementEntity>>((ref) async {
  final client = Supabase.instance.client;
  final data = await client
      .from('announcements')
      .select()
      .order('created_at', ascending: false)
      .limit(50);
  return (data as List)
      .cast<Map<String, dynamic>>()
      .map(AnnouncementModel.fromJson)
      .toList();
});

// ── Screen ────────────────────────────────────────────────────────────────

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final announcementsAsync = ref.watch(adminAnnouncementsProvider);

    // Role gate
    final profile = profileAsync.valueOrNull;
    if (profile != null && !profile.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Admin', style: AppTextStyles.headingM),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Access Restricted', style: AppTextStyles.headingS),
              const SizedBox(height: 4),
              Text(
                'You need admin privileges to view this page.',
                style: AppTextStyles.bodyS,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin Dashboard', style: AppTextStyles.headingS),
            Text(
              'GCTU Campus Admin',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey2),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showCreateDialog(context, ref),
            tooltip: 'New announcement',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: announcementsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => Row(
                children: [
                  _StatChip(
                    label: 'Total',
                    value: '${items.length}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Published',
                    value:
                        '${items.where((a) => a.isPublished).length}',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Draft',
                    value:
                        '${items.where((a) => !a.isPublished).length}',
                    color: AppColors.grey3,
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Announcements list
          Expanded(
            child: announcementsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: AppTextStyles.bodyS),
              ),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📋',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('No announcements yet',
                              style: AppTextStyles.headingS),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to create the first announcement.',
                            style: AppTextStyles.bodyS,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _AdminAnnouncementTile(item: items[i], ref: ref),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreateAnnouncementSheet(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.headingS.copyWith(color: color),
          ),
          Text(
            label,
            style:
                AppTextStyles.caption.copyWith(color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _AdminAnnouncementTile extends ConsumerWidget {
  final AnnouncementEntity item;
  final WidgetRef ref;

  const _AdminAnnouncementTile({required this.item, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = item.category;
    final color = AppColors.categoryColor(cat);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Published indicator
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: item.isPublished ? AppColors.success : AppColors.grey3,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cat[0].toUpperCase() + cat.substring(1),
                          style:
                              AppTextStyles.labelS.copyWith(color: color),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.isPublished ? 'Published' : 'Draft',
                        style: AppTextStyles.caption.copyWith(
                          color: item.isPublished
                              ? AppColors.success
                              : AppColors.grey3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.title, style: AppTextStyles.labelL),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS,
                  ),
                ],
              ),
            ),
            // Publish toggle
            IconButton(
              icon: Icon(
                item.isPublished
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: item.isPublished ? AppColors.primary : AppColors.grey3,
                size: 20,
              ),
              onPressed: () => _togglePublish(context, ref),
              tooltip: item.isPublished ? 'Unpublish' : 'Publish',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePublish(BuildContext context, WidgetRef ref) async {
    try {
      await Supabase.instance.client.from('announcements').update({
        'is_published': !item.isPublished,
      }).eq('id', item.id);
      ref.invalidate(adminAnnouncementsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  ConsumerState<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends ConsumerState<_CreateAnnouncementSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _category = 'general';
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      final profile = ref.read(profileProvider).valueOrNull;
      await client.from('announcements').insert({
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'category': _category,
        'university_id': profile?.universityId ?? '',
        'author_id': user?.id ?? '',
        'is_published': false,
      });
      ref.invalidate(adminAnnouncementsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('New Announcement', style: AppTextStyles.headingS),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category picker
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['general', 'academic', 'events', 'admin', 'urgent']
                  .map((cat) => GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _category == cat
                                ? AppColors.categoryColor(cat)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat[0].toUpperCase() + cat.substring(1),
                            style: AppTextStyles.labelM.copyWith(
                              color: _category == cat
                                  ? AppColors.white
                                  : AppColors.grey1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.dark),
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.dark),
            decoration:
                const InputDecoration(hintText: 'Write announcement body…'),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Save as Draft'),
          ),
        ],
      ),
    );
  }
}
