import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/listing_card.dart';

/// Public seller profile: identity, aggregate rating, reviews and their
/// active listings. Buyers can leave a review here.
class SellerProfileScreen extends ConsumerWidget {
  final String sellerId;
  const SellerProfileScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(sellerRatingProvider(sellerId));
    final reviewsAsync = ref.watch(sellerReviewsProvider(sellerId));
    final listingsAsync = ref.watch(
        sellerListingsProvider((sellerId: sellerId, excludeId: '')));
    final me = ref.watch(currentUserProvider);
    final isMe = me?.id == sellerId;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Seller'),
      ),
      floatingActionButton: isMe
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _leaveReview(context, ref),
              backgroundColor: context.primary,
              icon: const Icon(Icons.rate_review_outlined,
                  color: Colors.white),
              label: const Text('Review',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          // Rating summary
          ratingAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (r) => Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderCol),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          r.total == 0
                              ? '—'
                              : r.average.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 34, fontWeight: FontWeight.w900)),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < r.average.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      r.total == 0
                          ? 'No reviews yet. Be the first to rate this seller after a transaction.'
                          : 'Based on ${r.total} review${r.total == 1 ? '' : 's'} from buyers on campus.',
                      style: TextStyle(
                          fontSize: 13, color: context.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Active listings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          listingsAsync.when(
            loading: () => const AppLoadingWidget.card(),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) => items.isEmpty
                ? Text('No active listings.',
                    style: TextStyle(color: context.textDisabled))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                      onTap: () => context
                          .push('/marketplace/listing/${items[i].id}'),
                    ),
                  ),
          ),

          const SizedBox(height: 20),
          const Text('Reviews',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          reviewsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (reviews) => reviews.isEmpty
                ? Text('No reviews yet.',
                    style: TextStyle(color: context.textDisabled))
                : Column(
                    children: reviews
                        .map((r) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: context.borderCol),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            r.reviewerName ?? 'Student',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600)),
                                      ),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < r.rating
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            size: 14,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (r.comment != null &&
                                      r.comment!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(r.comment!,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: context.textSecondary)),
                                  ],
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _leaveReview(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReviewSheet(sellerId: sellerId),
    );
  }
}

class _ReviewSheet extends ConsumerStatefulWidget {
  final String sellerId;
  const _ReviewSheet({required this.sellerId});

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: context.borderCol,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Rate this seller',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 40,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share details of your experience (optional)',
              filled: true,
              fillColor: context.inputFill,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Submit review'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final me = ref.read(currentUserProvider);
    if (me == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(marketplaceRepositoryProvider).addReview(
            revieweeId: widget.sellerId,
            reviewerId: me.id,
            rating: _rating,
            comment: _commentCtrl.text.trim(),
          );
      ref.invalidate(sellerReviewsProvider(widget.sellerId));
      ref.invalidate(sellerRatingProvider(widget.sellerId));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }
}