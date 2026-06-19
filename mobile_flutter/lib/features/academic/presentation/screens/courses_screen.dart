import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String? _faculty;
  String? _department;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final facultiesAsync = ref.watch(facultiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Courses',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.dark),
            tooltip: 'Add course',
            onPressed: () => context.push('/academic/course-new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.grey2, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Course code, name or lecturer',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (v) {
                        _debounce?.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 350), () {
                          ref.read(courseSearchProvider.notifier).state =
                              v.trim();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          facultiesAsync.maybeWhen(
            data: (faculties) {
              if (faculties.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _chip('All', _faculty == null, () {
                      setState(() {
                        _faculty = null;
                        _department = null;
                      });
                    }),
                    for (final f in faculties)
                      _chip(f, _faculty == f, () {
                        setState(() {
                          _faculty = _faculty == f ? null : f;
                          _department = null;
                        });
                      }),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),

          if (_faculty != null)
            Consumer(builder: (context, ref, _) {
              final depsAsync = ref.watch(departmentsProvider(_faculty!));
              return depsAsync.maybeWhen(
                data: (deps) {
                  if (deps.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final d in deps)
                          _chip(d, _department == d, () {
                            setState(() =>
                                _department = _department == d ? null : d);
                          }, small: true),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            }),

          Expanded(
            child: coursesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(coursesProvider)),
              data: (all) {
                final searchQuery = ref.watch(courseSearchProvider);
                var filtered = all.where((c) {
                  if (_faculty != null && c.faculty != _faculty) return false;
                  if (_department != null && c.department != _department) {
                    return false;
                  }
                  if (searchQuery.isNotEmpty) {
                    final q = searchQuery.toLowerCase();
                    if (!c.code.toLowerCase().contains(q) &&
                        !c.name.toLowerCase().contains(q) &&
                        !(c.lecturerName?.toLowerCase().contains(q) ?? false)) {
                      return false;
                    }
                  }
                  return true;
                }).toList();
                if (filtered.isEmpty) {
                  return _empty(context);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CourseRow(course: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded,
                  size: 32, color: context.primary),
            ),
            const SizedBox(height: 14),
            const Text('No courses found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/academic/course-new'),
              style: FilledButton.styleFrom(backgroundColor: context.primary),
              child: const Text('Add a course'),
            ),
          ],
        ),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap,
      {bool small = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: small ? 12 : 14),
          decoration: BoxDecoration(
            color: selected ? context.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? context.primary : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: small ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.grey1)),
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseModel course;
  const _CourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/academic/course/${course.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                course.code.length >= 4
                    ? course.code.substring(0, 4)
                    : course.code,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${course.code} · ${course.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  if (course.lecturerName != null &&
                      course.lecturerName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(course.lecturerName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey2)),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Text('${course.resourceCount}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.primary)),
                const Text('files',
                    style: TextStyle(fontSize: 10, color: AppColors.grey3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
