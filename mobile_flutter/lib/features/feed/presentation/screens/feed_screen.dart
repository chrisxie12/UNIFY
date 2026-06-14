import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
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
    final feedState = ref.watch(feedProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final fullName = metadata?['full_name'] as String? ?? '';
    final firstName = fullName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // Sticky app bar
            SliverAppBar(
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
              pinned: true,
              elevation: 0,
              expandedHeight: 96,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 72, 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting${firstName.isNotEmpty ? ', $firstName' : ''} 👋',
                      style: AppTextStyles.headingS,
                    ),
                    Text(
                      'GCTU Campus Feed',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey2,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      firstName.isNotEmpty
                          ? firstName[0].toUpperCase()
                          : 'U',
                      style: AppTextStyles.labelM
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            if (feedState.isLoading && feedState.items.isEmpty)
              const FeedShimmer()
            else if (feedState.error != null && feedState.items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('😕', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load feed',
                        style: AppTextStyles.headingS,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feedState.error!,
                        style: AppTextStyles.bodyS,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () =>
                            ref.read(feedProvider.notifier).refresh(),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (feedState.items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📭', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('Nothing yet', style: AppTextStyles.headingS),
                      const SizedBox(height: 4),
                      Text(
                        'Check back later for campus announcements.',
                        style: AppTextStyles.bodyS,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => AnnouncementCard(
                      announcement: feedState.items[i],
                    ),
                    childCount: feedState.items.length,
                  ),
                ),
              ),
              // Load-more indicator
              if (feedState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else if (!feedState.hasMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 40),
                    child: Center(
                      child: Text(
                        'You\'re all caught up 🎉',
                        style: AppTextStyles.bodyS,
                      ),
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}
