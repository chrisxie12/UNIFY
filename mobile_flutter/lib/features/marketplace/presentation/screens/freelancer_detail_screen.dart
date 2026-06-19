import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';

class FreelancerDetailScreen extends ConsumerWidget {
  final String userId;
  const FreelancerDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(freelancerProfileProvider(userId));
    final reviewsAsync = ref.watch(sellerReviewsProvider(userId));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Freelancer'),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (p) => p == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening chat with ${p.name ?? 'freelancer'}…'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.push('/app/messaging');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: context.primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('Hire / Message',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
        orElse: () => null,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (p) {
          if (p == null) {
            return const Center(
                child: Text('This student has no freelancer profile yet.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFDDE8FF),
                    backgroundImage: p.avatar != null && p.avatar!.isNotEmpty
                        ? CachedNetworkImageProvider(p.avatar!)
                        : null,
                    child: p.avatar == null || p.avatar!.isEmpty
                        ? Text(p.initials,
                            style: TextStyle(
                                color: context.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(p.name ?? 'Student',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                            ),
                            if (p.verified) ...[
                              const SizedBox(width: 4),
                              const VerifiedBadge(size: 17),
                            ],
                          ],
                        ),
                        if (p.headline != null)
                          Text(p.headline!,
                              style: TextStyle(
                                  fontSize: 13, color: context.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (p.programme != null) p.programme,
                            if (p.level != null) 'Level ${p.level}',
                          ].whereType<String>().join(' · '),
                          style: TextStyle(
                              fontSize: 12, color: context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  _stat(
                      p.reviewCount == 0
                          ? '—'
                          : p.rating.toStringAsFixed(1),
                      'Rating',
                      context),
                  _stat('${p.completedJobs}', 'Jobs done', context),
                  _stat(
                      p.hourlyRate != null
                          ? 'GHS ${p.hourlyRate!.toStringAsFixed(0)}'
                          : '—',
                      'Per hour',
                      context),
                ],
              ),

              if (p.bio != null && p.bio!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _section('About'),
                const SizedBox(height: 8),
                Text(p.bio!,
                    style: TextStyle(
                        fontSize: 14, height: 1.5, color: context.textSecondary)),
              ],

              if (p.skills.isNotEmpty) ...[
                const SizedBox(height: 20),
                _section('Skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: p.skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: context.primary)),
                          ))
                      .toList(),
                ),
              ],

              if (p.portfolioUrls.isNotEmpty) ...[
                const SizedBox(height: 20),
                _section('Portfolio'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.portfolioUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: p.portfolioUrls[i],
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 130,
                          color: context.cardBg,
                          child: Icon(Icons.broken_image_outlined,
                              color: context.textDisabled),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _section('Reviews'),
              const SizedBox(height: 8),
              reviewsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (reviews) => reviews.isEmpty
                    ? Text('No reviews yet.',
                        style: TextStyle(color: context.textDisabled))
                    : Column(
                        children:
                            reviews.map((r) => _ReviewTile(review: r)).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String value, String label, BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label,
                  style:
                      TextStyle(fontSize: 11, color: context.textSecondary)),
            ],
          ),
        ),
      );

  Widget _section(String title) => Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
}

class _ReviewTile extends StatelessWidget {
  final ListingReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFDDE8FF),
                backgroundImage: review.reviewerAvatar != null &&
                        review.reviewerAvatar!.isNotEmpty
                    ? CachedNetworkImageProvider(review.reviewerAvatar!)
                    : null,
                child: review.reviewerAvatar == null ||
                        review.reviewerAvatar!.isEmpty
                    ? Text(
                        (review.reviewerName ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12))
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(review.reviewerName ?? 'Student',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment!,
                style: TextStyle(
                    fontSize: 13, height: 1.4, color: context.textSecondary)),
          ],
          const SizedBox(height: 6),
          Text(review.createdAt.timeAgo,
              style: TextStyle(fontSize: 11, color: context.textDisabled)),
        ],
      ),
    );
  }
}
