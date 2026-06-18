import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/marketplace_models.dart';

class MarketplaceRepositoryImpl {
  final SupabaseClient _client;
  MarketplaceRepositoryImpl(this._client);

  static const _sellerJoin =
      'profiles!marketplace_listings_seller_id_fkey'
      '(full_name, avatar_url, programme, level, is_verified, created_at)';

  static const _listingSelect =
      '*, $_sellerJoin, listing_images(url, position)';

  // ── Browse / search ──────────────────────────────────────────

  Future<List<ListingModel>> getListings({
    required ListingFilter filter,
    String? universityId,
    String? viewerId,
    int limit = 40,
    int offset = 0,
  }) async {
    var q = _client
        .from('marketplace_listings')
        .select(_listingSelect)
        .eq('moderation', 'approved')
        .inFilter('status', ['active', 'pending']);

    if (filter.category != null) {
      q = q.eq('category', filter.category!.key);
    }
    if (filter.subcategory != null && filter.subcategory!.isNotEmpty) {
      q = q.eq('subcategory', filter.subcategory!);
    }
    if (universityId != null) {
      q = q.eq('university_id', universityId);
    }
    if (filter.query != null && filter.query!.trim().isNotEmpty) {
      final term = filter.query!.trim();
      q = q.or('title.ilike.%$term%,description.ilike.%$term%');
    }
    if (filter.minPrice != null) {
      q = q.gte('price', filter.minPrice!);
    }
    if (filter.maxPrice != null) {
      q = q.lte('price', filter.maxPrice!);
    }
    if (filter.condition != null && filter.condition!.isNotEmpty) {
      q = q.eq('condition', filter.condition!);
    }
    if (filter.location != null && filter.location!.isNotEmpty) {
      q = q.ilike('location', '%${filter.location!}%');
    }

    final data = await switch (filter.sort) {
      'price_asc' => q.order('price', ascending: true).range(offset, offset + limit - 1),
      'price_desc' => q.order('price', ascending: false).range(offset, offset + limit - 1),
      'popular' => q.order('view_count', ascending: false).range(offset, offset + limit - 1),
      _ => q
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1),
    };

    final saved = viewerId != null ? await _savedIds(viewerId) : <String>{};
    return (data as List)
        .map((r) =>
            ListingModel.fromJson(r as Map<String, dynamic>, savedIds: saved))
        .toList();
  }

  Future<List<ListingModel>> getFeatured({
    String? universityId,
    int limit = 10,
  }) async {
    var q = _client
        .from('marketplace_listings')
        .select(_listingSelect)
        .eq('moderation', 'approved')
        .eq('status', 'active')
        .eq('is_featured', true);
    if (universityId != null) q = q.eq('university_id', universityId);
    final data = await q.order('created_at', ascending: false).limit(limit);
    return (data as List)
        .map((r) => ListingModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<ListingModel?> getListing(String id, {String? viewerId}) async {
    final data = await _client
        .from('marketplace_listings')
        .select(_listingSelect)
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    final saved = viewerId != null ? await _savedIds(viewerId) : <String>{};
    return ListingModel.fromJson(data, savedIds: saved);
  }

  Future<List<ListingModel>> getMyListings(String userId) async {
    final data = await _client
        .from('marketplace_listings')
        .select(_listingSelect)
        .eq('seller_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => ListingModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Other active listings from the same seller (shown on detail page).
  Future<List<ListingModel>> getSellerListings(
    String sellerId, {
    String? excludeId,
    int limit = 6,
  }) async {
    var q = _client
        .from('marketplace_listings')
        .select(_listingSelect)
        .eq('seller_id', sellerId)
        .eq('moderation', 'approved')
        .eq('status', 'active');
    if (excludeId != null) q = q.neq('id', excludeId);
    final data = await q.order('created_at', ascending: false).limit(limit);
    return (data as List)
        .map((r) => ListingModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Create / update / delete ─────────────────────────────────

  Future<String> uploadImage(String userId, Uint8List bytes, String ext) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('listings').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('listings').getPublicUrl(path);
  }

  Future<String> createListing({
    required String sellerId,
    String? universityId,
    required MarketCategory category,
    String? subcategory,
    required String title,
    String? description,
    double? price,
    String priceType = 'fixed',
    bool isNegotiable = false,
    String? condition,
    String? location,
    Map<String, dynamic> details = const {},
    List<String> imageUrls = const [],
    DateTime? expiresAt,
  }) async {
    final inserted = await _client
        .from('marketplace_listings')
        .insert({
          'seller_id': sellerId,
          if (universityId != null) 'university_id': universityId,
          'category': category.key,
          if (subcategory != null) 'subcategory': subcategory,
          'title': title,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          'price_type': priceType,
          'is_negotiable': isNegotiable,
          if (condition != null) 'condition': condition,
          if (location != null) 'location': location,
          'details': details,
          if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
        })
        .select('id')
        .single();

    final listingId = inserted['id'] as String;
    if (imageUrls.isNotEmpty) {
      await _client.from('listing_images').insert([
        for (var i = 0; i < imageUrls.length; i++)
          {'listing_id': listingId, 'url': imageUrls[i], 'position': i},
      ]);
    }
    return listingId;
  }

  Future<void> updateStatus(String listingId, String status) async {
    await _client
        .from('marketplace_listings')
        .update({'status': status}).eq('id', listingId);
  }

  Future<void> deleteListing(String listingId) async {
    await _client.from('marketplace_listings').delete().eq('id', listingId);
  }

  Future<void> recordView(String listingId) async {
    try {
      await _client.rpc('increment_listing_view',
          params: {'p_listing_id': listingId});
    } catch (_) {/* analytics best-effort */}
  }

  // ── Saved listings (wishlist) ────────────────────────────────

  Future<Set<String>> _savedIds(String userId) async {
    final data = await _client
        .from('saved_listings')
        .select('listing_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['listing_id'] as String).toSet();
  }

  Future<bool> toggleSaved(String listingId, String userId) async {
    final existing = await _client
        .from('saved_listings')
        .select('listing_id')
        .eq('user_id', userId)
        .eq('listing_id', listingId)
        .maybeSingle();
    if (existing != null) {
      await _client
          .from('saved_listings')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
      return false;
    }
    await _client
        .from('saved_listings')
        .insert({'user_id': userId, 'listing_id': listingId});
    return true;
  }

  Future<List<ListingModel>> getSavedListings(String userId) async {
    final data = await _client
        .from('saved_listings')
        .select('listing_id, marketplace_listings($_listingSelect)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => e['marketplace_listings'])
        .whereType<Map<String, dynamic>>()
        .map((r) => ListingModel.fromJson(r, savedIds: {r['id'] as String}))
        .toList();
  }

  // ── Freelancer profiles ──────────────────────────────────────

  static const _freelancerJoin =
      'profiles!freelancer_profiles_user_id_fkey'
      '(full_name, avatar_url, programme, level, is_verified)';

  Future<List<FreelancerProfile>> getFreelancers({
    String? category,
    String? query,
    int limit = 40,
  }) async {
    var q = _client
        .from('freelancer_profiles')
        .select('*, $_freelancerJoin')
        .eq('is_available', true);
    if (category != null && category.isNotEmpty) {
      q = q.contains('categories', [category]);
    }
    if (query != null && query.trim().isNotEmpty) {
      q = q.or('headline.ilike.%$query%,bio.ilike.%$query%');
    }
    final data = await q.order('rating', ascending: false).limit(limit);
    return (data as List)
        .map((r) => FreelancerProfile.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<FreelancerProfile?> getFreelancer(String userId) async {
    final data = await _client
        .from('freelancer_profiles')
        .select('*, $_freelancerJoin')
        .eq('user_id', userId)
        .maybeSingle();
    return data == null ? null : FreelancerProfile.fromJson(data);
  }

  Future<void> upsertFreelancer({
    required String userId,
    String? headline,
    String? bio,
    List<String> skills = const [],
    List<String> categories = const [],
    double? hourlyRate,
    List<String> portfolioUrls = const [],
    bool isAvailable = true,
  }) async {
    await _client.from('freelancer_profiles').upsert({
      'user_id': userId,
      'headline': headline,
      'bio': bio,
      'skills': skills,
      'categories': categories,
      'hourly_rate': hourlyRate,
      'portfolio_urls': portfolioUrls,
      'is_available': isAvailable,
    }, onConflict: 'user_id');
  }

  // ── Reviews & ratings ────────────────────────────────────────

  Future<List<ListingReview>> getReviews(String revieweeId) async {
    final data = await _client
        .from('marketplace_reviews')
        .select(
            '*, profiles!marketplace_reviews_reviewer_id_fkey(full_name, avatar_url)')
        .eq('reviewee_id', revieweeId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => ListingReview.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<SellerRating> getSellerRating(String userId) async {
    try {
      final data = await _client
          .rpc('seller_rating', params: {'p_user_id': userId});
      if (data is List && data.isNotEmpty) {
        final row = data.first as Map<String, dynamic>;
        return SellerRating(
          average: (row['avg_rating'] as num?)?.toDouble() ?? 0,
          total: row['total'] as int? ?? 0,
        );
      }
    } catch (_) {/* fall through */}
    return const SellerRating();
  }

  Future<void> addReview({
    required String revieweeId,
    required String reviewerId,
    String? listingId,
    String role = 'seller',
    required int rating,
    String? comment,
  }) async {
    await _client.from('marketplace_reviews').upsert({
      'reviewee_id': revieweeId,
      'reviewer_id': reviewerId,
      if (listingId != null) 'listing_id': listingId,
      'role': role,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    }, onConflict: 'reviewer_id,reviewee_id,listing_id');
  }

  // ── Reporting / moderation ───────────────────────────────────

  Future<void> reportListing({
    required String listingId,
    required String reporterId,
    required String reason,
    String? details,
  }) async {
    await _client.from('listing_reports').insert({
      'listing_id': listingId,
      'reporter_id': reporterId,
      'reason': reason,
      if (details != null) 'details': details,
    });
  }

  // ── Search analytics ─────────────────────────────────────────

  Future<void> logSearch(String? userId, String query, {String? category}) async {
    if (query.trim().isEmpty) return;
    try {
      await _client.from('marketplace_searches').insert({
        if (userId != null) 'user_id': userId,
        'query': query.trim(),
        if (category != null) 'category': category,
      });
    } catch (_) {/* best-effort */}
  }

  // ── Admin moderation ─────────────────────────────────────────

  /// Pending report queue with the reported listing + reporter joined.
  Future<List<ListingReportItem>> getReportQueue() async {
    final data = await _client
        .from('listing_reports')
        .select(
            '*, marketplace_listings(id, title, category, status, seller_id), '
            'profiles!listing_reports_reporter_id_fkey(full_name)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => ListingReportItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolveReport(String reportId, String status) async {
    await _client
        .from('listing_reports')
        .update({'status': status}).eq('id', reportId);
  }

  /// Admin: change a listing's moderation state (approve / reject) or remove it.
  Future<void> moderateListing(String listingId,
      {String? moderation, String? status}) async {
    await _client.from('marketplace_listings').update({
      if (moderation != null) 'moderation': moderation,
      if (status != null) 'status': status,
    }).eq('id', listingId);
  }

  // ── Admin analytics ──────────────────────────────────────────

  Future<MarketplaceStats> getStats() async {
    Future<int> count(String column, String value) async {
      final rows = await _client
          .from('marketplace_listings')
          .select('id')
          .eq(column, value);
      return (rows as List).length;
    }

    final categoryCounts = <String, int>{};
    try {
      final cc = await _client.rpc('marketplace_category_counts');
      for (final row in (cc as List)) {
        categoryCounts[row['category'] as String] =
            (row['total'] as num).toInt();
      }
    } catch (_) {/* ignore */}

    final topSearches = <String, int>{};
    try {
      final ts = await _client.rpc('top_marketplace_searches');
      for (final row in (ts as List)) {
        topSearches[row['query'] as String] = (row['total'] as num).toInt();
      }
    } catch (_) {/* ignore */}

    final pendingReports = (await _client
            .from('listing_reports')
            .select('id')
            .eq('status', 'pending') as List)
        .length;

    return MarketplaceStats(
      activeListings: await count('status', 'active'),
      soldListings: await count('status', 'sold'),
      pendingReports: pendingReports,
      categoryCounts: categoryCounts,
      topSearches: topSearches,
    );
  }
}
