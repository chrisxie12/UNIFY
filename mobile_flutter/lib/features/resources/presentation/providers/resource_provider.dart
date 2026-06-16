import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/resource_repository.dart';
import '../../data/repositories/resource_repository_impl.dart';
import '../../data/models/community_resource_model.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepositoryImpl(Supabase.instance.client);
});

final communityResourcesProvider = FutureProvider.family<List<CommunityResourceModel>, String>((ref, communityId) async {
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getResources(communityId);
});
