import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myListingsProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('My Listings',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/marketplace/sell'),
        backgroundColor: context.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
                    child: Icon(Icons.inventory_2_outlined,
                        size: 32, color: context.textDisabled),
                  ),
                  const SizedBox(height: 14),
                  const Text('No listings yet',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => context.push('/marketplace/sell'),
                    style: FilledButton.styleFrom(
                        backgroundColor: context.primary),
                    child: const Text('Create your first listing'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _MyListingRow(listing: items[i]),
          );
        },
      ),
    );
  }
}

class _MyListingRow extends ConsumerWidget {
  final ListingModel listing;
  const _MyListingRow({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: listing.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: listing.coverImage!, fit: BoxFit.cover)
                  : Container(
                      color: listing.category.color.withValues(alpha: 0.08),
                      child: Icon(listing.category.icon,
                          color: listing.category.color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(listing.priceLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: listing.category.color)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statusChip(listing.status),
                    const SizedBox(width: 8),
                    Icon(Icons.remove_red_eye_outlined,
                        size: 13, color: context.textDisabled),
                    const SizedBox(width: 3),
                    Text('${listing.viewCount}',
                        style: TextStyle(
                            fontSize: 11, color: context.textDisabled)),
                    const SizedBox(width: 8),
                    Icon(Icons.favorite_border_rounded,
                        size: 13, color: context.textDisabled),
                    const SizedBox(width: 3),
                    Text('${listing.saveCount}',
                        style: TextStyle(
                            fontSize: 11, color: context.textDisabled)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: context.textSecondary),
            onSelected: (v) => _action(context, ref, v),
            itemBuilder: (_) => [
              if (!listing.isSold)
                const PopupMenuItem(
                    value: 'sold', child: Text('Mark as sold')),
              if (listing.isSold)
                const PopupMenuItem(
                    value: 'active', child: Text('Mark as available')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final (label, color) = switch (status) {
      'sold' || 'fulfilled' => ('Sold', AppColors.grey2),
      'expired' => ('Expired', AppColors.grey3),
      'removed' => ('Removed', AppColors.error),
      'pending' => ('Pending', AppColors.warning),
      _ => ('Active', AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Future<void> _action(
      BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(marketplaceRepositoryProvider);
    if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete listing?'),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete')),
          ],
        ),
      );
      if (ok == true) {
        await repo.deleteListing(listing.id);
        ref.invalidate(myListingsProvider);
        ref.invalidate(listingsProvider);
      }
    } else {
      await repo.updateStatus(listing.id, action);
      ref.invalidate(myListingsProvider);
      ref.invalidate(listingsProvider);
    }
  }
}