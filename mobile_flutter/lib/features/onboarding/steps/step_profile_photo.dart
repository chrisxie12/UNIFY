import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800);
    if (xFile == null) return;

    final file = File(xFile.path);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final ext = xFile.path.split('.').last;
      final path = 'avatars/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Supabase.instance.client.storage.from('profiles').upload(path, file);
      final url = Supabase.instance.client.storage.from('profiles').getPublicUrl(path);
      data.photoUrl = url;
      onChanged?.call();
    } catch (e) {
      debugPrint('[StepProfilePhoto] Upload error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

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
            onTap: data.photoUrl != null
                ? null
                : () => _pickImage(context, ImageSource.gallery),
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
                image: data.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(data.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: data.photoUrl == null
                  ? Center(
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
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(context, ImageSource.camera),
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
              onPressed: () => _pickImage(context, ImageSource.gallery),
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
