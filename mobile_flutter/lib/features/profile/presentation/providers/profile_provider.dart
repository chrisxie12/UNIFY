import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/profile_model.dart';
import '../../domain/entities/profile.dart';

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
