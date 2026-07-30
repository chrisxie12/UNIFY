import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/leadership/presentation/providers/leadership_provider.dart';
import '../../../communities/presentation/providers/community_provider.dart';
import '../../../../features/events/presentation/screens/events_screen.dart';
import '../../../../features/academic/presentation/screens/academic_hub_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: cs.surface,
            child: TabBar(
              tabs: const [
                Tab(text: 'Events'),
                Tab(text: 'Study'),
                Tab(text: 'Groups'),
              ],
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                EventsScreen(),
                AcademicHubScreen(),
                _GroupsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';
    final communitiesAsync = ref.watch(myCommunitiesProvider(userId));
    final isVerifiedAsync = ref.watch(isVerifiedLeaderProvider);

    return communitiesAsync.when(
      loading: () => const AppLoadingWidget.list(itemCount: 3),
      error: (e, _) => AppErrorWidget(e),
      data: (communities) {
        final isVerified = isVerifiedAsync.valueOrNull ?? false;

        if (communities.isEmpty) {
          return const AppEmptyWidget(
            icon: Icons.groups_rounded,
            title: 'No communities yet',
            subtitle: 'Join or create a community',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myCommunitiesProvider(userId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(USpacing.base),
            itemCount: communities.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                if (!isVerified) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: USpacing.base),
                  child: FilledButton.icon(
                    onPressed: () => context.push('/community-request'),
                    icon: const Icon(Icons.add),
                    label: const Text('Request New Community'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: URadius.mdAll),
                    ),
                  ),
                );
              }

              final community = communities[index - 1];
              return Card(
                margin: const EdgeInsets.only(bottom: USpacing.md),
                shape: RoundedRectangleBorder(borderRadius: URadius.mdAll),
                child: InkWell(
                  borderRadius: URadius.mdAll,
                  onTap: () => context.push('/community/${community.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(USpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          backgroundImage: community.avatarUrl != null
                              ? NetworkImage(community.avatarUrl!)
                              : null,
                          child: community.avatarUrl == null
                              ? Text(
                                  community.name.isNotEmpty
                                      ? community.name[0].toUpperCase()
                                      : 'C',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: USpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                community.communityTypeLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${community.memberCount} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CommunitiesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';
    final communitiesAsync = ref.watch(myCommunitiesProvider(userId));
    final isVerifiedAsync = ref.watch(isVerifiedLeaderProvider);

    return communitiesAsync.when(
      loading: () => const AppLoadingWidget.list(itemCount: 3),
      error: (e, _) => AppErrorWidget(e),
      data: (communities) {
        final isVerified = isVerifiedAsync.valueOrNull ?? false;

        if (communities.isEmpty) {
          return const AppEmptyWidget(
            icon: Icons.groups_rounded,
            title: 'No communities yet',
            subtitle: 'Join or create a community',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myCommunitiesProvider(userId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(USpacing.base),
            itemCount: communities.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                if (!isVerified) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: USpacing.base),
                  child: FilledButton.icon(
                    onPressed: () => context.push('/community-request'),
                    icon: const Icon(Icons.add),
                    label: const Text('Request New Community'),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.primary,
                      shape: RoundedRectangleBorder(borderRadius: URadius.mdAll),
                    ),
                  ),
                );
              }

              final community = communities[index - 1];
              return Card(
                margin: const EdgeInsets.only(bottom: USpacing.md),
                shape: RoundedRectangleBorder(borderRadius: URadius.mdAll),
                child: InkWell(
                  borderRadius: URadius.mdAll,
                  onTap: () => context.push('/community/${community.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(USpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: context.primary.withValues(alpha: 0.1),
                          backgroundImage: community.avatarUrl != null
                              ? NetworkImage(community.avatarUrl!)
                              : null,
                          child: community.avatarUrl == null
                              ? Text(
                                  community.name.isNotEmpty
                                      ? community.name[0].toUpperCase()
                                      : 'C',
                                  style: TextStyle(
                                    color: context.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: USpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                community.communityTypeLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${community.memberCount} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}