import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseProvider(widget.courseId));
    final resourcesAsync = ref.watch(resourcesByCourseProvider(widget.courseId));
    final assignmentsAsync = ref.watch(assignmentsProvider(widget.courseId));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.bg,
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              context.push('/academic/upload?course=${widget.courseId}'),
          backgroundColor: context.primary,
          child: const Icon(Icons.upload_rounded, color: Colors.white),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.appBarBg,
              surfaceTintColor: Colors.white,
              foregroundColor: AppColors.dark,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                background: courseAsync.maybeWhen(
                  data: (c) => Container(
                    padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primary,
                          Color.alphaBlend(
                              Colors.black.withValues(alpha: 0.20),
                              context.primary),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c?.code ?? '',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(c?.name ?? 'Course',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        if (c?.credits != null) ...[
                          const SizedBox(height: 4),
                          Text('${c!.credits} credits',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                  orElse: () => Container(color: context.primary),
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: context.primary,
                unselectedLabelColor: AppColors.grey2,
                indicatorColor: context.primary,
                tabs: const [
                  Tab(text: 'Notes'),
                  Tab(text: 'Past Questions'),
                  Tab(text: 'Assignments'),
                  Tab(text: 'Exams'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _resourceList(resourcesAsync, 'lecture_note'),
              _resourceList(resourcesAsync, 'past_question'),
              _assignmentList(assignmentsAsync),
              _examList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resourceList(
      AsyncValue<List<AcademicResourceModel>> async, String type) {
    return async.when(
      loading: () => const AppLoadingWidget.list(),
      error: (e, _) => AppErrorWidget(e),
      data: (all) {
        final items = all.where((r) => r.type == type).toList();
        if (items.isEmpty) {
          final label = type == 'lecture_note' ? 'Notes' : 'Past Questions';
          return _empty('No $label yet', 'Upload to share with your class.');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: items.length,
          itemBuilder: (_, i) => ResourceCard(
            resource: items[i],
            onTap: () =>
                context.push('/academic/resource/${items[i].id}'),
          ),
        );
      },
    );
  }

  Widget _assignmentList(AsyncValue<List<AssignmentModel>> async) {
    return async.when(
      loading: () => const AppLoadingWidget.list(),
      error: (e, _) => AppErrorWidget(e),
      data: (items) {
        if (items.isEmpty) {
          return _empty('No assignments', 'Course assignments appear here.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _AssignmentTile(assignment: items[i]),
        );
      },
    );
  }

  Widget _examList() {
    final async = ref.watch(examTimetablesForCourseProvider(widget.courseId));
    return async.when(
      loading: () => const AppLoadingWidget.list(),
      error: (e, _) => AppErrorWidget(e),
      data: (items) {
        if (items.isEmpty) {
          return _empty('No exams scheduled',
              'Quizzes, midsems and exams appear here.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ExamTile(exam: items[i]),
        );
      },
    );
  }

  Widget _empty(String title, String subtitle) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded,
                size: 44, color: context.textDisabled),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: context.textSecondary)),
          ],
        ),
      );
}

class _AssignmentTile extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    return Container(
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
              color: a.isOverdue ? context.errorBg : context.warningBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.assignment_rounded,
                color: a.isOverdue ? context.error : context.warning,
                size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text({
                  if (a.isOverdue) 'Overdue',
                  if (!a.isOverdue) 'Due ${a.dueDate.shortDateTime}',
                }.join(' · '),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            a.isOverdue ? context.error : AppColors.grey2)),
              ],
            ),
          ),
          if (a.isSubmitted)
            Icon(Icons.check_circle_rounded,
                color: context.success, size: 22),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final ExamTimetable exam;
  const _ExamTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.catUrgent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.event_rounded,
                color: AppColors.catUrgent, size: 22),
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
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}