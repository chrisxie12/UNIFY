import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/announcement.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement item;
  final VoidCallback? onTap;

  const AnnouncementCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3)),
            BoxShadow(color: Color(0x05000000), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isPinned) _PinnedBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(item: item),
                  const SizedBox(height: 12),
                  _Content(item: item),
                ],
              ),
            ),
            if (item.imageUrl != null) ...[
              const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: const [
          Icon(Icons.push_pin_rounded, size: 12, color: AppColors.grey2),
          SizedBox(width: 5),
          Text(
            'Pinned announcement',
            style: TextStyle(fontSize: 11, color: AppColors.grey2, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Announcement item;
  const _Header({required this.item});

  static Color _catColor(String cat) {
    switch (cat) {
      case 'urgent':   return const Color(0xFFEF4444);
      case 'academic': return const Color(0xFF0066FF);
      case 'events':   return const Color(0xFF8B5CF6);
      case 'admin':    return const Color(0xFFF59E0B);
      default:         return const Color(0xFF6B7280);
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
    final catColor = _catColor(item.category);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author avatar
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5F7FA),
            border: Border.all(color: AppColors.border),
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
        // Name + timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.authorName ?? 'Campus Admin',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.authorIsVerifiedLeader == true) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.verified_rounded, size: 14, color: context.primary),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _timeLabel(item.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.grey2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Category + urgent badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Chip(
              label: item.category[0].toUpperCase() + item.category.substring(1),
              color: catColor,
            ),
            if (item.isUrgent) ...[
              const SizedBox(height: 4),
              _Chip(
                label: 'Urgent',
                color: const Color(0xFFEF4444),
                icon: Icons.priority_high_rounded,
              ),
            ],
          ],
        ),
        // Unread indicator
        if (!item.isRead) ...[
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 5 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final Announcement item;
  const _Content({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark, height: 1.35,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          item.body,
          style: const TextStyle(fontSize: 13.5, color: AppColors.grey2, height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Post image ────────────────────────────────────────────────────────────────

class _PostImage extends StatelessWidget {
  final String url;
  const _PostImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(0)),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final Announcement item;
  const _Footer({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          const Icon(Icons.remove_red_eye_outlined, size: 13, color: AppColors.grey2),
          const SizedBox(width: 4),
          Text(
            '${item.viewCount}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey2),
          ),
          const Spacer(),
          _FooterBtn(icon: Icons.mode_comment_outlined, label: 'Comment'),
          const SizedBox(width: 18),
          _FooterBtn(icon: Icons.reply_rounded, label: 'Share'),
        ],
      ),
    );
  }
}

class _FooterBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FooterBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.grey2),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.grey2, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
