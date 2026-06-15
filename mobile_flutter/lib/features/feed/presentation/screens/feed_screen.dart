import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/feed_provider.dart';
import '../widgets/announcement_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final firstName = fullName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
              pinned: true,
              elevation: 0,
              expandedHeight: 90,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 72, 14),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting${firstName.isNotEmpty ? ', $firstName' : ''}',
                      style: AppTextStyles.headingS,
                    ),
                    Text(
                      'Campus Feed',
                      style: AppTextStyles.caption.copyWith(color: AppColors.grey2),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                ),
              ],
            ),

            feedAsync.when(
              loading: () => const FeedShimmer(),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grey3),
                      const SizedBox(height: 16),
                      Text('Could not load feed', style: AppTextStyles.headingS),
                      const SizedBox(height: 8),
                      Text(e.toString(), style: AppTextStyles.bodyS, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => ref.invalidate(feedProvider),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                if (state.items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.campaign_outlined, size: 56, color: AppColors.grey3),
                          const SizedBox(height: 16),
                          Text('No announcements yet', style: AppTextStyles.headingS),
                          const SizedBox(height: 8),
                          Text('Check back soon!', style: AppTextStyles.bodyS),
                        ],
                      ),
                    ),
                  );
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => AnnouncementCard(
                            item: state.items[i],
                            onTap: () => ref.read(feedProvider.notifier).markRead(state.items[i].id),
                          ),
                          childCount: state.items.length,
                        ),
                      ),
                    ),
                    if (state.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                    else if (!state.hasMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 40),
                          child: Center(
                            child: Text("You're all caught up 🎉", style: AppTextStyles.bodyS),
                          ),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
