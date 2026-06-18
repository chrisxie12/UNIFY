import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});
