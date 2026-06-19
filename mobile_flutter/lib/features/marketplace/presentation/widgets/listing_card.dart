import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Grid card for a listing in browse / search results.
class ListingCard extends ConsumerWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = listing.category;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F1F3)),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / placeholder ──────────────────────────────
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (listing.coverImage != null)
                    CachedNetworkImage(
                      imageUrl: listing.coverImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: context.cardBg),
                      errorWidget: (_, __, ___) => _placeholder(cat),
                    )
                  else
                    _placeholder(cat),

                  // Save heart
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _SaveButton(listing: listing),
                  ),

                  // Featured / sold ribbon
                  if (listing.isFeatured || listing.isSold)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: listing.isSold
                              ? AppColors.dark.withValues(alpha: 0.85)
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.isSold ? 'SOLD' : 'FEATURED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (listing.priceLabel.isNotEmpty)
                    Text(
                      listing.priceLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cat.color,
                      ),
                    ),
                  if (listing.isNegotiable)
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Text('Negotiable',
                          style:
                              TextStyle(fontSize: 10, color: context.textDisabled)),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(cat.icon, size: 12, color: context.textDisabled),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.location ?? cat.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10.5, color: context.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(MarketCategory cat) => Container(
        color: cat.color.withValues(alpha: 0.08),
        child: Center(child: Icon(cat.icon, size: 40, color: cat.color)),
      );
}

class _SaveButton extends ConsumerStatefulWidget {
  final ListingModel listing;
  const _SaveButton({required this.listing});

  @override
  ConsumerState<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends ConsumerState<_SaveButton> {
  late bool _saved = widget.listing.isSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() => _saved = !_saved);
        final result = await ref
            .read(savedListingsControllerProvider.notifier)
            .toggle(widget.listing.id);
        if (mounted) setState(() => _saved = result);
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: context.cardBg.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: AppColors.cardShadow,
        ),
        child: Icon(
          _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 17,
          color: _saved ? AppColors.error : AppColors.grey2,
        ),
      ),
    );
  }
}