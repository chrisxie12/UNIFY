import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/announcement_social_provider.dart';
import '../providers/feed_provider.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../domain/entities/announcement.dart';

class PostOptionsSheet extends ConsumerWidget {
  final Announcement post;

  const PostOptionsSheet({super.key, required this.post});

  static void show(BuildContext context, Announcement post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PostOptionsSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isAuthor = currentUserId != null && currentUserId == post.authorId;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: USpacing.sm),
          Container(width: 32, height: 4, decoration: BoxDecoration(color: context.textDisabled, borderRadius: BorderRadius.circular(2))),
          SizedBox(height: USpacing.sm),
          if (isAuthor) ...[
            _OptionTile(
              icon: PhosphorIconsBold.pencilSimpleLine,
              label: 'Edit post',
              onTap: () {
                Navigator.pop(context);
                context.push('/announcement/edit/${post.id}');
              },
            ),
            _OptionTile(
              icon: PhosphorIconsBold.trash,
              label: 'Delete post',
              destructive: true,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
            _divider(context),
          ],
          _OptionTile(
            icon: PhosphorIconsBold.shieldCheck,
            label: 'Report post',
            onTap: () {
              Navigator.pop(context);
              _reportPost(context, ref);
            },
          ),
          _OptionTile(
            icon: PhosphorIconsBold.eyeSlash,
            label: 'Hide this post',
            onTap: () async {
              Navigator.pop(context);
              final repo = ref.read(announcementSocialRepoProvider);
              await repo.hidePost(post.id);
              if (!context.mounted) return;
              ref.invalidate(feedProvider);
              UnifySnackbar.info(context, 'Post hidden');
            },
          ),
          _OptionTile(
            icon: PhosphorIconsBold.copy,
            label: 'Copy link',
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: 'https://unify.app/post/${post.id}'));
              UnifySnackbar.success(context, 'Link copied');
            },
          ),
          SizedBox(height: USpacing.sm),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Supabase.instance.client.from('announcements').delete().eq('id', post.id);
                if (!context.mounted) return;
                ref.invalidate(feedProvider);
                UnifySnackbar.success(context, 'Post deleted');
              } catch (e) {
                if (!context.mounted) return;
                UnifySnackbar.error(context, 'Failed to delete post');
              }
            },
            child: Text('Delete', style: TextStyle(color: context.error)),
          ),
        ],
      ),
    );
  }

  void _reportPost(BuildContext context, WidgetRef ref) {
    final reasons = ['Spam', 'Harassment', 'Misinformation', 'Inappropriate content', 'Other'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: USpacing.sm),
            Container(width: 32, height: 4, decoration: BoxDecoration(color: context.textDisabled, borderRadius: BorderRadius.circular(2))),
            SizedBox(height: USpacing.md),
            Text('Report post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary)),
            SizedBox(height: USpacing.sm),
            ...reasons.map((r) => ListTile(
                  leading: Icon(PhosphorIconsBold.flag, size: 20, color: context.textSecondary),
                  title: Text(r, style: TextStyle(color: context.textPrimary)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final repo = ref.read(announcementSocialRepoProvider);
                    await repo.reportPost(announcementId: post.id, reason: r);
                    if (!context.mounted) return;
                    UnifySnackbar.success(context, 'Report submitted');
                  },
                )),
            SizedBox(height: USpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback onTap;

  const _OptionTile({required this.icon, required this.label, this.destructive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = destructive ? context.error : context.textPrimary;
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}

Widget _divider(BuildContext context) => Divider(height: 1, indent: 16, endIndent: 16, color: context.borderSubtle);
