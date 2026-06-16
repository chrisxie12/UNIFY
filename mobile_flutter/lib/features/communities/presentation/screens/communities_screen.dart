import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class CommunitiesScreen extends ConsumerWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAppUserProvider).valueOrNull?.id ?? '';
    final communitiesAsync = ref.watch(myCommunitiesProvider(userId));

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
          if (communities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No communities yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Text('Join or create a community', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/community-request'),
                    icon: const Icon(Icons.add),
                    label: const Text('Request Community'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCommunitiesProvider(userId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: communities.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FilledButton.icon(
                      onPressed: () => context.push('/community-request'),
                      icon: const Icon(Icons.add),
                      label: const Text('Request New Community'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  );
                }

                final community = communities[index - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/community/${community.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF0066FF).withValues(alpha: 0.1),
                            backgroundImage: community.avatarUrl != null ? NetworkImage(community.avatarUrl!) : null,
                            child: community.avatarUrl == null
                                ? Text(
                                    community.name.isNotEmpty ? community.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(community.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  community.communityTypeLabel,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${community.memberCount} members',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
