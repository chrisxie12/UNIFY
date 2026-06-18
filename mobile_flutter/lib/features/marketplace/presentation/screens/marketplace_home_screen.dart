import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';

class MarketplaceHomeScreen extends ConsumerWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/marketplace/sell'),
        backgroundColor: context.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Sell',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.6,
            shadowColor: AppColors.border,
            title: const Text('Marketplace',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: AppColors.dark)),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded,
                    color: AppColors.dark),
                tooltip: 'Saved',
                onPressed: () => context.push('/marketplace/saved'),
              ),
              IconButton(
                icon: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.dark),
                tooltip: 'My listings',
                onPressed: () => context.push('/marketplace/mine'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Search bar ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: GestureDetector(
                onTap: () => context.push('/marketplace/search'),
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
                      Text('Search items, services, rooms…',
                          style:
                              TextStyle(color: AppColors.grey2, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Trust banner ─────────────────────────────────────
          const SliverToBoxAdapter(child: _TrustBanner()),

          // ── Category grid ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: _SectionHeader(
                title: 'Browse Categories',
                actionLabel: 'Freelancers',
                onAction: () => context.push('/marketplace/freelancers'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final cat = MarketCategory.values[i];
                  return _CategoryTile(
                    category: cat,
                    onTap: () =>
                        context.push('/marketplace/category/${cat.key}'),
                  );
                },
                childCount: MarketCategory.values.length,
              ),
            ),
          ),

          // ── Featured ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: featuredAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: _SectionHeader(title: 'Featured'),
                    ),
                    SizedBox(
                      height: 188,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) => _FeaturedCard(
                          listing: items[i],
                          onTap: () => context
                              .push('/marketplace/listing/${items[i].id}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Browse all CTA ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
              child: FilledButton.tonal(
                onPressed: () => context.push('/marketplace/category/all'),
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary.withValues(alpha: 0.10),
                  foregroundColor: context.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Browse all listings',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBanner extends StatelessWidget {
  const _TrustBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF0047DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verified students only',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                SizedBox(height: 2),
                Text('Every seller is a verified student on your campus.',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

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
            child: Row(
              children: [
                Text(actionLabel!,
                    style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: context.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final MarketCategory category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  const _FeaturedCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 120,
                width: 150,
                child: listing.coverImage != null
                    ? CachedNetworkImage(
                        imageUrl: listing.coverImage!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _ph(),
                      )
                    : _ph(),
              ),
            ),
            const SizedBox(height: 6),
            Text(listing.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark)),
            const SizedBox(height: 2),
            Text(listing.priceLabel,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: listing.category.color)),
          ],
        ),
      ),
    );
  }

  Widget _ph() => Container(
        color: listing.category.color.withValues(alpha: 0.08),
        child: Center(
            child: Icon(listing.category.icon,
                size: 36, color: listing.category.color)),
      );
}
