import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/community_content_models.dart';
import '../providers/communities_provider.dart';
import '../../../snapshots/presentation/widgets/snapshot_tray.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final String communityId;
  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityDetailProvider(communityId));

    return communityAsync.when(
      data: (community) {
        if (community == null) {
          return const Scaffold(
            body: Center(child: Text('Community not found')),
          );
        }
        return _CommunityDetailView(community: community);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────

class _CommunityDetailView extends ConsumerWidget {
  final community;
  const _CommunityDetailView({required this.community});

  static const _tabs = [
    'Announcements',
    'Discussions',
    'Resources',
    'Media',
    'Members',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync =
        ref.watch(communityMembershipProvider(community.id as String));
    final role = membershipAsync.valueOrNull;
    final isMember = role != null;
    final primary = context.primary;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerScrolled) => [
            SliverOverlapAbsorber(
              handle:
                  NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18),
                  color: innerScrolled ? AppColors.dark : Colors.white,
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(CupertinoIcons.ellipsis_vertical,
                        size: 18),
                    color: innerScrolled ? AppColors.dark : Colors.white,
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _CommunityHeader(
                    community: community,
                    role: role,
                    isMember: isMember,
                    primary: primary,
                  ),
                ),
                bottom: TabBar(
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  labelColor: primary,
                  unselectedLabelColor: AppColors.grey3,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  indicatorColor: primary,
                  indicatorWeight: 2.5,
                  dividerColor: AppColors.border,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _AnnouncementsTab(communityId: community.id as String),
              _DiscussionsTab(
                communityId: community.id as String,
                isMember: isMember,
                role: role,
              ),
              _ResourcesTab(
                communityId: community.id as String,
                isMember: isMember,
              ),
              _MediaTab(communityId: community.id as String),
              _MembersTab(communityId: community.id as String),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class _CommunityHeader extends ConsumerWidget {
  final community;
  final String? role;
  final bool isMember;
  final Color primary;

  const _CommunityHeader({
    required this.community,
    required this.role,
    required this.isMember,
    required this.primary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Banner background
        (community.coverUrl as String?) != null
            ? Image.network(
                community.coverUrl as String,
                fit: BoxFit.cover,
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, context.primaryDark],
                  ),
                ),
              ),

        // Dark gradient overlay for text legibility
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          left: 20,
          right: 20,
          bottom: 56, // above tab bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: (community.avatarUrl as String?) != null
                      ? DecorationImage(
                          image: NetworkImage(community.avatarUrl as String),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (community.avatarUrl as String?) == null
                    ? Center(
                        child: Text(
                          (community.name as String)
                              .trim()
                              .split(' ')
                              .take(2)
                              .map((w) => w.isNotEmpty ? w[0] : '')
                              .join()
                              .toUpperCase(),
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 10),

              // Name + badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      community.name as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const VerifiedBadge(size: 20, tooltip: 'Verified Community'),
                ],
              ),

              // Programme · Level
              if ((community.programme as String?) != null ||
                  (community.level as String?) != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    if ((community.programme as String?) != null)
                      community.programme as String,
                    if ((community.level as String?) != null)
                      community.level as String,
                  ].join(' · '),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Member count + join button
              Row(
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Text(
                    '${community.memberCount} members',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  _HeaderJoinButton(
                    communityId: community.id as String,
                    role: role,
                    isMember: isMember,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderJoinButton extends ConsumerWidget {
  final String communityId;
  final String? role;
  final bool isMember;

  const _HeaderJoinButton({
    required this.communityId,
    required this.role,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(communityMembershipProvider(communityId));
    final notifier =
        ref.read(communityMembershipProvider(communityId).notifier);
    final isLoading = membershipAsync.isLoading;
    final isOwner = role == 'owner';

    if (isOwner) {
      return _pillButton('Manage', context.primary, Colors.white, null);
    }

    return _pillButton(
      isMember ? 'Leave' : 'Join',
      isMember ? Colors.white.withValues(alpha: 0.2) : Colors.white,
      isMember ? Colors.white : context.primary,
      isLoading
          ? null
          : () => isMember ? notifier.leave() : notifier.join(),
    );
  }

  Widget _pillButton(
      String label, Color bg, Color fg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Helper mixin for all tabs ─────────────────────────────────

Widget _tabScaffold(BuildContext context, Widget sliver, {Widget? header}) {
  return Builder(
    builder: (context) => CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        if (header != null) SliverToBoxAdapter(child: header),
        sliver,
      ],
    ),
  );
}

// ── Announcements tab ─────────────────────────────────────────

class _AnnouncementsTab extends ConsumerWidget {
  final String communityId;
  const _AnnouncementsTab({required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync =
        ref.watch(communityAnnouncementsProvider(communityId));

    return _tabScaffold(
      context,
      header: SnapshotTray(communityId: communityId),
      announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return SliverFillRemaining(
              child: _EmptyState(
                icon: Icons.campaign_outlined,
                title: 'No announcements yet',
                subtitle: 'Official announcements from class reps\nwill appear here.',
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            sliver: SliverList.builder(
              itemCount: announcements.length,
              itemBuilder: (context, i) =>
                  _AnnouncementRow(data: announcements[i]),
            ),
          );
        },
        loading: () => const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SliverFillRemaining(
          child: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AnnouncementRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final p = data['profiles'] as Map<String, dynamic>?;
    final name = p?['full_name'] as String? ?? 'Admin';
    final isVerified = p?['is_verified_leader'] as bool? ?? false;
    final isPinned = data['is_pinned'] as bool? ?? false;
    final isUrgent = (data['category'] as String?) == 'urgent';
    final createdAt = DateTime.tryParse(data['created_at'] as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPinned)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded,
                      size: 12, color: context.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned',
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.surface,
                      backgroundImage: (p?['avatar_url'] as String?) != null
                          ? NetworkImage(p!['avatar_url'] as String)
                          : null,
                      child: (p?['avatar_url'] as String?) == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              if (isVerified) ...[
                                const SizedBox(width: 3),
                                const VerifiedBadge(size: 13),
                              ],
                            ],
                          ),
                          if (createdAt != null)
                            Text(
                              DateFormat('MMM d · h:mm a').format(createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.grey3),
                            ),
                        ],
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  data['title'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['body'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey1,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Discussions tab ───────────────────────────────────────────

class _DiscussionsTab extends ConsumerStatefulWidget {
  final String communityId;
  final bool isMember;
  final String? role;

  const _DiscussionsTab({
    required this.communityId,
    required this.isMember,
    required this.role,
  });

  @override
  ConsumerState<_DiscussionsTab> createState() => _DiscussionsTabState();
}

class _DiscussionsTabState extends ConsumerState<_DiscussionsTab> {
  bool _composing = false;
  final _bodyCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_bodyCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      final client = ref.read(supabaseProvider);
      final user = client.auth.currentUser!;
      await ref.read(communitiesRepositoryProvider).createPost(
        communityId: widget.communityId,
        authorId: user.id,
        body: _bodyCtrl.text.trim(),
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      );
      _bodyCtrl.clear();
      _titleCtrl.clear();
      setState(() => _composing = false);
      ref.invalidate(communityPostsProvider(widget.communityId));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider(widget.communityId));

    return Stack(
      children: [
        _tabScaffold(
          context,
          postsAsync.when(
            data: (posts) {
              if (!widget.isMember) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    icon: Icons.lock_outline_rounded,
                    title: 'Members only',
                    subtitle: 'Join this community to\nread and post discussions.',
                  ),
                );
              }
              if (posts.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No discussions yet',
                    subtitle: 'Start the first conversation!',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                sliver: SliverList.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, i) => _PostCard(post: posts[i]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ),

        // Compose panel at bottom
        if (widget.isMember)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _composing
                ? _ComposePanel(
                    bodyCtrl: _bodyCtrl,
                    titleCtrl: _titleCtrl,
                    submitting: _submitting,
                    onCancel: () => setState(() => _composing = false),
                    onSubmit: _submit,
                  )
                : GestureDetector(
                    onTap: () => setState(() => _composing = true),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 16,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: context.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Start a discussion…',
                            style: TextStyle(
                              color: AppColors.grey3,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _ComposePanel extends StatelessWidget {
  final TextEditingController bodyCtrl;
  final TextEditingController titleCtrl;
  final bool submitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _ComposePanel({
    required this.bodyCtrl,
    required this.titleCtrl,
    required this.submitting,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: titleCtrl,
            autofocus: true,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dark),
            decoration: const InputDecoration(
              hintText: 'Title (optional)',
              hintStyle: TextStyle(color: AppColors.grey3),
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          TextField(
            controller: bodyCtrl,
            maxLines: 4,
            minLines: 2,
            style:
                const TextStyle(fontSize: 14, color: AppColors.dark, height: 1.5),
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              hintStyle: TextStyle(color: AppColors.grey3),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.grey2)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: submitting ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPostModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final name = post.authorName ?? 'Member';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isPinned)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded,
                      size: 12, color: context.primary),
                  const SizedBox(width: 4),
                  Text('Pinned',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.primary)),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface,
                backgroundImage: post.authorAvatar != null
                    ? NetworkImage(post.authorAvatar!)
                    : null,
                child: post.authorAvatar == null
                    ? Text(name[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600))
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                        if (post.authorIsVerified) ...[
                          const SizedBox(width: 3),
                          const VerifiedBadge(size: 13),
                        ],
                      ],
                    ),
                    Text(
                      DateFormat('MMM d · h:mm a').format(post.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (post.title != null) ...[
            const SizedBox(height: 10),
            Text(
              post.title!,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            post.body,
            style: const TextStyle(
                fontSize: 14, color: AppColors.grey1, height: 1.5),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite_border_rounded,
                  size: 16, color: AppColors.grey3),
              const SizedBox(width: 4),
              Text('${post.reactionCount}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey3)),
              const SizedBox(width: 14),
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: AppColors.grey3),
              const SizedBox(width: 4),
              Text('${post.commentCount}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Resources tab ─────────────────────────────────────────────

class _ResourcesTab extends ConsumerWidget {
  final String communityId;
  final bool isMember;

  const _ResourcesTab(
      {required this.communityId, required this.isMember});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync =
        ref.watch(communityResourcesProvider(communityId));

    return _tabScaffold(
      context,
      resourcesAsync.when(
        data: (resources) {
          if (!isMember) {
            return SliverFillRemaining(
              child: _EmptyState(
                icon: Icons.lock_outline_rounded,
                title: 'Members only',
                subtitle: 'Join this community to\naccess shared resources.',
              ),
            );
          }
          if (resources.isEmpty) {
            return SliverFillRemaining(
              child: _EmptyState(
                icon: Icons.folder_open_outlined,
                title: 'No resources yet',
                subtitle:
                    'Lecture notes, past questions,\nand more will appear here.',
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            sliver: SliverList.builder(
              itemCount: resources.length,
              itemBuilder: (context, i) =>
                  _ResourceCard(resource: resources[i]),
            ),
          );
        },
        loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator())),
        error: (e, _) =>
            SliverFillRemaining(child: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final CommunityResourceModel resource;
  const _ResourceCard({required this.resource});

  static const _categoryLabels = <String, String>{
    'lecture_notes': 'Lecture Notes',
    'past_questions': 'Past Questions',
    'assignments': 'Assignments',
    'projects': 'Projects',
    'general': 'General',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(resource.fileTypeIcon,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _categoryLabels[resource.category] ?? resource.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey2,
                        ),
                      ),
                    ),
                    if (resource.fileSizeLabel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(resource.fileSizeLabel,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey3)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.download_outlined,
                        size: 12, color: AppColors.grey3),
                    const SizedBox(width: 3),
                    Text(
                      '${resource.downloadCount} downloads',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey3),
                    ),
                    if (resource.uploaderName != null) ...[
                      const Text(' · ',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.grey3)),
                      Text(
                        resource.uploaderName!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey3),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.download_rounded,
                size: 20, color: context.primary),
            onPressed: () {
              // TODO: open fileUrl in browser
            },
          ),
        ],
      ),
    );
  }
}

// ── Media tab ─────────────────────────────────────────────────

class _MediaTab extends ConsumerWidget {
  final String communityId;
  const _MediaTab({required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _tabScaffold(
      context,
      SliverFillRemaining(
        child: _EmptyState(
          icon: Icons.photo_library_outlined,
          title: 'No media yet',
          subtitle: 'Images shared in this\ncommunity will appear here.',
        ),
      ),
    );
  }
}

// ── Members tab ───────────────────────────────────────────────

class _MembersTab extends ConsumerWidget {
  final String communityId;
  const _MembersTab({required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(communityMembersProvider(communityId));

    return _tabScaffold(
      context,
      membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return SliverFillRemaining(
              child: _EmptyState(
                icon: Icons.people_outline_rounded,
                title: 'No members yet',
                subtitle: 'Be the first to join!',
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            sliver: SliverList.builder(
              itemCount: members.length,
              itemBuilder: (context, i) => _MemberRow(member: members[i]),
            ),
          );
        },
        loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator())),
        error: (e, _) =>
            SliverFillRemaining(child: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final CommunityMemberProfile member;
  const _MemberRow({required this.member});

  static const _roleColors = <String, Color>{
    'owner': Color(0xFFFFA500),
    'moderator': Color(0xFF7C3AED),
    'member': AppColors.grey3,
  };

  static const _roleLabels = <String, String>{
    'owner': 'Owner',
    'moderator': 'Mod',
    'member': 'Member',
  };

  @override
  Widget build(BuildContext context) {
    final name = member.fullName ?? 'Member';
    final roleColor = _roleColors[member.role] ?? AppColors.grey3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surface,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.initials,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                    if (member.isVerifiedLeader) ...[
                      const SizedBox(width: 4),
                      const VerifiedBadge(size: 14),
                    ],
                  ],
                ),
                if (member.programme != null || member.level != null)
                  Text(
                    [
                      if (member.programme != null) member.programme!,
                      if (member.level != null) member.level!,
                    ].join(' · '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey3),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _roleLabels[member.role] ?? member.role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable empty state ──────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.grey3),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey3,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
