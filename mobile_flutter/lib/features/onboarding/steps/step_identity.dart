import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

const _brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [UnifyColors.primaryBlue, UnifyColors.accentPurple],
);

class StepIdentity extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepIdentity({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  void _select(UserIdentity identity) {
    data.identity = identity;
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Accent line
          Container(
            width: 48,
            height: 3,
            decoration: BoxDecoration(
              gradient: _brandGradient,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Which path\nare you on?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
              color: UnifyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              'Select your current academic level so we can personalize your UNIFY experience.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                height: 1.5,
                color: UnifyColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 36),

          _PathCard(
            icon: Icons.school_rounded,
            accent: UnifyColors.primaryBlue,
            title: 'University',
            subtitle: 'Currently enrolled or applying to a university',
            selected: data.identity == UserIdentity.uni,
            onTap: () => _select(UserIdentity.uni),
          ),
          const SizedBox(height: 20),
          _PathCard(
            icon: Icons.account_balance_rounded,
            accent: UnifyColors.accentPurple,
            title: 'Senior High School',
            subtitle: 'In SHS or recently graduated',
            selected: data.identity == UserIdentity.shs,
            onTap: () => _select(UserIdentity.shs),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'You can always update this later in your profile settings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                height: 1.5,
                color: UnifyColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PathCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF)],
                )
              : null,
          color: selected ? null : UnifyColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? UnifyColors.primaryBlue : const Color(0xFFF1F5F9),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? UnifyColors.primaryBlue.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: selected ? 24 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon wrap
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: selected ? _brandGradient : null,
                color: selected ? null : accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 26,
                color: selected ? Colors.white : accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: UnifyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      height: 1.3,
                      color: UnifyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Check indicator
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: selected ? _brandGradient : null,
                shape: BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(color: UnifyColors.textTertiary, width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
