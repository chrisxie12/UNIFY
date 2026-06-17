import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/community_detail_model.dart';
import '../providers/community_provider.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../../../posts/presentation/providers/post_provider.dart';
import '../../../posts/data/models/post_model.dart';
import '../../../events/presentation/widgets/event_card.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../resources/presentation/widgets/resource_card.dart';
import '../../../resources/presentation/providers/resource_provider.dart';
import '../../../resources/data/models/community_resource_model.dart';

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

    return communityAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
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
                                    const Color(0xFF0066FF),
                                    const Color(0xFF0066FF).withValues(alpha: 0.7),
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
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0066FF),
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
                                        const Icon(
                                          Icons.verified,
                                          color: Color(0xFF0066FF),
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
                    labelColor: const Color(0xFF0066FF),
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: const Color(0xFF0066FF),
                    tabs: const [
                      Tab(icon: Icon(Icons.campaign, size: 20), text: 'Announcements'),
                      Tab(icon: Icon(Icons.article, size: 20), text: 'Posts'),
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
                _PostsTab(communityId: widget.communityId, userId: userId),
                _EventsTab(communityId: widget.communityId, userId: userId),
                _ResourcesTab(communityId: widget.communityId),
                _MembersTab(communityId: widget.communityId),
              ],
            ),
          ),
          floatingActionButton: _tabController.index == 1
              ? FloatingActionButton(
                  onPressed: () {
                    context.push('/community/${widget.communityId}/create-post');
                  },
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.edit),
                )
              : null,
        );
      },
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
        backgroundColor: isMember ? Colors.grey[200] : const Color(0xFF0066FF),
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
      error: (e, _) => Center(child: Text('Error loading announcements')),
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
                    Icon(Icons.campaign, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No announcements yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Announcements will appear here', style: TextStyle(color: Colors.grey[500])),
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
                  color: post.isPinned ? const Color(0xFF0066FF).withValues(alpha: 0.03) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: post.isPinned
                      ? const Border(left: BorderSide(color: Color(0xFF0066FF), width: 3))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PostCard(
                  post: post,
                    onTap: () => context.push('/post/${post.id}'),
                  onLike: () async {
                    final repo = ref.read(postRepositoryProvider);
                    final uid = userId;
                    if (uid != null) {
                      if (post.isLikedByMe == true) {
                        await repo.unlikePost(post.id, uid);
                      } else {
                        await repo.likePost(post.id, uid);
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

class _PostsTab extends ConsumerWidget {
  final String communityId;
  final String? userId;

  const _PostsTab({required this.communityId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider(communityId));

    return postsAsync.when(
      loading: () => const _PostsShimmer(),
      error: (e, _) => Center(child: Text('Error loading posts')),
      data: (posts) {
        final regular = posts.where((p) => !p.isAnnouncement).toList();
        final pinned = regular.where((p) => p.isPinned).toList();
        final unpinned = regular.where((p) => !p.isPinned).toList();
        final sorted = [...pinned, ...unpinned];

        if (sorted.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.article, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No posts yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Be the first to start a discussion', style: TextStyle(color: Colors.grey[500])),
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
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final post = sorted[index];
              return PostCard(
                post: post,
                  onTap: () => context.push('/post/${post.id}'),
                onLike: () async {
                  final repo = ref.read(postRepositoryProvider);
                  final uid = userId;
                  if (uid != null) {
                    if (post.isLikedByMe == true) {
                      await repo.unlikePost(post.id, uid);
                    } else {
                      await repo.likePost(post.id, uid);
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
              );
            },
          ),
        );
      },
    );
  }
}

class _EventsTab extends ConsumerWidget {
  final String communityId;
  final String? userId;

  const _EventsTab({required this.communityId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(communityEventsProvider(communityId));
    final isManagerAsync = ref.watch(isCommunityManagerProvider(communityId));

    return eventsAsync.when(
      loading: () => const _EventsShimmer(),
      error: (e, _) => Center(child: Text('Error loading events')),
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
                    Icon(Icons.event, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No events yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Events will appear here', style: TextStyle(color: Colors.grey[500])),
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ...upcoming.map((event) => EventCard(
                      event: event,
                      onTap: () => context.push('/event/${event.id}'),
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ...past.map((event) => Opacity(
                      opacity: 0.5,
                      child: EventCard(
                        event: event,
                        onTap: () => context.push('/event/${event.id}'),
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
      error: (e, _) => Center(child: Text('Error loading resources')),
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
              color: Colors.white,
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
                              Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('No resources yet', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('Upload study resources', style: TextStyle(color: Colors.grey[500])),
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
            color: selected ? const Color(0xFF0066FF) : Colors.grey[100],
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
      error: (e, _) => Center(child: Text('Error loading members')),
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
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => ref.read(_memberSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
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
                        color: Colors.grey[600],
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
                          color: Colors.grey[500],
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
                          color: Colors.grey[500],
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
                          style: TextStyle(color: Colors.grey[500]),
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
                style: const TextStyle(
                  color: Color(0xFF0066FF),
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
            const Icon(Icons.verified, color: Color(0xFF0066FF), size: 16),
          ],
        ],
      ),
      subtitle: programme != null || level != null
          ? Text(
              [programme, level].nonNulls.join(' · '),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: role == 'owner' || role == 'manager'
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role == 'owner' ? 'Owner' : 'Manager',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0066FF),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                        color: Colors.grey[200],
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
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80, height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
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
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity, height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200, height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                    color: Colors.grey[200],
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
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 160, height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120, height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                    color: Colors.grey[200],
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
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 140, height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
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
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            width: 120, height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            width: 180, height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}
