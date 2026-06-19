import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/system/presentation/providers/feature_flags_provider.dart';

/// Wraps [child] so it only renders when the feature flag [flagKey] is
/// enabled. Shows nothing (or [fallback]) while loading / disabled.
class FeatureFlagGate extends ConsumerWidget {
  final String flagKey;
  final Widget child;
  final Widget? fallback;

  const FeatureFlagGate({
    super.key,
    required this.flagKey,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(allFeatureFlagsProvider);
    return flags.when(
      data: (list) {
        final match = list.where((f) => f.key == flagKey);
        if (match.isEmpty) return child;
        return match.first.enabled ? child : (fallback ?? const SizedBox.shrink());
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

/// Shorthand — returns a simple bool for use in imperative code.
bool refFlagBool(WidgetRef ref, String flagKey) {
  final flags = ref.read(allFeatureFlagsProvider).valueOrNull;
  if (flags == null) return true;
  final match = flags.where((f) => f.key == flagKey);
  if (match.isEmpty) return true;
  return match.first.enabled;
}
