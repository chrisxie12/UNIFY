import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/announcement.dart';
import '../providers/announcement_social_provider.dart';
import 'comment_sheet.dart';
import '../../../../core/extensions/theme_extensions.dart';

// ── Design tokens (local) ─────────────────────────────────────────────────────
const _radiusLg  = 16.0;
const _radiusSm  =  8.0;

const _categoryColors = <String, Color>{
  'general':  Color(0xFF64748B),
  'admin':    Color(0xFFDC2626),
  'events':   Color(0xFF7C3AED),
  'academic': Color(0xFF2563EB),
};

TextStyle _sg(double size, FontWeight weight, Color color, {double? ls, double? h}) =>
    GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: h,
    );

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return DateFormat('MMM d').format(dt);
}

String _fmtNum(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}

// ── Card ──────────────────────────────────────────────────────────────────────
class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, required this.item, this.onTap});

  final Announcement item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(
      announcementLikeProvider((id: item.id, initialCount: item.likesCount)),
    );
    final catKey   = item.category.toLowerCase();
    final catColor = _categoryColors[catKey] ?? const Color(0xFF2563EB);
    final catLabel = item.category[0].toUpperCase() + item.category.substring(1);
    final hasImage = item.imageUrl != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pinned banner ──────────────────────────────────────────────────
            if (item.isPinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.push_pin_rounded, size: 12, color: Color(0xFF2563EB)),
                    const SizedBox(width: 5),
                    Text('Pinned post', style: _sg(11, FontWeight.w600, const Color(0xFF2563EB))),
                  ],
                ),
              ),

            // ── Header ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(avatarUrl: item.authorAvatar, name: item.authorName, size: 40),
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
                                style: _sg(14, FontWeight.w700, context.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.authorIsVerifiedLeader) ...[
                              const SizedBox(width: 3),
                              Icon(Icons.verified_rounded, size: 14, color: context.primary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            if (item.authorLeadershipRole != null) ...[
                              Text(item.authorLeadershipRole!,
                                  style: _sg(12, FontWeight.w400, context.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(' · ', style: _sg(12, FontWeight.w400, context.textSecondary)),
                            ],
                            Text(_timeAgo(item.createdAt),
                                style: _sg(12, FontWeight.w400, context.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(_radiusSm),
                    ),
                    child: Text(catLabel, style: _sg(11, FontWeight.w600, catColor)),
                  ),
                  const SizedBox(width: 4),
                  // Unread dot + more menu
                  Column(
                    children: [
                      if (!item.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 4, right: 4),
                          decoration: BoxDecoration(
                            color: context.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.more_horiz, color: context.textSecondary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Image ──────────────────────────────────────────────────────────
            if (hasImage)
              GestureDetector(
                onDoubleTap: () => ref
                    .read(announcementLikeProvider((id: item.id, initialCount: item.likesCount)).notifier)
                    .toggle(),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // ── Text content ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14, hasImage ? 10 : 0, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.isUrgent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.priority_high_rounded,
                              size: 13, color: Color(0xFFDC2626)),
                          const SizedBox(width: 3),
                          Text('Urgent',
                              style: _sg(11, FontWeight.w700, const Color(0xFFDC2626))),
                        ],
                      ),
                    ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.title}  ',
                          style: _sg(14, FontWeight.w700, context.textPrimary, h: 1.45),
                        ),
                        TextSpan(
                          text: item.body,
                          style: _sg(14, FontWeight.w400, context.textPrimary, h: 1.45),
                        ),
                      ],
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Stats row ──────────────────────────────────────────────────────
            if (likeState.count > 0 || item.viewCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                child: Row(
                  children: [
                    if (likeState.count > 0) ...[
                      Icon(Icons.favorite_rounded, size: 13,
                          color: const Color(0xFFE1306C).withValues(alpha: 0.9)),
                      const SizedBox(width: 4),
                      Text(_fmtNum(likeState.count),
                          style: _sg(12, FontWeight.w500, context.textSecondary)),
                      const SizedBox(width: 10),
                    ],
                    if (item.viewCount > 0) ...[
                      Icon(Icons.visibility_outlined, size: 13, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text('${_fmtNum(item.viewCount)} views',
                          style: _sg(12, FontWeight.w400, context.textSecondary)),
                    ],
                    if (item.commentsCount > 0) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => CommentSheet.show(context, item.id),
                        child: Text(
                          '${_fmtNum(item.commentsCount)} ${item.commentsCount == 1 ? 'comment' : 'comments'}',
                          style: _sg(12, FontWeight.w400, context.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Divider above action row
            Divider(height: 1, thickness: 0.5, color: context.borderCol),

            // ── Action row ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  _ActionBtn(
                    icon: likeState.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    label: 'Like',
                    color: likeState.isLiked ? const Color(0xFFE1306C) : context.textSecondary,
                    onTap: () {
                      onTap?.call();
                      ref
                          .read(announcementLikeProvider((id: item.id, initialCount: item.likesCount)).notifier)
                          .toggle();
                    },
                  ),
                  _ActionBtn(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comment',
                    color: context.textSecondary,
                    onTap: () => CommentSheet.show(context, item.id),
                  ),
                  _ActionBtn(
                    icon: Icons.repeat_rounded,
                    label: 'Reshare',
                    color: context.textSecondary,
                    onTap: () {},
                  ),
                  const Spacer(),
                  _ActionBtn(
                    icon: Icons.send_outlined,
                    label: 'Share',
                    color: context.textSecondary,
                    onTap: () async {
                      await Share.share('${item.title}\n\n${item.body}', subject: item.title);
                      ref.read(announcementSocialRepoProvider).recordShare(item.id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl, this.name, required this.size});

  final String? avatarUrl;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = name?.isNotEmpty == true ? name![0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.primary.withValues(alpha: 0.15),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _Initial(label, context),
              )
            : _Initial(label, context),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String label;
  final BuildContext ctx;
  const _Initial(this.label, this.ctx);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          label,
          style: _sg(16, FontWeight.w700, ctx.primary),
        ),
      );
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(label, style: _sg(12, FontWeight.w500, color)),
          ],
        ),
      ),
    );
  }
}

// ── Pinned label (used by feed_screen) ───────────────────────────────────────
class PinnedSectionLabel extends StatelessWidget {
  final String label;
  const PinnedSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 12, color: Color(0xFF94A3B8)),
          const SizedBox(width: 5),
          Text(
            label,
            style: _sg(11, FontWeight.w700, const Color(0xFF94A3B8), ls: 1.1),
          ),
        ],
      ),
    );
  }
}
