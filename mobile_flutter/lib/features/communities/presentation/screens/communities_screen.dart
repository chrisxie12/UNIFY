import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/communities_provider.dart';
import '../widgets/community_card.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen> {
  bool _searchActive = false;
  final _searchController = TextEditingController();

  static const _filters = [
    ('all',         'All'),
    ('academic',    'Academic'),
    ('clubs',       'Clubs'),
    ('sports',      'Sports'),
    ('residential', 'Residential'),
    ('social',      'Social'),
    ('tech',        'Tech'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final selectedFilter = ref.watch(hubFilterProvider);
    final allAsync = ref.watch(allCommunitiesProvider);
    final myAsync = ref.watch(myCommunitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: _searchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search communities…',
                  hintStyle: const TextStyle(color: AppColors.grey3),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) =>
                    ref.read(hubSearchProvider.notifier).state = v,
              )
            : const Text(
                'Hubs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _searchActive ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.dark,
            ),
            onPressed: () {
              setState(() => _searchActive = !_searchActive);
              if (!_searchActive) {
                _searchController.clear();
                ref.read(hubSearchProvider.notifier).state = '';
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: () async {
          ref.invalidate(allCommunitiesProvider);
          ref.invalidate(myCommunitiesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final (value, label) = _filters[i];
                    final active = selectedFilter == value;
                    return GestureDetector(
                      onTap: () =>
                          ref.read(hubFilterProvider.notifier).state = value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppColors.grey2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            if (selectedFilter == 'all' &&
                ref.watch(hubSearchProvider).isEmpty)
              myAsync.when(
                data: (myCommunities) {
                  if (myCommunities.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Text(
                            'My Communities',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey2,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: myCommunities.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) => GestureDetector(
                              onTap: () => context.push('/community/${myCommunities[i].id}'),
                              child: _MyCommunityChip(community: myCommunities[i]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Text(
                            'Discover',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey2,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

            allAsync.when(
              data: (communities) {
                if (communities.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.grid_view_rounded,
                              size: 52, color: AppColors.grey3),
                          const SizedBox(height: 12),
                          const Text(
                            'No communities yet',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Be the first to request a community\nfor your class!',
                            style: TextStyle(
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
                return SliverPadding(
                  padding: const EdgeInsets.only(top: 4, bottom: 120),
                  sliver: SliverList.builder(
                    itemCount: communities.length,
                    itemBuilder: (context, i) => CommunityCard(
                      community: communities[i],
                      onTap: () =>
                          context.push('/community/${communities[i].id}'),
                    ),
                  ),
                );
              },
              loading: () => SliverList.builder(
                itemCount: 6,
                itemBuilder: (_, __) => const _CommunitiesShimmer(),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 40, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load communities',
                        style: TextStyle(color: AppColors.grey2),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(allCommunitiesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyCommunityChip extends StatelessWidget {
  final community;
  const _MyCommunityChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final initials = (community.name as String).trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.primary, context.primaryDark],
            ),
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
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 68,
          child: Text(
            community.name as String,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CommunitiesShimmer extends StatelessWidget {
  const _CommunitiesShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
