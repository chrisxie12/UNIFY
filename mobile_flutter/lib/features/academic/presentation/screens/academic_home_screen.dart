import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';

class AcademicHomeScreen extends ConsumerWidget {
  const AcademicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final resourcesAsync = ref.watch(searchResourcesProvider(''));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/academic/upload'),
        backgroundColor: context.primary,
        icon: const Icon(Icons.upload_rounded, color: Colors.white),
        label: const Text('Upload',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        color: context.primary,
        onRefresh: () async {
          ref.invalidate(coursesProvider);
          ref.invalidate(searchResourcesProvider(''));
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.6,
              shadowColor: AppColors.border,
              title: const Text('Academic Hub',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      color: AppColors.dark)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cloud_download_outlined,
                      color: AppColors.dark),
                  tooltip: 'Offline library',
                  onPressed: () => context.push('/academic/offline'),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: GestureDetector(
                  onTap: () => context.push('/academic/search'),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: AppColors.grey2, size: 21),
                        SizedBox(width: 10),
                        Text('Search courses, notes, past questions…',
                            style: TextStyle(
                                color: AppColors.grey2, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tools grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.86,
                  children: [
                    _Tool(
                      icon: Icons.calculate_rounded,
                      label: 'GPA',
                      color: const Color(0xFF0066FF),
                      onTap: () => context.push('/academic/gpa'),
                    ),
                    _Tool(
                      icon: Icons.event_note_rounded,
                      label: 'Planner',
                      color: const Color(0xFF7C3AED),
                      onTap: () => context.push('/academic/planner'),
                    ),
                    _Tool(
                      icon: Icons.school_rounded,
                      label: 'Exam Prep',
                      color: const Color(0xFFDC2626),
                      onTap: () => context.push('/academic/exams'),
                    ),
                    _Tool(
                      icon: Icons.assignment_rounded,
                      label: 'Assignments',
                      color: const Color(0xFFD97706),
                      onTap: () => context.push('/academic/assignments'),
                    ),
                  ],
                ),
              ),
            ),

            // Courses
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: _Header(
                  title: 'Your Courses',
                  actionLabel: 'Browse all',
                  onAction: () => context.push('/academic/courses'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: coursesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (courses) {
                  if (courses.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text('No courses yet. Browse to add one.',
                          style:
                              TextStyle(color: AppColors.grey2, fontSize: 13)),
                    );
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: courses.length.clamp(0, 10),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _CourseChip(
                        code: courses[i].code,
                        title: courses[i].name,
                        count: courses[i].resourceCount,
                        onTap: () =>
                            context.push('/academic/course/${courses[i].id}'),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Recent resources
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: _Header(title: 'Recent Resources'),
              ),
            ),
            resourcesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 36, color: AppColors.grey3),
                        const SizedBox(height: 10),
                        const Text('Could not load resources',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Cached items show when offline.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.grey2)),
                      ],
                    ),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No resources yet. Be the first to upload.',
                            style: TextStyle(color: AppColors.grey2)),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ResourceCard(
                        resource: items[i],
                        onTap: () => context
                            .push('/academic/resource/${items[i].id}'),
                      ),
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Tool(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _Header({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.dark)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
      ],
    );
  }
}

class _CourseChip extends StatelessWidget {
  final String code;
  final String title;
  final int count;
  final VoidCallback onTap;
  const _CourseChip(
      {required this.code,
      required this.title,
      required this.count,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primary,
              Color.alphaBlend(
                  Colors.black.withValues(alpha: 0.18), context.primary),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(code,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.2)),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.folder_rounded,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text('$count resources',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
