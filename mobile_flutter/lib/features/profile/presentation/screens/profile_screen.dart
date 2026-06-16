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
  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  BoxShadow(color: Color(0x05000000), blurRadius: 2),
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
// Body
// ---------------------------------------------------------------------------

class _Body extends StatelessWidget {
  final Profile profile;
  final int postCount;
  final WidgetRef ref;

  const _Body({required this.profile, required this.postCount, required this.ref});

  @override
  Widget build(BuildContext context) {
    final incomplete = profile.completionScore < 80;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Identity block ────────────────────────────────────────
        SliverToBoxAdapter(
          child: _IdentityBlock(profile: profile, postCount: postCount),
        ),

        // ── Content cards ─────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (incomplete) ...[
                _CompletionCard(profile: profile),
                const SizedBox(height: 12),
              ],
              _AboutCard(profile: profile),
              const SizedBox(height: 12),
              _AcademicCard(profile: profile),
              const SizedBox(height: 12),
              _SocialCard(profile: profile),
              const SizedBox(height: 12),
              _InterestsCard(profile: profile),
              const SizedBox(height: 12),
              _SkillsCard(profile: profile),
              const SizedBox(height: 12),
              _AchievementsCard(profile: profile),
              const SizedBox(height: 12),
              _AccountCard(ref: ref),
            ]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Identity block — cover + avatar + name + stats
// ---------------------------------------------------------------------------

class _IdentityBlock extends StatelessWidget {
  final Profile profile;
  final int postCount;
  const _IdentityBlock({required this.profile, required this.postCount});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    const coverH = 170.0;
    const avatarD = 88.0; // diameter

    return Column(
      children: [
        // ── Cover + avatar ──────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover photo
            SizedBox(
              height: topPad + coverH,
              width: double.infinity,
              child: _CoverPhoto(profile: profile),
            ),
            // Action buttons (top-right)
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
                    icon: Icons.tune_rounded,
                    onTap: () => context.push('/app/profile/privacy'),
                  ),
                ],
              ),
            ),
            // Avatar hangs below cover
            Positioned(
              bottom: -(avatarD / 2),
              left: 16,
              child: GestureDetector(
                onTap: () => context.push('/app/profile/edit'),
                child: _Avatar(profile: profile, diameter: avatarD),
              ),
            ),
          ],
        ),

        // ── White identity card ─────────────────────────────────────
        Container(
          width: double.infinity,
          color: _kCard,
          padding: EdgeInsets.fromLTRB(16, avatarD / 2 + 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row
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
                              const Icon(Icons.verified, color: _kPrimary, size: 18),
                            ],
                          ],
                        ),
                        if (profile.username?.isNotEmpty == true)
                          Text(
                            '@${profile.username}',
                            style: const TextStyle(fontSize: 13, color: _kText2),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => context.push('/app/profile/edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPrimary,
                      side: const BorderSide(color: _kPrimary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Academic identity
              if (profile.programme?.isNotEmpty == true) ...[
                Text(profile.programme!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kText1)),
                const SizedBox(height: 2),
              ],
              if (profile.school?.isNotEmpty == true || profile.yearOfStudy != null)
                Text(
                  [
                    if (profile.school?.isNotEmpty == true) profile.school!,
                    if (profile.yearOfStudy != null) profile.studentStatus,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 13, color: _kText2),
                ),
              if (profile.campus?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: _kText2),
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
    return Stack(
      children: [
        Positioned.fill(
          child: hasPhoto
              ? CachedNetworkImage(
                  imageUrl: profile.coverPhotoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _DefaultCover(),
                  errorWidget: (_, __, ___) => const _DefaultCover(),
                )
              : const _DefaultCover(),
        ),
        // Bottom fade to white
        Positioned(
          bottom: 0, left: 0, right: 0, height: 40,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0x22000000)],
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

class _DefaultCover extends StatelessWidget {
  const _DefaultCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0047CC), Color(0xFF0066FF), Color(0xFF338AFF)],
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
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)],
        ),
        child: Icon(icon, size: 17, color: _kText1),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final Profile profile;
  final double diameter;
  const _Avatar({required this.profile, required this.diameter});

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (profile.avatarUrl?.isNotEmpty == true) {
      inner = CachedNetworkImage(
        imageUrl: profile.avatarUrl!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        placeholder: (_, __) => _Initials(initials: profile.initials, diameter: diameter),
        errorWidget: (_, __, ___) => _Initials(initials: profile.initials, diameter: diameter),
      );
    } else {
      inner = _Initials(initials: profile.initials, diameter: diameter);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: ClipOval(child: inner),
        ),
        Positioned(
          bottom: 1, right: 1,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: _kPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 11, color: Colors.white),
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
          style: TextStyle(
            fontSize: diameter * 0.32,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
          ),
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
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCell(value: '$postCount', label: 'Posts'),
            _StatDivider(),
            _StatCell(
              value: '0',
              label: 'Connections',
              onTap: () {},
              cta: true,
            ),
            _StatDivider(),
            _StatCell(
              value: '0',
              label: 'Communities',
              onTap: () => context.go('/app/communities'),
              cta: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final bool cta;
  final VoidCallback? onTap;
  const _StatCell({required this.value, required this.label, this.cta = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '0';
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: _kBorder);
}

// ---------------------------------------------------------------------------
// Base clean card
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
    if (onTap != null) return GestureDetector(onTap: onTap, child: inner);
    return inner;
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _CardTitle(this.title, {this.action, this.onAction});

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
// Profile completion card
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
                const Text(
                  'Complete your profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kText1),
                ),
                const SizedBox(height: 3),
                Text(
                  'A complete profile helps students and employers find you.',
                  style: const TextStyle(fontSize: 12, color: _kText2, height: 1.4),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$pct% complete', style: const TextStyle(fontSize: 11, color: _kPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _kText2),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About / Bio card
// ---------------------------------------------------------------------------

class _AboutCard extends StatelessWidget {
  final Profile profile;
  const _AboutCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio?.isNotEmpty == true;
    return _Card(
      onTap: hasBio ? null : () => context.push('/app/profile/edit'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('About', action: hasBio ? 'Edit' : null, onAction: () => context.push('/app/profile/edit')),
          hasBio
              ? Text(profile.bio!, style: const TextStyle(fontSize: 14, color: _kText1, height: 1.60))
              : Row(
                  children: [
                    const Text('Add a bio', style: TextStyle(fontSize: 14, color: _kText2)),
                    const Spacer(),
                    const Icon(Icons.add_circle_outline_rounded, size: 18, color: _kPrimary),
                  ],
                ),
        ],
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
    final rows = <_KV>[];
    if (profile.school?.isNotEmpty == true)      rows.add(_KV('University', profile.school!));
    if (profile.programme?.isNotEmpty == true)   rows.add(_KV('Programme', profile.programme!));
    if (profile.faculty?.isNotEmpty == true)     rows.add(_KV('Faculty', profile.faculty!));
    if (profile.department?.isNotEmpty == true)  rows.add(_KV('Department', profile.department!));
    if (profile.yearOfStudy != null)             rows.add(_KV('Year', 'Year ${profile.yearOfStudy} · ${profile.studentStatus}'));
    if (profile.expectedGraduationYear != null)  rows.add(_KV('Graduating', 'Class of ${profile.expectedGraduationYear}'));
    if (profile.campus?.isNotEmpty == true)      rows.add(_KV('Campus', profile.campus!));

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            'Academic Info',
            action: 'Edit',
            onAction: () => context.push('/app/profile/edit'),
          ),
          if (rows.isEmpty)
            GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: const Row(
                children: [
                  Icon(Icons.school_outlined, size: 16, color: _kText2),
                  SizedBox(width: 8),
                  Text('Add your university details', style: TextStyle(color: _kText2, fontSize: 14)),
                  Spacer(),
                  Icon(Icons.add_circle_outline_rounded, size: 18, color: _kPrimary),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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
// Social links card
// ---------------------------------------------------------------------------

class _SocialCard extends StatelessWidget {
  final Profile profile;
  const _SocialCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final platforms = [
      _SocialP('Instagram', Icons.camera_alt_outlined, const Color(0xFFE1306C), profile.instagramUrl),
      _SocialP('TikTok', Icons.music_note_rounded, const Color(0xFF010101), profile.tiktokUrl),
      _SocialP('Snapchat', Icons.chat_bubble_outline_rounded, const Color(0xFFFFBC00), profile.snapchatUrl),
      _SocialP('LinkedIn', Icons.work_outline, const Color(0xFF0A66C2), profile.linkedinUrl),
      _SocialP('Twitter', Icons.alternate_email, const Color(0xFF1DA1F2), profile.twitterUrl),
      _SocialP('GitHub', Icons.code, const Color(0xFF24292F), profile.githubUrl),
      _SocialP('Portfolio', Icons.language, _kGreen, profile.portfolioUrl),
    ];
    final active = platforms.where((p) => p.url?.isNotEmpty == true).toList();
    final hasActive = active.isNotEmpty;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            'Social & Links',
            action: 'Edit',
            onAction: () => context.push('/app/profile/edit'),
          ),
          // Icon row
          Wrap(
            spacing: 8, runSpacing: 8,
            children: platforms.map((p) {
              final isActive = p.url?.isNotEmpty == true;
              return GestureDetector(
                onTap: isActive ? null : () => context.push('/app/profile/edit'),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: p.color.withOpacity(isActive ? 0.10 : 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: p.color.withOpacity(isActive ? 0.30 : 0.10),
                    ),
                  ),
                  child: Icon(p.icon, color: p.color.withOpacity(isActive ? 1.0 : 0.30), size: 20),
                ),
              );
            }).toList(),
          ),
          if (hasActive) ...[
            const SizedBox(height: 14),
            Column(
              children: [
                for (int i = 0; i < active.length; i++) ...[
                  _SocialRow(platform: active[i]),
                  if (i < active.length - 1) const Divider(height: 1, color: _kBorder),
                ],
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push('/app/profile/edit'),
              child: const Text(
                'Add your social links',
                style: TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SocialP {
  final String label;
  final IconData icon;
  final Color color;
  final String? url;
  const _SocialP(this.label, this.icon, this.color, this.url);
}

class _SocialRow extends StatelessWidget {
  final _SocialP platform;
  const _SocialRow({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: platform.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(platform.icon, color: platform.color, size: 16),
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
          _CardTitle('Interests', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          profile.interests.isEmpty
              ? GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: const Row(
                    children: [
                      Text('Add interests to connect with students', style: TextStyle(color: _kText2, fontSize: 14)),
                      Spacer(),
                      Icon(Icons.add_circle_outline_rounded, size: 18, color: _kPrimary),
                    ],
                  ),
                )
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
          _CardTitle('Skills', action: 'Edit', onAction: () => context.push('/app/profile/edit')),
          profile.skills.isEmpty
              ? GestureDetector(
                  onTap: () => context.push('/app/profile/edit'),
                  child: const Row(
                    children: [
                      Text('Showcase your skills', style: TextStyle(color: _kText2, fontSize: 14)),
                      Spacer(),
                      Icon(Icons.add_circle_outline_rounded, size: 18, color: _kPrimary),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  children: profile.skills.map((s) => _Chip(label: s, color: _kGreen, prefix: '• ')).toList(),
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
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        '${prefix ?? ''}$label',
        style: TextStyle(fontSize: 13, color: color.darken(0.1), fontWeight: FontWeight.w500),
      ),
    );
  }
}

extension _ColorX on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
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
              // Clean UNIFY Score — text only, no glow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        color: badge.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badge.color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(badge.label, style: TextStyle(fontSize: 12, color: badge.color.darken(0.05), fontWeight: FontWeight.w600)),
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
          _Tile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            iconColor: _kPrimary,
            onTap: () => context.push('/app/profile/edit'),
          ),
          const Divider(height: 1, color: _kBorder, indent: 56),
          _Tile(
            icon: Icons.lock_outline,
            label: 'Privacy',
            iconColor: _kGreen,
            onTap: () => context.push('/app/profile/privacy'),
          ),
          const Divider(height: 1, color: _kBorder, indent: 56),
          _Tile(
            icon: Icons.palette_outlined,
            label: 'Appearance',
            iconColor: const Color(0xFF8B5CF6),
            showChevron: false,
            onTap: () => ThemePickerSheet.show(context),
          ),
          const Divider(height: 1, color: _kBorder, indent: 56),
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
                  content: const Text(
                    "You'll need to sign in again to access your account.",
                    style: TextStyle(color: _kText2, fontSize: 14, height: 1.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: _kText2)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(color: _kRed, fontWeight: FontWeight.w600)),
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
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor ?? _kText1),
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right, size: 18, color: _kText2),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
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
            // Cover
            Container(height: topPad + 170, color: Colors.white),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SBox(h: 22, w: 180, r: 6),
                  const SizedBox(height: 8),
                  _SBox(h: 14, w: 120, r: 6),
                  const SizedBox(height: 6),
                  _SBox(h: 14, w: 200, r: 6),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  _SBox(h: 72, w: double.infinity, r: 16),
                  const SizedBox(height: 12),
                  _SBox(h: 160, w: double.infinity, r: 16),
                  const SizedBox(height: 12),
                  _SBox(h: 120, w: double.infinity, r: 16),
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
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: _kRed),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: _kText2, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
