import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/support_models.dart';
import '../../data/repositories/support_repository_impl.dart';

final supportRepositoryProvider = Provider<SupportRepositoryImpl>((ref) {
  return SupportRepositoryImpl(ref.watch(supabaseProvider));
});

final faqsProvider = FutureProvider.autoDispose<List<FaqItem>>((ref) async {
  return ref.read(supportRepositoryProvider).getFaqs();
});

final articlesProvider =
    FutureProvider.autoDispose<List<HelpArticle>>((ref) async {
  return ref.read(supportRepositoryProvider).getArticles();
});

final articleProvider =
    FutureProvider.autoDispose.family<HelpArticle?, String>((ref, id) async {
  return ref.read(supportRepositoryProvider).getArticle(id);
});

final myTicketsProvider =
    FutureProvider.autoDispose<List<SupportTicket>>((ref) async {
  ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.read(supportRepositoryProvider).getMyTickets(user.id);
});

/// Admin ticket queue, optionally filtered by status (null = all).
final allTicketsProvider =
    FutureProvider.autoDispose.family<List<SupportTicket>, String?>(
        (ref, status) async {
  return ref.read(supportRepositoryProvider).getAllTickets(status: status);
});

/// Admin abuse queue, optionally filtered by status (null = all).
final abuseReportsProvider =
    FutureProvider.autoDispose.family<List<AbuseReport>, String?>(
        (ref, status) async {
  return ref.read(supportRepositoryProvider).getAbuseReports(status: status);
});
