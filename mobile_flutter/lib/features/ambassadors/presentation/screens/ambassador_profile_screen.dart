import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/components.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/ambassador_models.dart';
import '../providers/ambassador_provider.dart';
import 'ambassador_admin_screen.dart' show statusColor;
import 'ambassador_detail_screen.dart' show showAddEventDialog;

class AmbassadorProfileScreen extends ConsumerWidget {
  const AmbassadorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAsync = ref.watch(myAmbassadorProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Ambassador',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: myAsync.maybeWhen(
        data: (a) => a == null
            ? null
            : FloatingActionButton.extended(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add event'),
                onPressed: () =>
                    showAddEventDialog(context, ref, ambassadorId: a.id),
              ),
        orElse: () => null,
      ),
      body: myAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (ambassador) {
          if (ambassador == null) return UEmptyState(
            icon: Icons.campaign_rounded,
            title: "You're not a campus ambassador yet",
            subtitle: 'Campus ambassadors represent UNIFY at their university — organising events, growing the community and earning rewards. Reach out to the UNIFY team to get involved.',
          );
          return _AmbassadorBody(ambassador: ambassador);
        },
      ),
    );
  }
}

class _AmbassadorBody extends ConsumerWidget {
  final Ambassador ambassador;
  const _AmbassadorBody({required this.ambassador});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(ambassadorEventsProvider(ambassador.id));
    final color = statusColor(ambassador.status);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myAmbassadorProvider);
        ref.invalidate(ambassadorEventsProvider(ambassador.id));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(USpacing.md, USpacing.md, USpacing.md, 88),
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderCol),
            ),
            padding: const EdgeInsets.all(USpacing.base),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Your status',
                        style: UText.label.copyWith(color: context.textPrimary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(ambassador.status.toUpperCase(),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatTile(
                      icon: Icons.people_alt_rounded,
                      value: '${ambassador.referralCount}',
                      label: 'Referrals',
                      color: AppColors.info,
                    ),
                    _StatTile(
                      icon: Icons.event_rounded,
                      value: '${ambassador.eventsOrganized}',
                      label: 'Events organized',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: USpacing.base),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: USpacing.xs),
            child: Text('Your events',
                style: UText.h4.copyWith(color: context.textPrimary)),
          ),
          const SizedBox(height: USpacing.sm),
          eventsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: AppErrorWidget(e),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('No events yet — add your first one',
                        style: UText.bodyXS.copyWith(color: context.textSecondary)),
                  ),
                );
              }
              return Column(
                children: events
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _EventCard(event: e),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final AmbassadorEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final date = event.eventDate;
    final dateLabel =
        date == null ? null : '${date.day}/${date.month}/${date.year}';

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
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_rounded,
                color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: UText.label.copyWith(color: context.textPrimary)),
                if (event.description != null &&
                    event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(event.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: UText.caption.copyWith(color: context.textSecondary)),
                  ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (dateLabel != null) dateLabel,
                    '${event.attendance} attended',
                  ].join(' • '),
                  style: UText.tiny.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
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
          borderRadius: URadius.mdAll,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: UText.h2.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: UText.tiny.copyWith(color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}
