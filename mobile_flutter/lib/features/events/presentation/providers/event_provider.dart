import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/repositories/event_repository.dart';
import '../../data/models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.watch(supabaseProvider));
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

// ── Discovery ─────────────────────────────────────────────

final communityEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, communityId) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getEvents(communityId, currentUserId: userId);
});

final upcomingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getUpcomingEvents(currentUserId: userId);
});

final trendingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getTrendingEvents(currentUserId: userId);
});

final featuredEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getFeaturedEvents(currentUserId: userId);
});

final eventsByScopeProvider = FutureProvider.family<List<EventModel>, String>((ref, scope) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getEventsByScope(scope, currentUserId: userId);
});

final savedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.getSavedEvents(userId);
});

final searchEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.searchEvents(query, currentUserId: userId);
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return repo.getEvent(eventId, userId: userId);
});

// ── Tickets ───────────────────────────────────────────────

final myTicketsProvider = FutureProvider<List<EventTicketModel>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.getMyTickets(userId);
});

final myTicketProvider = FutureProvider.family<EventTicketModel?, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return repo.getMyTicket(eventId, userId);
});

final eventTicketsProvider = FutureProvider.family<List<EventTicketModel>, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventTickets(eventId);
});

final attendanceAnalyticsProvider = FutureProvider.family<EventAttendanceAnalytics, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getAttendanceAnalytics(eventId);
});

// ── Discussions ──────────────────────────────────────────

final eventDiscussionsProvider = FutureProvider.family<List<EventDiscussion>, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventDiscussions(eventId);
});

// ── Media ────────────────────────────────────────────────

final eventMediaProvider = FutureProvider.family<List<EventMedia>, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventMedia(eventId);
});

// ── Certificates ─────────────────────────────────────────

final userCertificatesProvider = FutureProvider<List<EventCertificate>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return repo.getUserCertificates(userId);
});
