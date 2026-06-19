import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../system/data/models/system_models.dart';
import '../../../system/presentation/providers/feature_flags_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

class FeatureFlagsScreen extends ConsumerWidget {
  const FeatureFlagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(allFeatureFlagsProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Feature Flags',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: flags.when(
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _FlagTile(flag: list[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FlagTile extends ConsumerWidget {
  final FeatureFlag flag;
  const _FlagTile({required this.flag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flag.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                if (flag.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(flag.description,
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary.shade600)),
                  ),
              ],
            ),
          ),
          Switch(
            value: flag.enabled,
            activeTrackColor: const Color(0xFF0066FF).withValues(alpha: 0.5),
            activeThumbColor: const Color(0xFF0066FF),
            onChanged: (v) {
              ref
                  .read(featureFlagsRepositoryProvider)
                  .toggle(flag.id, v);
              ref.invalidate(allFeatureFlagsProvider);
            },
          ),
        ],
      ),
    );
  }
}
