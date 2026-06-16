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

// ===========================================================================
// Root screen
// ===========================================================================

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

// ===========================================================================
// Aurora mesh background — CustomPainter with 5 soft radial blobs
// ===========================================================================

class _AuroraBg extends StatelessWidget {
  const _AuroraBg();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _AuroraPainter()));
  }
}

class _AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF040B1F));

    final blobs = <(Offset, double, Color, double)>[
      (Offset(size.width * 0.05, size.height * 0.06), size.width * 0.72, const Color(0xFF0047FF), 0.38),
      (Offset(size.width * 1.12, size.height * 0.28), size.width * 0.62, const Color(0xFF7C3AED), 0.30),
      (Offset(size.width * 0.95, size.height * -0.06), size.width * 0.46, const Color(0xFF06B6D4), 0.22),
      (Offset(size.width * -0.12, size.height * 0.72), size.width * 0.50, const Color(0xFFC026D3), 0.18),
      (Offset(size.width * 0.62, size.height * 0.96), size.width * 0.40, const Color(0xFF1D4ED8), 0.22),
    ];

    for (final (center, radius, color, opacity) in blobs) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
          ).createShader(Rect.fromCenter(center: center, width: radius * 2, height: radius * 2)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ===========================================================================
// Prismatic border painter — SweepGradient stroke around a rounded rect
// ===========================================================================

class _PrismaticBorderPainter extends CustomPainter {
  final BorderRadius borderRadius;
  const _PrismaticBorderPainter({required this.borderRadius});

  static const _colors = [
    Colors.white,
    Color(0xFF93C5FD),
    Color(0xFFA5B4FC),
    Color(0xFFC4B5FD),
    Color(0xFFF0ABFC),
    Color(0xFFA5B4FC),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      borderRadius.toRRect(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..shader = SweepGradient(colors: _colors).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _PrismaticBorderPainter old) =>
      old.borderRadius != borderRadius;
}

// ===========================================================================
// Avatar ring painter — prismatic circle stroke
// ===========================================================================

class _AvatarRingPainter extends CustomPainter {
  static const _colors = [
    Colors.white,
    Color(0xFF60A5FA),
    Color(0xFF818CF8),
    Color(0xFFC084FC),
    Color(0xFFF9A8D4),
    Color(0xFF67E8F9),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 - 1.5;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..shader = SweepGradient(colors: _colors)
            .createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ===========================================================================
// Liquid glass card — the base surface for all cards
// ===========================================================================

class _LiquidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const _LiquidCard({required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x15FFFFFF), Color(0x06FFFFFF)],
            ),
            borderRadius: br,
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
              // Specular highlight — 1 px white line at top
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.72),
                        Colors.white.withOpacity(0.72),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.18, 0.82, 1.0],
                    ),
                  ),
                ),
              ),
              // Prismatic border overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PrismaticBorderPainter(borderRadius: br),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Section label — gradient left-bar accent
// ===========================================================================

class _LiquidLabel extends StatelessWidget {
  final String title;
  const _LiquidLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Profile body
// ===========================================================================

class _ProfileBody extends StatelessWidget {
  final Profile profile;
  final int postCount;
  final WidgetRef ref;

  const _ProfileBody({required this.profile, required this.postCount, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _AuroraBg(),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _BioCard(profile: profile),
                  const SizedBox(height: 12),
                  _LiquidStatsRow(postCount: postCount),
                  const SizedBox(height: 12),
                  _AcademicCard(profile: profile),
                  const SizedBox(height: 12),
                  _SocialCard(profile: profile),
                  const SizedBox(height: 12),
                  _InterestsCard(profile: profile),
                  const SizedBox(height: 12),
                  _SkillsCard(profile: profile),
                  const SizedBox(height: 12),
                  _AchievementsSection(profile: profile),
                  const SizedBox(height: 12),
                  _AccountCard(ref: ref),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===========================================================================
// Cover photo box
// ===========================================================================

class _CoverPhotoBox extends StatelessWidget {
  final Profile profile;
  const _CoverPhotoBox({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profile.coverPhotoUrl?.isNotEmpty == true;
    return Stack(
      children: [
        Positioned.fill(
          child: hasPhoto
              ? CachedNetworkImage(
                  imageUrl: profile.coverPhotoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _DefaultCoverGradient(),
                  errorWidget: (_, __, ___) => const _DefaultCoverGradient(),
                )
              : const _DefaultCoverGradient(),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0, height: 100,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, const Color(0xFF040B1F).withOpacity(0.90)],
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

class _DefaultCoverGradient extends StatelessWidget {
  const _DefaultCoverGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B4B), Color(0xFF1E3A8A), Color(0xFF4C1D95)],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// ===========================================================================
// Frosted action button — circular with prismatic ring
// ===========================================================================

class _GlassActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _GlassActionBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _AvatarRingPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Profile header
// ===========================================================================

class _ProfileHeader extends ConsumerWidget {
  final Profile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeNotifierProvider);
    final topPad = MediaQuery.of(context).padding.top;
    const coverH = 165.0;
    const avatarR = 52.0;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: topPad + coverH,
              width: double.infinity,
              child: _CoverPhotoBox(profile: profile),
            ),
            Positioned(
              top: topPad + 12,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GlassActionBtn(
                    icon: Icons.ios_share_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile sharing coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GlassActionBtn(
                    icon: Icons.tune_rounded,
                    onTap: () => context.push('/app/profile/privacy'),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -avatarR,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _LiquidAvatar(profile: profile, radius: avatarR),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Icon(Icons.camera_alt_rounded, size: 14, color: activeTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 68),

        // Display name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.displayName ?? profile.email.split('@').first,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Color(0xFF60A5FA), size: 20),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Username / student status
        if (profile.yearOfStudy != null)
          Text(
            '${profile.displayUsername} • ${profile.studentStatus}',
            style: const TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500),
          )
        else
          GestureDetector(
            onTap: () => context.push('/app/profile/edit'),
            child: Text(
              profile.username?.isNotEmpty == true ? '@${profile.username}' : 'Set your handle',
              style: TextStyle(
                fontSize: 13,
                color: profile.username?.isNotEmpty == true ? Colors.white54 : Colors.white30,
                fontWeight: FontWeight.w500,
                decoration: profile.username?.isNotEmpty == true ? null : TextDecoration.underline,
                decorationColor: Colors.white30,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // UNIFY Score
        _UnifyScoreChip(score: profile.unifyScore),
        const SizedBox(height: 12),

        // Completion bar
        if (profile.completionScore < 100) ...[
          _CompletionBar(percent: profile.completionScore),
          const SizedBox(height: 14),
        ],

        // School / campus chips
        if (profile.school?.isNotEmpty == true || profile.campus?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (profile.school?.isNotEmpty == true)
                  _LiquidChip(label: profile.school!, icon: Icons.school_outlined),
                if (profile.campus?.isNotEmpty == true)
                  _LiquidChip(label: profile.campus!, icon: Icons.location_on_outlined),
              ],
            ),
          ),
        const SizedBox(height: 28),
      ],
    );
  }
}

// ===========================================================================
// Liquid avatar — prismatic ring + glow halos
// ===========================================================================

class _LiquidAvatar extends StatelessWidget {
  final Profile profile;
  final double radius;
  const _LiquidAvatar({required this.profile, required this.radius});

  @override
  Widget build(BuildContext context) {
    final total = radius * 2 + 10; // 5 px ring clearance per side
    Widget inner;
    if (profile.avatarUrl?.isNotEmpty == true) {
      inner = CachedNetworkImage(
        imageUrl: profile.avatarUrl!,
        width: radius * 2 - 4,
        height: radius * 2 - 4,
        fit: BoxFit.cover,
        placeholder: (_, __) => _LiquidInitials(initials: profile.initials, radius: radius - 2),
        errorWidget: (_, __, ___) => _LiquidInitials(initials: profile.initials, radius: radius - 2),
      );
    } else {
      inner = _LiquidInitials(initials: profile.initials, radius: radius - 2);
    }

    return SizedBox(
      width: total,
      height: total,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow halos
          Container(
            width: total,
            height: total,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF60A5FA).withOpacity(0.55), blurRadius: 34, spreadRadius: 5),
                BoxShadow(color: const Color(0xFFA78BFA).withOpacity(0.30), blurRadius: 20),
              ],
            ),
          ),
          // Prismatic ring
          Positioned.fill(
            child: CustomPaint(painter: _AvatarRingPainter()),
          ),
          // Avatar content
          ClipOval(
            child: SizedBox(width: radius * 2 - 4, height: radius * 2 - 4, child: inner),
          ),
        ],
      ),
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
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3FAE), Color(0xFF1D4ED8), Color(0xFF4338CA), Color(0xFF6D28D9)],
                  stops: [0.0, 0.35, 0.65, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Gloss sheen
          Positioned(
            top: radius * 0.10,
            left: radius * 0.16,
            child: Container(
              width: radius * 0.95,
              height: radius * 0.36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius * 0.3),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.40), Colors.white.withOpacity(0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.60,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [Shadow(color: Colors.black.withOpacity(0.25), offset: const Offset(0, 2), blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// UNIFY Score chip — spectral gradient + specular
// ===========================================================================

class _UnifyScoreChip extends StatelessWidget {
  final int score;
  const _UnifyScoreChip({required this.score});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFA21CAF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.60), blurRadius: 30),
              BoxShadow(color: const Color(0xFF1D4ED8).withOpacity(0.40), blurRadius: 14, spreadRadius: -4),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFFCD34D), size: 17),
                  const SizedBox(width: 5),
                  Text(
                    'UNIFY',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.65), letterSpacing: 1.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$score',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                ],
              ),
              // Specular
              Positioned(
                top: -10, left: 16, right: 16,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.white.withOpacity(0.65), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Profile completion bar
// ===========================================================================

class _CompletionBar extends StatelessWidget {
  final int percent;
  const _CompletionBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Profile $percent% complete',
          style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF60A5FA)),
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Liquid header chip — school / campus pill
// ===========================================================================

class _LiquidChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _LiquidChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    const br = BorderRadius.all(Radius.circular(20));
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: br,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 12, color: Colors.white70), const SizedBox(width: 5)],
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PrismaticBorderPainter(borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Bio card
// ===========================================================================

class _BioCard extends StatelessWidget {
  final Profile profile;
  const _BioCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio?.isNotEmpty == true;
    return GestureDetector(
      onTap: () => context.push('/app/profile/edit'),
      child: _LiquidCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                hasBio ? profile.bio! : 'Add a bio to tell people about yourself…',
                style: TextStyle(fontSize: 14, height: 1.60, color: hasBio ? Colors.white.withOpacity(0.90) : Colors.white54),
              ),
            ),
            const SizedBox(width: 10),
            Icon(hasBio ? Icons.edit_outlined : Icons.chevron_right, size: 16, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Stats row — 4 individual liquid orbs
// ===========================================================================

class _LiquidStatsRow extends StatelessWidget {
  final int postCount;
  const _LiquidStatsRow({required this.postCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatOrb(value: '$postCount', label: 'Posts', color: const Color(0xFF60A5FA)),
        const SizedBox(width: 8),
        _StatOrb(
          value: '0',
          label: 'Clubs',
          color: const Color(0xFFA78BFA),
          ctaLabel: 'Join',
          onTap: () => context.go('/app/communities'),
        ),
        const SizedBox(width: 8),
        const _StatOrb(value: '0', label: 'Friends', color: Color(0xFF34D399), ctaLabel: 'Find'),
        const SizedBox(width: 8),
        const _StatOrb(value: '0', label: 'Views', color: Color(0xFFFBBF24)),
      ],
    );
  }
}

class _StatOrb extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String? ctaLabel;
  final VoidCallback? onTap;

  const _StatOrb({required this.value, required this.label, required this.color, this.ctaLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '0';
    final isCta = isEmpty && ctaLabel != null;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: _LiquidCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isEmpty ? color.withOpacity(0.28) : color,
                  shape: BoxShape.circle,
                  boxShadow: isEmpty ? null : [BoxShadow(color: color.withOpacity(0.55), blurRadius: 7)],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isEmpty ? Colors.white24 : Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isCta ? ctaLabel! : label,
                style: TextStyle(
                  fontSize: 10,
                  color: isCta ? color : Colors.white38,
                  fontWeight: isCta ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Academic card
// ===========================================================================

class _AcademicCard extends StatelessWidget {
  final Profile profile;
  const _AcademicCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_KV>[];
    if (profile.school?.isNotEmpty == true) rows.add(_KV('School', profile.school!));
    if (profile.faculty?.isNotEmpty == true) rows.add(_KV('Faculty', profile.faculty!));
    if (profile.department?.isNotEmpty == true) rows.add(_KV('Department', profile.department!));
    if (profile.programme?.isNotEmpty == true) rows.add(_KV('Programme', profile.programme!));
    if (profile.yearOfStudy != null) rows.add(_KV('Year of Study', 'Year ${profile.yearOfStudy}'));
    if (profile.expectedGraduationYear != null) {
      rows.add(_KV('Expected Graduation', 'Class of ${profile.expectedGraduationYear}'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiquidLabel('Academic'),
        _LiquidCard(
          padding: EdgeInsets.zero,
          child: rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => context.push('/app/profile/edit'),
                    child: Row(
                      children: [
                        const Icon(Icons.school_outlined, color: Colors.white38, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Add your academic info', style: TextStyle(color: Colors.white38, fontSize: 14))),
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < rows.length; i++) ...[
                      _InfoRow(label: rows[i].label, value: rows[i].value),
                      if (i < rows.length - 1)
                        Divider(height: 1, color: Colors.white.withOpacity(0.07), indent: 16, endIndent: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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

// ===========================================================================
// Social card
// ===========================================================================

class _SocialCard extends StatelessWidget {
  final Profile profile;
  const _SocialCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final platforms = [
      _SocialPlatform('Instagram', Icons.camera_alt_outlined, const Color(0xFFE1306C), profile.instagramUrl),
      _SocialPlatform('TikTok', Icons.music_note_rounded, const Color(0xFFFF0050), profile.tiktokUrl),
      _SocialPlatform('Snapchat', Icons.chat_bubble_outline_rounded, const Color(0xFFFFE921), profile.snapchatUrl),
      _SocialPlatform('LinkedIn', Icons.work_outline, const Color(0xFF0A66C2), profile.linkedinUrl),
      _SocialPlatform('Twitter', Icons.alternate_email, const Color(0xFF1DA1F2), profile.twitterUrl),
      _SocialPlatform('GitHub', Icons.code, const Color(0xFFE2E8F0), profile.githubUrl),
      _SocialPlatform('Portfolio', Icons.language, const Color(0xFF34D399), profile.portfolioUrl),
    ];
    final active = platforms.where((p) => p.url?.isNotEmpty == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiquidLabel('Social'),
        _LiquidCard(
          child: active.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: platforms
                          .map((p) => _SocialIconBtn(platform: p, active: false, onTap: () => context.push('/app/profile/edit')))
                          .toList(),
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
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: platforms
                          .map((p) => _SocialIconBtn(platform: p, active: p.url?.isNotEmpty == true))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < active.length; i++) ...[
                      _SocialRow(platform: active[i]),
                      if (i < active.length - 1)
                        Divider(height: 1, color: Colors.white.withOpacity(0.07)),
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

class _SocialIconBtn extends StatelessWidget {
  final _SocialPlatform platform;
  final bool active;
  final VoidCallback? onTap;
  const _SocialIconBtn({required this.platform, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    const br = BorderRadius.all(Radius.circular(14));
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              color: platform.color.withOpacity(active ? 0.14 : 0.05),
              borderRadius: br,
            ),
            child: Stack(
              children: [
                Center(child: Icon(platform.icon, color: platform.color.withOpacity(active ? 1.0 : 0.28), size: 20)),
                // Specular
                Positioned(
                  top: 0, left: 4, right: 4,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.white.withOpacity(0.55), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PrismaticBorderPainter(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final _SocialPlatform platform;
  const _SocialRow({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: platform.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: platform.color.withOpacity(0.28), width: 0.8),
            ),
            child: Icon(platform.icon, color: platform.color, size: 15),
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

// ===========================================================================
// Interests card
// ===========================================================================

class _InterestsCard extends StatelessWidget {
  final Profile profile;
  const _InterestsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiquidLabel('Interests'),
        _LiquidCard(
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
                  spacing: 8, runSpacing: 8,
                  children: profile.interests.map((i) => _InterestChip(label: i)).toList(),
                ),
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
    const br = BorderRadius.all(Radius.circular(20));
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: br,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PrismaticBorderPainter(borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Skills card
// ===========================================================================

class _SkillsCard extends StatelessWidget {
  final Profile profile;
  const _SkillsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiquidLabel('Skills'),
        _LiquidCard(
          child: profile.skills.isEmpty
              ? GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_outlined, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Add your skills', style: TextStyle(color: Colors.white38, fontSize: 14))),
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: profile.skills.map((s) => _SkillChip(label: s)).toList(),
                ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    const br = BorderRadius.all(Radius.circular(20));
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.11),
            borderRadius: br,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code_rounded, color: Color(0xFF10B981), size: 11),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PrismaticBorderPainter(borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Achievements
// ===========================================================================

class _AchievementsSection extends StatelessWidget {
  final Profile profile;
  const _AchievementsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[
      const _Badge(icon: Icons.rocket_launch_outlined, label: 'Early Adopter', color: Color(0xFF8B5CF6)),
      if (profile.isComplete)
        const _Badge(icon: Icons.verified_user_outlined, label: 'Verified Student', color: Color(0xFF10B981)),
      if (profile.isVerified)
        const _Badge(icon: Icons.star_outline_rounded, label: 'Verified', color: Color(0xFFF59E0B)),
      if (profile.unifyScore >= 500)
        const _Badge(icon: Icons.bolt_rounded, label: 'Power User', color: Color(0xFF60A5FA)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiquidLabel('Achievements'),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: badges.map((b) => _BadgeCapsule(badge: b)).toList(),
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

class _BadgeCapsule extends StatelessWidget {
  final _Badge badge;
  const _BadgeCapsule({required this.badge});

  @override
  Widget build(BuildContext context) {
    const br = BorderRadius.all(Radius.circular(24));
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: badge.color.withOpacity(0.14),
            borderRadius: br,
            boxShadow: [
              BoxShadow(color: badge.color.withOpacity(0.30), blurRadius: 18, spreadRadius: 0),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badge.icon, color: badge.color, size: 15),
                  const SizedBox(width: 6),
                  Text(badge.label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              // Specular
              Positioned(
                top: -10, left: 12, right: 12,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.white.withOpacity(0.55), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PrismaticBorderPainter(borderRadius: BorderRadius.circular(24))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Account card
// ===========================================================================

class _AccountCard extends StatelessWidget {
  final WidgetRef ref;
  const _AccountCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiquidLabel('Account'),
        _LiquidCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Tile(icon: Icons.edit_outlined, label: 'Edit Profile', iconColor: const Color(0xFF60A5FA), onTap: () => context.push('/app/profile/edit')),
              Divider(height: 1, color: Colors.white.withOpacity(0.07)),
              _Tile(icon: Icons.lock_outline, label: 'Privacy', iconColor: const Color(0xFF34D399), onTap: () => context.push('/app/profile/privacy')),
              Divider(height: 1, color: Colors.white.withOpacity(0.07)),
              _Tile(icon: Icons.palette_outlined, label: 'Appearance', iconColor: const Color(0xFFA78BFA), showChevron: false, onTap: () => ThemePickerSheet.show(context)),
              Divider(height: 1, color: Colors.white.withOpacity(0.07)),
              _Tile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                iconColor: const Color(0xFFF87171),
                labelColor: const Color(0xFFF87171),
                showChevron: false,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF0E1527),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Sign out?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                      content: const Text(
                        "You'll need to sign in again to access your account.",
                        style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w600))),
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

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? labelColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _Tile({
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
      splashColor: Colors.white.withOpacity(0.04),
      highlightColor: Colors.white.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor.withOpacity(0.22), iconColor.withOpacity(0.10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withOpacity(0.28), width: 0.8),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label, style: TextStyle(color: labelColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            if (showChevron) Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 18),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Skeleton loading
// ===========================================================================

class _GlassSkeleton extends StatelessWidget {
  const _GlassSkeleton();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        const _AuroraBg(),
        Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.13),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(height: topPad + 165, color: Colors.white),
                const SizedBox(height: 68),
                Center(child: _SBox(h: 22, w: 190, r: 6)),
                const SizedBox(height: 8),
                Center(child: _SBox(h: 14, w: 120, r: 6)),
                const SizedBox(height: 20),
                Center(child: _SBox(h: 38, w: 140, r: 19)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _SBox(h: 64, w: double.infinity, r: 24),
                      const SizedBox(height: 12),
                      _SBox(h: 90, w: double.infinity, r: 24),
                      const SizedBox(height: 12),
                      _SBox(h: 210, w: double.infinity, r: 24),
                    ],
                  ),
                ),
              ],
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
  Widget build(BuildContext context) =>
      Container(height: h, width: w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r)));
}

// ===========================================================================
// Error view
// ===========================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _AuroraBg(),
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
