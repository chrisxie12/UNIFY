import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _lastKnown;
  bool _serviceEnabled = false;
  LocationPermission _permission = LocationPermission.denied;

  Position? get lastKnown => _lastKnown;
  bool get isLocationAvailable => _lastKnown != null;

  Future<Position?> getCurrentPosition() async {
    if (_lastKnown != null) return _lastKnown;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      debugPrint('[LocationService] Location services disabled');
      return null;
    }

    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        debugPrint('[LocationService] Location permission denied');
        return null;
      }
    }

    if (_permission == LocationPermission.deniedForever) {
      debugPrint('[LocationService] Location permission permanently denied');
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 10));
      _lastKnown = position;
      return position;
    } catch (e) {
      debugPrint('[LocationService] getCurrentPosition error: $e');
      return null;
    }
  }

  Future<void> refreshLocation() async {
    _lastKnown = null;
    await getCurrentPosition();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = FutureProvider.autoDispose<Position?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentPosition();
});
