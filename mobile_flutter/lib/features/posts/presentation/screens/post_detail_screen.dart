import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/post_model.dart';
import '../../data/models/post_comment_model.dart';
import '../providers/post_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  String? _replyToId;
  String? _replyToName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));
    final userId = ref.read(supabaseProvider).auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'pin') {
                final post = await ref.read(postDetailProvider(widget.postId).future);
                final repo = ref.read(postRepositoryProvider);
                await repo.togglePin(widget.postId, !post.isPinned);
                ref.invalidate(postDetailProvider(widget.postId));
              } else if (value == 'delete') {
                final repo = ref.read(postRepositoryProvider);
                await repo.deletePost(widget.postId);
                if (mounted) context.pop();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pin', child: Text('Toggle pin')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (post) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  _PostContent(post: post, userId: userId),
                  const Divider(height: 1),
                  if (_replyToId != null)
                    Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 16, color: const Color(0xFF0066FF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Replying to $_replyToName',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _replyToId = null;
                              _replyToName = null;
                            }),
                            child: Icon(Icons.close, size: 18, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  commentsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: Text('Error loading comments')),
                    ),
                    data: (comments) {
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text('No comments yet', style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: comments.map((comment) => _CommentTile(
                          comment: comment,
                          depth: 0,
                          onReply: (commentId, name) => setState(() {
                            _replyToId = commentId;
                            _replyToName = name;
                          }),
                          userId: userId,
                          postId: widget.postId,
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyToId != null ? 'Write a reply...' : 'Write a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(post.id, userId),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _commentController.text.trim().isNotEmpty
                        ? () => _submitComment(post.id, userId)
                        : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _commentController.text.trim().isNotEmpty
                            ? const Color(0xFF0066FF)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: _commentController.text.trim().isNotEmpty
                            ? Colors.white
                            : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment(String postId, String? userId) async {
    if (_commentController.text.trim().isEmpty || userId == null) return;

    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.createComment(PostCommentModel(
        id: '',
        postId: postId,
        parentId: _replyToId,
        authorId: userId,
        body: _commentController.text.trim(),
        likesCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      _commentController.clear();
      setState(() {
        _replyToId = null;
        _replyToName = null;
      });
      ref.invalidate(postCommentsProvider(widget.postId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment')),
        );
      }
    } finally {
      if (mounted) setState(() {});
    }
  }
}

class _PostContent extends ConsumerWidget {
  final PostModel post;
  final String? userId;

  const _PostContent({required this.post, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                backgroundImage: post.authorAvatar != null
                    ? NetworkImage(post.authorAvatar!)
                    : null,
                child: post.authorAvatar == null
                    ? Text(
                        (post.authorName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0066FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.authorIsVerifiedLeader == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF0066FF), size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateTime(post.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (post.isPinned)
                Icon(Icons.push_pin, size: 18, color: Colors.grey[400]),
            ],
          ),
          if (post.title != null) ...[
            const SizedBox(height: 16),
            Text(
              post.title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            post.body,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          if (post.mediaUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.mediaUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400])),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[100],
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: const Color(0xFF0066FF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.linkUrl!,
                      style: const TextStyle(color: Color(0xFF0066FF), fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionChip(
                icon: post.isLikedByMe == true ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(post.likesCount),
                color: post.isLikedByMe == true ? const Color(0xFF0066FF) : Colors.grey[600],
                onTap: () async {
                  final repo = ref.read(postRepositoryProvider);
                  final uid = userId;
                  if (uid != null) {
                    if (post.isLikedByMe == true) {
                      await repo.unlikePost(post.id, uid);
                    } else {
                      await repo.likePost(post.id, uid);
                    }
                    ref.invalidate(postDetailProvider(post.id));
                  }
                },
              ),
              _ActionChip(
                icon: Icons.chat_bubble_outline,
                label: _formatCount(post.commentsCount),
                color: Colors.grey[600],
                onTap: null,
              ),
              _ActionChip(
                icon: post.isBookmarkedByMe == true ? Icons.bookmark : Icons.bookmark_border,
                label: _formatCount(post.bookmarksCount),
                color: post.isBookmarkedByMe == true ? const Color(0xFF0066FF) : Colors.grey[600],
                onTap: () async {
                  final repo = ref.read(postRepositoryProvider);
                  final uid = userId;
                  if (uid != null) {
                    if (post.isBookmarkedByMe == true) {
                      await repo.unbookmarkPost(post.id, uid);
                    } else {
                      await repo.bookmarkPost(post.id, uid);
                    }
                    ref.invalidate(postDetailProvider(post.id));
                  }
                },
              ),
              _ActionChip(
                icon: Icons.share_outlined,
                label: null,
                color: Colors.grey[600],
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dt);
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(label!, style: TextStyle(fontSize: 12, color: color)),
          ],
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final PostCommentModel comment;
  final int depth;
  final Function(String commentId, String name) onReply;
  final String? userId;
  final String postId;

  const _CommentTile({
    required this.comment,
    required this.depth,
    required this.onReply,
    required this.userId,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: depth > 0 ? 16.0 : 0,
            right: 16,
            top: 0,
          ),
          decoration: depth > 0
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[200]!, width: 2),
                  ),
                )
              : null,
          child: Padding(
            padding: EdgeInsets.only(left: depth > 0 ? 12 : 16, top: 12, right: 16, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: comment.authorAvatar != null
                          ? NetworkImage(comment.authorAvatar!)
                          : null,
                      child: comment.authorAvatar == null
                          ? Text(
                              (comment.authorName ?? 'U')[0].toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFF0066FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.authorName ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (comment.authorIsVerifiedLeader == true) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Color(0xFF0066FF), size: 14),
                              ],
                              const SizedBox(width: 8),
                              Text(
                                _timeAgo(comment.createdAt),
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment.body,
                            style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 14,
                                      color: comment.isLikedByMe == true
                                          ? const Color(0xFF0066FF)
                                          : Colors.grey[500],
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${comment.likesCount}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: comment.isLikedByMe == true
                                            ? const Color(0xFF0066FF)
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => onReply(comment.id, comment.authorName ?? 'User'),
                                child: Text(
                                  'Reply',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (comment.replies != null)
          ...comment.replies!.map((reply) => _CommentTile(
            comment: reply,
            depth: depth + 1,
            onReply: onReply,
            userId: userId,
            postId: postId,
          )),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(dt);
  }
}
