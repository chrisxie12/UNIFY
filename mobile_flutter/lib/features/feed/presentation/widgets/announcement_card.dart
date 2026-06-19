import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/announcement.dart';
import '../../../../core/extensions/theme_extensions.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.item, this.onTap});

  final Announcement item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderCol, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isPinned) _PinnedBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(item: item),
                  const SizedBox(height: 10),
                  _Content(item: item),
                ],
              ),
            ),
            if (item.imageUrl != null) ...[
              const SizedBox(height: 10),
              _PostImage(url: item.imageUrl!),
            ],
            _Footer(item: item),
          ],
        ),
      ),
    );
  }
}

// ── Pinned banner ─────────────────────────────────────────────────────────────

class _PinnedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded, size: 11, color: context.textSecondary),
          const SizedBox(width: 4),
          Text(
            'Pinned',
            style: TextStyle(fontSize: 11, color: context.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.item});

  final Announcement item;

  static Color _catColor(String cat, BuildContext context) {
    switch (cat) {
      case 'urgent':   return const Color(0xFFEF4444);
      case 'academic': return context.primary;
      case 'events':   return const Color(0xFF7C3AED);
      case 'admin':    return const Color(0xFFF59E0B);
      default:         return context.textSecondary;
    }
  }

  static String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _catColor(item.category, context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.inputFill,
            border: Border.all(color: context.borderCol),
          ),
          child: item.authorAvatar != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: item.authorAvatar!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _AuthorInitial(item.authorName),
                  ),
                )
              : _AuthorInitial(item.authorName),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.authorName ?? 'Campus Admin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.authorIsVerifiedLeader == true) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.verified_rounded, size: 13, color: context.primary),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text(
                _timeLabel(item.createdAt),
                style: TextStyle(fontSize: 11, color: context.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Chip(
              label: item.category[0].toUpperCase() + item.category.substring(1),
              color: catColor,
            ),
            if (item.isUrgent) ...[
              const SizedBox(height: 3),
              const _Chip(label: 'Urgent', color: Color(0xFFEF4444), icon: Icons.priority_high_rounded),
            ],
          ],
        ),
        if (!item.isRead) ...[
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
          ),
        ],
      ],
    );
  }
}

class _AuthorInitial extends StatelessWidget {
  final String? name;
  const _AuthorInitial(this.name);

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      name?.isNotEmpty == true ? name![0].toUpperCase() : 'U',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 5 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
            height: 1.35,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          item.body,
          style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Post image ────────────────────────────────────────────────────────────────

class _PostImage extends StatelessWidget {
  const _PostImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.remove_red_eye_outlined, size: 13, color: context.textDisabled),
          const SizedBox(width: 4),
          Text(
            '${item.viewCount}',
            style: TextStyle(fontSize: 11, color: context.textDisabled),
          ),
          const Spacer(),
          const _FooterBtn(icon: Icons.mode_comment_outlined, label: 'Comment'),
          const _FooterBtn(icon: Icons.reply_rounded, label: 'Share'),
        ],
      ),
    );
  }
}

class _FooterBtn extends StatelessWidget {
  const _FooterBtn({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: context.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
