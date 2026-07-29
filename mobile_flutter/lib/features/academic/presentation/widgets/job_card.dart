import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';

class JobCardData {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String jobType;
  final String urgency;
  final Color color;

  const JobCardData({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.urgency,
    required this.color,
  });
}

class JobCard extends StatelessWidget {
  final JobCardData job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = job.color;
    final initial = job.company[0];

    return Material(
      color: context.cardBg,
      borderRadius: BorderRadius.circular(URadius.md),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(URadius.md),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(USpacing.base),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(URadius.md),
            border: Border.all(color: context.borderSubtle.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(URadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                  ),
                  const SizedBox(width: USpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.company,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    PhosphorIconsBold.bookmarkSimple,
                    size: 16,
                    color: context.textDisabled,
                  ),
                ],
              ),
              const SizedBox(height: USpacing.md),
              Row(
                children: [
                  Icon(PhosphorIconsBold.mapPin, size: 12, color: context.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: TextStyle(fontSize: 11, color: context.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    job.salary,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: USpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Tag(label: job.jobType, color: c),
                  if (job.urgency.isNotEmpty)
                    _Tag(
                      label: job.urgency,
                      color: context.warning,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(URadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
