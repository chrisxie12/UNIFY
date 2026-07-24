import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/announcement.dart';
import '../providers/announcement_social_provider.dart';
import 'comment_sheet.dart';
import '../../../../core/extensions/theme_extensions.dart';

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return DateFormat('MMM d').format(dt);
}

String _fmtNum(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  return '$n';
}

class AnnouncementCard extends ConsumerWidget {
  const AnnouncementCard({super.key, required this.item, this.onTap});

  final Announcement item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(
      announcementLikeProvider((id: item.id, initialCount: item.likesCount)),
    );
    final hasImage = item.imageUrl != null;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      color: context.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.isPinned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: context.primary.withValues(alpha: 0.04),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded, size: 12, color: context.primary),
                  const SizedBox(width: 5),
                  Text(
                    'Pinned post',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                _Avatar(avatarUrl: item.authorAvatar, name: item.authorName, size: 36),
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
                                color: textPrimary,
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
                      Row(
                        children: [
                          if (item.authorLeadershipRole != null) ...[
                            Text(
                              item.authorLeadershipRole!,
                              style: TextStyle(fontSize: 11, color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(' · ', style: TextStyle(fontSize: 11, color: textSecondary)),
                          ],
                          Text(_timeAgo(item.createdAt), style: TextStyle(fontSize: 11, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.more_horiz, color: textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: textPrimary, fontSize: 13, height: 1.45),
                children: [
                  TextSpan(
                    text: '${item.title}  ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: item.body,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (item.isUrgent)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Row(
                children: [
                  Icon(Icons.priority_high_rounded, size: 12, color: Color(0xFFDC2626)),
                  SizedBox(width: 3),
                  Text(
                    'Urgent',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),

          if (hasImage) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onDoubleTap: () {
                ref
                    .read(announcementLikeProvider((id: item.id, initialCount: item.likesCount)).notifier)
                    .toggle();
              },
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
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ref
                        .read(announcementLikeProvider((id: item.id, initialCount: item.likesCount)).notifier)
                        .toggle();
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      likeState.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(likeState.isLiked),
                      size: 24,
                      color: likeState.isLiked ? const Color(0xFFE1306C) : textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => CommentSheet.show(context, item.id),
                  child: Icon(Icons.mode_comment_outlined, size: 22, color: textPrimary),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.repeat_rounded, size: 22, color: textPrimary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await Share.share('${item.title}\n\n${item.body}', subject: item.title);
                    ref.read(announcementSocialRepoProvider).recordShare(item.id);
                  },
                  child: Icon(Icons.send_outlined, size: 22, color: textPrimary),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.bookmark_border, size: 22, color: textPrimary),
                ),
              ],
            ),
          ),

          if (likeState.count > 0 || item.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
              child: Row(
                children: [
                  if (likeState.count > 0)
                    Text(
                      '${_fmtNum(likeState.count)} likes',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                  if (likeState.count > 0 && item.commentsCount > 0)
                    const SizedBox(width: 4),
                  if (item.commentsCount > 0)
                    GestureDetector(
                      onTap: () => CommentSheet.show(context, item.id),
                      child: Text(
                        '${_fmtNum(item.commentsCount)} ${item.commentsCount == 1 ? 'comment' : 'comments'}',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 4),
          Divider(height: 1, thickness: 0.3, color: context.borderCol.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

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
                errorWidget: (_, __, ___) => Center(
                  child: Text(label, style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.w700, color: context.primary)),
                ),
              )
            : Center(
                child: Text(label, style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.w700, color: context.primary)),
              ),
      ),
    );
  }
}
