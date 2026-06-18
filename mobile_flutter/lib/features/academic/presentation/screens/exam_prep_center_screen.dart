import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

class ExamPrepCenterScreen extends ConsumerWidget {
  const ExamPrepCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetablesAsync = ref.watch(examTimetablesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Preparation')),
      body: timetablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (exams) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exam Countdown', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      exams.isNotEmpty
                          ? '${_daysUntil(exams.first.examDate)} days to ${exams.first.courseCode ?? "next exam"}'
                          : 'No exams scheduled',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Exam Timetable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              const SizedBox(height: 8),
              if (exams.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No exam dates added yet', style: TextStyle(color: Colors.grey[500])),
                  ),
                )
              else
                ...exams.map((exam) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          child: const Icon(Icons.event, color: Colors.red, size: 20),
                        ),
                        title: Text(exam.courseCode ?? exam.courseName ?? 'Exam', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat('EEEE, MMM d, yyyy').format(exam.examDate)} · ${exam.examTime ?? 'TBA'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            if (exam.venue != null)
                              Text('Venue: ${exam.venue}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                        trailing: Text('${_daysUntil(exam.examDate)}d', style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w600)),
                      ),
                    )),
              const SizedBox(height: 16),
              Text('Study Resources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QuickActionCard(icon: Icons.library_books, label: 'Past Questions', color: Colors.indigo, onTap: () => context.push('/academic/resources', extra: {'type': 'past_question'})),
                  const SizedBox(width: 12),
                  _QuickActionCard(icon: Icons.group, label: 'Study Groups', color: Colors.teal, onTap: () => context.push('/academic/planner')),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  int _daysUntil(DateTime date) {
    return date.difference(DateTime.now()).inDays.clamp(0, 999);
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
