import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/feedback_models.dart';
import '../providers/feedback_provider.dart';

class FeedbackAdminScreen extends ConsumerWidget {
  const FeedbackAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          elevation: 0.6,
          shadowColor: context.borderCol,
          title: const Text('Feedback Admin',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            isScrollable: true,
            labelColor: context.primary,
            unselectedLabelColor: AppColors.grey2,
            indicatorColor: context.primary,
            tabs: const [
              Tab(text: 'Open'),
              Tab(text: 'In Progress'),
              Tab(text: 'Fixed'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        body: const Column(
          children: [
            _StatHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _QueueTab(status: FeedbackStatus.open),
                  _QueueTab(status: FeedbackStatus.inProgress),
                  _QueueTab(status: FeedbackStatus.fixed),
                  _QueueTab(status: FeedbackStatus.closed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatHeader extends ConsumerWidget {
  const _StatHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(feedbackCountsProvider);
    return counts.when(
      loading: () => const SizedBox(height: 64),
      error: (_, __) => const SizedBox.shrink(),
      data: (c) => Container(
        color: context.cardBg,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Row(
          children: [
            for (final s in FeedbackStatus.all)
              Expanded(
                child: _stat(context, FeedbackStatus.label(s), c[s] ?? 0,
                    FeedbackStatus.color(s)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int value, Color color) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: context.textSecondary)),
      ],
    );
  }
}

class _QueueTab extends ConsumerWidget {
  const _QueueTab({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(feedbackQueueProvider(status));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorWidget(e),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text('No ${FeedbackStatus.label(status).toLowerCase()} items',
                style: TextStyle(color: context.textSecondary)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(feedbackQueueProvider(status));
            ref.invalidate(feedbackCountsProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _FeedbackCard(item: items[i]),
          ),
        );
      },
    );
  }
}

class _FeedbackCard extends ConsumerWidget {
  const _FeedbackCard({required this.item});
  final FeedbackItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _openSheet(context, ref),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _chip(item.type.label, item.type.color, icon: item.type.icon),
                const SizedBox(width: 8),
                _chip(FeedbackStatus.label(item.status),
                    FeedbackStatus.color(item.status)),
                const Spacer(),
                Text('${item.voteCount} votes',
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.title,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: context.textPrimary)),
            if (item.screenshotUrl != null &&
                item.screenshotUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.screenshotUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: context.cardBg,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined,
                        color: context.textDisabled),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _meta(context, Icons.person_outline, item.reporterName ?? 'Unknown'),
                if (item.deviceInfo != null)
                  _meta(context, Icons.smartphone_outlined, item.deviceInfo!),
                if (item.appVersion != null)
                  _meta(context, Icons.tag, 'v${item.appVersion}'),
              ],
            ),
            if (item.adminResponse != null &&
                item.adminResponse!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(item.adminResponse!,
                    style: TextStyle(
                        fontSize: 13, color: context.textPrimary)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _ManageSheet(item: item),
    );
  }

  Widget _chip(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.textDisabled),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 12, color: context.textSecondary)),
      ],
    );
  }
}

class _ManageSheet extends ConsumerStatefulWidget {
  const _ManageSheet({required this.item});
  final FeedbackItem item;

  @override
  ConsumerState<_ManageSheet> createState() => _ManageSheetState();
}

class _ManageSheetState extends ConsumerState<_ManageSheet> {
  late String _status = widget.item.status;
  late final TextEditingController _responseCtrl =
      TextEditingController(text: widget.item.adminResponse ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final admin = ref.read(currentUserProvider);
    try {
      await ref.read(feedbackRepositoryProvider).setStatus(
            widget.item.id,
            _status,
            adminResponse: _responseCtrl.text.trim().isEmpty
                ? null
                : _responseCtrl.text.trim(),
            resolvedBy: admin?.id,
          );
      ref.invalidate(feedbackCountsProvider);
      for (final s in FeedbackStatus.all) {
        ref.invalidate(feedbackQueueProvider(s));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.item.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const Text('Status',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final s in FeedbackStatus.all)
                ChoiceChip(
                  label: Text(FeedbackStatus.label(s)),
                  selected: _status == s,
                  selectedColor:
                      FeedbackStatus.color(s).withValues(alpha: 0.18),
                  onSelected: (_) => setState(() => _status = s),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Admin response',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _responseCtrl,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Reply to the reporter (optional)',
              filled: true,
              fillColor: context.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderCol),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderCol),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
