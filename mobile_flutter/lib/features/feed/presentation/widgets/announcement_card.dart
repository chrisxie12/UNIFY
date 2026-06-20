import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/announcement.dart';
import '../../../../core/extensions/theme_extensions.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.item, this.onTap});

  final Announcement item;
  final VoidCallback? onTap;

  static String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.isPinned)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Icon(Icons.push_pin_rounded, size: 11, color: context.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Pinned post',
                  style: TextStyle(fontSize: 11, color: context.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

        // ── Post header ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              _PostAvatar(avatarUrl: item.authorAvatar, name: item.authorName),
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
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.authorIsVerifiedLeader) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.verified_rounded, size: 13, color: context.primary),
                        ],
                      ],
                    ),
                    if (item.authorLeadershipRole != null)
                      Text(
                        item.authorLeadershipRole!,
                        style: TextStyle(fontSize: 11, color: context.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: context.textPrimary, size: 20),
                onPressed: () {},
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // ── Image ────────────────────────────────────────────────────────────
        if (hasImage)
          GestureDetector(
            onDoubleTap: onTap,
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          )
        else
          // Text-only post body shown between header and actions
          Container(
            width: double.infinity,
            color: context.inputFill,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isUrgent)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.priority_high_rounded, size: 13, color: Color(0xFFEF4444)),
                        SizedBox(width: 3),
                        Text(
                          'Urgent',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.5),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

        // ── Action row ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
          child: Row(
            children: [
              _ActionBtn(icon: Icons.favorite_border, onPressed: onTap),
              const SizedBox(width: 2),
              _ActionBtn(icon: Icons.chat_bubble_outline_rounded, onPressed: () {}),
              const SizedBox(width: 2),
              _ActionBtn(icon: Icons.send_outlined, onPressed: () {}),
              const Spacer(),
              _ActionBtn(icon: Icons.bookmark_border_rounded, onPressed: () {}),
            ],
          ),
        ),

        // ── View count ───────────────────────────────────────────────────────
        if (item.viewCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Text(
              '${item.viewCount} ${item.viewCount == 1 ? 'view' : 'views'}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
            ),
          ),

        const SizedBox(height: 4),

        // ── Caption (image posts only — text posts already show body above) ──
        if (hasImage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${item.authorName ?? 'Campus Admin'} ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '${item.title} — ${item.body}',
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 4),

        // ── Timestamp ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _timeLabel(item.createdAt).toUpperCase(),
            style: TextStyle(fontSize: 10, color: context.textSecondary, letterSpacing: 0.3),
          ),
        ),

        const SizedBox(height: 12),
        Divider(height: 1, thickness: 0.5, color: context.borderCol),
      ],
    );
  }
}

class _PostAvatar extends StatelessWidget {
  const _PostAvatar({this.avatarUrl, this.name});

  final String? avatarUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.inputFill,
        border: Border.all(color: context.borderCol, width: 0.5),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _Initial(name),
              )
            : _Initial(name),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String? name;
  const _Initial(this.name);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name?.isNotEmpty == true ? name![0].toUpperCase() : 'U',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
        ),
      );
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: context.textPrimary, size: 26),
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
    );
  }
}
