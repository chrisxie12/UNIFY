import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../leadership/data/models/community_request_model.dart';
import '../providers/communities_provider.dart';

class CommunityCard extends ConsumerWidget {
  final CommunityModel community;
  final VoidCallback? onTap;
  final bool showJoinButton;

  const CommunityCard({
    super.key,
    required this.community,
    this.onTap,
    this.showJoinButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = context.primary;
    final roleAsync = showJoinButton
        ? ref.watch(communityMembershipProvider(community.id))
        : const AsyncData<String?>(null);
    final role = roleAsync.valueOrNull;
    final isMember = role != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _CommunityAvatar(community: community),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          community.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const VerifiedBadge(size: 15),
                    ],
                  ),
                  if (community.programme != null || community.level != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (community.programme != null) community.programme!,
                        if (community.level != null) community.level!,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textDisabled,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (community.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      community.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 13, color: context.textDisabled),
                      const SizedBox(width: 3),
                      Text(
                        '${community.memberCount} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textDisabled,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(type: community.communityType),
                    ],
                  ),
                ],
              ),
            ),
            if (showJoinButton) ...[
              const SizedBox(width: 10),
              _JoinButton(
                community: community,
                isMember: isMember,
                role: role,
                primary: primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommunityAvatar extends StatelessWidget {
  final CommunityModel community;
  const _CommunityAvatar({required this.community});

  @override
  Widget build(BuildContext context) {
    final initials = community.name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primary,
            context.primaryDark,
          ],
        ),
        image: community.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(community.avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: community.avatarUrl == null
          ? Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            )
          : null,
    );
  }
}

class _JoinButton extends ConsumerWidget {
  final CommunityModel community;
  final bool isMember;
  final String? role;
  final Color primary;

  const _JoinButton({
    required this.community,
    required this.isMember,
    required this.role,
    required this.primary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(communityMembershipProvider(community.id).notifier);
    final isOwner = role == 'owner';

    if (isOwner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Owner',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => isMember ? notifier.leave() : notifier.join(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isMember ? Colors.transparent : primary,
          border: Border.all(
            color: isMember ? AppColors.border : primary,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isMember ? 'Joined' : 'Join',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isMember ? AppColors.grey2 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  static const _labels = <String, String>{
    'class': 'Class', 'level': 'Level', 'course': 'Course',
    'programme': 'Programme', 'department': 'Department',
    'faculty': 'Faculty', 'university': 'University',
    'hostel': 'Hostel', 'hall': 'Hall', 'residence': 'Residence',
    'church': 'Church', 'sports': 'Sports',
    'entrepreneurship': 'Startup', 'technology': 'Tech',
    'gaming': 'Gaming', 'photography': 'Photo',
    'music': 'Music', 'campus_jobs': 'Jobs',
    'scholarships': 'Scholarships', 'club': 'Club',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _labels[type] ?? type,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: context.textSecondary,
        ),
      ),
    );
  }
}