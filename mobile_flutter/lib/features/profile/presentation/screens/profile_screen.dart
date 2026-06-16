import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/widgets/theme_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------

const _kPrimary = Color(0xFF0066FF);
const _kBg      = Color(0xFFF5F7FA);
const _kCard    = Colors.white;
const _kText1   = Color(0xFF0A0A1A);
const _kText2   = Color(0xFF6B7280);
const _kBorder  = Color(0xFFE5E7EB);
const _kGreen   = Color(0xFF10B981);
const _kRed     = Color(0xFFEF4444);

const _kShadow = [
  BoxShadow(color: Color(0x09000000), blurRadius: 12, offset: Offset(0, 3)),
  BoxShadow(color: Color(0x05000000), blurRadius: 4),
];

// ---------------------------------------------------------------------------
// Root screen
// ---------------------------------------------------------------------------

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync   = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: profileAsync.when(
        loading: () => const _Skeleton(),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (profile) {
          if (profile == null) return const _ErrorView(message: 'Profile not found.');
          return _Body(
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
// Animated body — staggered entrance for each section
// ---------------------------------------------------------------------------

class _Body extends StatefulWidget {
  final Profile profile;
  final int postCount;
  final WidgetRef ref;
  const _Body({required this.profile, required this.postCount, required this.ref});

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
    const n = 9;
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _section(0, _Header(profile: p, postCount: widget.postCount, ctrl: _ctrl)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (incomplete) ...[
                _section(1, _CompletionCard(profile: p)),
                const SizedBox(height: 12),
              ],
              _section(2, _AboutCard(profile: p)),
              const SizedBox(height: 12),
              _section(3, _AcademicCard(profile: p)),
              const SizedBox(height: 12),
              _section(4, _SocialCard(profile: p)),
              const SizedBox(height: 12),
              _section(5, _InterestsCard(profile: p)),
              const SizedBox(height: 12),
              _section(6, _SkillsCard(profile: p)),
              const SizedBox(height: 12),
              _section(7, _AchievementsCard(profile: p)),
              const SizedBox(height: 12),
              _section(8, _AccountCard(ref: widget.ref)),
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
  const _Header({required this.profile, required this.postCount, required this.ctrl});

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
              color: _kCard,
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
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: _kText1,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 5),
                                  const Icon(Icons.verified_rounded, color: _kPrimary, size: 19),
                                ],
                              ],
                            ),
                            if (profile.username?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text('@${profile.username}', style: const TextStyle(fontSize: 13, color: _kText2)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => context.push('/app/profile/edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kPrimary,
                          side: const BorderSide(color: _kPrimary, width: 1.5),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kText1),
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
                      style: const TextStyle(fontSize: 13, color: _kText2),
                    ),

                  // Campus
                  if (profile.campus?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: _kText2),
                        const SizedBox(width: 3),
                        Text(profile.campus!, style: const TextStyle(fontSize: 13, color: _kText2)),
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
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing coming soon'), behavior: SnackBarBehavior.floating),
                ),
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.settings_outlined,
                onTap: () => context.push('/app/profile/privacy'),
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
          colors: [Color(0xFF003EB3), Color(0xFF0066FF), Color(0xFF4DA3FF)],
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
          color: Colors.white.withOpacity(0.90),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x25000000), blurRadius: 8)],
        ),
        child: Icon(icon, size: 18, color: _kText1),
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
            border: Border.all(color: Colors.white, width: 3.5),
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
              color: _kPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
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
          style: TextStyle(fontSize: diameter * 0.30, fontWeight: FontWeight.w800, color: _kPrimary),
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
        const Divider(height: 1, color: _kBorder),
        const SizedBox(height: 14),
        Row(
          children: [
            _StatCell(value: postCount, label: 'Posts'),
            _Divider(),
            _StatCell(value: 0, label: 'Connections', cta: true),
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
                  color: isEmpty && !cta ? const Color(0xFFD1D5DB) : _kText1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: cta && isEmpty ? _kPrimary : _kText2,
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
      Container(width: 1, height: 36, color: _kBorder);
}

// ---------------------------------------------------------------------------
// Base card
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const _Card({required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget inner = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 0.5),
        boxShadow: _kShadow,
      ),
      child: child,
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: _kPrimary.withOpacity(0.04),
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
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText1)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: const TextStyle(fontSize: 13, color: _kPrimary, fontWeight: FontWeight.w500)),
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
                const Text('Complete your profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kText1)),
                const SizedBox(height: 3),
                const Text('A complete profile helps students and employers find you.', style: TextStyle(fontSize: 12, color: _kText2, height: 1.4)),
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
                      backgroundColor: _kBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text('$pct% complete', style: const TextStyle(fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _kText2),
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
              ? Text(profile.bio!, style: const TextStyle(fontSize: 14, color: _kText1, height: 1.65))
              : GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: Row(
                    children: [
                      const Text('Add a bio to introduce yourself', style: TextStyle(fontSize: 14, color: _kText2)),
                      const Spacer(),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, size: 16, color: _kPrimary),
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
                    decoration: BoxDecoration(color: _kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.school_rounded, size: 18, color: _kPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Add your university details', style: TextStyle(color: _kText2, fontSize: 14))),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _kText2),
                ],
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  _DataRow(label: rows[i].label, value: rows[i].value),
                  if (i < rows.length - 1) const Divider(height: 1, color: _kBorder),
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
            child: Text(label, style: const TextStyle(fontSize: 13, color: _kText2)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
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
        bgStart: const Color(0xFFF9ED32), bgEnd: const Color(0xFF833AB4),
        isGradient: true, child: const _IgIcon()),
      _SocialP('TikTok', profile.tiktokUrl,
        solid: const Color(0xFF010101), child: const _TikTokIcon()),
      _SocialP('Snapchat', profile.snapchatUrl,
        solid: const Color(0xFFFFFC00), child: const _SnapchatIcon()),
      _SocialP('LinkedIn', profile.linkedinUrl,
        solid: const Color(0xFF0A66C2), child: const _LinkedInIcon()),
      _SocialP('X (Twitter)', profile.twitterUrl,
        solid: const Color(0xFF000000), child: const _XIcon()),
      _SocialP('GitHub', profile.githubUrl,
        solid: const Color(0xFF24292F), child: const _GitHubIcon()),
      _SocialP('Portfolio', profile.portfolioUrl,
        solid: _kPrimary, child: const Icon(Icons.language_rounded, color: Colors.white, size: 22)),
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
                  if (i < active.length - 1) const Divider(height: 1, color: _kBorder),
                ],
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: const Text('Add your social links →', style: TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
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
  final Color? bgStart;
  final Color? bgEnd;
  final bool isGradient;
  final Widget child;

  const _SocialP(this.label, this.url, {
    this.solid,
    this.bgStart,
    this.bgEnd,
    this.isGradient = false,
    required this.child,
  });
}

class _BrandIconBox extends StatelessWidget {
  final _SocialP platform;
  const _BrandIconBox({required this.platform});

  @override
  Widget build(BuildContext context) {
    final shadow = BoxShadow(
      color: (platform.solid ?? platform.bgEnd ?? Colors.black).withOpacity(0.22),
      blurRadius: 8,
      offset: const Offset(0, 3),
    );

    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: platform.isGradient ? null : platform.solid,
        gradient: platform.isGradient
            ? LinearGradient(
                colors: [platform.bgStart!, platform.bgEnd!],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [shadow],
      ),
      child: Center(child: platform.child),
    );
  }
}

// ── Brand icon widgets ─────────────────────────────────────────────────────

class _IgIcon extends StatelessWidget {
  const _IgIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white, width: 1.8),
          ),
        ),
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.8),
          ),
        ),
        const Positioned(
          top: 3, right: 3,
          child: CircleAvatar(radius: 1.5, backgroundColor: Colors.white),
        ),
      ],
    );
  }
}

class _TikTokIcon extends StatelessWidget {
  const _TikTokIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'TT',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
    );
  }
}

class _SnapchatIcon extends StatelessWidget {
  const _SnapchatIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _GhostPainter(),
    );
  }
}

class _GhostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Simple ghost body
    path.moveTo(cx - 8, cy + 8);
    path.lineTo(cx - 8, cy - 2);
    path.quadraticBezierTo(cx - 8, cy - 10, cx, cy - 10);
    path.quadraticBezierTo(cx + 8, cy - 10, cx + 8, cy - 2);
    path.lineTo(cx + 8, cy + 8);
    path.lineTo(cx + 4, cy + 5);
    path.lineTo(cx, cy + 8);
    path.lineTo(cx - 4, cy + 5);
    path.close();

    canvas.drawPath(path, paint);

    // Eyes
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx - 3, cy - 2), 1.5, paint);
    canvas.drawCircle(Offset(cx + 3, cy - 2), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _LinkedInIcon extends StatelessWidget {
  const _LinkedInIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'in',
      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, fontStyle: FontStyle.italic),
    );
  }
}

class _XIcon extends StatelessWidget {
  const _XIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'X',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
    );
  }
}

class _GitHubIcon extends StatelessWidget {
  const _GitHubIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _OctocatPainter(),
    );
  }
}

class _OctocatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2 - 1;

    // Head circle
    canvas.drawCircle(Offset(cx, cy), 9, paint);

    // Ears
    final earPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, cy - 7), width: 6, height: 5), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 6, cy - 7), width: 6, height: 5), earPaint);

    // Inner ear (dark)
    final darkPaint = Paint()..color = const Color(0xFF24292F)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, cy - 7), width: 3, height: 2.5), darkPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 6, cy - 7), width: 3, height: 2.5), darkPaint);

    // Eyes
    canvas.drawCircle(Offset(cx - 3, cy), 1.8, darkPaint);
    canvas.drawCircle(Offset(cx + 3, cy), 1.8, darkPaint);

    // Nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 3), width: 3, height: 2), darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
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
                Text(platform.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kText1)),
                Text(platform.url!, style: const TextStyle(fontSize: 11, color: _kPrimary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.open_in_new_rounded, size: 14, color: _kText2),
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
                  children: profile.interests.map((i) => _Chip(label: i, color: _kPrimary)).toList(),
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
                  children: profile.skills.map((s) => _Chip(label: s, color: _kGreen, prefix: '✦ ')).toList(),
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: _kText2))),
          const SizedBox(width: 8),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: _kPrimary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, size: 16, color: _kPrimary),
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
  const _AchievementsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[
      const _Badge(emoji: '🚀', label: 'Early Adopter', color: Color(0xFF8B5CF6)),
      if (profile.isComplete)
        const _Badge(emoji: '✅', label: 'Complete Profile', color: Color(0xFF10B981)),
      if (profile.isVerified)
        const _Badge(emoji: '⭐', label: 'Verified Student', color: Color(0xFFF59E0B)),
      if (profile.unifyScore >= 500)
        const _Badge(emoji: '⚡', label: 'Power User', color: Color(0xFF0066FF)),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Achievements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText1)),
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
                    const Icon(Icons.bolt_rounded, size: 13, color: _kPrimary),
                    const SizedBox(width: 3),
                    Text(
                      '${profile.unifyScore} pts',
                      style: const TextStyle(fontSize: 12, color: _kPrimary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: badges.map((b) => _BadgePill(badge: b)).toList(),
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
        color: badge.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badge.color.withOpacity(0.22)),
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
// Account card
// ---------------------------------------------------------------------------

class _AccountCard extends StatelessWidget {
  final WidgetRef ref;
  const _AccountCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 0.5),
        boxShadow: _kShadow,
      ),
      child: Column(
        children: [
          _Tile(icon: Icons.edit_outlined, label: 'Edit Profile', iconColor: _kPrimary, onTap: () => context.push('/app/profile/edit')),
          const Divider(height: 1, color: _kBorder, indent: 58),
          _Tile(icon: Icons.lock_outline, label: 'Privacy', iconColor: _kGreen, onTap: () => context.push('/app/profile/privacy')),
          const Divider(height: 1, color: _kBorder, indent: 58),
          _Tile(icon: Icons.palette_outlined, label: 'Appearance', iconColor: const Color(0xFF8B5CF6), showChevron: false, onTap: () => ThemePickerSheet.show(context)),
          const Divider(height: 1, color: _kBorder, indent: 58),
          _Tile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            iconColor: _kRed,
            labelColor: _kRed,
            showChevron: false,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Sign out?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: _kText1)),
                  content: const Text("You'll need to sign in again to access your account.", style: TextStyle(color: _kText2, fontSize: 14, height: 1.5)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: _kText2))),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: _kRed, fontWeight: FontWeight.w600))),
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
      splashColor: iconColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor ?? _kText1)),
            ),
            if (showChevron) const Icon(Icons.chevron_right_rounded, size: 20, color: _kText2),
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
            Container(height: topPad + 170, color: Colors.white),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 58, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SBox(h: 22, w: 190, r: 6),
                  const SizedBox(height: 8),
                  _SBox(h: 14, w: 130, r: 6),
                  const SizedBox(height: 6),
                  _SBox(h: 14, w: 210, r: 6),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  _SBox(h: 70, w: double.infinity, r: 16),
                  const SizedBox(height: 12),
                  _SBox(h: 160, w: double.infinity, r: 16),
                  const SizedBox(height: 12),
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
      Container(height: h, width: w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r)));
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: _kRed),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: _kText2, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
