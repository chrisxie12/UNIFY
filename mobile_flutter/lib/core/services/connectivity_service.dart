import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service.statusStream;
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  ConnectivityStatus get currentStatus => _lastStatus;
  ConnectivityStatus _lastStatus = ConnectivityStatus.online;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
      _lastStatus = isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;
      _controller.add(_lastStatus);
    });
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
    } catch (e) {
      debugPrint('[ConnectivityService] Check failed: $e');
      return true;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
