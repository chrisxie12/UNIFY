import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/system_models.dart';
import '../providers/system_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Returns the accent colour for an announcement severity.
Color severityColor(String severity) {
  switch (severity) {
    case 'critical':
      return AppColors.error;
    case 'warning':
      return AppColors.warning;
    case 'info':
    default:
      return AppColors.info;
  }
}

/// Returns the icon for an announcement type.
IconData announcementTypeIcon(String type) {
  switch (type) {
    case 'feature':
      return Icons.auto_awesome_rounded;
    case 'maintenance':
      return Icons.build_rounded;
    case 'update':
      return Icons.system_update_rounded;
    case 'general':
    default:
      return Icons.campaign_rounded;
  }
}

/// A slim banner showing the first active (non-dismissed) announcement.
/// Safe to embed at the top of any list — renders nothing when there is
/// nothing to show.
class SystemAnnouncementBanner extends ConsumerWidget {
  const SystemAnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activeAnnouncementsProvider);

    return async.maybeWhen(
      data: (announcements) {
        if (announcements.isEmpty) return const SizedBox.shrink();
        return _BannerCard(announcement: announcements.first);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _BannerCard extends ConsumerWidget {
  final SystemAnnouncement announcement;

  const _BannerCard({required this.announcement});

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      try {
        await ref
            .read(systemRepositoryProvider)
            .dismiss(announcement.id, user.id);
      } catch (_) {/* swallow — dismissal is best-effort */}
    }
    ref.invalidate(activeAnnouncementsProvider);
  }

  void _copyAction(BuildContext context) {
    final url = announcement.actionUrl;
    if (url == null || url.isEmpty) return;
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = severityColor(announcement.severity);
    final hasAction = announcement.actionLabel != null &&
        announcement.actionLabel!.isNotEmpty &&
        announcement.actionUrl != null &&
        announcement.actionUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        announcementTypeIcon(announcement.type),
                        color: accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            announcement.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.3,
                              color: context.textSecondary,
                            ),
                          ),
                          if (hasAction) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 30,
                              child: TextButton.icon(
                                onPressed: () => _copyAction(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: accent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.link_rounded, size: 16),
                                label: Text(
                                  announcement.actionLabel!,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _dismiss(context, ref),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: context.textDisabled,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Dismiss',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}