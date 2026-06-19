import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/leadership/presentation/providers/leadership_provider.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class CommunitiesScreen extends ConsumerWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';
    final communitiesAsync = ref.watch(myCommunitiesProvider(userId));
    final isVerifiedAsync = ref.watch(isVerifiedLeaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: communitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (communities) {
          final isVerified = isVerifiedAsync.valueOrNull ?? false;

          Widget requestButton() {
            if (isVerified) {
              return FilledButton.icon(
                onPressed: () => context.push('/community-request'),
                icon: const Icon(Icons.add),
                label: const Text('Request New Community'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: URadius.mdAll),
                ),
              );
            }
            return Column(
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/verification-request'),
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text('Get Verified'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(borderRadius: URadius.mdAll),
                  ),
                ),
                const SizedBox(height: USpacing.sm),
                Text(
                  'Community creation is restricted to verified student representatives.',
                  style: UText.tiny.copyWith(color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          if (communities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups, size: 64, color: context.textSecondary),
                  const SizedBox(height: USpacing.md),
                  Text('No communities yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.textSecondary)),
                  const SizedBox(height: USpacing.xs),
                  Text('Join or create a community', style: UText.bodyS.copyWith(color: context.textSecondary)),
                  const SizedBox(height: USpacing.xl),
                  requestButton(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCommunitiesProvider(userId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(USpacing.base),
              itemCount: communities.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: USpacing.base),
                    child: requestButton(),
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
                            backgroundImage: community.avatarUrl != null ? NetworkImage(community.avatarUrl!) : null,
                            child: community.avatarUrl == null
                                ? Text(
                                    community.name.isNotEmpty ? community.name[0].toUpperCase() : 'C',
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: USpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(community.name, style: UText.labelL),
                                const SizedBox(height: 2),
                                Text(
                                  community.communityTypeLabel,
                                  style: UText.caption.copyWith(color: context.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${community.memberCount} members',
                            style: UText.caption.copyWith(color: context.textSecondary),
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
      ),
    );
  }
}
