import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/academic_models.dart';
import '../../../../core/extensions/theme_extensions.dart';

IconData _resourceIcon(String type) {
  switch (type) {
    case 'lecture_note':
    case 'notes':
      return Icons.article_rounded;
    case 'past_question':
      return Icons.quiz_rounded;
    case 'study_guide':
      return Icons.menu_book_rounded;
    case 'textbook':
      return Icons.book_rounded;
    case 'video':
      return Icons.play_circle_rounded;
    case 'assignment':
      return Icons.assignment_rounded;
    case 'reference':
      return Icons.link_rounded;
    default:
      return Icons.description_rounded;
  }
}

Color _resourceColor(String type) {
  switch (type) {
    case 'lecture_note':
    case 'notes':
      return AppColors.primary;
    case 'past_question':
      return AppColors.warning;
    case 'study_guide':
      return AppColors.success;
    case 'textbook':
      return AppColors.info;
    case 'video':
      return AppColors.error;
    case 'assignment':
      return AppColors.catUrgent;
    case 'reference':
      return AppColors.catEvents;
    default:
      return AppColors.grey2;
  }
}

Color _verificationColor(String status) {
  switch (status) {
    case 'verified_course_rep':
      return AppColors.success;
    case 'verified_faculty_admin':
      return AppColors.info;
    case 'official':
      return AppColors.success;
    default:
      return AppColors.grey3;
  }
}

class ResourceCard extends StatelessWidget {
  final AcademicResourceModel resource;
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
          color: context.cardBg,
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
                color: _resourceColor(r.type).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(_resourceIcon(r.type),
                  color: _resourceColor(r.type), size: 22),
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
                      if (r.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded,
                            size: 15,
                            color: _verificationColor(r.verificationStatus)),
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
                        Text(r.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 11.5, color: context.textSecondary)),
                        const SizedBox(width: 8),
                      ],
                      Icon(Icons.download_rounded,
                          size: 13, color: context.textDisabled),
                      const SizedBox(width: 2),
                      Text('${r.downloadCount}',
                          style: const TextStyle(
                              fontSize: 11.5, color: context.textDisabled)),
                    ],
                  ),
                  if (r.uploaderName != null) ...[
                    const SizedBox(height: 4),
                    Text('by ${r.uploaderName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: context.textDisabled)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: context.textDisabled),
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
