import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Reusable story / avatar circle for the feed stories row.
///
/// - [hasRing] wraps the circle in a blue→purple gradient ring.
/// - [isSelf]  shows the "+" badge for the current user's story slot.
class StoryCircle extends StatelessWidget {
  const StoryCircle({
    super.key,
    required this.name,
    this.imageUrl,
    this.initials,
    this.color,
    this.hasRing = false,
    this.isSelf = false,
    this.size = 52,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final String? initials;
  final Color? color;
  final bool hasRing;
  final bool isSelf;
  final double size;
  final VoidCallback? onTap;

  static const _ringGradient = LinearGradient(
    colors: [
      Color(0xFFE1306C),
      Color(0xFFFD1D1D),
      Color(0xFFF56040),
      Color(0xFFFCAF45),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final fallbackColor = color ?? context.primary;
    final label = initials ?? (name.isNotEmpty ? name[0].toUpperCase() : 'U');

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fallbackColor,
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _InitialContent(label: label),
              )
            : _InitialContent(label: label),
      ),
    );

    if (hasRing) {
      avatar = Container(
        width: size + 4,
        height: size + 4,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _ringGradient,
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.cardBg,
          ),
          padding: const EdgeInsets.all(1.5),
          child: avatar,
        ),
      );
    }

    if (isSelf) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.borderCol, width: 1.5),
              color: context.inputFill,
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _InitialContent(label: label),
                    )
                  : _InitialContent(label: label),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: context.primary,
                shape: BoxShape.circle,
                border: Border.all(color: context.cardBg, width: 1.5),
              ),
              child: const Icon(Icons.add, size: 11, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          const SizedBox(height: 5),
          SizedBox(
            width: size + 8,
            child: Text(
              isSelf ? 'Your Story' : name.split(' ').first,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelf ? context.textSecondary : context.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialContent extends StatelessWidget {
  final String label;
  const _InitialContent({required this.label});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}
