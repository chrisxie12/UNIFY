import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/repositories/event_repository.dart';
import '../../data/models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.watch(supabaseProvider));
});

final communityEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, communityId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvents(communityId);
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvent(eventId);
});
