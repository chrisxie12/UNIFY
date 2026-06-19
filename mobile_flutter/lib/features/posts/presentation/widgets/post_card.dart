import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/post_model.dart';
import '../../../../core/extensions/theme_extensions.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: context.cardBg,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: post.authorAvatar != null
                        ? NetworkImage(post.authorAvatar!)
                        : null,
                    child: post.authorAvatar == null
                        ? Text(
                            (post.authorName ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.authorIsVerifiedLeader == true) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatTime(post.createdAt),
                              style: TextStyle(
                                color: context.textSecondary],
                                fontSize: 12,
                              ),
                            ),
                            if (post.postType == 'question') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Question',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                            if (post.bestAnswerId != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Answered',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (post.isPinned)
                    Icon(Icons.push_pin, size: 18, color: context.textSecondary]),
                ],
              ),
              if (post.title != null) ...[
                const SizedBox(height: 12),
                Text(
                  post.title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                post.body,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary],
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.body.length > 280)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Show more',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              if (post.mediaUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.mediaUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: context.textSecondary],
                      child: Center(
                        child: Icon(Icons.broken_image, color: context.textSecondary]),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 200,
                        color: context.textSecondary],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ],
              if (post.linkUrl != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.textSecondary],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.textSecondary]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.linkUrl!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  _VoteButtons(
                    netVotes: post.netVoteCount,
                    myVote: post.myVote,
                    onUpvote: onUpvote,
                    onDownvote: onDownvote,
                  ),
                  const Spacer(),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: _formatCount(post.commentsCount),
                    color: context.textSecondary],
                    onPressed: onTap,
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: post.isBookmarkedByMe == true
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: _formatCount(post.bookmarksCount),
                    color: post.isBookmarkedByMe == true
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                    onPressed: onBookmark,
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    color: context.textSecondary],
                    onPressed: onShare,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _VoteButtons extends StatelessWidget {
  final int netVotes;
  final String? myVote;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;

  const _VoteButtons({
    required this.netVotes,
    this.myVote,
    this.onUpvote,
    this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onUpvote,
          child: Icon(
            myVote == 'upvote' ? Icons.arrow_upward : Icons.arrow_upward_outlined,
            size: 22,
            color: myVote == 'upvote' ? Theme.of(context).colorScheme.primary : Colors.grey[500],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          netVotes.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: myVote == 'upvote'
                ? Theme.of(context).colorScheme.primary
                : myVote == 'downvote'
                    ? Colors.red
                    : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onDownvote,
          child: Icon(
            myVote == 'downvote' ? Icons.arrow_downward : Icons.arrow_downward_outlined,
            size: 22,
            color: myVote == 'downvote' ? Colors.red : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    this.label,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
