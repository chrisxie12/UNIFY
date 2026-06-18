import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studyPlansProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Study Planner',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newPlan(context, ref),
        backgroundColor: context.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_note_rounded,
                      size: 56, color: context.primary),
                  const SizedBox(height: 14),
                  const Text('No study plans yet',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Create schedules, revision plans or countdowns.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey2)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: plans.length,
            itemBuilder: (_, i) => _PlanCard(plan: plans[i]),
          );
        },
      ),
    );
  }

  void _newPlan(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _NewPlanSheet(),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final StudyPlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(plan.type.label,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: context.primary)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(plan.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.grey3, size: 20),
                  onSelected: (v) async {
                    if (v == 'task') {
                      _addTask(context, ref);
                    } else if (v == 'delete') {
                      await ref
                          .read(academicRepositoryProvider)
                          .deleteStudyPlan(plan.id);
                      ref.invalidate(studyPlansProvider);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'task', child: Text('Add task')),
                    PopupMenuItem(value: 'delete', child: Text('Delete plan')),
                  ],
                ),
              ],
            ),
          ),

          // Countdown
          if (plan.targetDate != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.flag_rounded,
                      size: 15, color: context.primary),
                  const SizedBox(width: 6),
                  Text(
                    (plan.daysLeft ?? 0) >= 0
                        ? '${plan.daysLeft} days left · ${plan.targetDate!.shortDate}'
                        : 'Target passed',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey1),
                  ),
                ],
              ),
            ),

          // Progress
          if (plan.tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: plan.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation(context.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${plan.doneCount}/${plan.tasks.length} done',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey3)),
                ],
              ),
            ),

          // Tasks
          ...plan.tasks.map((t) => CheckboxListTile(
                value: t.done,
                onChanged: (v) async {
                  await ref
                      .read(academicRepositoryProvider)
                      .toggleTask(t.id, v ?? false);
                  ref.invalidate(studyPlansProvider);
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: context.primary,
                title: Text(t.title,
                    style: TextStyle(
                        fontSize: 13.5,
                        decoration: t.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: t.done ? AppColors.grey3 : AppColors.dark)),
                subtitle: t.dueAt != null
                    ? Text(t.dueAt!.shortDate,
                        style: const TextStyle(fontSize: 11))
                    : null,
              )),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: TextButton.icon(
              onPressed: () => _addTask(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add task'),
            ),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add task'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Revise chapter 3'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await ref
                  .read(academicRepositoryProvider)
                  .addTask(plan.id, ctrl.text.trim());
              ref.invalidate(studyPlansProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _NewPlanSheet extends ConsumerStatefulWidget {
  const _NewPlanSheet();

  @override
  ConsumerState<_NewPlanSheet> createState() => _NewPlanSheetState();
}

class _NewPlanSheetState extends ConsumerState<_NewPlanSheet> {
  final _titleCtrl = TextEditingController();
  StudyPlanType _type = StudyPlanType.schedule;
  DateTime? _target;
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('New study plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: 'e.g. Final exams revision',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: StudyPlanType.values.map((t) {
              final sel = _type == t;
              return ChoiceChip(
                label: Text(t.label),
                selected: sel,
                onSelected: (_) => setState(() => _type = t),
                selectedColor: context.primary.withValues(alpha: 0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now.add(const Duration(days: 14)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _target = picked);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 18, color: AppColors.grey2),
                  const SizedBox(width: 10),
                  Text(
                    _target == null
                        ? 'Target date (optional)'
                        : '${_target!.day}/${_target!.month}/${_target!.year}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _busy ? null : _create,
            style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Create plan'),
          ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(academicRepositoryProvider).createStudyPlan({
        'user_id': user.id,
        'title': _titleCtrl.text.trim(),
        'type': _type.key,
        'target_date': _target?.toIso8601String(),
      });
      ref.invalidate(studyPlansProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not create: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
