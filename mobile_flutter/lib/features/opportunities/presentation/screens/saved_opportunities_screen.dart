import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/opportunities_provider.dart';
import '../widgets/opportunity_card.dart';

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedOpportunitiesProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Saved Opportunities',
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
                    decoration: const BoxDecoration(
                        color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.bookmark_border_rounded,
                        size: 32, color: AppColors.grey3),
                  ),
                  const SizedBox(height: 14),
                  const Text('No saved opportunities',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Bookmark opportunities to revisit them here.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey2)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: context.primary,
            onRefresh: () async =>
                ref.invalidate(savedOpportunitiesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => OpportunityCard(
                opportunity: items[i],
                onTap: () =>
                    context.push('/opportunities/detail/${items[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
