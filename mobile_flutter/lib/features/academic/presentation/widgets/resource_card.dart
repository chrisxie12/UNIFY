import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/academic_models.dart';

/// Compact list tile for an academic resource.
class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onTap;
  const ResourceCard({super.key, required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = resource;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: r.resourceType.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(r.resourceType.icon,
                  color: r.resourceType.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(r.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.2)),
                      ),
                      if (r.verification.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded,
                            size: 15, color: r.verification.color),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(r.fileType.toUpperCase(), AppColors.grey2),
                      const SizedBox(width: 8),
                      if (r.ratingCount > 0) ...[
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(r.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.grey2)),
                        const SizedBox(width: 8),
                      ],
                      Icon(Icons.download_rounded,
                          size: 13, color: AppColors.grey3),
                      const SizedBox(width: 2),
                      Text('${r.downloadCount}',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.grey3)),
                    ],
                  ),
                  if (r.uploaderName != null) ...[
                    const SizedBox(height: 4),
                    Text('by ${r.uploaderName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey3)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey3),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
      );
}
