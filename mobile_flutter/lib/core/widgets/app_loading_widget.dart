import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../design_system/tokens.dart';
import '../extensions/theme_extensions.dart';

/// Themed shimmer loading widget — the companion to [AppEmptyWidget] and
/// [AppErrorWidget] for consistent async state handling.
///
/// Three named constructors cover the most common loading patterns:
///
/// ```dart
/// // Single card placeholder
/// const AppLoadingWidget.card()
///
/// // Scrollable list of N rows
/// AppLoadingWidget.list(itemCount: 5)
///
/// // Profile header (avatar + lines)
/// const AppLoadingWidget.profile()
/// ```
///
/// Shimmer colours come from [BuildContext.shimmerBase] and
/// [BuildContext.shimmerHighlight], so they adapt to light / dark mode.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget.card({super.key})
      : _variant = _Variant.card,
        _itemCount = 1;

  const AppLoadingWidget.list({super.key, int itemCount = 3})
      : _variant = _Variant.list,
        _itemCount = itemCount;

  const AppLoadingWidget.profile({super.key})
      : _variant = _Variant.profile,
        _itemCount = 1;

  final _Variant _variant;
  final int _itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.shimmerBase,
      highlightColor: context.shimmerHighlight,
      child: switch (_variant) {
        _Variant.card    => const _CardSkeleton(),
        _Variant.list    => _ListSkeleton(count: _itemCount),
        _Variant.profile => const _ProfileSkeleton(),
      },
    );
  }
}

// ── Variants ──────────────────────────────────────────────────────────────────

enum _Variant { card, list, profile }

// ── Skeleton primitives ───────────────────────────────────────────────────────

// Shimmer replaces the white fill colour with the gradient; children of
// Shimmer.fromColors must use opaque colours for the effect to show.

Widget _box(double w, double h, {double radius = URadius.md}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

Widget _line({double? width, double height = 12, double radius = URadius.pill}) =>
    _box(width ?? double.infinity, height, radius: radius);

// ── Card skeleton ─────────────────────────────────────────────────────────────

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: USpacing.page,
      child: Container(
        padding: USpacing.cardPad,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: URadius.baseAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(44, 44, radius: URadius.pill),
                const SizedBox(width: USpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line(height: 14, width: 140),
                      const SizedBox(height: USpacing.xs),
                      _line(height: 11, width: 90),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: USpacing.base),
            _line(height: 14),
            const SizedBox(height: USpacing.xs),
            _line(height: 14),
            const SizedBox(height: USpacing.xs),
            _line(height: 14, width: 200),
            const SizedBox(height: USpacing.base),
            _box(double.infinity, 160, radius: URadius.md),
          ],
        ),
      ),
    );
  }
}

// ── List skeleton ─────────────────────────────────────────────────────────────

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: USpacing.page,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: USpacing.md),
      itemBuilder: (_, __) => const _ListRowSkeleton(),
    );
  }
}

class _ListRowSkeleton extends StatelessWidget {
  const _ListRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: USpacing.cardPad,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: URadius.mdAll,
      ),
      child: Row(
        children: [
          _box(48, 48, radius: URadius.pill),
          const SizedBox(width: USpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(height: 13, width: 160),
                const SizedBox(height: USpacing.xs),
                _line(height: 11, width: 110),
              ],
            ),
          ),
          const SizedBox(width: USpacing.md),
          _line(height: 11, width: 36),
        ],
      ),
    );
  }
}

// ── Profile skeleton ──────────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: USpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name block
          Row(
            children: [
              _box(72, 72, radius: URadius.pill),
              const SizedBox(width: USpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(height: 16, width: 160),
                    const SizedBox(height: USpacing.sm),
                    _line(height: 12, width: 120),
                    const SizedBox(height: USpacing.sm),
                    _line(height: 11, width: 90),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: USpacing.xl),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBox(),
              _StatBox(),
              _StatBox(),
            ],
          ),
          const SizedBox(height: USpacing.xl),

          // Bio lines
          _line(height: 12),
          const SizedBox(height: USpacing.xs),
          _line(height: 12),
          const SizedBox(height: USpacing.xs),
          _line(height: 12, width: 220),
          const SizedBox(height: USpacing.xl),

          // Action button
          _box(double.infinity, 44, radius: URadius.base),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _box(40, 18, radius: URadius.sm),
        const SizedBox(height: USpacing.xs),
        _box(56, 11, radius: URadius.pill),
      ],
    );
  }
}
