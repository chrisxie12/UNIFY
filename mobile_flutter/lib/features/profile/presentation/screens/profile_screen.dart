import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../leadership/presentation/providers/leadership_provider.dart';
import '../../../leadership/data/models/user_badge_model.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Root screen
// ---------------------------------------------------------------------------

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync   = ref.watch(profileStatsProvider);
    final badgesAsync  = ref.watch(userBadgesProvider);
    final leadershipAsync = ref.watch(userLeadershipProvider);
    final isLeaderAsync = ref.watch(isVerifiedLeaderProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: profileAsync.when(
        loading: () => const _Skeleton(),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(profileProvider)),
        data: (profile) {
          if (profile == null) return const AppErrorWidget('Profile not found.');
          return _Body(
            profile: profile,
            postCount: statsAsync.valueOrNull?.postCount ?? 0,
            badges: badgesAsync.valueOrNull ?? [],
            leadership: leadershipAsync.valueOrNull ?? [],
            isLeader: isLeaderAsync.valueOrNull ?? false,
            ref: ref,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated body — staggered entrance for each section
// ---------------------------------------------------------------------------

class _Body extends StatefulWidget {
  final Profile profile;
  final int postCount;
  final List<UserBadgeModel> badges;
  final List<UserLeadershipModel> leadership;
  final bool isLeader;
  final WidgetRef ref;
  const _Body({
    required this.profile,
    required this.postCount,
    required this.badges,
    required this.leadership,
    required this.isLeader,
    required this.ref,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    final n = widget.leadership.isNotEmpty ? 11 : 10;
    _fades = List.generate(n, (i) => CurvedAnimation(
      parent: _ctrl,
      curve: Interval(i * 0.05, 0.45 + i * 0.05, curve: Curves.easeOut),
    ));
    _slides = _fades.map((f) =>
      Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(f),
    ).toList();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _section(int idx, Widget child) => FadeTransition(
    opacity: _fades[idx],
    child: SlideTransition(position: _slides[idx], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final incomplete = p.completionScore < 80;
    final hasLeadership = widget.leadership.isNotEmpty;

    int idx = 0;
    Widget s(int n, Widget child) => _section(n, child);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: s(idx++, _Header(profile: p, postCount: widget.postCount, ctrl: _ctrl, badges: widget.badges)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (incomplete) ...[
                s(idx++, _CompletionCard(profile: p)),
                const SizedBox(height: 12),
              ],

              // Leadership section (if user has leadership roles)
              if (hasLeadership) ...[
                s(idx++, _LeadershipCard(leadership: widget.leadership)),
                const SizedBox(height: 12),
              ],

              // Verification status card (shown when not yet verified)
              if (p.verificationStatus == 'none' || p.verificationStatus == 'pending' || p.verificationStatus == 'rejected') ...[
                s(idx++, _VerificationStatusCard(status: p.verificationStatus)),
                const SizedBox(height: 12),
              ],

              s(idx++, _AboutCard(profile: p)),
              const SizedBox(height: 12),
              s(idx++, _AcademicCard(profile: p)),
              const SizedBox(height: 12),
              s(idx++, _SocialCard(profile: p)),
              const SizedBox(height: 12),

              // Request Community Creation button (verified leaders only)
              if (widget.isLeader) ...[
                s(idx++, _RequestCommunityCard()),
                const SizedBox(height: 12),
              ],

              s(idx++, _InterestsCard(profile: p)),
              const SizedBox(height: 12),
              s(idx++, _SkillsCard(profile: p)),
              const SizedBox(height: 12),
              s(idx++, _AchievementsCard(profile: p, badges: widget.badges)),
              const SizedBox(height: 12),
              s(idx, _AccountCard(ref: widget.ref)),
            ]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header — fixes avatar z-order with outer Stack
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final Profile profile;
  final int postCount;
  final AnimationController ctrl;
  final List<UserBadgeModel> badges;
  const _Header({required this.profile, required this.postCount, required this.ctrl, this.badges = const []});

  static Color _badgeColor(String slug) {
    switch (slug) {
      case 'verified_student': return AppColors.primary;
      case 'class_rep':        return const Color(0xFFFFD700);
      case 'src_executive':    return const Color(0xFF7C3AED);
      case 'admin':            return const Color(0xFFDC2626);
      default:                 return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    const coverH = 170.0;
    const avatarD = 88.0;
    const avatarR = avatarD / 2; // 44

    // ── Outer Stack: Column + avatar Positioned on top (fixes z-order) ──────
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Background column ──────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover photo
            SizedBox(
              height: topPad + coverH,
              width: double.infinity,
              child: _CoverPhoto(profile: profile),
            ),
            // White identity block — paddingTop makes room for avatar bottom half
            Container(
              color: context.cardBg,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, avatarR + 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Edit button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    profile.displayName ?? profile.email.split('@').first,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: context.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 5),
                                  Icon(Icons.verified_rounded, color: context.primary, size: 19),
                                ],
                                // Role-based badges (with colors)
                                ...badges.map((b) => Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Tooltip(
                                    message: b.badge.name,
                                    child: Container(
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        color: _badgeColor(b.badge.slug).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        b.badge.slug == 'admin' ? Icons.shield_rounded : Icons.verified_rounded,
                                        size: 13,
                                        color: _badgeColor(b.badge.slug),
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            if (profile.username?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text('@${profile.username}', style: TextStyle(fontSize: 13, color: context.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => context.push('/app/profile/edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primary,
                          side: BorderSide(color: context.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Programme
                  if (profile.programme?.isNotEmpty == true) ...[
                    Text(
                      profile.programme!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary),
                    ),
                    const SizedBox(height: 3),
                  ],

                  // University · Year
                  if (profile.school?.isNotEmpty == true || profile.yearOfStudy != null)
                    Text(
                      [
                        if (profile.school?.isNotEmpty == true) profile.school!,
                        if (profile.yearOfStudy != null) profile.studentStatus,
                      ].join(' · '),
                      style: TextStyle(fontSize: 13, color: context.textSecondary),
                    ),

                  // Campus
                  if (profile.campus?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 13, color: context.textSecondary),
                        const SizedBox(width: 3),
                        Text(profile.campus!, style: TextStyle(fontSize: 13, color: context.textSecondary)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Stats strip
                  _StatsStrip(postCount: postCount),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),

        // ── Avatar — rendered ABOVE the Column (z-order fix) ──────────────
        Positioned(
          top: topPad + coverH - avatarR,
          left: 16,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: ctrl,
              curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
            ),
            child: GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: _Avatar(profile: profile, diameter: avatarD),
            ),
          ),
        ),

        // ── Action buttons on cover ────────────────────────────────────────
        Positioned(
          top: topPad + 12,
          right: 16,
          child: Row(
            children: [
              _ActionBtn(
                icon: Icons.ios_share_outlined,
                onTap: () => UnifySnackbar.info(context, 'Sharing coming soon'),
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.settings_outlined,
                onTap: () => context.push('/app/profile/settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cover photo
// ---------------------------------------------------------------------------

class _CoverPhoto extends StatelessWidget {
  final Profile profile;
  const _CoverPhoto({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profile.coverPhotoUrl?.isNotEmpty == true;
    return hasPhoto
        ? CachedNetworkImage(
            imageUrl: profile.coverPhotoUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const _DefaultCover(),
            errorWidget: (_, __, ___) => const _DefaultCover(),
          )
        : const _DefaultCover();
  }
}

class _DefaultCover extends StatelessWidget {
  const _DefaultCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003EB3), AppColors.primary, Color(0xFF4DA3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button on cover
// ---------------------------------------------------------------------------

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: context.cardBg.withValues(alpha: 0.90),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x25000000), blurRadius: 8)],
        ),
        child: Icon(icon, size: 18, color: context.textPrimary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar — white border + camera badge + initials fallback
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final Profile profile;
  final double diameter;
  const _Avatar({required this.profile, required this.diameter});

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (profile.avatarUrl?.isNotEmpty == true) {
      content = CachedNetworkImage(
        imageUrl: profile.avatarUrl!,
        width: diameter, height: diameter,
        fit: BoxFit.cover,
        placeholder: (_, __) => _Initials(initials: profile.initials, diameter: diameter),
        errorWidget: (_, __, ___) => _Initials(initials: profile.initials, diameter: diameter),
      );
    } else {
      content = _Initials(initials: profile.initials, diameter: diameter);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: diameter, height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.cardBg, width: 3.5),
            boxShadow: const [
              BoxShadow(color: Color(0x20000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: ClipOval(child: content),
        ),
        Positioned(
          bottom: 2, right: 2,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: context.primary,
              shape: BoxShape.circle,
              border: Border.all(color: context.cardBg, width: 2.5),
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  final double diameter;
  const _Initials({required this.initials, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter, height: diameter,
      color: const Color(0xFFDDE8FF),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(fontSize: diameter * 0.30, fontWeight: FontWeight.w800, color: context.primary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats strip
// ---------------------------------------------------------------------------

class _StatsStrip extends StatelessWidget {
  final int postCount;
  const _StatsStrip({required this.postCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: context.borderCol),
        const SizedBox(height: 14),
        Row(
          children: [
            _StatCell(value: postCount, label: 'Posts'),
            _Divider(),
            const _StatCell(value: 0, label: 'Connections', cta: true),
            _Divider(),
            _StatCell(value: 0, label: 'Communities', cta: true, onTap: () => context.go('/app/communities')),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final int value;
  final String label;
  final bool cta;
  final VoidCallback? onTap;
  const _StatCell({required this.value, required this.label, this.cta = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 0;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, val, _) => Column(
            children: [
              Text(
                '$val',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isEmpty && !cta ? const Color(0xFFD1D5DB) : context.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: cta && isEmpty ? context.primary : context.textSecondary,
                  fontWeight: cta && isEmpty ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: context.borderCol);
}

// ---------------------------------------------------------------------------
// Base card
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget inner = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderCol, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: context.primary.withValues(alpha: 0.04),
          child: inner,
        ),
      );
    }
    return inner;
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _CardHeader(this.title, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: TextStyle(fontSize: 13, color: context.primary, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completion card
// ---------------------------------------------------------------------------

class _CompletionCard extends StatelessWidget {
  final Profile profile;
  const _CompletionCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final pct = profile.completionScore;
    return _Card(
      onTap: () => context.push('/app/profile/edit'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete your profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                const SizedBox(height: 3),
                Text('A complete profile helps students and employers find you.', style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct / 100),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) => LinearProgressIndicator(
                      value: val,
                      minHeight: 6,
                      backgroundColor: context.borderCol,
                      valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text('$pct% complete', style: TextStyle(fontSize: 11, color: context.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: context.textSecondary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About card
// ---------------------------------------------------------------------------

class _AboutCard extends StatelessWidget {
  final Profile profile;
  const _AboutCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio?.isNotEmpty == true;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader('About', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          hasBio
              ? Text(profile.bio!, style: TextStyle(fontSize: 14, color: context.textPrimary, height: 1.65))
              : GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: Row(
                    children: [
                      Text('Add a bio to introduce yourself', style: TextStyle(fontSize: 14, color: context.textSecondary)),
                      const Spacer(),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_rounded, size: 16, color: context.primary),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Academic card
// ---------------------------------------------------------------------------

class _AcademicCard extends StatelessWidget {
  final Profile profile;
  const _AcademicCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_KV>[];
    if (profile.school?.isNotEmpty == true)     rows.add(_KV('University', profile.school!));
    if (profile.programme?.isNotEmpty == true)  rows.add(_KV('Programme', profile.programme!));
    if (profile.faculty?.isNotEmpty == true)    rows.add(_KV('Faculty', profile.faculty!));
    if (profile.department?.isNotEmpty == true) rows.add(_KV('Department', profile.department!));
    if (profile.yearOfStudy != null)            rows.add(_KV('Year', 'Year ${profile.yearOfStudy} · ${profile.studentStatus}'));
    if (profile.expectedGraduationYear != null) rows.add(_KV('Graduating', 'Class of ${profile.expectedGraduationYear}'));
    if (profile.campus?.isNotEmpty == true)     rows.add(_KV('Campus', profile.campus!));

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader('Academic Info', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          if (rows.isEmpty)
            GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: context.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.school_rounded, size: 18, color: context.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Add your university details', style: TextStyle(color: context.textSecondary, fontSize: 14))),
                  Icon(Icons.chevron_right_rounded, size: 18, color: context.textSecondary),
                ],
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  _DataRow(label: rows[i].label, value: rows[i].value),
                  if (i < rows.length - 1) Divider(height: 1, color: context.borderCol),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _KV {
  final String label;
  final String value;
  const _KV(this.label, this.value);
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 13, color: context.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
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
// Social links card — real brand icons
// ---------------------------------------------------------------------------

class _SocialCard extends StatelessWidget {
  final Profile profile;
  const _SocialCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final platforms = <_SocialP>[
      _SocialP('Instagram', profile.instagramUrl,
        isGradient: true, child: const _BrandSvg(_BrandPaths.instagram)),
      _SocialP('TikTok', profile.tiktokUrl,
        solid: const Color(0xFF010101), child: const _BrandSvg(_BrandPaths.tiktok)),
      _SocialP('Snapchat', profile.snapchatUrl,
        solid: const Color(0xFFFFFC00),
        child: const _BrandSvg(_BrandPaths.snapchat, color: Color(0xFF1A1A1A))),
      _SocialP('LinkedIn', profile.linkedinUrl,
        solid: const Color(0xFF0A66C2), child: const _BrandSvg(_BrandPaths.linkedin)),
      _SocialP('X (Twitter)', profile.twitterUrl,
        solid: const Color(0xFF000000), child: const _BrandSvg(_BrandPaths.x)),
      _SocialP('GitHub', profile.githubUrl,
        solid: const Color(0xFF181717), child: const _BrandSvg(_BrandPaths.github)),
      _SocialP('Portfolio', profile.portfolioUrl,
        solid: context.primary, child: const Icon(Icons.language_rounded, color: Colors.white, size: 22)),
    ];
    final active = platforms.where((p) => p.url?.isNotEmpty == true).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader('Social & Links', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          // Brand icon grid
          Wrap(
            spacing: 10, runSpacing: 10,
            children: platforms.map((p) {
              final isActive = p.url?.isNotEmpty == true;
              return AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.35,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: isActive ? null : () => context.push('/app/profile/edit'),
                  child: _BrandIconBox(platform: p),
                ),
              );
            }).toList(),
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                for (int i = 0; i < active.length; i++) ...[
                  _SocialRow(platform: active[i]),
                  if (i < active.length - 1) Divider(height: 1, color: context.borderCol),
                ],
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: Text('Add your social links →', style: TextStyle(color: context.primary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SocialP {
  final String label;
  final String? url;
  final Color? solid;
  final bool isGradient;
  final Widget child;

  const _SocialP(this.label, this.url, {
    this.solid,
    this.isGradient = false,
    required this.child,
  });
}

class _BrandIconBox extends StatelessWidget {
  final _SocialP platform;
  const _BrandIconBox({required this.platform});

  // Official Instagram brand gradient (warm corner → cool corner).
  static const _instagramGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFFEDA75), // amber
      Color(0xFFFA7E1E), // orange
      Color(0xFFD62976), // magenta
      Color(0xFF962FBF), // purple
      Color(0xFF4F5BD5), // indigo
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final shadowColor = platform.isGradient
        ? const Color(0xFFD62976)
        : (platform.solid ?? Colors.black);
    final shadow = BoxShadow(
      color: shadowColor.withValues(alpha: 0.22),
      blurRadius: 8,
      offset: const Offset(0, 3),
    );

    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: platform.isGradient ? null : platform.solid,
        gradient: platform.isGradient ? _instagramGradient : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [shadow],
      ),
      child: Center(child: platform.child),
    );
  }
}

// ── Brand icon widgets ─────────────────────────────────────────────────────

/// Renders an official monochrome brand glyph (Simple Icons path data) tinted
/// to [color] at [size]. All glyphs use a 0 0 24 24 viewBox.
class _BrandSvg extends StatelessWidget {
  final String path;
  final Color color;
  const _BrandSvg(this.path, {this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path d="$path"/></svg>',
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// Official brand glyph vector paths (from the Simple Icons set, 24×24 viewBox).
abstract class _BrandPaths {
  static const instagram =
      'M12 0C8.74 0 8.333.015 7.053.072 5.775.132 4.905.333 4.14.63c-.789.306-1.459.717-2.126 1.384S.935 3.35.63 4.14C.333 4.905.131 5.775.072 7.053.012 8.333 0 8.74 0 12s.015 3.667.072 4.947c.06 1.277.261 2.148.558 2.913.306.788.717 1.459 1.384 2.126.667.666 1.336 1.079 2.126 1.384.766.296 1.636.499 2.913.558C8.333 23.988 8.74 24 12 24s3.667-.015 4.947-.072c1.277-.06 2.148-.262 2.913-.558.788-.306 1.459-.718 2.126-1.384.666-.667 1.079-1.335 1.384-2.126.296-.765.499-1.636.558-2.913.06-1.28.072-1.687.072-4.947s-.015-3.667-.072-4.947c-.06-1.277-.262-2.149-.558-2.913-.306-.789-.718-1.459-1.384-2.126C21.319 1.347 20.651.935 19.86.63c-.765-.297-1.636-.499-2.913-.558C15.667.012 15.26 0 12 0zm0 2.16c3.203 0 3.585.016 4.85.071 1.17.055 1.805.249 2.227.415.562.217.96.477 1.382.896.419.42.679.819.896 1.381.164.422.36 1.057.413 2.227.057 1.266.07 1.646.07 4.85s-.015 3.585-.074 4.85c-.061 1.17-.256 1.805-.421 2.227-.224.562-.479.96-.899 1.382-.419.419-.824.679-1.38.896-.42.164-1.065.36-2.235.413-1.274.057-1.649.07-4.859.07-3.211 0-3.586-.015-4.859-.074-1.171-.061-1.816-.256-2.236-.421-.569-.224-.96-.479-1.379-.899-.421-.419-.69-.824-.9-1.38-.165-.42-.359-1.065-.42-2.235-.045-1.26-.061-1.649-.061-4.844 0-3.196.016-3.586.061-4.861.061-1.17.255-1.814.42-2.234.21-.57.479-.96.9-1.381.419-.419.81-.689 1.379-.898.42-.166 1.051-.361 2.221-.421 1.275-.045 1.65-.06 4.859-.06l.045.03zm0 3.678c-3.405 0-6.162 2.76-6.162 6.162 0 3.405 2.76 6.162 6.162 6.162 3.405 0 6.162-2.76 6.162-6.162 0-3.405-2.76-6.162-6.162-6.162zM12 16c-2.21 0-4-1.79-4-4s1.79-4 4-4 4 1.79 4 4-1.79 4-4 4zm7.846-10.405c0 .795-.646 1.44-1.44 1.44-.795 0-1.44-.646-1.44-1.44 0-.794.646-1.439 1.44-1.439.793-.001 1.44.645 1.44 1.439z';
  static const tiktok =
      'M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z';
  static const snapchat =
      'M12.206.793c.99 0 4.347.276 5.93 3.821.529 1.193.403 3.219.299 4.847l-.003.06c-.012.18-.022.345-.03.51.075.045.203.09.401.09.3-.016.659-.12 1.033-.301.165-.088.344-.104.464-.104.182 0 .359.029.509.09.45.149.734.479.734.838.015.449-.39.839-1.213 1.168-.089.029-.209.075-.344.119-.45.135-1.139.36-1.333.81-.09.224-.061.524.12.868l.015.015c.06.12 1.526 2.97 4.305 3.435.225.034.435.225.435.435.015.075-.015.15-.03.225-.207.7-1.621 1.179-2.99 1.434-.149.029-.18.299-.359.554-.045.075-.061.15-.061.225-.044.39-.299.434-.609.434-.149 0-.345-.044-.554-.089-.479-.105-1.139-.255-1.829-.255-.42 0-.854.029-1.273.104-.81.135-1.5.629-2.295 1.178-.999.689-2.115 1.469-3.838 1.469-.073 0-.146-.003-.219-.009-.073.006-.146.009-.219.009-1.724 0-2.84-.78-3.838-1.469-.795-.549-1.485-1.043-2.295-1.178-.419-.075-.853-.104-1.273-.104-.69 0-1.35.165-1.829.27-.21.044-.404.089-.554.089-.404 0-.62-.135-.659-.434 0-.075-.03-.15-.061-.225-.179-.255-.21-.525-.359-.554-1.369-.255-2.783-.734-2.99-1.434-.015-.075-.045-.15-.03-.225 0-.21.21-.401.435-.435 2.79-.465 4.245-3.315 4.305-3.435l.015-.015c.181-.344.21-.644.12-.868-.194-.45-.883-.675-1.333-.81-.135-.044-.255-.09-.344-.119-1.107-.435-1.228-.93-1.183-1.272.06-.345.479-.601.853-.601.105 0 .195.015.27.045.404.194.764.299 1.064.299.234 0 .354-.045.42-.09l-.045-.495c-.105-1.62-.225-3.645.299-4.847C7.844 1.069 11.2.793 12.206.793z';
  static const linkedin =
      'M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.225 0z';
  static const x =
      'M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584H.474l8.6-9.83L0 1.154h7.594l5.243 6.932ZM17.61 20.644h2.039L6.486 3.24H4.298Z';
  static const github =
      'M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12';
}

String _badgeEmoji(String category) {
  switch (category) {
    case 'leadership': return '🛡️';
    case 'verification': return '✅';
    case 'milestone': return '🏆';
    case 'community': return '🌟';
    default: return '🎖️';
  }
}

class _SocialRow extends StatelessWidget {
  final _SocialP platform;
  const _SocialRow({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36, height: 36,
            child: _BrandIconBox(platform: platform),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                Text(platform.url!, style: TextStyle(fontSize: 11, color: context.primary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded, size: 14, color: context.textSecondary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interests card
// ---------------------------------------------------------------------------

class _InterestsCard extends StatelessWidget {
  final Profile profile;
  const _InterestsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader('Interests', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          profile.interests.isEmpty
              ? _EmptyPrompt('Add interests to connect with like-minded students', onTap: () => context.push('/app/profile/edit'))
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: profile.interests.map((i) => _Chip(label: i, color: context.primary)).toList(),
                ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skills card
// ---------------------------------------------------------------------------

class _SkillsCard extends StatelessWidget {
  final Profile profile;
  const _SkillsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader('Skills', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          profile.skills.isEmpty
              ? _EmptyPrompt('Showcase your technical and soft skills', onTap: () => context.push('/app/profile/edit'))
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: profile.skills.map((s) => _Chip(label: s, color: context.success, prefix: '✦ ')).toList(),
                ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final String? prefix;
  const _Chip({required this.label, required this.color, this.prefix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        '${prefix ?? ''}$label',
        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _EmptyPrompt(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: context.textSecondary))),
          const SizedBox(width: 8),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: context.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(Icons.add_rounded, size: 16, color: context.primary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Achievements card
// ---------------------------------------------------------------------------

class _AchievementsCard extends StatelessWidget {
  final Profile profile;
  final List<UserBadgeModel> badges;
  const _AchievementsCard({required this.profile, this.badges = const []});

  @override
  Widget build(BuildContext context) {
    final localBadges = <_Badge>[
      const _Badge(emoji: '🚀', label: 'Early Adopter', color: Color(0xFF8B5CF6)),
      if (profile.isComplete)
        const _Badge(emoji: '✅', label: 'Complete Profile', color: Color(0xFF10B981)),
      if (profile.isVerified)
        const _Badge(emoji: '⭐', label: 'Verified Student', color: Color(0xFFF59E0B)),
      if (profile.unifyScore >= 500)
        const _Badge(emoji: '⚡', label: 'Power User', color: AppColors.primary),
    ];
    // Add server badges
    for (final ub in badges) {
      final exists = localBadges.any((b) => b.label == ub.badge.name);
      if (!exists) {
        localBadges.add(_Badge(
          emoji: _badgeEmoji(ub.badge.category),
          label: ub.badge.name,
          color: ub.badge.category == 'leadership' ? const Color(0xFFFF6B35) : context.primary,
        ));
      }
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Achievements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFD4FF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 13, color: context.primary),
                    const SizedBox(width: 3),
                    Text(
                      '${profile.unifyScore} pts',
                      style: TextStyle(fontSize: 12, color: context.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: localBadges.map((b) => _BadgePill(badge: b)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String emoji;
  final String label;
  final Color color;
  const _Badge({required this.emoji, required this.label, required this.color});
}

class _BadgePill extends StatelessWidget {
  final _Badge badge;
  const _BadgePill({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badge.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(badge.label, style: TextStyle(fontSize: 12, color: badge.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leadership card
// ---------------------------------------------------------------------------

class _LeadershipCard extends StatelessWidget {
  final List<UserLeadershipModel> leadership;
  const _LeadershipCard({required this.leadership});

  @override
  Widget build(BuildContext context) {
    final primary = context.textPrimary;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, size: 16, color: Color(0xFFFF6B35)),
              const SizedBox(width: 6),
              Text('Leadership', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primary)),
            ],
          ),
          const SizedBox(height: 12),
          ...leadership.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield_rounded, size: 18, color: Color(0xFFFF6B35)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.role.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
                      const SizedBox(height: 2),
                      if (l.programme != null)
                        Text(l.programme!, style: TextStyle(fontSize: 12, color: context.textSecondary)),
                      if (l.level != null)
                        Text('Level ${l.level}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                      if (l.department != null || l.faculty != null)
                        Text(
                          [if (l.department != null) l.department!, if (l.faculty != null) l.faculty!].join(' · '),
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.verified_rounded, size: 11, color: context.primary),
                          const SizedBox(width: 3),
                          Text('Verified by UNIFY', style: TextStyle(fontSize: 10, color: context.primary, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          Text('AY ${l.academicYear}', style: TextStyle(fontSize: 10, color: context.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/dashboard'),
              icon: const Icon(Icons.dashboard_rounded, size: 16),
              label: const Text('Open Leadership Dashboard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B35),
                side: const BorderSide(color: Color(0xFFFF6B35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Verification Status card (get verified / pending / rejected)
// ---------------------------------------------------------------------------

class _VerificationStatusCard extends StatelessWidget {
  final String status; // 'none' | 'pending' | 'rejected'
  const _VerificationStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'pending') {
      return _Card(
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: context.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.access_time_rounded, color: context.warning, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Pending', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Your request is being reviewed by an admin',
                      style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'rejected') {
      return _Card(
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: context.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.cancel_rounded, color: context.error, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Rejected', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.error)),
                  const SizedBox(height: 2),
                  Text('Your request was not approved. You can reapply.',
                      style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: context.textSecondary),
          ],
        ),
        onTap: () => context.push('/verification-request'),
      );
    }

    // status == 'none' — tonal blue CTA
    return GestureDetector(
      onTap: () => context.push('/verification-request'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // blue-50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE)), // blue-200
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get Verified', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Apply for student leader verification',
                      style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Request Community Creation card (verified leaders only)
// ---------------------------------------------------------------------------

class _RequestCommunityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: () => context.push('/community-request'),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.group_add_rounded, color: context.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request Community Creation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
                const SizedBox(height: 2),
                Text('Create a new community for your class, department, or faculty',
                    style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: context.textSecondary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account card
// ---------------------------------------------------------------------------

class _AccountCard extends StatelessWidget {
  final WidgetRef ref;
  const _AccountCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(currentAppUserProvider).valueOrNull;
    final isAdmin = appUser?.isAdmin ?? false;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderCol, width: 0.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _Tile(icon: Icons.edit_outlined, label: 'Edit Profile', iconColor: context.primary, onTap: () => context.push('/app/profile/edit')),
          Divider(height: 1, color: context.borderCol, indent: 58),
          _Tile(icon: Icons.lock_outline, label: 'Privacy', iconColor: context.success, onTap: () => context.push('/app/profile/privacy')),
          Divider(height: 1, color: context.borderCol, indent: 58),
          _Tile(icon: Icons.palette_outlined, label: 'Appearance', iconColor: const Color(0xFF8B5CF6), onTap: () => context.push('/app/profile/settings')),
          if (isAdmin) ...[
            Divider(height: 1, color: context.borderCol, indent: 58),
            _Tile(
              icon: Icons.rocket_launch_rounded,
              label: 'Launch Control',
              iconColor: context.primary,
              onTap: () => context.push('/launch'),
            ),
          ],
          Divider(height: 1, color: context.borderCol, indent: 58),
          _Tile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            iconColor: context.error,
            labelColor: context.error,
            showChevron: false,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('Sign out?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: context.textPrimary)),
                  content: Text("You'll need to sign in again to access your account.", style: TextStyle(color: context.textSecondary, fontSize: 14, height: 1.5)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: context.textSecondary))),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Sign Out', style: TextStyle(color: context.error, fontWeight: FontWeight.w600))),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go('/welcome');
              }
            },
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(16),
      splashColor: iconColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor ?? context.textPrimary)),
            ),
            if (showChevron) Icon(Icons.chevron_right_rounded, size: 20, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------------

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: topPad + 170, color: context.cardBg),
            Container(
              color: context.cardBg,
              padding: const EdgeInsets.fromLTRB(16, 58, 16, 20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SBox(h: 22, w: 190, r: 6),
                  SizedBox(height: 8),
                  _SBox(h: 14, w: 130, r: 6),
                  SizedBox(height: 6),
                  _SBox(h: 14, w: 210, r: 6),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  _SBox(h: 70, w: double.infinity, r: 16),
                  SizedBox(height: 12),
                  _SBox(h: 160, w: double.infinity, r: 16),
                  SizedBox(height: 12),
                  _SBox(h: 130, w: double.infinity, r: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SBox extends StatelessWidget {
  final double h, w, r;
  const _SBox({required this.h, required this.w, required this.r});

  @override
  Widget build(BuildContext context) =>
      Container(height: h, width: w, decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(r)));
}




