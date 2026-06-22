import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/design/design_tokens.dart';
import '../onboarding_screen.dart';

/// Step 6 — optional profile photo. Stores a local file path on [OnboardingData];
/// uploading to storage happens at submit time (not yet wired).
class StepProfilePhoto extends StatefulWidget {
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
  State<StepProfilePhoto> createState() => _StepProfilePhotoState();
}

class _StepProfilePhotoState extends State<StepProfilePhoto> {
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (x == null) return;
      setState(() => widget.data.photoPath = x.path);
      widget.onChanged?.call();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the picker. Check permissions.')),
      );
    }
  }

  void _remove() {
    setState(() => widget.data.photoPath = null);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.data.photoPath;
    final hasPhoto = path != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Add a profile photo',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28, fontWeight: FontWeight.w700, height: 1.15,
              letterSpacing: -0.5, color: UnifyColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text(
              'A photo helps classmates and tutors recognize you and builds trust in the community.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15, height: 1.5, color: UnifyColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),

          // Photo ring
          GestureDetector(
            onTap: () => _pick(ImageSource.gallery),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasPhoto ? UnifyColors.primaryBlue : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasPhoto
                  ? Image.file(File(path), fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: UnifyColors.primaryBlue.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: UnifyColors.primaryBlue, size: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: UnifyColors.textTertiary),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),

          _ActionButton(
            icon: Icons.camera_alt_outlined,
            label: 'Take a photo',
            onTap: () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.add_photo_alternate_outlined,
            label: 'Upload from gallery',
            onTap: () => _pick(ImageSource.gallery),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: hasPhoto ? _remove : null,
            child: Text(
              hasPhoto ? 'Remove photo' : 'Skip for now',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: hasPhoto ? UnifyColors.error : UnifyColors.textTertiary),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: Text(
              'You can always add or change your photo later in your profile settings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12, height: 1.5, color: UnifyColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: UnifyColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF374151)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937)),
            ),
          ],
        ),
      ),
    );
  }
}
