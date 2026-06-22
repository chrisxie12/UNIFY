import 'package:flutter/material.dart';
import '../onboarding_screen.dart';

class StepProfilePhoto extends StatelessWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepProfilePhoto({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Add a profile photo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A photo helps classmates and tutors recognize you\nand builds trust in the community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              // Photo upload would be handled here
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              label: const Text('Take a photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_library_outlined, size: 20),
              label: const Text('Upload from gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onChanged,
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can always add or change your photo later\nin your profile settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary.withValues(alpha: 0.4),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
