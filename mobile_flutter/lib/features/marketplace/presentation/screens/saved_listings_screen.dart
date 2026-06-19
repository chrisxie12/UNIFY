import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/listing_card.dart';

class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedListingsProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Saved Listings',
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
                    child: Icon(Icons.favorite_border_rounded,
                        size: 34, color: context.textDisabled),
                  ),
                  const SizedBox(height: 14),
                  const Text('No saved listings',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Tap the heart on any listing to save it here.',
                      style: TextStyle(fontSize: 13, color: context.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(savedListingsProvider),
            color: context.primary,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => ListingCard(
                listing: items[i],
                onTap: () =>
                    context.push('/marketplace/listing/${items[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}