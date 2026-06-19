import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  String _dueLabel(AssignmentModel a) {
    if (a.isOverdue) return 'Overdue';
    final diff = a.dueDate.difference(DateTime.now());
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays} days';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAssignmentsProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Assignment Hub',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(myAssignmentsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 56, color: context.primary),
                  const SizedBox(height: 14),
                  const Text('No assignments',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Assignments from your courses appear here.',
                      style: TextStyle(fontSize: 13, color: context.textSecondary)),
                ],
              ),
            );
          }
          final pending = items.where((a) => !a.isSubmitted).toList();
          final done = items.where((a) => a.isSubmitted).toList();
          return RefreshIndicator(
            color: context.primary,
            onRefresh: () async => ref.invalidate(myAssignmentsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (pending.isNotEmpty) ...[
                  const _SectionLabel('Pending'),
                  ...pending.map((a) => _AssignmentCard(
                      assignment: a, dueLabel: _dueLabel(a))),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const _SectionLabel('Submitted'),
                  ...done.map((a) => _AssignmentCard(
                      assignment: a, dueLabel: _dueLabel(a))),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.textSecondary)),
      );
}

class _AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;
  final String dueLabel;
  const _AssignmentCard({required this.assignment, required this.dueLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = assignment;
    return GestureDetector(
      onTap: () => _open(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (a.isSubmitted
                        ? context.success
                        : a.isOverdue
                            ? context.error
                            : context.warning)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                a.isSubmitted
                    ? Icons.check_circle_rounded
                    : Icons.assignment_rounded,
                color: a.isSubmitted
                    ? context.success
                    : a.isOverdue
                        ? context.error
                        : context.warning,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(dueLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: a.isOverdue
                              ? context.error
                              : AppColors.grey2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.textDisabled),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SubmitSheet(assignment: assignment),
    );
  }
}

class _SubmitSheet extends ConsumerStatefulWidget {
  final AssignmentModel assignment;
  const _SubmitSheet({required this.assignment});

  @override
  ConsumerState<_SubmitSheet> createState() => _SubmitSheetState();
}

class _SubmitSheetState extends ConsumerState<_SubmitSheet> {
  final _linkCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  String _dueLabel(AssignmentModel a) {
    if (a.isOverdue) return 'Overdue';
    final diff = a.dueDate.difference(DateTime.now());
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays} days';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(a.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(_dueLabel(a),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: a.isOverdue ? AppColors.error : AppColors.grey2)),
          if (a.description != null && a.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(a.description!,
                style: TextStyle(
                    fontSize: 14, height: 1.4, color: context.textPrimary)),
          ],
          const SizedBox(height: 16),
          const Text('Submission link',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _linkCtrl,
            decoration: InputDecoration(
              hintText: 'Paste your submission link',
              filled: true,
              fillColor: context.inputFill,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Mark submitted'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(academicRepositoryProvider).submitAssignment(
            widget.assignment.id,
            user.id,
            url: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
          );
      ref.invalidate(myAssignmentsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Marked as submitted'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }
}