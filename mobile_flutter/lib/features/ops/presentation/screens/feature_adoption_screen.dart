import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/ops_models.dart';
import '../providers/ops_provider.dart';

class FeatureAdoptionScreen extends ConsumerWidget {
  const FeatureAdoptionScreen({super.key});

  static const Map<String, ({IconData icon, String label})> _meta = {
    'communities': (icon: Icons.groups_rounded, label: 'Communities'),
    'messaging': (icon: Icons.chat_bubble_rounded, label: 'Messaging'),
    'marketplace': (icon: Icons.storefront_rounded, label: 'Marketplace'),
    'academic': (icon: Icons.school_rounded, label: 'Academic Hub'),
    'events': (icon: Icons.event_rounded, label: 'Events'),
    'opportunities': (icon: Icons.explore_rounded, label: 'Opportunities'),
  };

  ({IconData icon, String label}) _metaFor(String key) {
    return _meta[key] ?? (icon: Icons.widgets_rounded, label: key);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptionAsync = ref.watch(featureAdoptionProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Feature Adoption',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(featureAdoptionProvider),
        child: adoptionAsync.when(
          loading: () => const AppLoadingWidget.list(itemCount: 5),
          error: (e, _) => AppErrorWidget(e),
          data: (features) {
            if (features.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.insights_rounded,
                      size: 56, color: context.borderCol),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No analytics yet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Feature usage will appear here once members start '
                      'interacting with the app over the last 30 days.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: context.textSecondary),
                    ),
                  ),
                ],
              );
            }

            final maxUsers = features
                .map((f) => f.users)
                .reduce((a, b) => a > b ? a : b);
            // Lowest-usage feature (server sorts desc, so it's the last with
            // any users — but compute defensively).
            FeatureAdoption? lowest;
            for (final f in features) {
              if (lowest == null || f.users < lowest.users) lowest = f;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                  child: Text(
                    'Active users per feature (last 30 days)',
                    style: TextStyle(fontSize: 12.5, color: context.textSecondary),
                  ),
                ),
                ...features.map((f) {
                  final meta = _metaFor(f.feature);
                  final ratio = maxUsers == 0 ? 0.0 : f.users / maxUsers;
                  final isUnderused =
                      lowest != null && f.feature == lowest.feature;
                  return _FeatureRow(
                    icon: meta.icon,
                    label: meta.label,
                    users: f.users,
                    events: f.events,
                    ratio: ratio,
                    underused: isUnderused,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int users;
  final int events;
  final double ratio;
  final bool underused;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.users,
    required this.events,
    required this.ratio,
    required this.underused,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary),
                ),
              ),
              if (underused) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Underused',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text('$users',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                underused ? AppColors.warning : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$users ${users == 1 ? 'user' : 'users'} · $events ${events == 1 ? 'event' : 'events'}',
            style: TextStyle(fontSize: 11.5, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}