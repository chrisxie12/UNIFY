import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/announcement_social_repository.dart';
import '../../domain/entities/announcement_comment.dart';

final announcementSocialRepoProvider = Provider<AnnouncementSocialRepository>((ref) {
  return AnnouncementSocialRepository(Supabase.instance.client);
});

// ── Like state per announcement ───────────────────────────────────────────────

class _LikeState {
  final bool isLiked;
  final int count;
  final bool isLoading;
  const _LikeState({required this.isLiked, required this.count, this.isLoading = false});
  _LikeState copyWith({bool? isLiked, int? count, bool? isLoading}) => _LikeState(
        isLiked: isLiked ?? this.isLiked,
        count: count ?? this.count,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AnnouncementLikeNotifier extends FamilyNotifier<_LikeState, ({String id, int initialCount})> {
  @override
  _LikeState build(({String id, int initialCount}) arg) {
    // Load status from DB lazily after first frame
    Future.microtask(() async {
      final repo = ref.read(announcementSocialRepoProvider);
      final (isLiked, count) = await repo.getLikeStatus(arg.id);
      state = _LikeState(isLiked: isLiked, count: count);
    });
    return _LikeState(isLiked: false, count: arg.initialCount);
  }

  Future<void> toggle() async {
    if (state.isLoading) return;
    // Optimistic update
    final prev = state;
    state = _LikeState(
      isLiked: !prev.isLiked,
      count: prev.isLiked ? prev.count - 1 : prev.count + 1,
      isLoading: true,
    );
    try {
      final repo = ref.read(announcementSocialRepoProvider);
      final (isLiked, count) = await repo.toggleLike(arg.id);
      state = _LikeState(isLiked: isLiked, count: count);
    } catch (_) {
      state = prev; // roll back on error
    }
  }
}

final announcementLikeProvider =
    NotifierProvider.family<AnnouncementLikeNotifier, _LikeState, ({String id, int initialCount})>(
  AnnouncementLikeNotifier.new,
);

// ── Comments per announcement ─────────────────────────────────────────────────

class AnnouncementCommentsNotifier extends AutoDisposeFamilyAsyncNotifier<List<AnnouncementComment>, String> {
  @override
  Future<List<AnnouncementComment>> build(String announcementId) async {
    final repo = ref.read(announcementSocialRepoProvider);
    return repo.getComments(announcementId);
  }

  Future<bool> add(String body) async {
    if (body.trim().isEmpty) return false;
    final repo = ref.read(announcementSocialRepoProvider);
    final comment = await repo.addComment(arg, body);
    if (comment == null) return false;
    state = AsyncData([...state.valueOrNull ?? [], comment]);
    return true;
  }

  Future<void> remove(String commentId) async {
    final repo = ref.read(announcementSocialRepoProvider);
    await repo.deleteComment(commentId);
    state = AsyncData(
      (state.valueOrNull ?? []).where((c) => c.id != commentId).toList(),
    );
  }
}

final announcementCommentsProvider =
    AsyncNotifierProvider.autoDispose.family<AnnouncementCommentsNotifier, List<AnnouncementComment>, String>(
  AnnouncementCommentsNotifier.new,
);
