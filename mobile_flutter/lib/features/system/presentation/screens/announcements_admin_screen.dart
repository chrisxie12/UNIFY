import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/system_models.dart';
import '../providers/system_provider.dart';
import '../widgets/system_announcement_banner.dart';

/// Admin composer + manager for in-app system announcements.
class AnnouncementsAdminScreen extends ConsumerStatefulWidget {
  const AnnouncementsAdminScreen({super.key});

  @override
  ConsumerState<AnnouncementsAdminScreen> createState() =>
      _AnnouncementsAdminScreenState();
}

class _AnnouncementsAdminScreenState
    extends ConsumerState<AnnouncementsAdminScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _actionLabelCtrl = TextEditingController();
  final _actionUrlCtrl = TextEditingController();

  String _type = 'general';
  String _severity = 'info';
  String _audience = 'all';
  DateTime? _endsAt;
  bool _submitting = false;

  static const _types = ['feature', 'maintenance', 'update', 'general'];
  static const _severities = ['info', 'warning', 'critical'];
  static const _audiences = ['all', 'university', 'beta'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _actionLabelCtrl.dispose();
    _actionUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEndsAt() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endsAt = picked);
  }

  Future<void> _broadcast() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body are required')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final user = ref.read(currentUserProvider);
      await ref.read(systemRepositoryProvider).createAnnouncement(
            title: title,
            body: body,
            type: _type,
            severity: _severity,
            audience: _audience,
            actionLabel: _actionLabelCtrl.text.trim(),
            actionUrl: _actionUrlCtrl.text.trim(),
            endsAt: _endsAt,
            createdBy: user?.id,
          );
      if (!mounted) return;
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _actionLabelCtrl.clear();
      _actionUrlCtrl.clear();
      setState(() {
        _type = 'general';
        _severity = 'info';
        _audience = 'all';
        _endsAt = null;
      });
      ref.invalidate(allAnnouncementsProvider);
      ref.invalidate(activeAnnouncementsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement broadcast')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _toggle(SystemAnnouncement a, bool value) async {
    await ref.read(systemRepositoryProvider).toggleAnnouncement(a.id, value);
    ref.invalidate(allAnnouncementsProvider);
    ref.invalidate(activeAnnouncementsProvider);
  }

  Future<void> _delete(SystemAnnouncement a) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete announcement?'),
        content: Text('"${a.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(systemRepositoryProvider).deleteAnnouncement(a.id);
    ref.invalidate(allAnnouncementsProvider);
    ref.invalidate(activeAnnouncementsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(allAnnouncementsProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        elevation: 0.6,
        title: Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          final activeCount = list.where((a) => a.isActive).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _statHeader(activeCount, list.length),
              const SizedBox(height: 16),
              _composer(),
              const SizedBox(height: 24),
              Text(
                'All announcements',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No announcements yet',
                      style: TextStyle(color: AppColors.grey3),
                    ),
                  ),
                )
              else
                ...list.map(_announcementCard),
            ],
          );
        },
      ),
    );
  }

  Widget _statHeader(int active, int total) {
    return Row(
      children: [
        Expanded(child: _statCard('Active', '$active', AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Total', '$total', AppColors.primary)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 13, color: context.textSecondary)),
        ],
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New announcement',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: _input('Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            minLines: 3,
            decoration: _input('Body'),
          ),
          const SizedBox(height: 12),
          _dropdown('Type', _type, _types, (v) => setState(() => _type = v!)),
          const SizedBox(height: 12),
          _dropdown('Severity', _severity, _severities,
              (v) => setState(() => _severity = v!)),
          const SizedBox(height: 12),
          _dropdown('Audience', _audience, _audiences,
              (v) => setState(() => _audience = v!)),
          const SizedBox(height: 12),
          TextField(
            controller: _actionLabelCtrl,
            decoration: _input('Action label (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _actionUrlCtrl,
            keyboardType: TextInputType.url,
            decoration: _input('Action URL (optional)'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickEndsAt,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: context.borderCol),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 18, color: AppColors.grey2),
                  const SizedBox(width: 10),
                  Text(
                    _endsAt == null
                        ? 'Ends at (optional)'
                        : 'Ends ${_endsAt!.toLocal().toString().split(' ').first}',
                    style: TextStyle(
                      color:
                          _endsAt == null ? AppColors.grey3 : context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_endsAt != null)
                    GestureDetector(
                      onTap: () => setState(() => _endsAt = null),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.grey3),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _broadcast,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : const Icon(Icons.campaign_rounded, size: 20),
              label: const Text(
                'Broadcast',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(SystemAnnouncement a) {
    final accent = severityColor(a.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(announcementTypeIcon(a.type), color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: a.isActive,
                activeColor: AppColors.primary,
                onChanged: (v) => _toggle(a, v),
              ),
              IconButton(
                onPressed: () => _delete(a),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.error,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            a.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.grey2),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(a.severity, accent),
              _chip(a.type, AppColors.grey1),
              _chip(a.audience, AppColors.grey2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return InputDecorator(
      decoration: _input(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
