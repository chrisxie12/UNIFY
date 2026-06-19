import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../extensions/theme_extensions.dart';

/// Wraps [child] with an animated offline banner that slides in when the
/// device loses network connectivity and slides out when it reconnects.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});
  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<List<ConnectivityResult>> _sub;
  bool _isOffline = false;
  late final AnimationController _ctrl;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _sub = Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
    // Check initial state
    Connectivity().checkConnectivity().then(_onConnectivityChange);
  }

  void _onConnectivityChange(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline == _isOffline) return;
    setState(() => _isOffline = offline);
    if (offline) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _slide,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            color: context.isDark
                ? const Color(0xFF3D1A00)
                : const Color(0xFFFFF3CD),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 16,
                  color: context.isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF92400E),
                ),
                const SizedBox(width: 8),
                Text(
                  'No internet connection',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
