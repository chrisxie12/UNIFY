import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/leadership/presentation/providers/leadership_provider.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';

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
        loading: () => const AppLoadingWidget.list(itemCount: 3),
        error: (e, _) => AppErrorWidget(e),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Community creation is restricted to verified student representatives.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

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
              padding: const EdgeInsets.all(16),
              itemCount: communities.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: requestButton(),
                  );
                }

                final community = communities[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/community/${community.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.group, color: Color(0xFF2563EB), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  community.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${community.memberCount} members',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.push('/community/${community.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            child: const Text('Join', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
