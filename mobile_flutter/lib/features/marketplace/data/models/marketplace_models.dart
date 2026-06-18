import 'package:flutter/material.dart';

/// The nine marketplace categories. The string [key] matches the DB CHECK
/// constraint on `marketplace_listings.category`.
enum MarketCategory {
  buySell('buy_sell', 'Buy & Sell', Icons.storefront_rounded),
  hostel('hostel', 'Hostel Essentials', Icons.bed_rounded),
  academic('academic', 'Academic Resources', Icons.menu_book_rounded),
  service('service', 'Services', Icons.handyman_rounded),
  roommate('roommate', 'Roommate Finder', Icons.people_alt_rounded),
  lostFound('lost_found', 'Lost & Found', Icons.search_rounded),
  job('job', 'Campus Jobs', Icons.work_outline_rounded),
  internship('internship', 'Internships', Icons.business_center_rounded),
  ticket('ticket', 'Event Tickets', Icons.confirmation_number_rounded);

  const MarketCategory(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;

  static MarketCategory fromKey(String key) =>
      MarketCategory.values.firstWhere(
        (c) => c.key == key,
        orElse: () => MarketCategory.buySell,
      );

  /// Accent colour per category, for chips / headers / cards.
  Color get color {
    switch (this) {
      case MarketCategory.buySell:
        return const Color(0xFF0066FF);
      case MarketCategory.hostel:
        return const Color(0xFF0F766E);
      case MarketCategory.academic:
        return const Color(0xFF7C3AED);
      case MarketCategory.service:
        return const Color(0xFFEA580C);
      case MarketCategory.roommate:
        return const Color(0xFFDB2777);
      case MarketCategory.lostFound:
        return const Color(0xFFDC2626);
      case MarketCategory.job:
        return const Color(0xFF0891B2);
      case MarketCategory.internship:
        return const Color(0xFF2563EB);
      case MarketCategory.ticket:
        return const Color(0xFFD97706);
    }
  }

  /// Whether this category centres on a price (vs. roommate / lost&found / jobs).
  bool get isPriced => switch (this) {
        MarketCategory.buySell ||
        MarketCategory.hostel ||
        MarketCategory.academic ||
        MarketCategory.service ||
        MarketCategory.ticket =>
          true,
        _ => false,
      };
}

/// A single marketplace listing across all categories. Category-specific
/// fields live in [details].
class ListingModel {
  final String id;
  final String sellerId;
  final String? universityId;
  final MarketCategory category;
  final String? subcategory;
  final String title;
  final String? description;
  final double? price;
  final String priceType; // fixed | hourly | quote | free | swap
  final bool isNegotiable;
  final String currency;
  final String? condition;
  final String? location;
  final String status; // active | sold | fulfilled | expired | removed | pending
  final String moderation; // approved | pending | rejected
  final bool isFeatured;
  final int viewCount;
  final int saveCount;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String> images;

  // Joined seller identity
  final String? sellerName;
  final String? sellerAvatar;
  final String? sellerProgramme;
  final String? sellerLevel;
  final bool sellerVerified;
  final DateTime? sellerJoinedAt;

  // Per-viewer flag
  final bool isSaved;

  const ListingModel({
    required this.id,
    required this.sellerId,
    this.universityId,
    required this.category,
    this.subcategory,
    required this.title,
    this.description,
    this.price,
    this.priceType = 'fixed',
    this.isNegotiable = false,
    this.currency = 'GHS',
    this.condition,
    this.location,
    this.status = 'active',
    this.moderation = 'approved',
    this.isFeatured = false,
    this.viewCount = 0,
    this.saveCount = 0,
    this.details = const {},
    required this.createdAt,
    this.expiresAt,
    this.images = const [],
    this.sellerName,
    this.sellerAvatar,
    this.sellerProgramme,
    this.sellerLevel,
    this.sellerVerified = false,
    this.sellerJoinedAt,
    this.isSaved = false,
  });

  factory ListingModel.fromJson(
    Map<String, dynamic> json, {
    Set<String> savedIds = const {},
  }) {
    final p = json['profiles'] as Map<String, dynamic>?;
    final imgs = (json['listing_images'] as List?) ?? const [];
    final imgList = imgs
        .map((e) => e as Map<String, dynamic>)
        .toList()
      ..sort((a, b) =>
          (a['position'] as int? ?? 0).compareTo(b['position'] as int? ?? 0));

    return ListingModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      universityId: json['university_id'] as String?,
      category: MarketCategory.fromKey(json['category'] as String),
      subcategory: json['subcategory'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      priceType: json['price_type'] as String? ?? 'fixed',
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'GHS',
      condition: json['condition'] as String?,
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'active',
      moderation: json['moderation'] as String? ?? 'approved',
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
      details: (json['details'] as Map?)?.cast<String, dynamic>() ?? const {},
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      images: imgList.map((e) => e['url'] as String).toList(),
      sellerName: p?['full_name'] as String?,
      sellerAvatar: p?['avatar_url'] as String?,
      sellerProgramme: p?['programme'] as String?,
      sellerLevel: p?['level'] as String?,
      sellerVerified: p?['is_verified'] as bool? ?? false,
      sellerJoinedAt: p?['created_at'] != null
          ? DateTime.tryParse(p!['created_at'] as String)
          : null,
      isSaved: savedIds.contains(json['id'] as String),
    );
  }

  String? get coverImage => images.isNotEmpty ? images.first : null;

  bool get isFree => priceType == 'free' || (price == null && category.isPriced);
  bool get isSold => status == 'sold' || status == 'fulfilled';

  /// Human-readable price label (e.g. "GHS 1,200", "Free", "Negotiable").
  String get priceLabel {
    if (priceType == 'free') return 'Free';
    if (priceType == 'swap') return 'Swap';
    if (priceType == 'quote' || price == null) {
      return category.isPriced ? 'Ask for price' : '';
    }
    final formatted = _money(price!);
    final suffix = priceType == 'hourly' ? '/hr' : '';
    return '$currency $formatted$suffix';
  }

  static String _money(double v) {
    final whole = v.truncateToDouble() == v;
    final s = whole ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    // Thousands separators
    final parts = s.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }

  String get conditionLabel {
    switch (condition) {
      case 'new':
        return 'Brand New';
      case 'like_new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      case 'for_parts':
        return 'For Parts';
      default:
        return '';
    }
  }

  T? detail<T>(String key) => details[key] as T?;
}

/// A freelancer / service-provider profile (mini-Fiverr).
class FreelancerProfile {
  final String id;
  final String userId;
  final String? headline;
  final String? bio;
  final List<String> skills;
  final List<String> categories;
  final double? hourlyRate;
  final List<String> portfolioUrls;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final int completedJobs;

  // Joined identity
  final String? name;
  final String? avatar;
  final String? programme;
  final String? level;
  final bool verified;

  const FreelancerProfile({
    required this.id,
    required this.userId,
    this.headline,
    this.bio,
    this.skills = const [],
    this.categories = const [],
    this.hourlyRate,
    this.portfolioUrls = const [],
    this.isAvailable = true,
    this.rating = 0,
    this.reviewCount = 0,
    this.completedJobs = 0,
    this.name,
    this.avatar,
    this.programme,
    this.level,
    this.verified = false,
  });

  factory FreelancerProfile.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    List<String> arr(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];
    return FreelancerProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      headline: json['headline'] as String?,
      bio: json['bio'] as String?,
      skills: arr(json['skills']),
      categories: arr(json['categories']),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      portfolioUrls: arr(json['portfolio_urls']),
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      completedJobs: json['completed_jobs'] as int? ?? 0,
      name: p?['full_name'] as String?,
      avatar: p?['avatar_url'] as String?,
      programme: p?['programme'] as String?,
      level: p?['level'] as String?,
      verified: p?['is_verified'] as bool? ?? false,
    );
  }

  String get initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}

/// A seller / freelancer review.
class ListingReview {
  final String id;
  final String? listingId;
  final String revieweeId;
  final String reviewerId;
  final String role; // seller | buyer | freelancer
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerAvatar;

  const ListingReview({
    required this.id,
    this.listingId,
    required this.revieweeId,
    required this.reviewerId,
    this.role = 'seller',
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatar,
  });

  factory ListingReview.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return ListingReview(
      id: json['id'] as String,
      listingId: json['listing_id'] as String?,
      revieweeId: json['reviewee_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      role: json['role'] as String? ?? 'seller',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerName: p?['full_name'] as String?,
      reviewerAvatar: p?['avatar_url'] as String?,
    );
  }
}

/// Aggregate rating for a seller / freelancer.
class SellerRating {
  final double average;
  final int total;
  const SellerRating({this.average = 0, this.total = 0});
}

/// A row in the admin moderation report queue.
class ListingReportItem {
  final String id;
  final String reason;
  final String? details;
  final DateTime createdAt;
  final String? listingId;
  final String? listingTitle;
  final String? listingStatus;
  final String? reporterName;

  const ListingReportItem({
    required this.id,
    required this.reason,
    this.details,
    required this.createdAt,
    this.listingId,
    this.listingTitle,
    this.listingStatus,
    this.reporterName,
  });

  factory ListingReportItem.fromJson(Map<String, dynamic> json) {
    final l = json['marketplace_listings'] as Map<String, dynamic>?;
    final p = json['profiles'] as Map<String, dynamic>?;
    return ListingReportItem(
      id: json['id'] as String,
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      listingId: l?['id'] as String?,
      listingTitle: l?['title'] as String?,
      listingStatus: l?['status'] as String?,
      reporterName: p?['full_name'] as String?,
    );
  }
}

/// Aggregate marketplace statistics for the admin dashboard.
class MarketplaceStats {
  final int activeListings;
  final int soldListings;
  final int pendingReports;
  final Map<String, int> categoryCounts;
  final Map<String, int> topSearches;

  const MarketplaceStats({
    this.activeListings = 0,
    this.soldListings = 0,
    this.pendingReports = 0,
    this.categoryCounts = const {},
    this.topSearches = const {},
  });
}

/// Filters applied to a marketplace browse query.
class ListingFilter {
  final MarketCategory? category;
  final String? subcategory;
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? location;
  final String sort; // recent | price_asc | price_desc | popular

  const ListingFilter({
    this.category,
    this.subcategory,
    this.query,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.location,
    this.sort = 'recent',
  });

  ListingFilter copyWith({
    MarketCategory? category,
    String? subcategory,
    String? query,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? sort,
    bool clearCategory = false,
    bool clearSub = false,
  }) {
    return ListingFilter(
      category: clearCategory ? null : (category ?? this.category),
      subcategory: clearSub ? null : (subcategory ?? this.subcategory),
      query: query ?? this.query,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      sort: sort ?? this.sort,
    );
  }
}
