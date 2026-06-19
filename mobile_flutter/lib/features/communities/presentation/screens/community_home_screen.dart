import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../providers/community_provider.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../../../posts/presentation/providers/post_provider.dart';
import '../../../events/presentation/widgets/event_card.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../resources/presentation/widgets/resource_card.dart';
import '../../../resources/presentation/providers/resource_provider.dart';
import '../../../resources/data/models/community_resource_model.dart';
import '../../../polls/presentation/widgets/poll_card.dart';
import '../../../polls/presentation/providers/poll_provider.dart';
import '../../../polls/data/models/poll_model.dart';
import '../../../../core/extensions/theme_extensions.dart';

class CommunityHomeScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityHomeScreen({super.key, required this.communityId});

  @override
  ConsumerState<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends ConsumerState<CommunityHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityAsync = ref.watch(communityDetailProvider(widget.communityId));
    final userId = ref.read(supabaseProvider).auth.currentUser?.id;
    final isManagerAsync = ref.watch(isCommunityManagerProvider(widget.communityId));

    return communityAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(e),
      ),
      data: (community) {
        final theme = Theme.of(context);
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      community.coverUrl != null
                          ? Image.network(community.coverUrl!, fit: BoxFit.cover)
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              backgroundImage: community.avatarUrl != null
                                  ? NetworkImage(community.avatarUrl!)
                                  : null,
                              child: community.avatarUrl == null
                                  ? Text(
                                      community.name.isNotEmpty
                                          ? community.name[0].toUpperCase()
                                          : 'C',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          community.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (community.creatorIsVerifiedLeader == true)
                                        Icon(
                                          Icons.verified,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    community.communityTypeLabel,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _JoinButton(communityId: community.id, isMember: community.isMember ?? false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.campaign, size: 20), text: 'Announcements'),
                      Tab(icon: Icon(Icons.forum, size: 20), text: 'Discussions'),
                      Tab(icon: Icon(Icons.event, size: 20), text: 'Events'),
                      Tab(icon: Icon(Icons.folder, size: 20), text: 'Resources'),
                      Tab(icon: Icon(Icons.people, size: 20), text: 'Members'),
                    ],
                  ),
                  theme.colorScheme.surface,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _AnnouncementsTab(communityId: widget.communityId, userId: userId),
                _DiscussionsTab(communityId: widget.communityId, userId: userId),
                _EventsTab(communityId: widget.communityId, userId: userId),
                _ResourcesTab(communityId: widget.communityId),
                _MembersTab(communityId: widget.communityId),
              ],
            ),
          ),
          floatingActionButton: isManagerAsync.when(
            data: (isManager) {
              if (!isManager) return null;
              if (_tabController.index == 1) {
                return FloatingActionButton(
                  onPressed: () {
                    _showCreateMenu(context, widget.communityId);
                  },
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.edit),
                );
              }
              if (_tabController.index == 2) {
                return FloatingActionButton(
                  onPressed: () {
                    // Navigate to create event
                  },
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                );
              }
              return null;
            },
            loading: () => null,
            error: (_, __) => null,
          ),
        );
      },
    );
  }

  void _showCreateMenu(BuildContext context, String communityId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.textSecondary],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.article, color: Theme.of(context).colorScheme.primary),
                title: const Text('Create Post'),
                subtitle: const Text('Share text, images, or links'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/community/$communityId/create-post');
                },
              ),
              ListTile(
                leading: Icon(Icons.poll, color: Theme.of(context).colorScheme.primary),
                title: const Text('Create Poll'),
                subtitle: const Text('Ask the community to vote'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/community/$communityId/create-poll');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate old) => tabBar != old.tabBar;
}

class _JoinButton extends ConsumerWidget {
  final String communityId;
  final bool isMember;

  const _JoinButton({required this.communityId, required this.isMember});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final repo = ref.read(communityRepositoryProvider);
        if (isMember) {
          await repo.leaveCommunity(communityId, '');
        } else {
          await repo.joinCommunity(communityId, '');
        }
        ref.invalidate(communityDetailProvider(communityId));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isMember ? Colors.grey[200] : Theme.of(context).colorScheme.primary,
        foregroundColor: isMember ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(isMember ? 'Joined' : 'Join'),
    );
  }
}

class _AnnouncementsTab extends ConsumerWidget {
  final String communityId;
  final String? userId;

  const _AnnouncementsTab({required this.communityId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(communityId));

    return postsAsync.when(
      loading: () => const _PostsShimmer(),
      error: (e, _) => const Center(child: Text('Error loading announcements')),
      data: (posts) {
        final announcements = posts.where((p) => p.isAnnouncement).toList();
        final pinned = announcements.where((p) => p.isPinned).toList();
        final unpinned = announcements.where((p) => !p.isPinned).toList();
        final sorted = [...pinned, ...unpinned];

        if (sorted.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.campaign, size: 48, color: context.textSecondary]),
                    const SizedBox(height: 12),
                    Text('No announcements yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Announcements will appear here', style: TextStyle(color: context.textSecondary])),
                  ],
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(communityPostsProvider(communityId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final post = sorted[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: post.isPinned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: post.isPinned
                      ? Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 3))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: context.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PostCard(
                  post: post,
                  onTap: () => context.push('/post/${post.id}'),
                  onUpvote: () async {
                    final repo = ref.read(postRepositoryProvider);
                    final uid = userId;
                    if (uid != null) {
                      if (post.myVote == 'upvote') {
                        await repo.removeVote(post.id, uid);
                      } else {
                        await repo.upvotePost(post.id, uid);
                      }
                      ref.invalidate(communityPostsProvider(communityId));
                    }
                  },
                  onDownvote: () async {
                    final repo = ref.read(postRepositoryProvider);
                    final uid = userId;
                    if (uid != null) {
                      if (post.myVote == 'downvote') {
                        await repo.removeVote(post.id, uid);
                      } else {
                        await repo.downvotePost(post.id, uid);
                      }
                      ref.invalidate(communityPostsProvider(communityId));
                    }
                  },
                  onBookmark: () async {
                    final repo = ref.read(postRepositoryProvider);
                    final uid = userId;
                    if (uid != null) {
                      if (post.isBookmarkedByMe == true) {
                        await repo.unbookmarkPost(post.id, uid);
                      } else {
                        await repo.bookmarkPost(post.id, uid);
                      }
                      ref.invalidate(communityPostsProvider(communityId));
                    }
                  },
                  onShare: () {},
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DiscussionsTab extends ConsumerWidget {
  final String communityId;
  final String? userId;

  const _DiscussionsTab({required this.communityId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(communityId));
    final pollsAsync = ref.watch(communityPollsProvider(communityId));

    return postsAsync.when(
      loading: () => const _PostsShimmer(),
      error: (e, _) => const Center(child: Text('Error loading discussions')),
      data: (posts) => pollsAsync.when(
        loading: () => const _PostsShimmer(),
        error: (_, __) => const Center(child: Text('Error loading polls')),
        data: (polls) {
          final regular = posts.where((p) => !p.isAnnouncement && p.postType != 'poll').toList();
          final pinned = regular.where((p) => p.isPinned).toList();
          final unpinned = regular.where((p) => !p.isPinned).toList();

          final items = <Widget>[];
          for (final post in [...pinned, ...unpinned]) {
            items.add(PostCard(
              post: post,
              onTap: () => context.push('/post/${post.id}'),
              onUpvote: () async {
                final repo = ref.read(postRepositoryProvider);
                final uid = userId;
                if (uid != null) {
                  if (post.myVote == 'upvote') {
                    await repo.removeVote(post.id, uid);
                  } else {
                    await repo.upvotePost(post.id, uid);
                  }
                  ref.invalidate(communityPostsProvider(communityId));
                }
              },
              onDownvote: () async {
                final repo = ref.read(postRepositoryProvider);
                final uid = userId;
                if (uid != null) {
                  if (post.myVote == 'downvote') {
                    await repo.removeVote(post.id, uid);
                  } else {
                    await repo.downvotePost(post.id, uid);
                  }
                  ref.invalidate(communityPostsProvider(communityId));
                }
              },
              onBookmark: () async {
                final repo = ref.read(postRepositoryProvider);
                final uid = userId;
                if (uid != null) {
                  if (post.isBookmarkedByMe == true) {
                    await repo.unbookmarkPost(post.id, uid);
                  } else {
                    await repo.bookmarkPost(post.id, uid);
                  }
                  ref.invalidate(communityPostsProvider(communityId));
                }
              },
              onShare: () {},
            ));
          }

          for (final poll in polls) {
            items.add(_buildPollCard(context, ref, poll, communityId));
          }

          if (items.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.forum, size: 48, color: context.textSecondary]),
                      const SizedBox(height: 12),
                      Text('No discussions yet', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Start a conversation or create a poll',
                          style: TextStyle(color: context.textSecondary])),
                    ],
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityPostsProvider(communityId));
              ref.invalidate(communityPollsProvider(communityId));
            },
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              children: items,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollCard(BuildContext context, WidgetRef ref, PollModel poll, String communityId) {
    return PollCard(
      poll: poll,
      onVote: (optionId) async {
        final repo = ref.read(pollRepositoryProvider);
        final uid = userId;
        if (uid != null) {
          if (poll.myVote != null) {
            await repo.unvote(poll.id, uid);
          }
          await repo.vote(poll.id, optionId, uid);
          ref.invalidate(communityPollsProvider(communityId));
        }
      },
    );
  }
}

class _EventsTab extends ConsumerWidget {
  final String communityId;
  final String? userId;

  const _EventsTab({required this.communityId, required this.userId});

  void _showRsvpSheet(BuildContext context, WidgetRef ref, String eventId, String? currentStatus) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.textSecondary],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('RSVP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.check_circle, color: currentStatus == 'going'
                    ? Theme.of(context).colorScheme.primary : Colors.grey),
                title: const Text('Going'),
                trailing: currentStatus == 'going'
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(eventRepositoryProvider);
                  final uid = userId;
                  if (uid != null) {
                    await repo.rsvpEvent(eventId, uid, 'going');
                    ref.invalidate(communityEventsProvider(communityId));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline, color: currentStatus == 'maybe'
                    ? const Color(0xFFFF6B35) : Colors.grey),
                title: const Text('Maybe'),
                trailing: currentStatus == 'maybe'
                    ? const Icon(Icons.check, color: Color(0xFFFF6B35))
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(eventRepositoryProvider);
                  final uid = userId;
                  if (uid != null) {
                    await repo.rsvpEvent(eventId, uid, 'maybe');
                    ref.invalidate(communityEventsProvider(communityId));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: currentStatus == 'not_going'
                    ? Colors.red : Colors.grey),
                title: const Text('Not Going'),
                trailing: currentStatus == 'not_going'
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(eventRepositoryProvider);
                  final uid = userId;
                  if (uid != null) {
                    await repo.rsvpEvent(eventId, uid, 'not_going');
                    ref.invalidate(communityEventsProvider(communityId));
                  }
                },
              ),
              if (currentStatus != null) ...[
                const Divider(),
                ListTile(
                  leading: Icon(Icons.remove_circle_outline, color: context.textSecondary),
                  title: const Text('Clear RSVP',
                      style: TextStyle(color: context.textSecondary)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final repo = ref.read(eventRepositoryProvider);
                    final uid = userId;
                    if (uid != null) {
                      await repo.cancelRsvp(eventId, uid);
                      ref.invalidate(communityEventsProvider(communityId));
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(communityEventsProvider(communityId));
    final isManagerAsync = ref.watch(isCommunityManagerProvider(communityId));

    return eventsAsync.when(
      loading: () => const _EventsShimmer(),
      error: (e, _) => const Center(child: Text('Error loading events')),
      data: (events) {
        final now = DateTime.now();
        final upcoming = events.where((e) => e.eventDate.isAfter(now) || e.eventDate.isAtSameMomentAs(now)).toList();
        final past = events.where((e) => e.eventDate.isBefore(now)).toList();

        if (events.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.event, size: 48, color: context.textSecondary]),
                    const SizedBox(height: 12),
                    Text('No events yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Events will appear here', style: TextStyle(color: context.textSecondary])),
                  ],
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(communityEventsProvider(communityId));
              },
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary],
                        ),
                      ),
                    ),
                    ...upcoming.map((event) => EventCard(
                      event: event,
                      onTap: () => context.push('/event/${event.id}'),
                      onRsvp: () => _showRsvpSheet(context, ref, event.id, event.myRsvpStatus),
                    )),
                  ],
                  if (past.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Past',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary],
                        ),
                      ),
                    ),
                    ...past.map((event) => Opacity(
                      opacity: 0.5,
                      child: EventCard(
                        event: event,
                        onTap: () => context.push('/event/${event.id}'),
                        onRsvp: () => _showRsvpSheet(context, ref, event.id, event.myRsvpStatus),
                      ),
                    )),
                  ],
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: isManagerAsync.when(
                data: (isManager) => isManager
                    ? FloatingActionButton.small(
                        onPressed: () {},
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.add),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResourcesTab extends ConsumerWidget {
  final String communityId;

  const _ResourcesTab({required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(communityResourcesProvider(communityId));

    return resourcesAsync.when(
      loading: () => const _ResourcesShimmer(),
      error: (e, _) => const Center(child: Text('Error loading resources')),
      data: (resources) {
        final types = CommunityResourceModel.resourceTypeLabels.keys.toList();
        final selectedType = ref.watch(_selectedResourceTypeProvider);

        final filtered = selectedType == null || selectedType == 'all'
            ? resources
            : resources.where((r) => r.resourceType == selectedType).toList();

        return Column(
          children: [
            Container(
              height: 48,
              color: context.cardBg,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: selectedType == null || selectedType == 'all',
                    onTap: () => ref.read(_selectedResourceTypeProvider.notifier).state = 'all',
                  ),
                  ...types.map((type) => _FilterChip(
                    label: CommunityResourceModel.resourceTypeLabels[type] ?? type,
                    selected: selectedType == type,
                    onTap: () => ref.read(_selectedResourceTypeProvider.notifier).state = type,
                  )),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.folder_open, size: 48, color: context.textSecondary]),
                              const SizedBox(height: 12),
                              Text('No resources yet', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('Upload study resources', style: TextStyle(color: context.textSecondary])),
                            ],
                          ),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(communityResourcesProvider(communityId));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final resource = filtered[index];
                          return ResourceCard(
                            resource: resource,
                            onDownload: () async {
                              final repo = ref.read(resourceRepositoryProvider);
                              await repo.incrementDownloadCount(resource.id);
                              ref.invalidate(communityResourcesProvider(communityId));
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

final _selectedResourceTypeProvider = StateProvider<String?>((ref) => null);

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class _MembersTab extends ConsumerWidget {
  final String communityId;

  const _MembersTab({required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(communityMembersProvider(communityId));

    return membersAsync.when(
      loading: () => const _MembersShimmer(),
      error: (e, _) => const Center(child: Text('Error loading members')),
      data: (members) {
        final searchQuery = ref.watch(_memberSearchProvider);
        final filtered = searchQuery.isEmpty
            ? members
            : members.where((m) {
                final name = (m['profiles'] as Map<String, dynamic>?)?['display_name'] as String? ?? '';
                return name.toLowerCase().contains(searchQuery.toLowerCase());
              }).toList();

        final managers = filtered.where((m) => m['role'] == 'owner' || m['role'] == 'manager').toList();
        final regulars = filtered.where((m) => m['role'] != 'owner' && m['role'] != 'manager').toList();

        return Column(
          children: [
            Container(
              color: context.cardBg,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => ref.read(_memberSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: Icon(Icons.search, color: context.textSecondary]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      '${filtered.length} members',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary],
                      ),
                    ),
                  ),
                  if (managers.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        'Community Leaders',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary],
                        ),
                      ),
                    ),
                    ...managers.map((m) => _MemberTile(member: m)),
                  ],
                  if (regulars.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary],
                        ),
                      ),
                    ),
                    ...regulars.map((m) => _MemberTile(member: m)),
                  ],
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No members found',
                          style: TextStyle(color: context.textSecondary]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

final _memberSearchProvider = StateProvider<String>((ref) => '');

class _MemberTile extends StatelessWidget {
  final Map<String, dynamic> member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final profile = member['profiles'] as Map<String, dynamic>?;
    final name = profile?['display_name'] as String? ?? 'User';
    final avatar = profile?['avatar_url'] as String?;
    final isVerified = profile?['is_verified_leader'] as bool? ?? false;
    final programme = profile?['programme'] as String?;
    final level = profile?['level'] as String?;
    final role = member['role'] as String? ?? 'member';

    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey[200],
        backgroundImage: avatar != null ? NetworkImage(avatar) : null,
        child: avatar == null
            ? Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 4),
            Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 16),
          ],
        ],
      ),
      subtitle: programme != null || level != null
          ? Text(
              [programme, level].nonNulls.join(' · '),
              style: TextStyle(fontSize: 12, color: context.textSecondary]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: role == 'owner' || role == 'manager'
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role == 'owner' ? 'Owner' : 'Manager',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : null,
      onTap: () => context.push('/app/profile'),
    );
  }
}

class _PostsShimmer extends StatelessWidget {
  const _PostsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.textPrimary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: context.textSecondary],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120, height: 12,
                          decoration: BoxDecoration(
                            color: context.textSecondary],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80, height: 10,
                          decoration: BoxDecoration(
                            color: context.textSecondary],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity, height: 14,
                  decoration: BoxDecoration(
                    color: context.textSecondary],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity, height: 14,
                  decoration: BoxDecoration(
                    color: context.textSecondary],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200, height: 14,
                  decoration: BoxDecoration(
                    color: context.textSecondary],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventsShimmer extends StatelessWidget {
  const _EventsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.textPrimary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60, height: 72,
                  decoration: BoxDecoration(
                    color: context.textSecondary],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, height: 14,
                        decoration: BoxDecoration(
                          color: context.textSecondary],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 160, height: 12,
                        decoration: BoxDecoration(
                          color: context.textSecondary],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120, height: 12,
                        decoration: BoxDecoration(
                          color: context.textSecondary],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResourcesShimmer extends StatelessWidget {
  const _ResourcesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.textPrimary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: context.textSecondary],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, height: 14,
                        decoration: BoxDecoration(
                          color: context.textSecondary],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 140, height: 12,
                        decoration: BoxDecoration(
                          color: context.textSecondary],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MembersShimmer extends StatelessWidget {
  const _MembersShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: context.textSecondary],
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            width: 120, height: 14,
            decoration: BoxDecoration(
              color: context.textSecondary],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            width: 180, height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: context.textSecondary],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}
