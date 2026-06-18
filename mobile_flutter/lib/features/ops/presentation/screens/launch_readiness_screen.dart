import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/ops_provider.dart';
import '../widgets/ops_widgets.dart';

class LaunchReadinessScreen extends ConsumerWidget {
  const LaunchReadinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessAsync = ref.watch(launchReadinessProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Launch Readiness',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(launchReadinessProvider),
        child: readinessAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Could not load: $e')),
              ),
            ],
          ),
          data: (m) {
            final verificationPending = opsInt(m['verification_pending']);
            final totalUsers = opsInt(m['total_users']);
            final newUsers7d = opsInt(m['new_users_7d']);
            final verifiedLeaders = opsInt(m['verified_leaders']);
            final communities = opsInt(m['communities']);
            final communities7d = opsInt(m['communities_7d']);
            final eventsUpcoming = opsInt(m['events_upcoming']);
            final listingsActive = opsInt(m['listings_active']);
            final betaTesters = opsInt(m['beta_testers']);
            final waitlist = opsInt(m['waitlist']);
            final openFeedback = opsInt(m['open_feedback']);
            final openAbuse = opsInt(m['open_abuse']);
            final criticalErrors24h = opsInt(m['critical_errors_24h']);
            final dau = opsInt(m['dau']);

            final checks = <({String label, bool ok})>[
              (label: 'No critical errors (24h)', ok: criticalErrors24h == 0),
              (
                label: 'Verification backlog under control',
                ok: verificationPending <= 5
              ),
              (label: 'Has registered users', ok: totalUsers > 0),
              (label: 'Has active communities', ok: communities > 0),
              (label: 'Daily active users present', ok: dau > 0),
            ];
            final passing = checks.where((c) => c.ok).length;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: [
                _ReadinessSummary(checks: checks, passing: passing),
                OpsSectionCard(
                  title: 'Users',
                  icon: Icons.group_rounded,
                  children: [
                    OpsMetricRow(label: 'Total users', value: '$totalUsers'),
                    OpsMetricRow(label: 'New users (7d)', value: '$newUsers7d'),
                    OpsMetricRow(
                        label: 'Verified leaders', value: '$verifiedLeaders'),
                    OpsMetricRow(label: 'Daily active users', value: '$dau'),
                  ],
                ),
                OpsSectionCard(
                  title: 'Communities',
                  icon: Icons.groups_rounded,
                  children: [
                    OpsMetricRow(
                        label: 'Active communities', value: '$communities'),
                    OpsMetricRow(
                        label: 'New communities (7d)',
                        value: '$communities7d'),
                  ],
                ),
                OpsSectionCard(
                  title: 'Activity',
                  icon: Icons.event_available_rounded,
                  children: [
                    OpsMetricRow(
                        label: 'Upcoming events', value: '$eventsUpcoming'),
                    OpsMetricRow(
                        label: 'Active listings', value: '$listingsActive'),
                  ],
                ),
                OpsSectionCard(
                  title: 'Growth',
                  icon: Icons.trending_up_rounded,
                  children: [
                    OpsMetricRow(label: 'Beta testers', value: '$betaTesters'),
                    OpsMetricRow(label: 'Waitlist', value: '$waitlist'),
                  ],
                ),
                OpsSectionCard(
                  title: 'Moderation & Health',
                  icon: Icons.shield_rounded,
                  children: [
                    OpsMetricRow(
                      label: 'Verification pending',
                      value: '$verificationPending',
                      valueColor: verificationPending > 5
                          ? AppColors.warning
                          : null,
                    ),
                    OpsMetricRow(
                        label: 'Open feedback', value: '$openFeedback'),
                    OpsMetricRow(label: 'Open abuse reports', value: '$openAbuse'),
                    OpsMetricRow(
                      label: 'Critical errors (24h)',
                      value: '$criticalErrors24h',
                      valueColor:
                          criticalErrors24h > 0 ? AppColors.error : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReadinessSummary extends StatelessWidget {
  final List<({String label, bool ok})> checks;
  final int passing;
  const _ReadinessSummary({required this.checks, required this.passing});

  @override
  Widget build(BuildContext context) {
    final allGood = passing == checks.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allGood
                    ? Icons.verified_rounded
                    : Icons.fact_check_rounded,
                color: allGood ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Readiness',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary),
              ),
              const Spacer(),
              Text(
                '$passing of ${checks.length} checks passing',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: allGood ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...checks.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    c.ok
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    size: 18,
                    color: c.ok ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.label,
                      style: TextStyle(
                          fontSize: 13.5, color: context.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
