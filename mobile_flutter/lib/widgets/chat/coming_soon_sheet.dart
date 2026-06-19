import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _surfaceDark  = Color(0xFF1A1A2E);
const _accentBlue   = Color(0xFF00D4FF);
const _accentPurple = Color(0xFF7C3AED);
const _textPrimary  = Colors.white;
const _textSecondary = Color(0xFF8B8B9E);

TextStyle _sg(double size, FontWeight w, Color c, {TextAlign? align}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, color: c);

void showGamingComingSoonSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _GamingSheet(),
  );
}

class _GamingSheet extends StatelessWidget {
  const _GamingSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accentPurple.withValues(alpha: 0.30), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Gamepad icon with glow
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _accentPurple.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accentPurple.withValues(alpha: 0.30),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.gamepad_rounded, color: _accentPurple, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Gaming Coming Soon',
              style: _sg(20, FontWeight.w700, _textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Play campus games, challenge friends, and climb the leaderboard. Stay tuned!',
              style: _sg(14, FontWeight.w400, _textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Feature preview chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _FeatureChip('🏆 Leaderboard'),
                SizedBox(width: 8),
                _FeatureChip('🎮 Mini Games'),
                SizedBox(width: 8),
                _FeatureChip('👥 Challenges'),
              ],
            ),
            const SizedBox(height: 28),
            // Gradient CTA button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accentPurple, _accentBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _accentPurple.withValues(alpha: 0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Got it',
                    style: _sg(16, FontWeight.w600, Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
      ),
    );
  }
}
