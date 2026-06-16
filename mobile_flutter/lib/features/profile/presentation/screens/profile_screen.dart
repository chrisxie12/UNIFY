import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/theme_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Root screen
// ---------------------------------------------------------------------------

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: profileAsync.when(
        loading: () => const _GlassSkeleton(),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (profile) {
          if (profile == null) return const _ErrorView(message: 'Profile not found.');
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
// Full-screen mesh gradient background
// ---------------------------------------------------------------------------

class _GradientBg extends StatelessWidget {
  const _GradientBg();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base diagonal gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF09142B),
                  Color(0xFF0D2F7A),
                  Color(0xFF130D4D),
                  Color(0xFF2B0857),
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Purple accent mesh — top-right
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.2),
                  Colors.transparent,
                  Colors.transparent,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
        // Electric-blue mesh — bottom
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF1D4ED8).withOpacity(0.10),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profile body
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
    return Stack(
      children: [
        const _GradientBg(),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _GlassBioSection(profile: profile),
                  const SizedBox(height: 14),
                  _GlassStatsRow(postCount: postCount),
                  const SizedBox(height: 14),
                  _GlassAcademicCard(profile: profile),
                  const SizedBox(height: 14),
                  _GlassSocialCard(profile: profile),
                  const SizedBox(height: 14),
                  _GlassInterestsSection(profile: profile),
                  const SizedBox(height: 14),
                  _GlassAchievementsSection(profile: profile),
                  const SizedBox(height: 14),
                  _GlassAccountSection(ref: ref),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header (floats over gradient — no SliverAppBar)
// ---------------------------------------------------------------------------

class _ProfileHeader extends ConsumerWidget {
  final Profile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeNotifierProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(top: topPad + 20, bottom: 28),
      child: Column(
        children: [
          // Avatar + camera badge
          GestureDetector(
            onTap: () => context.push('/app/profile/edit'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _GlassAvatar(profile: profile, radius: 50),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 14, color: activeTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Display name + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.displayName ?? profile.email.split('@').first,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Color(0xFF60A5FA), size: 20),
              ],
            ],
          ),
          const SizedBox(height: 5),

          // Username
          if (profile.username != null && profile.username!.isNotEmpty)
            Text(
              '@${profile.username}',
              style: const TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500),
            )
          else
            GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: const Text(
                'Set your handle',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white30,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white30,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // School chip
          if (profile.school != null && profile.school!.isNotEmpty)
            _GlassHeaderChip(label: profile.school!, icon: Icons.school_outlined),
        ],
      ),
    );
  }
}

class _GlassHeaderChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _GlassHeaderChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: Colors.white70),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar — liquid gradient initials with gloss
// ---------------------------------------------------------------------------

class _GlassAvatar extends StatelessWidget {
  final Profile profile;
  final double radius;
  const _GlassAvatar({required this.profile, required this.radius});

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      inner = CachedNetworkImage(
        imageUrl: profile.avatarUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, __) => _LiquidInitials(initials: profile.initials, radius: radius),
        errorWidget: (_, __, ___) => _LiquidInitials(initials: profile.initials, radius: radius),
      );
    } else {
      inner = _LiquidInitials(initials: profile.initials, radius: radius);
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.45),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipOval(child: inner),
    );
  }
}

class _LiquidInitials extends StatelessWidget {
  final String initials;
  final double radius;
  const _LiquidInitials({required this.initials, required this.radius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        children: [
          // Liquid resin gradient base
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E3FAE),
                    Color(0xFF1D4ED8),
                    Color(0xFF4338CA),
                    Color(0xFF6D28D9),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Glossy highlight
          Positioned(
            top: radius * 0.12,
            left: radius * 0.18,
            child: Container(
              width: radius * 0.9,
              height: radius * 0.38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius * 0.3),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.38),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Initials
          Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.60,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Base glass card
// ---------------------------------------------------------------------------

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const _GlassCard({required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: br,
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 0.8,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// Glass section label
class _GlassSectionLabel extends StatelessWidget {
  final String title;
  const _GlassSectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bio section
// ---------------------------------------------------------------------------

class _GlassBioSection extends StatelessWidget {
  final Profile profile;
  const _GlassBioSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio != null && profile.bio!.isNotEmpty;
    return GestureDetector(
      onTap: () => context.push('/app/profile/edit'),
      child: _GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                hasBio ? profile.bio! : 'Add a bio to tell people about yourself…',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: hasBio ? Colors.white.withOpacity(0.88) : Colors.white54,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              hasBio ? Icons.edit_outlined : Icons.chevron_right,
              size: 16,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _GlassStatsRow extends StatelessWidget {
  final int postCount;
  const _GlassStatsRow({required this.postCount});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _GlassStatBox(value: '$postCount', label: 'Posts'),
          _GlassDivider(),
          _GlassStatBox(
            value: '0',
            label: 'Communities',
            zeroLabel: 'Join',
            onTap: () => context.go('/app/communities'),
          ),
          _GlassDivider(),
          const _GlassStatBox(value: '0', label: 'Friends', zeroLabel: 'Find'),
          _GlassDivider(),
          const _GlassStatBox(value: '0', label: 'Views'),
        ],
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 40, color: Colors.white.withOpacity(0.15));
}

class _GlassStatBox extends StatelessWidget {
  final String value;
  final String label;
  final String? zeroLabel;
  final VoidCallback? onTap;
  const _GlassStatBox({required this.value, required this.label, this.zeroLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '0';
    final isCta = isEmpty && zeroLabel != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isEmpty ? Colors.white24 : Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isCta ? zeroLabel! : label,
              style: TextStyle(
                fontSize: 11,
                color: isCta ? const Color(0xFF60A5FA) : Colors.white38,
                fontWeight: isCta ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Academic card
// ---------------------------------------------------------------------------

class _GlassAcademicCard extends StatelessWidget {
  final Profile profile;
  const _GlassAcademicCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_KV>[];
    if (profile.school?.isNotEmpty == true)      rows.add(_KV('School', profile.school!));
    if (profile.faculty?.isNotEmpty == true)     rows.add(_KV('Faculty', profile.faculty!));
    if (profile.department?.isNotEmpty == true)  rows.add(_KV('Department', profile.department!));
    if (profile.programme?.isNotEmpty == true)   rows.add(_KV('Programme', profile.programme!));
    if (profile.yearOfStudy != null)             rows.add(_KV('Year of Study', 'Year ${profile.yearOfStudy}'));
    if (profile.expectedGraduationYear != null)  rows.add(_KV('Expected Graduation', 'Class of ${profile.expectedGraduationYear}'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GlassSectionLabel('Academic'),
        _GlassCard(
          padding: EdgeInsets.zero,
          child: rows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No academic info yet.', style: TextStyle(color: Colors.white38, fontSize: 14)),
                )
              : Column(
                  children: [
                    for (int i = 0; i < rows.length; i++) ...[
                      _GlassInfoRow(label: rows[i].label, value: rows[i].value),
                      if (i < rows.length - 1)
                        Divider(height: 1, color: Colors.white.withOpacity(0.08), indent: 16, endIndent: 16),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _KV {
  final String label;
  final String value;
  const _KV(this.label, this.value);
}

class _GlassInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _GlassInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Social card — glass icon grid + link rows
// ---------------------------------------------------------------------------

class _GlassSocialCard extends StatelessWidget {
  final Profile profile;
  const _GlassSocialCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final platforms = [
      _SocialPlatform('Instagram', Icons.camera_alt_outlined, const Color(0xFFE1306C), profile.instagramUrl),
      _SocialPlatform('LinkedIn',  Icons.work_outline,        const Color(0xFF0A66C2), profile.linkedinUrl),
      _SocialPlatform('Twitter',   Icons.alternate_email,     const Color(0xFF1DA1F2), profile.twitterUrl),
      _SocialPlatform('GitHub',    Icons.code,                const Color(0xFFE2E8F0), profile.githubUrl),
      _SocialPlatform('Portfolio', Icons.language,            const Color(0xFF34D399), profile.portfolioUrl),
    ];

    final active = platforms.where((p) => p.url?.isNotEmpty == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GlassSectionLabel('Social'),
        _GlassCard(
          child: active.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glass icon grid at 30% — all platforms dimmed
                    Row(
                      children: platforms.map((p) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _GlassSocialIcon(platform: p, active: false,
                            onTap: () => context.push('/app/profile/edit')),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.push('/app/profile/edit'),
                      child: const Row(
                        children: [
                          Text('Add social links', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 13, fontWeight: FontWeight.w500)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF60A5FA)),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Icon strip
                    Row(
                      children: platforms.map((p) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _GlassSocialIcon(platform: p, active: p.url?.isNotEmpty == true),
                      )).toList(),
                    ),
                    const SizedBox(height: 14),
                    // Active link rows
                    for (int i = 0; i < active.length; i++) ...[
                      _GlassSocialRow(platform: active[i]),
                      if (i < active.length - 1)
                        Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SocialPlatform {
  final String label;
  final IconData icon;
  final Color color;
  final String? url;
  const _SocialPlatform(this.label, this.icon, this.color, this.url);
}

class _GlassSocialIcon extends StatelessWidget {
  final _SocialPlatform platform;
  final bool active;
  final VoidCallback? onTap;
  const _GlassSocialIcon({required this.platform, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: platform.color.withOpacity(active ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: platform.color.withOpacity(active ? 0.40 : 0.12),
                width: 0.8,
              ),
            ),
            child: Icon(platform.icon,
                color: platform.color.withOpacity(active ? 1.0 : 0.30), size: 20),
          ),
        ),
      ),
    );
  }
}

class _GlassSocialRow extends StatelessWidget {
  final _SocialPlatform platform;
  const _GlassSocialRow({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: platform.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: platform.color.withOpacity(0.25), width: 0.8),
            ),
            child: Icon(platform.icon, color: platform.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform.label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(platform.url!, style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded, color: Colors.white.withOpacity(0.2), size: 14),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interests
// ---------------------------------------------------------------------------

class _GlassInterestsSection extends StatelessWidget {
  final Profile profile;
  const _GlassInterestsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GlassSectionLabel('Interests'),
        _GlassCard(
          child: profile.interests.isEmpty
              ? GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: Row(
                    children: [
                      const Icon(Icons.interests_outlined, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Add interests', style: TextStyle(color: Colors.white38, fontSize: 14))),
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.interests.map((i) => _GlassInterestChip(label: i)).toList(),
                ),
        ),
      ],
    );
  }
}

class _GlassInterestChip extends StatelessWidget {
  final String label;
  const _GlassInterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.8),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Achievements — glowing glass capsules
// ---------------------------------------------------------------------------

class _GlassAchievementsSection extends StatelessWidget {
  final Profile profile;
  const _GlassAchievementsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[
      const _Badge(icon: Icons.rocket_launch_outlined, label: 'Early Adopter',   color: Color(0xFF8B5CF6)),
      if (profile.isComplete)
        const _Badge(icon: Icons.verified_user_outlined, label: 'Verified Student', color: Color(0xFF10B981)),
      if (profile.isVerified)
        const _Badge(icon: Icons.star_outline_rounded,   label: 'Verified',         color: Color(0xFFF59E0B)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GlassSectionLabel('Achievements'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: badges.map((b) => _GlassBadgeCapsule(badge: b)).toList(),
        ),
      ],
    );
  }
}

class _Badge {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});
}

class _GlassBadgeCapsule extends StatelessWidget {
  final _Badge badge;
  const _GlassBadgeCapsule({required this.badge});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: badge.color.withOpacity(0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: badge.color.withOpacity(0.42), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: badge.color.withOpacity(0.18),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badge.icon, color: badge.color, size: 15),
              const SizedBox(width: 6),
              Text(
                badge.label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account section
// ---------------------------------------------------------------------------

class _GlassAccountSection extends StatelessWidget {
  final WidgetRef ref;
  const _GlassAccountSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GlassSectionLabel('Account'),
        _GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _GlassTile(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                iconColor: const Color(0xFF60A5FA),
                onTap: () => context.push('/app/profile/edit'),
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.08)),
              _GlassTile(
                icon: Icons.palette_outlined,
                label: 'Appearance',
                iconColor: const Color(0xFFA78BFA),
                showChevron: false,
                onTap: () => ThemePickerSheet.show(context),
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.08)),
              _GlassTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                iconColor: const Color(0xFFF87171),
                labelColor: const Color(0xFFF87171),
                showChevron: false,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      title: const Text('Sign out?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                      content: const Text(
                        "You'll need to sign in again to access your account.",
                        style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign Out', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) context.go('/get-started');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _GlassTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.labelColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: iconColor.withOpacity(0.24), width: 0.8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: labelColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading
// ---------------------------------------------------------------------------

class _GlassSkeleton extends StatelessWidget {
  const _GlassSkeleton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _GradientBg(),
        Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.06),
          highlightColor: Colors.white.withOpacity(0.14),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: _SBox(h: 100, w: 100, r: 50)),
                  const SizedBox(height: 18),
                  Center(child: _SBox(h: 22, w: 180, r: 6)),
                  const SizedBox(height: 8),
                  Center(child: _SBox(h: 14, w: 110, r: 6)),
                  const SizedBox(height: 32),
                  _SBox(h: 64, w: double.infinity, r: 20),
                  const SizedBox(height: 14),
                  _SBox(h: 80, w: double.infinity, r: 20),
                  const SizedBox(height: 14),
                  _SBox(h: 200, w: double.infinity, r: 20),
                  const SizedBox(height: 14),
                  _SBox(h: 120, w: double.infinity, r: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SBox extends StatelessWidget {
  final double h, w, r;
  const _SBox({required this.h, required this.w, required this.r});

  @override
  Widget build(BuildContext context) => Container(
        height: h,
        width: w,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r)),
      );
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _GradientBg(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFFF87171)),
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: Colors.white60, fontSize: 14), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
