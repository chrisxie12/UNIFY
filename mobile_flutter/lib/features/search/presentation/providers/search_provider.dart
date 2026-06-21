import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/supabase_provider.dart';

// ── Category enum ─────────────────────────────────────────────────────────────

enum SearchCategory { all, people, communities, events, academic, marketplace }

// ── All-tab mixed result model ────────────────────────────────────────────────

class SearchResults {
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> communities;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> resources;
  final List<Map<String, dynamic>> opportunities;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> listings;
  final List<Map<String, dynamic>> freelancers;

  const SearchResults({
    this.students = const [],
    this.communities = const [],
    this.events = const [],
    this.resources = const [],
    this.opportunities = const [],
    this.courses = const [],
    this.listings = const [],
    this.freelancers = const [],
  });

  bool get isEmpty =>
      students.isEmpty && communities.isEmpty && events.isEmpty &&
      resources.isEmpty && opportunities.isEmpty && courses.isEmpty &&
      listings.isEmpty && freelancers.isEmpty;

  int get totalCount =>
      students.length + communities.length + events.length +
      resources.length + opportunities.length + courses.length +
      listings.length + freelancers.length;
}

// ── Paginated single-category result ─────────────────────────────────────────

class SearchPage {
  final List<Map<String, dynamic>> items;
  final bool hasMore;
  const SearchPage({required this.items, required this.hasMore});
}

// ── globalSearchProvider — top-5 per category for the "All" tab ───────────────

final globalSearchProvider = FutureProvider.family<SearchResults, String>((ref, query) async {
  final q = query.trim();
  if (q.length < 2) return const SearchResults();

  final supabase = ref.watch(supabaseProvider);
  final like = '%$q%';

  final results = await Future.wait([
    supabase.from('profiles')
        .select('id, full_name, avatar_url, programme, department, level')
        .or('full_name.ilike.$like,programme.ilike.$like,department.ilike.$like')
        .limit(5),
    supabase.from('communities')
        .select('id, name, description, avatar_url, member_count')
        .or('name.ilike.$like,description.ilike.$like')
        .limit(5),
    supabase.from('community_events')
        .select('id, title, description, venue, event_date, event_time, image_url')
        .or('title.ilike.$like,description.ilike.$like,venue.ilike.$like')
        .limit(5),
    supabase.from('academic_resources')
        .select('id, title, description, file_type, course_id')
        .or('title.ilike.$like,description.ilike.$like')
        .limit(5),
    supabase.from('opportunities')
        .select('id, title, organization, type, deadline, description')
        .or('title.ilike.$like,organization.ilike.$like,description.ilike.$like')
        .limit(5),
    supabase.from('courses')
        .select('id, code, name, description, department, credits')
        .or('code.ilike.$like,name.ilike.$like,description.ilike.$like')
        .limit(5),
    supabase.from('marketplace_listings')
        .select('id, title, price, condition, category, image_urls')
        .or('title.ilike.$like,description.ilike.$like')
        .eq('status', 'active')
        .limit(5),
    supabase.from('freelancer_profiles')
        .select('id, user_id, headline, bio, skills, hourly_rate, profile_image_url')
        .or('headline.ilike.$like,bio.ilike.$like')
        .limit(5),
  ]);

  return SearchResults(
    students:      (results[0] as List).cast<Map<String, dynamic>>(),
    communities:   (results[1] as List).cast<Map<String, dynamic>>(),
    events:        (results[2] as List).cast<Map<String, dynamic>>(),
    resources:     (results[3] as List).cast<Map<String, dynamic>>(),
    opportunities: (results[4] as List).cast<Map<String, dynamic>>(),
    courses:       (results[5] as List).cast<Map<String, dynamic>>(),
    listings:      (results[6] as List).cast<Map<String, dynamic>>(),
    freelancers:   (results[7] as List).cast<Map<String, dynamic>>(),
  );
});

// ── categorySearchProvider — paginated per-category tab ───────────────────────

const _kPageSize = 20;
const _kHalfPage = _kPageSize ~/ 2;

typedef _CatParams = ({String query, SearchCategory category, int offset});

final categorySearchProvider =
    FutureProvider.family<SearchPage, _CatParams>((ref, p) async {
  final q = p.query.trim();
  if (q.length < 2) return const SearchPage(items: [], hasMore: false);

  final supabase = ref.watch(supabaseProvider);
  final like = '%$q%';
  final from = p.offset;
  final to = p.offset + _kPageSize - 1;

  switch (p.category) {
    case SearchCategory.all:
      return const SearchPage(items: [], hasMore: false);

    case SearchCategory.people:
      final rows = (await supabase
          .from('profiles')
          .select('id, full_name, avatar_url, programme, department, level')
          .or('full_name.ilike.$like,programme.ilike.$like,department.ilike.$like')
          .range(from, to))
          .cast<Map<String, dynamic>>();
      return SearchPage(items: rows, hasMore: rows.length == _kPageSize);

    case SearchCategory.communities:
      final rows = (await supabase
          .from('communities')
          .select('id, name, description, avatar_url, member_count')
          .or('name.ilike.$like,description.ilike.$like')
          .range(from, to))
          .cast<Map<String, dynamic>>();
      return SearchPage(items: rows, hasMore: rows.length == _kPageSize);

    case SearchCategory.events:
      final rows = (await supabase
          .from('community_events')
          .select('id, title, description, venue, event_date, event_time, image_url')
          .or('title.ilike.$like,description.ilike.$like,venue.ilike.$like')
          .range(from, to))
          .cast<Map<String, dynamic>>();
      return SearchPage(items: rows, hasMore: rows.length == _kPageSize);

    case SearchCategory.academic:
      final halfFrom = (p.offset ~/ 2);
      final halfTo = halfFrom + _kHalfPage - 1;
      final [courseRows, resourceRows] = await Future.wait([
        supabase.from('courses')
            .select('id, code, name, description, department, credits')
            .or('code.ilike.$like,name.ilike.$like,description.ilike.$like')
            .range(halfFrom, halfTo),
        supabase.from('academic_resources')
            .select('id, title, description, file_type, course_id')
            .or('title.ilike.$like,description.ilike.$like')
            .range(halfFrom, halfTo),
      ]);
      final items = [
        ...courseRows.cast<Map<String, dynamic>>().map((r) => {...r, '_type': 'course'}),
        ...resourceRows.cast<Map<String, dynamic>>().map((r) => {...r, '_type': 'resource'}),
      ];
      return SearchPage(
        items: items,
        hasMore: courseRows.length == _kHalfPage || resourceRows.length == _kHalfPage,
      );

    case SearchCategory.marketplace:
      final halfFrom = (p.offset ~/ 2);
      final halfTo = halfFrom + _kHalfPage - 1;
      final [listingRows, freelancerRows] = await Future.wait([
        supabase.from('marketplace_listings')
            .select('id, title, price, condition, category, image_urls')
            .or('title.ilike.$like,description.ilike.$like')
            .eq('status', 'active')
            .range(halfFrom, halfTo),
        supabase.from('freelancer_profiles')
            .select('id, user_id, headline, bio, skills, hourly_rate, profile_image_url')
            .or('headline.ilike.$like,bio.ilike.$like')
            .range(halfFrom, halfTo),
      ]);
      final items = [
        ...listingRows.cast<Map<String, dynamic>>().map((r) => {...r, '_type': 'listing'}),
        ...freelancerRows.cast<Map<String, dynamic>>().map((r) => {...r, '_type': 'freelancer'}),
      ];
      return SearchPage(
        items: items,
        hasMore: listingRows.length == _kHalfPage || freelancerRows.length == _kHalfPage,
      );
  }
});

// ── Recent Searches ───────────────────────────────────────────────────────────

const _kRecentKey = 'recent_searches';
const _kMaxRecent = 10;

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kRecentKey) ?? [];
    if (mounted) state = raw;
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [q, ...state.where((s) => s != q)].take(_kMaxRecent).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecentKey, updated);
  }

  Future<void> remove(String query) async {
    final updated = state.where((s) => s != query).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecentKey, updated);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentKey);
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
  (_) => RecentSearchesNotifier(),
);
