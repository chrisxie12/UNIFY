import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';

/// Provides a `ProfileRepositoryImpl` backed by the Supabase client.
final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  return ProfileRepositoryImpl(ref.watch(supabaseProvider));
});

/// Fetches any user's profile by ID (for viewing other members' profiles).
final viewProfileProvider = FutureProvider.autoDispose.family<Profile?, String>((ref, userId) async {
  final client = ref.watch(supabaseProvider);
  final data = await client.from('profiles').select().eq('id', userId).maybeSingle();
  if (data == null) return null;
  return ProfileModel.fromJson({...data, 'email': ''});
});

/// Fetches the authenticated user's full profile from Supabase.
final profileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  final data = await client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) return null;
  return ProfileModel.fromJson({...data, 'email': user.email ?? ''});
});

/// Post count for the authenticated user, counted from the announcements table.
final profileStatsProvider =
    FutureProvider.autoDispose<_ProfileStats>((ref) async {
  ref.watch(authStateProvider);
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return const _ProfileStats(postCount: 0);

  final result = await client
      .from('announcements')
      .select('id')
      .eq('author_id', user.id);

  final postCount = (result as List).length;
  return _ProfileStats(postCount: postCount);
});

class _ProfileStats {
  final int postCount;
  const _ProfileStats({required this.postCount});
}
