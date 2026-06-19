import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';

/// Upcoming deadlines for saved / tracked opportunities. Drives the
/// in-app reminder list (and local-notification scheduling once wired).
class DeadlinesScreen extends ConsumerWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingDeadlinesProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Upcoming Deadlines',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: context.cardBg, shape: BoxShape.circle),
                    child: Icon(Icons.alarm_off_rounded,
                        size: 32, color: context.textDisabled),
                  ),
                  const SizedBox(height: 14),
                  const Text('No upcoming deadlines',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Save opportunities to see their deadlines here.',
                      style: TextStyle(fontSize: 13, color: context.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: context.primary,
            onRefresh: () async =>
                ref.invalidate(upcomingDeadlinesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _DeadlineRow(opportunity: items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  final OpportunityModel opportunity;
  const _DeadlineRow({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final days = o.daysLeft ?? 0;
    return GestureDetector(
      onTap: () => context.push('/opportunities/detail/${o.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: o.isClosingSoon
                    ? AppColors.error.withValues(alpha: 0.10)
                    : o.type.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$days',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: o.isClosingSoon
                              ? AppColors.error
                              : o.type.color)),
                  Text(days == 1 ? 'day' : 'days',
                      style: TextStyle(
                          fontSize: 10,
                          color: o.isClosingSoon
                              ? AppColors.error
                              : o.type.color)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(o.type.icon, size: 13, color: context.textDisabled),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(o.organization ?? o.type.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (o.stage != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: o.stage!.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(o.stage!.label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: o.stage!.color)),
              ),
          ],
        ),
      ),
    );
  }
}
