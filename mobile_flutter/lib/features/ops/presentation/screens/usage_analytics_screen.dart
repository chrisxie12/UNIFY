import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/models/ops_models.dart';
import '../providers/ops_provider.dart';
import '../widgets/ops_widgets.dart';

class UsageAnalyticsScreen extends ConsumerWidget {
  const UsageAnalyticsScreen({super.key});

  String _formatSession(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(opsOverviewProvider);
    final dauAsync = ref.watch(dauSeriesProvider);
    final retentionAsync = ref.watch(retentionProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Usage Analytics',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(opsOverviewProvider);
          ref.invalidate(dauSeriesProvider);
          ref.invalidate(retentionProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            overviewAsync.when(
              loading: () => const _LoadingBox(),
              error: (e, _) => _ErrorBox(error: e),
              data: (m) {
                final dau = opsInt(m['dau']);
                final wau = opsInt(m['wau']);
                final mau = opsInt(m['mau']);
                final avgSession = opsInt(m['avg_session_seconds']);
                final sessions7d = opsInt(m['sessions_7d']);
                final newUsers7d = opsInt(m['new_users_7d']);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          OpsStatCard(
                            icon: Icons.today_rounded,
                            value: '$dau',
                            label: 'DAU',
                            color: AppColors.primary,
                          ),
                          OpsStatCard(
                            icon: Icons.date_range_rounded,
                            value: '$wau',
                            label: 'WAU',
                            color: AppColors.info,
                          ),
                          OpsStatCard(
                            icon: Icons.calendar_month_rounded,
                            value: '$mau',
                            label: 'MAU',
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          OpsStatCard(
                            icon: Icons.timer_rounded,
                            value: _formatSession(avgSession),
                            label: 'Avg session',
                            color: AppColors.warning,
                          ),
                          OpsStatCard(
                            icon: Icons.login_rounded,
                            value: '$sessions7d',
                            label: 'Sessions 7d',
                            color: AppColors.primary,
                          ),
                          OpsStatCard(
                            icon: Icons.person_add_rounded,
                            value: '$newUsers7d',
                            label: 'New users 7d',
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            dauAsync.when(
              loading: () => const _LoadingBox(),
              error: (e, _) => _ErrorBox(error: e),
              data: (series) => _DauChartCard(series: series),
            ),
            retentionAsync.when(
              loading: () => const _LoadingBox(),
              error: (e, _) => _ErrorBox(error: e),
              data: (m) => _RetentionCard(data: m),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DauChartCard extends StatelessWidget {
  final List<DauPoint> series;
  const _DauChartCard({required this.series});

  @override
  Widget build(BuildContext context) {
    final maxActive =
        series.isEmpty ? 0 : series.map((p) => p.active).reduce((a, b) => a > b ? a : b);
    return OpsSectionCard(
      title: 'Daily active users',
      icon: Icons.show_chart_rounded,
      children: [
        if (series.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No activity data yet',
                  style: TextStyle(color: context.textSecondary)),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(series.length, (i) {
                final p = series[i];
                final ratio = maxActive == 0 ? 0.0 : p.active / maxActive;
                final h = (ratio * 120).clamp(2.0, 120.0);
                final showLabel = i % 2 == 0;
                final label =
                    p.day.length >= 10 ? p.day.substring(5) : p.day; // MM-DD
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${p.active}',
                          style: TextStyle(
                              fontSize: 8.5, color: context.textDisabled)),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        height: h,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 12,
                        child: showLabel
                            ? Text(label,
                                style: TextStyle(
                                    fontSize: 7.5, color: context.textDisabled),
                                textAlign: TextAlign.center)
                            : null,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _RetentionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RetentionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cohort = opsInt(data['cohort_size']);
    final d1 = opsInt(data['returned_d1']);
    final d7 = opsInt(data['returned_d7']);
    final d1Pct = cohort == 0 ? 0.0 : (d1 / cohort) * 100;
    final d7Pct = cohort == 0 ? 0.0 : (d7 / cohort) * 100;

    return OpsSectionCard(
      title: 'Retention',
      icon: Icons.replay_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _RetentionPill(
                label: 'Day 1',
                pct: d1Pct,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RetentionPill(
                label: 'Day 7',
                pct: d7Pct,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Based on a cohort of $cohort new ${cohort == 1 ? 'user' : 'users'}.',
          style: TextStyle(fontSize: 11.5, color: context.textSecondary),
        ),
      ],
    );
  }
}

class _RetentionPill extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  const _RetentionPill(
      {required this.label, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color),
          ),
          Text(label,
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _ErrorBox extends StatelessWidget {
  final Object error;
  const _ErrorBox({required this.error});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(ErrorMapper.toUserMessage(error))),
      );
}