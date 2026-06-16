import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/community_detail_model.dart';
import '../providers/community_provider.dart';

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
                      Tab(icon: Icon(Icons.forum, size: 20), text: 'Discussions'),
                      Tab(icon: Icon(Icons.folder, size: 20), text: 'Resources'),
                      Tab(icon: Icon(Icons.photo_library, size: 20), text: 'Media'),
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
                _AnnouncementsTab(communityId: widget.communityId),
                _DiscussionsTab(communityId: widget.communityId),
                _ResourcesTab(communityId: widget.communityId),
                const Center(child: Text('Media coming soon')),
                _MembersTab(community: community),
              ],
            ),
          ),
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

class _AnnouncementsTab extends StatelessWidget {
  final String communityId;
  const _AnnouncementsTab({required this.communityId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.campaign, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('Community Announcements', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Announcements will appear here', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscussionsTab extends StatelessWidget {
  final String communityId;
  const _DiscussionsTab({required this.communityId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.forum, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('Community Discussions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Start a discussion', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  final String communityId;
  const _ResourcesTab({required this.communityId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.folder, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('Study Resources', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Upload and find resources', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }
}

class _MembersTab extends ConsumerWidget {
  final CommunityDetailModel community;
  const _MembersTab({required this.community});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${community.memberCount} members', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (community.managers.isNotEmpty) ...[
          Text('Managers', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          ...community.managers.map((m) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: m.avatarUrl != null ? NetworkImage(m.avatarUrl!) : null,
                  child: m.avatarUrl == null ? Text((m.displayName ?? 'U')[0].toUpperCase()) : null,
                ),
                title: Row(
                  children: [
                    Text(m.displayName ?? 'User'),
                    if (m.isVerifiedLeader == true) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, color: const Color(0xFF0066FF), size: 16),
                    ],
                  ],
                ),
                subtitle: Text(m.role == 'owner' ? 'Owner' : m.role == 'manager' ? 'Manager' : 'Moderator'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: m.role == 'owner'
                        ? const Color(0xFF0066FF).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    m.role == 'owner' ? 'Owner' : m.role,
                    style: TextStyle(
                      fontSize: 11,
                      color: m.role == 'owner' ? const Color(0xFF0066FF) : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )),
          const Divider(),
        ],
      ],
    );
  }
}
