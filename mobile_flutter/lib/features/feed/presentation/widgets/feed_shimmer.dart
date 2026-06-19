import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.border,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(context, 60, 20, radius: 6),
              const SizedBox(width: 8),
              _box(context, 40, 20, radius: 6),
            ],
          ),
          const SizedBox(height: 12),
          _box(context, double.infinity, 18, radius: 4),
          const SizedBox(height: 8),
          _box(context, double.infinity, 14, radius: 4),
          const SizedBox(height: 4),
          _box(context, 200, 14, radius: 4),
          const SizedBox(height: 16),
          Row(
            children: [
              _circle(context, 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(context, 80, 12, radius: 4),
                  const SizedBox(height: 4),
                  _box(context, 60, 10, radius: 4),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _box(BuildContext context, double w, double h, {double radius = 4}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _circle(BuildContext context, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: context.cardBg, shape: BoxShape.circle),
      );
}
