import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../../core/extensions/theme_extensions.dart';

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;

  const LoadingOverlay({super.key, required this.loading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0x80FFFFFF),
              child: Center(
                child: CircularProgressIndicator(
                  color: context.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AnnouncementCardShimmer extends StatelessWidget {
  const AnnouncementCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(80, 14),
                  const SizedBox(height: 8),
                  _box(double.infinity, 14),
                  const SizedBox(height: 6),
                  _box(200, 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h) => Container(
        width: w, height: h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}

/// Sliver shimmer list — use inside CustomScrollView
class FeedShimmer extends StatelessWidget {
  final int count;
  const FeedShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const AnnouncementCardShimmer(),
          childCount: count,
        ),
      ),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            ),
            const SizedBox(height: 16),
            Container(
              width: 160, height: 20,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120, height: 14,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}
