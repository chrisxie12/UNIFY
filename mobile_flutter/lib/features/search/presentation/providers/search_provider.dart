import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';

class SearchResults {
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> communities;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> resources;
  final List<Map<String, dynamic>> opportunities;

  const SearchResults({
    this.students = const [],
    this.communities = const [],
    this.events = const [],
    this.resources = const [],
    this.opportunities = const [],
  });

  bool get isEmpty =>
      students.isEmpty &&
      communities.isEmpty &&
      events.isEmpty &&
      resources.isEmpty &&
      opportunities.isEmpty;

  int get totalCount =>
      students.length +
      communities.length +
      events.length +
      resources.length +
      opportunities.length;
}

final globalSearchProvider = FutureProvider.family<SearchResults, String>((ref, query) async {
  if (query.trim().length < 2) return const SearchResults();

  final supabase = ref.watch(supabaseProvider);
  final searchTerm = query.trim();
  final likePattern = '%$searchTerm%';

  final results = await Future.wait([
    // Students / Profiles
    supabase
        .from('profiles')
        .select('id, full_name, avatar_url, programme, department, level, university_id')
        .or('full_name.ilike.$likePattern,programme.ilike.$likePattern,department.ilike.$likePattern')
        .limit(5),
    // Communities
    supabase
        .from('communities')
        .select('id, name, description, avatar_url, member_count, university_id')
        .or('name.ilike.$likePattern,description.ilike.$likePattern')
        .limit(5),
    // Events
    supabase
        .from('community_events')
        .select('id, title, description, venue, event_date, event_time, image_url, community_id')
        .or('title.ilike.$likePattern,description.ilike.$likePattern,venue.ilike.$likePattern')
        .limit(5),
    // Academic Resources
    supabase
        .from('academic_resources')
        .select('id, title, description, file_type, course_id, uploaded_by')
        .or('title.ilike.$likePattern,description.ilike.$likePattern')
        .limit(5),
    // Opportunities
    supabase
        .from('opportunities')
        .select('id, title, organization, type, deadline, description')
        .or('title.ilike.$likePattern,organization.ilike.$likePattern,description.ilike.$likePattern')
        .limit(5),
  ]);

  return SearchResults(
    students: (results[0] as List).cast<Map<String, dynamic>>(),
    communities: (results[1] as List).cast<Map<String, dynamic>>(),
    events: (results[2] as List).cast<Map<String, dynamic>>(),
    resources: (results[3] as List).cast<Map<String, dynamic>>(),
    opportunities: (results[4] as List).cast<Map<String, dynamic>>(),
  );
});
