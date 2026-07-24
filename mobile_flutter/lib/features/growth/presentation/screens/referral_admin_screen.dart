import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/growth_models.dart';
import '../providers/growth_provider.dart';

class ReferralAdminScreen extends ConsumerWidget {
  const ReferralAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralsAsync = ref.watch(allReferralsProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Referrals',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: referralsAsync.when(
      loading: () => const AppLoadingWidget.list(itemCount: 5),
      error: (e, _) => AppErrorWidget(e),
      data: (referrals) {
          final total = referrals.length;
          final accepted =
              referrals.where((r) => r.status == 'accepted').length;
          final active = referrals.where((r) => r.status == 'active').length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allReferralsProvider),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  children: [
                    _StatTile(
                      icon: Icons.send_rounded,
                      value: '$total',
                      label: 'Total',
                      color: AppColors.warning,
                    ),
                    _StatTile(
                      icon: Icons.how_to_reg_rounded,
                      value: '$accepted',
                      label: 'Accepted',
                      color: AppColors.info,
                    ),
                    _StatTile(
                      icon: Icons.verified_rounded,
                      value: '$active',
                      label: 'Active',
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (referrals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: AppEmptyWidget(
                      icon: Icons.share_outlined,
                      title: 'No referrals yet',
                    ),
                  )
                else
                  ...referrals.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ReferralCard(referral: r),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final Referral referral;
  const _ReferralCard({required this.referral});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(referral.status);
    final date = referral.createdAt;
    final dateLabel =
        '${date.day}/${date.month}/${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.person_add_rounded, color: context.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.referrerName?.isNotEmpty == true
                      ? referral.referrerName!
                      : 'Referrer',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  referral.referredEmail?.isNotEmpty == true
                      ? 'Invited ${referral.referredEmail}'
                      : 'Invited a friend',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (referral.channel != null &&
                        referral.channel!.isNotEmpty)
                      referral.channel,
                    dateLabel,
                  ].join(' • '),
                  style: TextStyle(fontSize: 11, color: context.textDisabled),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(label: referral.status, color: color),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'sent':
      return AppColors.warning;
    case 'accepted':
      return AppColors.info;
    case 'active':
      return AppColors.success;
    default:
      return AppColors.grey2;
  }
}
