import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class CacheService {
  final Duration _expiry;

  CacheService({Duration? expiry}) : _expiry = expiry ?? AppConstants.cacheExpiry;

  Future<Box<String>> _openBox(String boxName) async {
    return await Hive.openBox<String>(boxName);
  }

  Future<void> put({
    required String boxName,
    required String key,
    required dynamic data,
  }) async {
    try {
      final box = await _openBox(boxName);
      final entry = jsonEncode({
        'data': data,
        'cached_at': DateTime.now().toIso8601String(),
      });
      await box.put(key, entry);
    } catch (e) {
      debugPrint('[CacheService] Put failed ($boxName/$key): $e');
    }
  }

  Future<dynamic> get({
    required String boxName,
    required String key,
  }) async {
    try {
      final box = await _openBox(boxName);
      final raw = box.get(key);
      if (raw == null) return null;

      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(entry['cached_at'] as String);
      if (DateTime.now().difference(cachedAt) > _expiry) {
        await box.delete(key);
        return null;
      }
      return entry['data'];
    } catch (e) {
      debugPrint('[CacheService] Get failed ($boxName/$key): $e');
      return null;
    }
  }

  Future<void> invalidate({required String boxName, String? key}) async {
    try {
      final box = await _openBox(boxName);
      if (key != null) {
        await box.delete(key);
      } else {
        await box.clear();
      }
    } catch (e) {
      debugPrint('[CacheService] Invalidate failed ($boxName): $e');
    }
  }

  Future<void> invalidateAll() async {
    try {
      await Hive.deleteBoxFromDisk(AppConstants.feedBoxName);
      await Hive.deleteBoxFromDisk(AppConstants.profileCacheBox);
    } catch (e) {
      debugPrint('[CacheService] Invalidate all failed: $e');
    }
  }
}
