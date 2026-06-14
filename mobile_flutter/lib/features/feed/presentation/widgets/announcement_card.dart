import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../domain/entities/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement item;
  final VoidCallback? onTap;

  const AnnouncementCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(item.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isUrgent ? AppColors.error.withOpacity(0.4) : AppColors.border,
            width: item.isUrgent ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null) _buildImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryChip(label: item.category, color: catColor),
                      if (item.isPinned) ...[
                        const SizedBox(width: 6),
                        _badge(Icons.push_pin_rounded, 'Pinned', AppColors.grey3),
                      ],
                      if (item.isUrgent) ...[
                        const SizedBox(width: 6),
                        _badge(Icons.priority_high_rounded, 'Urgent', AppColors.error),
                      ],
                      const Spacer(),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.body,
                    style: AppTextStyles.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Avatar(name: item.authorName, url: item.authorAvatar),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.authorName ?? 'GCTU Admin',
                              style: AppTextStyles.label.copyWith(fontSize: 12),
                            ),
                            Text(
                              item.createdAt.timeAgo,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.grey3),
                      const SizedBox(width: 4),
                      Text(
                        '${item.viewCount}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        item.imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? name;
  final String? url;
  const _Avatar({this.name, this.url});

  @override
  Widget build(BuildContext context) {
    final initials = name?.isNotEmpty == true ? name![0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.surface,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Text(initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.grey1))
          : null,
    );
  }
}
