import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/feed_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(Supabase.instance.client);
});

// ── Feed state ─────────────────────────────────────────────────────────────

class FeedState {
  final List<AnnouncementEntity> items;
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
    List<AnnouncementEntity>? items,
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

// ── Notifier ───────────────────────────────────────────────────────────────

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    // Kick off initial load
    Future.microtask(load);
    return const FeedState(isLoading: true);
  }

  FeedRepository get _repo => ref.read(feedRepositoryProvider);

  Future<void> load() async {
    if (state.isLoading && state.items.isNotEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getAnnouncements(
        pageSize: AppConstants.feedPageSize,
      );
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length >= AppConstants.feedPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.refreshAnnouncements(
        pageSize: AppConstants.feedPageSize,
      );
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length >= AppConstants.feedPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.items.isEmpty) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final last = state.items.last;
      final more = await _repo.getAnnouncements(
        pageSize: AppConstants.feedPageSize,
        after: last.publishedAt,
      );
      state = state.copyWith(
        items: [...state.items, ...more],
        isLoadingMore: false,
        hasMore: more.length >= AppConstants.feedPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);
