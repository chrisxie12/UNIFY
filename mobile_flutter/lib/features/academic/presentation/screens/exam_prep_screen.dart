import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';

class ExamPrepScreen extends ConsumerWidget {
  const ExamPrepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examTimetablesProvider);
    final resourcesAsync = ref.watch(searchResourcesProvider(''));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Exam Preparation',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        color: context.primary,
        onRefresh: () async {
          ref.invalidate(examTimetablesProvider);
          ref.invalidate(searchResourcesProvider(''));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            examsAsync.maybeWhen(
              data: (exams) {
                final upcoming = exams
                    .where((e) => e.examDate.isAfter(DateTime.now()))
                    .toList();
                if (upcoming.isEmpty) return const SizedBox.shrink();
                final next = upcoming.first;
                final daysLeft = next.examDate.difference(DateTime.now()).inDays;
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Next exam',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(next.courseName ?? next.courseCode ?? 'Exam',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(next.examDate.shortDateTime,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text('${daysLeft >= 0 ? daysLeft : 0}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900)),
                          const Text('days',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.groups_rounded,
                    label: 'Study Groups',
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/app/communities'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.event_note_rounded,
                    label: 'Revision Plan',
                    color: const Color(0xFF0066FF),
                    onTap: () => context.push('/academic/planner'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            const Text('Exam timetable',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            examsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (exams) => exams.isEmpty
                  ? const Text('No exams scheduled yet.',
                      style: TextStyle(color: context.textDisabled))
                  : Column(
                      children:
                          exams.map((e) => _ExamRow(exam: e)).toList()),
            ),

            const SizedBox(height: 22),
            const Text('Revision materials',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            resourcesAsync.maybeWhen(
              data: (all) {
                final revision = all
                    .where((r) =>
                        r.type == 'study_guide' ||
                        r.type == 'past_question')
                    .take(10)
                    .toList();
                if (revision.isEmpty) {
                  return const Text('No revision materials yet.',
                      style: TextStyle(color: context.textDisabled));
                }
                return Column(
                  children: revision
                      .map((r) => ResourceCard(
                            resource: r,
                            onTap: () => context
                                .push('/academic/resource/${r.id}'),
                          ))
                      .toList(),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  final ExamTimetable exam;
  const _ExamRow({required this.exam});

  @override
  Widget build(BuildContext context) {
    final days = exam.examDate.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.catUrgent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(days >= 0 ? '$days' : '—',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.catUrgent)),
                const Text('days',
                    style: TextStyle(
                        fontSize: 9, color: AppColors.catUrgent)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.courseName ?? exam.courseCode ?? 'Exam',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  [
                    exam.examDate.shortDateTime,
                    if (exam.venue != null) exam.venue,
                  ].join(' · '),
                  style:
                      TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
