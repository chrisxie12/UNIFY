import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/announcement_social_repository.dart';
import '../../domain/entities/announcement_comment.dart';

final announcementSocialRepoProvider = Provider<AnnouncementSocialRepository>((ref) {
  return AnnouncementSocialRepository(Supabase.instance.client);
});

// ── Like state per announcement ───────────────────────────────────────────────

class LikeState {
  final bool isLiked;
  final int count;
  final bool isLoading;
  const LikeState({required this.isLiked, required this.count, this.isLoading = false});
  LikeState copyWith({bool? isLiked, int? count, bool? isLoading}) => LikeState(
        isLiked: isLiked ?? this.isLiked,
        count: count ?? this.count,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AnnouncementLikeNotifier extends FamilyNotifier<LikeState, ({String id, int initialCount})> {
  @override
  LikeState build(({String id, int initialCount}) arg) {
    // Load status from DB lazily after first frame
    Future.microtask(() async {
      final repo = ref.read(announcementSocialRepoProvider);
      final (isLiked, count) = await repo.getLikeStatus(arg.id);
      state = LikeState(isLiked: isLiked, count: count);
    });
    return LikeState(isLiked: false, count: arg.initialCount);
  }

  Future<void> toggle() async {
    if (state.isLoading) return;
    // Optimistic update
    final prev = state;
    state = LikeState(
      isLiked: !prev.isLiked,
      count: prev.isLiked ? prev.count - 1 : prev.count + 1,
      isLoading: true,
    );
    try {
      final repo = ref.read(announcementSocialRepoProvider);
      final (isLiked, count) = await repo.toggleLike(arg.id);
      state = LikeState(isLiked: isLiked, count: count);
    } catch (_) {
      state = prev; // roll back on error
    }
  }
}

final announcementLikeProvider =
    NotifierProvider.family<AnnouncementLikeNotifier, LikeState, ({String id, int initialCount})>(
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

// ── Save state per announcement ──────────────────────────────────────────────

class SaveState {
  final bool isSaved;
  final bool isLoading;
  const SaveState({required this.isSaved, this.isLoading = false});
  SaveState copyWith({bool? isSaved, bool? isLoading}) => SaveState(
        isSaved: isSaved ?? this.isSaved,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AnnouncementSaveNotifier extends FamilyNotifier<SaveState, String> {
  @override
  SaveState build(String arg) {
    Future.microtask(() async {
      final repo = ref.read(announcementSocialRepoProvider);
      final isSaved = await repo.getSaveStatus(arg);
      state = SaveState(isSaved: isSaved);
    });
    return const SaveState(isSaved: false);
  }

  Future<void> toggle() async {
    if (state.isLoading) return;
    final prev = state;
    state = SaveState(isSaved: !prev.isSaved, isLoading: true);
    try {
      final repo = ref.read(announcementSocialRepoProvider);
      final isSaved = await repo.toggleSave(arg);
      state = SaveState(isSaved: isSaved);
    } catch (_) {
      state = prev;
    }
  }
}

final announcementSaveProvider =
    NotifierProvider.family<AnnouncementSaveNotifier, SaveState, String>(
  AnnouncementSaveNotifier.new,
);
