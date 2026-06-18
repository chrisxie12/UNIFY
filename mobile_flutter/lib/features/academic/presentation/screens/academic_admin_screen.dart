import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Academic Analytics',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (stats) {
          final searches = stats.topSearches.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return RefreshIndicator(
            color: context.primary,
            onRefresh: () async => ref.invalidate(academicStatsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _statCard('Courses', stats.courses,
                        Icons.menu_book_rounded, context.primary),
                    _statCard('Resources', stats.resources,
                        Icons.description_rounded, const Color(0xFF7C3AED)),
                    _statCard('Top file', stats.topDownloads,
                        Icons.download_rounded, AppColors.success,
                        caption: 'downloads'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Most downloaded',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                if (stats.mostDownloaded.isEmpty)
                  const Text('No downloads yet.',
                      style: TextStyle(color: AppColors.grey3))
                else
                  ...stats.mostDownloaded.map((r) => ResourceCard(
                        resource: r,
                        onTap: () =>
                            context.push('/academic/resource/${r.id}'),
                      )),
                const SizedBox(height: 24),
                const Text('Most searched topics',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                if (searches.isEmpty)
                  const Text('No searches recorded yet.',
                      style: TextStyle(color: AppColors.grey3))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: searches
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${e.key}  ·  ${e.value}',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color,
          {String? caption}) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F1F3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              Text(caption ?? label,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.grey2)),
            ],
          ),
        ),
      );
}
