import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/models/announcement_model.dart';
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
  final bool isOffline;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.isOffline = false,
  });

  FeedState copyWith({
    List<Announcement>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool? isOffline,
  }) =>
      FeedState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        isOffline: isOffline ?? this.isOffline,
      );
}

class FeedNotifier extends AutoDisposeAsyncNotifier<FeedState> {
  static const _pageSize = 20;
  static const _cacheBox = 'feed';
  static const _cacheKey = 'announcements';

  late final CacheService _cache;

  @override
  Future<FeedState> build() async {
    _cache = CacheService();
    final repo = ref.watch(feedRepositoryProvider);
    final isOnline = await ref.watch(connectivityProvider.future).then((s) => s == ConnectivityStatus.online);

    if (isOnline) {
      try {
        final items = await repo.getFeed(limit: _pageSize);
        _cacheFeed(items);
        return FeedState(items: items, hasMore: items.length >= _pageSize);
      } catch (e) {
        debugPrint('[FeedNotifier] Online fetch failed, falling back to cache: $e');
        final cached = await _loadCachedFeed();
        return FeedState(items: cached, hasMore: false, isOffline: true);
      }
    }

    final cached = await _loadCachedFeed();
    return FeedState(items: cached, hasMore: false, isOffline: true);
  }

  Future<void> refresh() async {
    final repo = ref.read(feedRepositoryProvider);
    final isOnline = await ref.read(connectivityProvider.future).then((s) => s == ConnectivityStatus.online);

    if (!isOnline) {
      state = AsyncData((state.valueOrNull ?? const FeedState()).copyWith(error: null));
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.refresh();
      final items = await repo.getFeed(limit: _pageSize);
      _cacheFeed(items);
      return FeedState(items: items, hasMore: items.length >= _pageSize);
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore || current.isOffline) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(feedRepositoryProvider);
      final cursor = current.items.last.createdAt.toIso8601String();
      final more = await repo.getFeed(cursor: cursor, limit: _pageSize);
      final updated = [...current.items, ...more];
      state = AsyncData(current.copyWith(
        isLoadingMore: false,
        items: updated,
        hasMore: more.length >= _pageSize,
      ));
      _cacheFeed(updated);
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.items.map((a) {
      if (a.id == id) return _withRead(a);
      return a;
    }).toList();
    state = AsyncData(current.copyWith(items: updated));
    await ref.read(feedRepositoryProvider).markRead(id);
  }

  Announcement _withRead(Announcement a) {
    if (a is AnnouncementModel) return a.copyWithRead();
    return a;
  }

  void _cacheFeed(List<Announcement> items) {
    _cache.put(
      boxName: _cacheBox,
      key: _cacheKey,
      data: items.map((a) => {
        'id': a.id,
        'title': a.title,
        'body': a.body,
        'category': a.category,
        'created_at': a.createdAt.toIso8601String(),
        'author_name': a.authorName,
        'author_avatar': a.authorAvatar,
        'is_pinned': a.isPinned,
        'is_read': a.isRead,
      }).toList(),
    );
  }

  Future<List<Announcement>> _loadCachedFeed() async {
    final raw = await _cache.get(boxName: _cacheBox, key: _cacheKey);
    if (raw == null) return [];
    try {
      final list = raw as List;
      return list.map((j) => AnnouncementModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[FeedNotifier] Cache parse error: $e');
      return [];
    }
  }
}

final feedProvider =
    AsyncNotifierProvider.autoDispose<FeedNotifier, FeedState>(FeedNotifier.new);
