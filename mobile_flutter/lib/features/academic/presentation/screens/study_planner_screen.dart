import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

class StudyPlannerScreen extends ConsumerStatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  ConsumerState<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends ConsumerState<StudyPlannerScreen> {
  final _titleController = TextEditingController();
  DateTime? _examDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createPlan() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    ref.read(academicProvider.notifier).createStudyPlan(title, examDate: _examDate);
    _titleController.clear();
    setState(() => _examDate = null);
    // ignore: unused_local_variable
    final _ = ref.refresh(studyPlansProvider);
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(studyPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No study plans yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showCreateDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Study Plan'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plans.length,
            itemBuilder: (_, i) => _StudyPlanCard(plan: plans[i]),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Study Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Database Systems Revision',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_examDate != null
                  ? 'Exam: ${DateFormat('MMM d, yyyy').format(_examDate!)}'
                  : 'Set exam date (optional)'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _examDate = date);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(context); _createPlan(); }, child: const Text('Create')),
        ],
      ),
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  final StudyPlanModel plan;
  const _StudyPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = plan.progress;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                if (plan.examDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Exam: ${DateFormat('MMM d').format(plan.examDate!)}',
                      style: TextStyle(fontSize: 11, color: Colors.red[700]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: theme.colorScheme.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}% complete · ${plan.items.where((i) => i.isCompleted).length}/${plan.items.length} tasks',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (plan.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...plan.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          item.isCompleted ? Icons.check_circle : Icons.radio_button_off,
                          size: 16,
                          color: item.isCompleted ? Colors.green : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              color: item.isCompleted ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (plan.items.length > 3)
                Text('+${plan.items.length - 3} more tasks', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ],
        ),
      ),
    );
  }
}
