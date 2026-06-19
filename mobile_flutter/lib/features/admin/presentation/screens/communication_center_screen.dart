import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/errors/error_mapper.dart';

class CommunicationCenterScreen extends ConsumerStatefulWidget {
  const CommunicationCenterScreen({super.key});

  @override
  ConsumerState<CommunicationCenterScreen> createState() => _CommunicationCenterScreenState();
}

class _CommunicationCenterScreenState extends ConsumerState<CommunicationCenterScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _scopeType = 'university';
  String _priority = 'normal';
  bool _sendPush = false;
  bool _sendEmail = false;
  bool _isSending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(adminAnnouncementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _showHistory(context, announcementsAsync),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_rounded, size: 20, color: context.primary),
                    const SizedBox(width: 8),
                    const Text('New Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Announcement title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    hintText: 'Write your announcement...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _scopeType,
                  decoration: _inputDec('Scope'),
                  items: const [
                    DropdownMenuItem(value: 'university', child: Text('Entire University')),
                    DropdownMenuItem(value: 'faculty', child: Text('Faculty')),
                    DropdownMenuItem(value: 'department', child: Text('Department')),
                    DropdownMenuItem(value: 'community', child: Text('Community')),
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                  ],
                  onChanged: (v) => setState(() => _scopeType = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: _inputDec('Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (v) => setState(() => _priority = v!),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Send Push Notification'),
                  value: _sendPush,
                  onChanged: (v) => setState(() => _sendPush = v ?? false),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Send Email'),
                  value: _sendEmail,
                  onChanged: (v) => setState(() => _sendEmail = v ?? false),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSending ? null : _sendAnnouncement,
                    icon: _isSending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(_isSending ? 'Sending...' : 'Send Announcement'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          announcementsAsync.when(
            data: (announcements) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent Announcements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
                const SizedBox(height: 12),
                ...announcements.take(5).map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark))),
                          StatusBadge(a.priority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(a.body, style: const TextStyle(fontSize: 12, color: AppColors.grey1), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(a.scopeLabel, style: const TextStyle(fontSize: 10, color: AppColors.grey2)),
                          const SizedBox(width: 8),
                          Text(a.senderName ?? '', style: const TextStyle(fontSize: 10, color: AppColors.grey2)),
                          const Spacer(),
                          Text(timeAgo(a.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.grey3)),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    );
  }

  Future<void> _sendAnnouncement() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final repo = ref.read(adminRepositoryProvider);
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return;

      await repo.createAnnouncement({
        'sender_id': userId,
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'scope_type': _scopeType,
        'priority': _priority,
        'send_push': _sendPush,
        'send_email': _sendEmail,
      });

      _titleCtrl.clear();
      _bodyCtrl.clear();
      ref.invalidate(adminAnnouncementsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement sent!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }

    setState(() => _isSending = false);
  }

  void _showHistory(BuildContext context, AsyncValue<List> announcementsAsync) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Announcement History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
            const SizedBox(height: 16),
            announcementsAsync.when(
              data: (announcements) => Column(
                children: announcements.map((a) => ListTile(
                  title: Text(a.title),
                  subtitle: Text('${a.scopeLabel} · ${timeAgo(a.createdAt)}'),
                  dense: true,
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(adminAnnouncementsProvider)),
            ),
          ],
        ),
      ),
    );
  }
}
