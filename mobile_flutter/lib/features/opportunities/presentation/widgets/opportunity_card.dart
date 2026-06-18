import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';

/// A LinkedIn-Jobs-style opportunity card for feeds and lists.
class OpportunityCard extends ConsumerWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  const OpportunityCard(
      {super.key, required this.opportunity, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = opportunity;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F1F3)),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: o.type.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: o.coverUrl != null && o.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: o.coverUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Icon(o.type.icon, color: o.type.color),
                        )
                      : Icon(o.type.icon, color: o.type.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              o.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  color: AppColors.dark),
                            ),
                          ),
                          if (o.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded,
                                size: 15, color: o.type.color),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        o.organization ?? o.type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.grey2),
                      ),
                    ],
                  ),
                ),
                _SaveButton(opportunity: o),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _tag(o.type.label, o.type.color),
                if (o.isFunded) _tag('Funded', AppColors.success),
                if (o.isRemote) _tag('Remote', AppColors.info),
                if (o.location != null && o.location!.isNotEmpty)
                  _metaText(Icons.location_on_outlined, o.location!),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _DeadlinePill(opportunity: o),
                const Spacer(),
                if (o.stage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: o.stage!.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(o.stage!.label,
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: o.stage!.color)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
      );

  Widget _metaText(IconData ic, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, size: 13, color: AppColors.grey3),
          const SizedBox(width: 3),
          Text(text,
              style: const TextStyle(fontSize: 11.5, color: AppColors.grey2)),
        ],
      );
}

class _DeadlinePill extends StatelessWidget {
  final OpportunityModel opportunity;
  const _DeadlinePill({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final urgent = o.isClosingSoon;
    final closed = o.isExpired;
    final color = closed
        ? AppColors.grey3
        : urgent
            ? AppColors.error
            : AppColors.grey1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          closed ? Icons.lock_clock_rounded : Icons.schedule_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(o.deadlineLabel,
            style: TextStyle(
                fontSize: 12,
                fontWeight: urgent ? FontWeight.w700 : FontWeight.w500,
                color: color)),
      ],
    );
  }
}

class _SaveButton extends ConsumerStatefulWidget {
  final OpportunityModel opportunity;
  const _SaveButton({required this.opportunity});

  @override
  ConsumerState<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends ConsumerState<_SaveButton> {
  late bool _saved = widget.opportunity.isSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() => _saved = !_saved);
        final r = await ref
            .read(opportunitySaveControllerProvider.notifier)
            .toggle(widget.opportunity.id);
        if (mounted) setState(() => _saved = r);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: _saved ? AppColors.primary : AppColors.grey3,
          size: 22,
        ),
      ),
    );
  }
}
