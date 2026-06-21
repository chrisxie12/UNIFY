import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/unify_post.dart';
import '../../../../core/providers/supabase_provider.dart';

final unifyFeedStreamProvider = StreamProvider<List<UnifyPost>>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return supabase
      .from('community_posts')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .limit(50)
      .map((data) {
        return data.map((json) => UnifyPost.fromJson(json)).toList();
      });
});
