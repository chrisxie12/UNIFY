import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/design_system/components.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';

class AcademicHomeScreen extends ConsumerWidget {
  const AcademicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final resourcesAsync = ref.watch(resourcesProvider);

    return Scaffold(
      backgroundColor: context.bg,
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
          ref.invalidate(resourcesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.cardBg,
              surfaceTintColor: context.cardBg,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.6,
              shadowColor: context.borderCol,
              title: Text('Academic Hub',
                  style: UText.h3.copyWith(color: context.textPrimary)),
              actions: [
                IconButton(
                  icon: Icon(Icons.cloud_download_outlined,
                      color: context.textPrimary),
                  tooltip: 'Offline library',
                  onPressed: () => context.push('/academic/offline'),
                ),
                const SizedBox(width: USpacing.xs),
              ],
            ),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    USpacing.base, USpacing.md, USpacing.base, USpacing.xs),
                child: GestureDetector(
                  onTap: () => context.push('/academic/search'),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: URadius.mdAll,
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: context.textSecondary, size: 21),
                        const SizedBox(width: 10),
                        Text('Search courses, notes, past questions…',
                            style: UText.bodyS.copyWith(
                                color: context.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tools grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    USpacing.base, 14, USpacing.base, USpacing.xs),
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
                padding: const EdgeInsets.fromLTRB(
                    USpacing.base, 14, USpacing.base, USpacing.sm),
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
                  padding: EdgeInsets.all(USpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (courses) {
                  if (courses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                          USpacing.base, 0, USpacing.base, USpacing.sm),
                      child: Text('No courses yet. Browse to add one.',
                          style: UText.bodyXS.copyWith(
                              color: context.textSecondary)),
                    );
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: USpacing.base),
                      itemCount: courses.length.clamp(0, 10),
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: USpacing.md),
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
                padding: EdgeInsets.fromLTRB(
                    USpacing.base, 14, USpacing.base, USpacing.sm),
                child: _Header(title: 'Recent Resources'),
              ),
            ),
            resourcesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: AppLoadingWidget.list(itemCount: 2),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(USpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 36, color: context.textSecondary),
                        const SizedBox(height: 10),
                        Text('Could not load resources',
                            style: UText.bodyS.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: USpacing.xs),
                        Text('Cached items show when offline.',
                            style: UText.caption.copyWith(
                                color: context.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(USpacing.xl),
                      child: Center(
                        child: Text(
                            'No resources yet. Be the first to upload.',
                            style: UText.bodyS.copyWith(
                                color: context.textSecondary)),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      USpacing.base, 0, USpacing.base, 100),
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
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
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
                style: UText.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary)),
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
            style: UText.h4.copyWith(color: context.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
                style: UText.labelS.copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.w600)),
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
                style: UText.labelL.copyWith(
                    color: context.cardBg,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: USpacing.xs),
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
                const SizedBox(width: USpacing.xs),
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
