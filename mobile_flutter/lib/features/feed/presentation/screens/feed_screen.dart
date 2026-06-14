import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/feed_provider.dart';
import '../widgets/announcement_card.dart';
import '../widgets/feed_shimmer.dart';

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

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UNIFY',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.primaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => const FeedShimmer(),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(feedProvider),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.primaryLight,
          onRefresh: () => ref.read(feedProvider.notifier).refresh(),
          child: state.items.isEmpty
              ? const _EmptyFeed()
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      );
                    }
                    final item = state.items[i];
                    return AnnouncementCard(
                      item: item,
                      onTap: () {
                        ref.read(feedProvider.notifier).markRead(item.id);
                        // TODO: navigate to announcement detail
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grey3),
            const SizedBox(height: 16),
            Text('Could not load feed', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.caption, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.campaign_outlined, size: 56, color: AppColors.grey3),
          const SizedBox(height: 16),
          Text('No announcements yet', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('Check back soon!', style: AppTextStyles.body),
        ],
      ),
    );
  }
}
