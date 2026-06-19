import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/support_models.dart';
import '../providers/support_provider.dart';

class SupportAdminScreen extends ConsumerWidget {
  const SupportAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          elevation: 0.6,
          shadowColor: context.borderCol,
          title: const Text('Support Admin',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            labelColor: context.primary,
            unselectedLabelColor: AppColors.grey2,
            indicatorColor: context.primary,
            tabs: const [
              Tab(text: 'Tickets'),
              Tab(text: 'Abuse'),
              Tab(text: 'Content'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TicketsTab(),
            _AbuseTab(),
            _ContentTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tickets ────────────────────────────────────────────────────

class _TicketsTab extends ConsumerWidget {
  const _TicketsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allTicketsProvider(null));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load\n$e')),
      data: (tickets) {
        if (tickets.isEmpty) {
          return const Center(
              child: Text('No support tickets',
                  style: TextStyle(color: context.textSecondary)));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(allTicketsProvider(null)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _TicketCard(ticket: tickets[i]),
          ),
        );
      },
    );
  }
}

class _TicketCard extends ConsumerWidget {
  const _TicketCard({required this.ticket});
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _openSheet(context, ref),
      borderRadius: BorderRadius.circular(14),
      child: _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _chip(TicketStatus.label(ticket.status),
                    TicketStatus.color(ticket.status)),
                const SizedBox(width: 8),
                if (ticket.category != null)
                  _chip(ticket.category!, AppColors.grey2),
              ],
            ),
            const SizedBox(height: 10),
            Text(ticket.subject,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(ticket.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: context.textPrimary)),
            const SizedBox(height: 8),
            Text('From: ${ticket.userName ?? 'Unknown'}',
                style: TextStyle(fontSize: 12, color: context.textSecondary)),
            if (ticket.adminResponse != null &&
                ticket.adminResponse!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _responseBox(ticket.adminResponse!),
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
      builder: (_) => _TicketManageSheet(ticket: ticket),
    );
  }
}

class _TicketManageSheet extends ConsumerStatefulWidget {
  const _TicketManageSheet({required this.ticket});
  final SupportTicket ticket;

  @override
  ConsumerState<_TicketManageSheet> createState() =>
      _TicketManageSheetState();
}

class _TicketManageSheetState extends ConsumerState<_TicketManageSheet> {
  late String _status = widget.ticket.status;
  late final TextEditingController _responseCtrl =
      TextEditingController(text: widget.ticket.adminResponse ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _responseCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(supportRepositoryProvider).setTicketStatus(
            widget.ticket.id,
            _status,
            adminResponse: _responseCtrl.text.trim().isEmpty
                ? null
                : _responseCtrl.text.trim(),
          );
      ref.invalidate(allTicketsProvider(null));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: widget.ticket.subject,
      saving: _saving,
      onSave: _save,
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final s in TicketStatus.all)
              ChoiceChip(
                label: Text(TicketStatus.label(s)),
                selected: _status == s,
                selectedColor: TicketStatus.color(s).withValues(alpha: 0.18),
                onSelected: (_) => setState(() => _status = s),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Admin response',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _multiline(_responseCtrl, 'Reply to the user (optional)'),
      ],
    );
  }
}

// ── Abuse ──────────────────────────────────────────────────────

class _AbuseTab extends ConsumerWidget {
  const _AbuseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(abuseReportsProvider(null));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load\n$e')),
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(
              child: Text('No abuse reports',
                  style: TextStyle(color: context.textSecondary)));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(abuseReportsProvider(null)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AbuseCard(report: reports[i]),
          ),
        );
      },
    );
  }
}

class _AbuseCard extends ConsumerWidget {
  const _AbuseCard({required this.report});
  final AbuseReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _openSheet(context, ref),
      borderRadius: BorderRadius.circular(14),
      child: _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _chip(AbuseStatus.label(report.status),
                    AbuseStatus.color(report.status)),
                const SizedBox(width: 8),
                _chip(report.targetType, AppColors.grey2),
              ],
            ),
            const SizedBox(height: 10),
            Text(report.reason,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            if (report.details != null && report.details!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(report.details!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 13, color: context.textPrimary)),
            ],
            const SizedBox(height: 8),
            Text(
              'Reporter: ${report.reporterName ?? 'Unknown'}'
              '${report.targetId != null ? ' · Target: ${report.targetId}' : ''}',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
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
      builder: (_) => _AbuseManageSheet(report: report),
    );
  }
}

class _AbuseManageSheet extends ConsumerStatefulWidget {
  const _AbuseManageSheet({required this.report});
  final AbuseReport report;

  @override
  ConsumerState<_AbuseManageSheet> createState() => _AbuseManageSheetState();
}

class _AbuseManageSheetState extends ConsumerState<_AbuseManageSheet> {
  late String _status = widget.report.status;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(supportRepositoryProvider)
          .setAbuseStatus(widget.report.id, _status);
      ref.invalidate(abuseReportsProvider(null));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: widget.report.reason,
      saving: _saving,
      onSave: _save,
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final s in AbuseStatus.all)
              ChoiceChip(
                label: Text(AbuseStatus.label(s)),
                selected: _status == s,
                selectedColor: AbuseStatus.color(s).withValues(alpha: 0.18),
                onSelected: (_) => setState(() => _status = s),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Content (FAQs + articles) ──────────────────────────────────

class _ContentTab extends ConsumerWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqs = ref.watch(faqsProvider);
    final articles = ref.watch(articlesProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('FAQs',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            TextButton.icon(
              onPressed: () => _createFaq(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        faqs.when(
          loading: () => const _Loading(),
          error: (e, _) => Text('Could not load\n$e',
              style: TextStyle(color: context.textSecondary)),
          data: (items) {
            if (items.isEmpty) return const _Empty('No FAQs yet.');
            return Column(
              children: [
                for (final f in items) ...[
                  _CardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.question,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(f.answer,
                            style: const TextStyle(
                                fontSize: 13, color: context.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text('Help articles',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            TextButton.icon(
              onPressed: () => _createArticle(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        articles.when(
          loading: () => const _Loading(),
          error: (e, _) => Text('Could not load\n$e',
              style: TextStyle(color: context.textSecondary)),
          data: (items) {
            if (items.isEmpty) return const _Empty('No articles yet.');
            return Column(
              children: [
                for (final a in items) ...[
                  _CardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          '${a.viewCount} views · ${a.helpfulCount} helpful',
                          style: const TextStyle(
                              fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _createFaq(BuildContext context, WidgetRef ref) {
    final question = TextEditingController();
    final answer = TextEditingController();
    final category = TextEditingController(text: 'general');
    showDialog(
      context: context,
      builder: (ctx) => _CreateDialog(
        title: 'New FAQ',
        fields: [
          _DialogField(controller: question, label: 'Question'),
          _DialogField(controller: answer, label: 'Answer', maxLines: 4),
          _DialogField(controller: category, label: 'Category'),
        ],
        onSubmit: () async {
          await ref.read(supportRepositoryProvider).createFaq(
                question: question.text.trim(),
                answer: answer.text.trim(),
                category: category.text.trim(),
              );
          ref.invalidate(faqsProvider);
        },
      ),
    );
  }

  void _createArticle(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    final body = TextEditingController();
    final category = TextEditingController(text: 'general');
    showDialog(
      context: context,
      builder: (ctx) => _CreateDialog(
        title: 'New Article',
        fields: [
          _DialogField(controller: title, label: 'Title'),
          _DialogField(controller: body, label: 'Body', maxLines: 6),
          _DialogField(controller: category, label: 'Category'),
        ],
        onSubmit: () async {
          await ref.read(supportRepositoryProvider).createArticle(
                title: title.text.trim(),
                body: body.text.trim(),
                category: category.text.trim(),
              );
          ref.invalidate(articlesProvider);
        },
      ),
    );
  }
}

// ── Create dialog ──────────────────────────────────────────────

class _CreateDialog extends StatefulWidget {
  const _CreateDialog({
    required this.title,
    required this.fields,
    required this.onSubmit,
  });
  final String title;
  final List<_DialogField> fields;
  final Future<void> Function() onSubmit;

  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  bool _saving = false;

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.onSubmit();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Created.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardBg,
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in widget.fields) ...[
              f,
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.borderCol),
        ),
      ),
    );
  }
}

// ── Shared bits ────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: child,
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({
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
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
                  : const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, style: TextStyle(color: context.textSecondary)),
      );
}

Widget _chip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color)),
  );
}

Widget _responseBox(String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.info.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text,
        style: TextStyle(fontSize: 13, color: context.textPrimary)),
  );
}

Widget _multiline(TextEditingController controller, String hint) {
  return TextField(
    controller: controller,
    minLines: 2,
    maxLines: 5,
    decoration: InputDecoration(
      hintText: hint,
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
  );
}
