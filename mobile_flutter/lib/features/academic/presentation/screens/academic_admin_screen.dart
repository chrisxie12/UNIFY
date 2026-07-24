import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';

/// Academic analytics dashboard: most-downloaded resources, totals and
/// most-searched topics.
class AcademicAdminScreen extends ConsumerWidget {
  const AcademicAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(academicStatsProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        surfaceTintColor: context.cardBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: Text('Academic Analytics',
            style: UText.h3.copyWith(color: context.textPrimary)),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(academicStatsProvider)),
        data: (stats) {
          final searches = stats.topSearches.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return RefreshIndicator(
            color: context.primary,
            onRefresh: () async => ref.invalidate(academicStatsProvider),
            child: ListView(
              padding: const EdgeInsets.all(USpacing.base),
              children: [
                Row(
                  children: [
                    _statCard('Courses', stats.courses,
                        Icons.menu_book_rounded, context.primary, context),
                    _statCard('Resources', stats.resources,
                        Icons.description_rounded, const Color(0xFF7C3AED), context),
                    _statCard('Top file', stats.topDownloads,
                        Icons.download_rounded, AppColors.success, context,
                        caption: 'downloads'),
                  ],
                ),
                const SizedBox(height: USpacing.xl),
                Text('Most downloaded',
                    style: UText.h4.copyWith(color: context.textPrimary)),
                const SizedBox(height: USpacing.md),
                if (stats.mostDownloaded.isEmpty)
                  const AppEmptyWidget(
                    icon: Icons.download_outlined,
                    title: 'No downloads yet.',
                  )
                else
                  ...stats.mostDownloaded.map((r) => ResourceCard(
                        resource: r,
                        // No standalone resource-detail screen exists; open the
                        // shared resources repository rather than a dead route.
                        onTap: () => context.push('/academic/resources'),
                      )),
                const SizedBox(height: USpacing.xl),
                Text('Most searched topics',
                    style: UText.h4.copyWith(color: context.textPrimary)),
                const SizedBox(height: USpacing.md),
                if (searches.isEmpty)
                  const AppEmptyWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No searches recorded yet.',
                  )
                else
                  Wrap(
                    spacing: USpacing.sm,
                    runSpacing: USpacing.sm,
                    children: searches
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: USpacing.md, vertical: 7),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: URadius.lgAll,
                              ),
                              child: Text('${e.key}  ·  ${e.value}',
                                  style: UText.caption.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: USpacing.x2),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color, BuildContext context,
          {String? caption}) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: USpacing.xs),
          padding: const EdgeInsets.symmetric(vertical: USpacing.base),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text('$value',
                  style: UText.h2.copyWith(color: context.textPrimary)),
              Text(caption ?? label,
                  textAlign: TextAlign.center,
                  style: UText.caption.copyWith(color: context.textSecondary)),
            ],
          ),
        ),
      );
}
