import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const _ProfileSkeleton(),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (profile) {
          if (profile == null) {
            return const _ErrorView(message: 'Profile not found.');
          }
          return _ProfileBody(
            profile: profile,
            postCount: statsAsync.valueOrNull?.postCount ?? 0,
            ref: ref,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main profile body
// ---------------------------------------------------------------------------

class _ProfileBody extends StatelessWidget {
  final Profile profile;
  final int postCount;
  final WidgetRef ref;

  const _ProfileBody({
    required this.profile,
    required this.postCount,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ProfileSliverHeader(profile: profile),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _BioSection(profile: profile),
              const SizedBox(height: 20),
              _StatsRow(postCount: postCount),
              const SizedBox(height: 20),
              _AcademicCard(profile: profile),
              const SizedBox(height: 20),
              _SocialLinksCard(profile: profile),
              const SizedBox(height: 20),
              _InterestsSection(profile: profile),
              const SizedBox(height: 20),
              _AchievementsSection(profile: profile),
              const SizedBox(height: 20),
              _AccountSection(ref: ref),
            ]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsing header
// ---------------------------------------------------------------------------

class _ProfileSliverHeader extends StatelessWidget {
  final Profile profile;
  const _ProfileSliverHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Tappable avatar -> edit profile
                GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: _Avatar(profile: profile, radius: 44),
                ),
                const SizedBox(height: 12),
                // Name + verification badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.displayName ?? profile.email.split('@').first,
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF60A5FA),
                        size: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.displayUsername,
                  style: AppTextStyles.bodyS.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 12),
                // School / programme / year chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (profile.school != null && profile.school!.isNotEmpty)
                      _HeaderChip(label: profile.school!),
                    if (profile.programme != null &&
                        profile.programme!.isNotEmpty)
                      _HeaderChip(label: profile.programme!),
                    if (profile.yearOfStudy != null)
                      _HeaderChip(label: 'Year ${profile.yearOfStudy}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  const _HeaderChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar with initials fallback
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final Profile profile;
  final double radius;
  const _Avatar({required this.profile, this.radius = 36});

  @override
  Widget build(BuildContext context) {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryLight,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profile.avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, __) => _InitialsAvatar(
              initials: profile.initials,
              radius: radius,
            ),
            errorWidget: (_, __, ___) => _InitialsAvatar(
              initials: profile.initials,
              radius: radius,
            ),
          ),
        ),
      );
    }
    return _InitialsAvatar(initials: profile.initials, radius: radius);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  const _InitialsAvatar({required this.initials, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bio section
// ---------------------------------------------------------------------------

class _BioSection extends StatelessWidget {
  final Profile profile;
  const _BioSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio != null && profile.bio!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            hasBio ? profile.bio! : 'Add a bio to tell people about yourself…',
            style: hasBio
                ? AppTextStyles.body
                : AppTextStyles.body.copyWith(color: AppColors.grey3),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.edit_outlined, size: 16, color: AppColors.grey3),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final int postCount;
  const _StatsRow({required this.postCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _StatBox(value: postCount.toString(), label: 'Posts'),
          _VerticalDivider(),
          const _StatBox(value: '0', label: 'Communities'),
          _VerticalDivider(),
          const _StatBox(value: '0', label: 'Friends'),
          _VerticalDivider(),
          const _StatBox(value: '0', label: 'Views'),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 40,
      color: AppColors.border,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header helper
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelS.copyWith(
          color: AppColors.grey2,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Academic info card
// ---------------------------------------------------------------------------

class _AcademicCard extends StatelessWidget {
  final Profile profile;
  const _AcademicCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_RowData>[];

    if (profile.school != null && profile.school!.isNotEmpty) {
      rows.add(_RowData('School', profile.school!));
    }
    if (profile.faculty != null && profile.faculty!.isNotEmpty) {
      rows.add(_RowData('Faculty', profile.faculty!));
    }
    if (profile.department != null && profile.department!.isNotEmpty) {
      rows.add(_RowData('Department', profile.department!));
    }
    if (profile.programme != null && profile.programme!.isNotEmpty) {
      rows.add(_RowData('Programme', profile.programme!));
    }
    if (profile.yearOfStudy != null) {
      rows.add(_RowData('Year of Study', 'Year ${profile.yearOfStudy}'));
    }
    if (profile.expectedGraduationYear != null) {
      rows.add(_RowData(
        'Expected Graduation',
        profile.expectedGraduationYear.toString(),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Academic'),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: rows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No academic info added yet.'),
                )
              : Column(
                  children: [
                    for (int i = 0; i < rows.length; i++) ...[
                      _InfoRow(label: rows[i].label, value: rows[i].value),
                      if (i < rows.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _RowData {
  final String label;
  final String value;
  const _RowData(this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodySemi,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Social links card
// ---------------------------------------------------------------------------

class _SocialLinksCard extends StatelessWidget {
  final Profile profile;
  const _SocialLinksCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final links = <_SocialLink>[];

    if (profile.instagramUrl != null && profile.instagramUrl!.isNotEmpty) {
      links.add(_SocialLink(
        icon: Icons.camera_alt_outlined,
        label: 'Instagram',
        url: profile.instagramUrl!,
        color: const Color(0xFFE1306C),
      ));
    }
    if (profile.linkedinUrl != null && profile.linkedinUrl!.isNotEmpty) {
      links.add(_SocialLink(
        icon: Icons.work_outline,
        label: 'LinkedIn',
        url: profile.linkedinUrl!,
        color: const Color(0xFF0077B5),
      ));
    }
    if (profile.twitterUrl != null && profile.twitterUrl!.isNotEmpty) {
      links.add(_SocialLink(
        icon: Icons.alternate_email,
        label: 'Twitter / X',
        url: profile.twitterUrl!,
        color: const Color(0xFF1DA1F2),
      ));
    }
    if (profile.githubUrl != null && profile.githubUrl!.isNotEmpty) {
      links.add(_SocialLink(
        icon: Icons.code,
        label: 'GitHub',
        url: profile.githubUrl!,
        color: AppColors.dark,
      ));
    }
    if (profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty) {
      links.add(_SocialLink(
        icon: Icons.language,
        label: 'Portfolio',
        url: profile.portfolioUrl!,
        color: AppColors.accent,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Social'),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: links.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.add_link, color: AppColors.grey3, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Add social links',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.grey3),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < links.length; i++) ...[
                      _SocialLinkRow(link: links[i]),
                      if (i < links.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SocialLink {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  const _SocialLink({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });
}

class _SocialLinkRow extends StatelessWidget {
  final _SocialLink link;
  const _SocialLinkRow({required this.link});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: link.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(link.icon, color: link.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.label, style: AppTextStyles.bodySemi),
                Text(
                  link.url,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.grey3, size: 18),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interests section
// ---------------------------------------------------------------------------

class _InterestsSection extends StatelessWidget {
  final Profile profile;
  const _InterestsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Interests'),
        profile.interests.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.interests_outlined,
                        color: AppColors.grey3, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Add interests',
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.grey3),
                    ),
                  ],
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.interests
                    .map((interest) => _InterestChip(label: interest))
                    .toList(),
              ),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Achievements section
// ---------------------------------------------------------------------------

class _AchievementsSection extends StatelessWidget {
  final Profile profile;
  const _AchievementsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final badges = <_BadgeData>[
      const _BadgeData(
        icon: Icons.rocket_launch_outlined,
        label: 'Early Adopter',
        color: Color(0xFF8B5CF6),
      ),
      if (profile.isComplete)
        const _BadgeData(
          icon: Icons.verified_user_outlined,
          label: 'Verified Student',
          color: AppColors.success,
        ),
      if (profile.isVerified)
        const _BadgeData(
          icon: Icons.star_outline_rounded,
          label: 'Verified',
          color: Color(0xFFF59E0B),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Achievements'),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _BadgeCard(badge: badges[index]),
          ),
        ),
      ],
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  const _BadgeData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _BadgeCard extends StatelessWidget {
  final _BadgeData badge;
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badge.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon, color: badge.color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            badge.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account / settings section
// ---------------------------------------------------------------------------

class _AccountSection extends StatelessWidget {
  final WidgetRef ref;
  const _AccountSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Account'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                iconColor: AppColors.primary,
                onTap: () => context.push('/app/profile/edit'),
              ),
              const Divider(height: 1, indent: 56, endIndent: 0),
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                iconColor: AppColors.error,
                labelColor: AppColors.error,
                onTap: () async {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .signOut();
                  if (context.mounted) context.go('/get-started');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySemi.copyWith(
                  color: labelColor ?? AppColors.dark,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey3, size: 18),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading
// ---------------------------------------------------------------------------

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Container(
              height: 260,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio
                  _ShimmerBox(height: 14, width: double.infinity),
                  const SizedBox(height: 6),
                  _ShimmerBox(height: 14, width: 180),
                  const SizedBox(height: 20),
                  // Stats
                  _ShimmerBox(height: 72, width: double.infinity, radius: 16),
                  const SizedBox(height: 20),
                  // Academic card
                  _ShimmerBox(height: 200, width: double.infinity, radius: 16),
                  const SizedBox(height: 20),
                  // Social
                  _ShimmerBox(height: 120, width: double.infinity, radius: 16),
                  const SizedBox(height: 20),
                  // Interests
                  _ShimmerBox(height: 60, width: double.infinity, radius: 16),
                  const SizedBox(height: 20),
                  // Achievements
                  Row(
                    children: [
                      _ShimmerBox(height: 96, width: 104, radius: 16),
                      const SizedBox(width: 12),
                      _ShimmerBox(height: 96, width: 104, radius: 16),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Account
                  _ShimmerBox(height: 100, width: double.infinity, radius: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    required this.width,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.grey2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
