import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/support_models.dart';
import '../providers/support_provider.dart';

class SupportCenterScreen extends ConsumerWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqs = ref.watch(faqsProvider);
    final articles = ref.watch(articlesProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Support Center',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientDiag,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How can we help?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                    'Browse FAQs and articles, or reach out to the team directly.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Frequently asked'),
          const SizedBox(height: 10),
          faqs.when(
            loading: () => const _LoadingBox(),
            error: (e, _) => _ErrorText(e),
            data: (items) {
              if (items.isEmpty) {
                return const _EmptyText('No FAQs yet.');
              }
              return Container(
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: context.borderCol),
                      ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(items[i].question,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(items[i].answer,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.grey1)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Help articles'),
          const SizedBox(height: 10),
          articles.when(
            loading: () => const _LoadingBox(),
            error: (e, _) => _ErrorText(e),
            data: (items) {
              if (items.isEmpty) {
                return const _EmptyText('No articles yet.');
              }
              return Column(
                children: [
                  for (final a in items) ...[
                    _articleTile(context, a),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  context,
                  icon: Icons.support_agent_rounded,
                  label: 'Contact support',
                  color: context.primary,
                  onTap: () => _openTicketSheet(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  context,
                  icon: Icons.flag_outlined,
                  label: 'Report a problem',
                  color: AppColors.error,
                  onTap: () => _openAbuseSheet(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _articleTile(BuildContext context, HelpArticle a) {
    return InkWell(
      onTap: () => context.push('/support/article/${a.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.article_outlined,
                  size: 20, color: context.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (a.category != null && a.category!.isNotEmpty)
                    Text(a.category!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey3),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _openTicketSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _TicketSheet(),
    );
  }

  void _openAbuseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _AbuseSheet(),
    );
  }
}

// ── Ticket form ────────────────────────────────────────────────

class _TicketSheet extends ConsumerStatefulWidget {
  const _TicketSheet();

  @override
  ConsumerState<_TicketSheet> createState() => _TicketSheetState();
}

class _TicketSheetState extends ConsumerState<_TicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = 'general';
  bool _saving = false;

  static const _categories = [
    'general',
    'account',
    'technical',
    'billing',
    'other',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a subject and message.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(supportRepositoryProvider).createTicket(
            userId: user.id,
            subject: subject,
            message: message,
            category: _category,
          );
      ref.invalidate(myTicketsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support request sent. We will reply soon.')),
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
    return _SheetScaffold(
      title: 'Contact support',
      saving: _saving,
      onSave: _submit,
      children: [
        _SheetField(
            controller: _subjectCtrl,
            label: 'Subject',
            hint: 'What do you need help with?'),
        const SizedBox(height: 12),
        _SheetDropdown(
          label: 'Category',
          value: _category,
          items: _categories,
          onChanged: (v) => setState(() => _category = v ?? 'general'),
        ),
        const SizedBox(height: 12),
        _SheetField(
            controller: _messageCtrl,
            label: 'Message',
            hint: 'Describe your issue',
            minLines: 3,
            maxLines: 6),
      ],
    );
  }
}

// ── Abuse form ─────────────────────────────────────────────────

class _AbuseSheet extends ConsumerStatefulWidget {
  const _AbuseSheet();

  @override
  ConsumerState<_AbuseSheet> createState() => _AbuseSheetState();
}

class _AbuseSheetState extends ConsumerState<_AbuseSheet> {
  final _targetIdCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  String _targetType = 'user';
  String _reason = 'spam';
  bool _saving = false;

  static const _targetTypes = ['user', 'post', 'listing', 'message', 'other'];
  static const _reasons = [
    'spam',
    'harassment',
    'inappropriate',
    'scam',
    'impersonation',
    'other',
  ];

  @override
  void dispose() {
    _targetIdCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(supportRepositoryProvider).reportAbuse(
            reporterId: user.id,
            targetType: _targetType,
            targetId: _targetIdCtrl.text.trim().isEmpty
                ? null
                : _targetIdCtrl.text.trim(),
            reason: _reason,
            details: _detailsCtrl.text.trim().isEmpty
                ? null
                : _detailsCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you.')),
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
    return _SheetScaffold(
      title: 'Report a problem',
      saving: _saving,
      onSave: _submit,
      children: [
        _SheetDropdown(
          label: 'What are you reporting?',
          value: _targetType,
          items: _targetTypes,
          onChanged: (v) => setState(() => _targetType = v ?? 'user'),
        ),
        const SizedBox(height: 12),
        _SheetField(
            controller: _targetIdCtrl,
            label: 'Target ID (optional)',
            hint: 'ID of the user / post / item'),
        const SizedBox(height: 12),
        _SheetDropdown(
          label: 'Reason',
          value: _reason,
          items: _reasons,
          onChanged: (v) => setState(() => _reason = v ?? 'spam'),
        ),
        const SizedBox(height: 12),
        _SheetField(
            controller: _detailsCtrl,
            label: 'Details (optional)',
            hint: 'Add any context that helps us investigate',
            minLines: 3,
            maxLines: 6),
      ],
    );
  }
}

// ── Shared small widgets ───────────────────────────────────────

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.children,
    required this.saving,
    required this.onSave,
  });
  final String title;
  final List<Widget> children;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...children,
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _SheetDropdown extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: [
        for (final i in items)
          DropdownMenuItem(
            value: i,
            child: Text(i[0].toUpperCase() + i.substring(1)),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.error);
  final Object error;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(child: Text(ErrorMapper.toUserMessage(error), style: const TextStyle(color: AppColors.grey2))),
  );
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, style: const TextStyle(color: AppColors.grey2)),
      );
}
