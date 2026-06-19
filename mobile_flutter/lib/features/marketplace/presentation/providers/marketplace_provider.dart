import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository_impl.dart';

final marketplaceRepositoryProvider =
    Provider<MarketplaceRepositoryImpl>((ref) {
  return MarketplaceRepositoryImpl(ref.watch(supabaseProvider));
});

// ── Current user's university (scope listings to campus) ─────

final marketUniversityIdProvider =
    FutureProvider.autoDispose<String?>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;
  try {
    final p = await client
        .from('profiles')
        .select('university_id')
        .eq('id', user.id)
        .maybeSingle();
    return p?['university_id'] as String?;
  } catch (e) {
    debugPrint('[MarketplaceProvider] Error: $e');
    return null;
  }
});

/// Whether the current user is allowed to post (verified + active student).
final canPostListingProvider = FutureProvider.autoDispose<bool>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return false;
  try {
    final p = await client
        .from('profiles')
        .select('is_verified, is_active')
        .eq('id', user.id)
        .maybeSingle();
    return (p?['is_verified'] as bool? ?? false) &&
        (p?['is_active'] as bool? ?? true);
  } catch (e) {
    debugPrint('[MarketplaceProvider] canPostListingProvider error: $e');
    return false;
  }
});

// ── Active browse filter ─────────────────────────────────────

final listingFilterProvider =
    StateProvider.autoDispose<ListingFilter>((ref) => const ListingFilter());

// ── Browse / search results ──────────────────────────────────

final listingsProvider =
    FutureProvider.autoDispose<List<ListingModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  final filter = ref.watch(listingFilterProvider);
  final universityId = ref.watch(marketUniversityIdProvider).valueOrNull;
  return ref.read(marketplaceRepositoryProvider).getListings(
        filter: filter,
        universityId: universityId,
        viewerId: user?.id,
      );
});

// ── Featured (promoted) listings for the home carousel ───────

final featuredListingsProvider =
    FutureProvider.autoDispose<List<ListingModel>>((ref) async {
  final universityId = ref.watch(marketUniversityIdProvider).valueOrNull;
  return ref
      .read(marketplaceRepositoryProvider)
      .getFeatured(universityId: universityId);
});

// ── A single listing's detail ────────────────────────────────

final listingDetailProvider =
    FutureProvider.autoDispose.family<ListingModel?, String>((ref, id) async {
  ref.watch(authStateProvider);
  final user = ref.watch(supabaseProvider).auth.currentUser;
  return ref
      .read(marketplaceRepositoryProvider)
      .getListing(id, viewerId: user?.id);
});

// ── Other listings by the same seller ────────────────────────

final sellerListingsProvider = FutureProvider.autoDispose
    .family<List<ListingModel>, ({String sellerId, String excludeId})>(
        (ref, arg) async {
  return ref.read(marketplaceRepositoryProvider).getSellerListings(
        arg.sellerId,
        excludeId: arg.excludeId,
      );
});

// ── My listings (seller dashboard) ───────────────────────────

final myListingsProvider =
    FutureProvider.autoDispose<List<ListingModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(marketplaceRepositoryProvider).getMyListings(user.id);
});

// ── Saved listings (wishlist) ────────────────────────────────

final savedListingsProvider =
    FutureProvider.autoDispose<List<ListingModel>>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];
  return ref.read(marketplaceRepositoryProvider).getSavedListings(user.id);
});

// ── Freelancers ──────────────────────────────────────────────

final freelancerSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final freelancerCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final freelancersProvider =
    FutureProvider.autoDispose<List<FreelancerProfile>>((ref) async {
  final query = ref.watch(freelancerSearchProvider);
  final category = ref.watch(freelancerCategoryProvider);
  return ref.read(marketplaceRepositoryProvider).getFreelancers(
        query: query.isEmpty ? null : query,
        category: category,
      );
});

final freelancerProfileProvider = FutureProvider.autoDispose
    .family<FreelancerProfile?, String>((ref, userId) {
  return ref.read(marketplaceRepositoryProvider).getFreelancer(userId);
});

final myFreelancerProfileProvider =
    FutureProvider.autoDispose<FreelancerProfile?>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;
  return ref.read(marketplaceRepositoryProvider).getFreelancer(user.id);
});

// ── Reviews & ratings ────────────────────────────────────────

final sellerRatingProvider =
    FutureProvider.autoDispose.family<SellerRating, String>((ref, userId) {
  return ref.read(marketplaceRepositoryProvider).getSellerRating(userId);
});

final sellerReviewsProvider = FutureProvider.autoDispose
    .family<List<ListingReview>, String>((ref, userId) {
  return ref.read(marketplaceRepositoryProvider).getReviews(userId);
});

// ── Save toggle action notifier ──────────────────────────────

class SavedListingsController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<bool> toggle(String listingId) async {
    final client = ref.read(supabaseProvider);
    final user = client.auth.currentUser;
    if (user == null) return false;
    final saved = await ref
        .read(marketplaceRepositoryProvider)
        .toggleSaved(listingId, user.id);
    ref.invalidate(savedListingsProvider);
    ref.invalidate(listingDetailProvider(listingId));
    return saved;
  }
}

final savedListingsControllerProvider =
    NotifierProvider.autoDispose<SavedListingsController, void>(
  SavedListingsController.new,
);

// ── Admin moderation & analytics ─────────────────────────────

final marketplaceReportQueueProvider =
    FutureProvider.autoDispose<List<ListingReportItem>>((ref) {
  ref.watch(authStateProvider);
  return ref.read(marketplaceRepositoryProvider).getReportQueue();
});

final marketplaceStatsProvider =
    FutureProvider.autoDispose<MarketplaceStats>((ref) {
  ref.watch(authStateProvider);
  return ref.read(marketplaceRepositoryProvider).getStats();
});
