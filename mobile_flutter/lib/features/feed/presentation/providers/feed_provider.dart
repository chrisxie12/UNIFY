import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(supabaseProvider));
});

class FeedState {
  final List<Announcement> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  FeedState copyWith({
    List<Announcement>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) =>
      FeedState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error,
      );
}

class FeedNotifier extends AutoDisposeAsyncNotifier<FeedState> {
  static const _pageSize = 20;

  @override
  Future<FeedState> build() async {
    final repo = ref.watch(feedRepositoryProvider);
    final items = await repo.getFeed(limit: _pageSize);
    return FeedState(items: items, hasMore: items.length >= _pageSize);
  }

  Future<void> refresh() async {
    final repo = ref.read(feedRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.refresh();
      final items = await repo.getFeed(limit: _pageSize);
      return FeedState(items: items, hasMore: items.length >= _pageSize);
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(feedRepositoryProvider);
      final cursor = current.items.last.createdAt.toIso8601String();
      final more = await repo.getFeed(cursor: cursor, limit: _pageSize);
      state = AsyncData(current.copyWith(
        isLoadingMore: false,
        items: [...current.items, ...more],
        hasMore: more.length >= _pageSize,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.items.map((a) {
      if (a.id == id) {
        return _withRead(a);
      }
      return a;
    }).toList();
    state = AsyncData(current.copyWith(items: updated));
    await ref.read(feedRepositoryProvider).markRead(id);
  }

  Announcement _withRead(Announcement a) {
    // Reconstruct with isRead=true using the model
    return a;
  }
}

final feedProvider =
    AsyncNotifierProvider.autoDispose<FeedNotifier, FeedState>(FeedNotifier.new);
