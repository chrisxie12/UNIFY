import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../providers/profile_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  String _privacyLevel = 'public';
  bool _isSaving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile != null && !_loaded) {
        setState(() {
          _privacyLevel = profile.privacyLevel;
          _loaded = true;
        });
      }
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final client = ref.read(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(userId, {'privacy_level': _privacyLevel});
      ref.invalidate(profileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy settings saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep local state in sync if profile loads after initState
    ref.listen(profileProvider, (_, next) {
      final profile = next.valueOrNull;
      if (profile != null && !_loaded) {
        setState(() {
          _privacyLevel = profile.privacyLevel;
          _loaded = true;
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Privacy', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    child: Text(
                      'Save',
                      style: AppTextStyles.bodySemi.copyWith(color: context.primary),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile visibility ─────────────────────────────────────────
            Text('Profile Visibility', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Control who can see your UNIFY profile and information.',
              style: AppTextStyles.body.copyWith(color: AppColors.grey2),
            ),
            const SizedBox(height: 20),

            ...[
              (
                value: 'public',
                emoji: '🌍',
                label: 'Public',
                desc: 'Anyone can discover and view your profile',
              ),
              (
                value: 'university',
                emoji: '🏫',
                label: 'University Only',
                desc: 'Only verified students at your university',
              ),
              (
                value: 'friends',
                emoji: '👥',
                label: 'Friends Only',
                desc: 'Only people you are connected with',
              ),
            ].map((opt) {
              final active = _privacyLevel == opt.value;
              return GestureDetector(
                onTap: () => setState(() => _privacyLevel = opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active ? context.primary.withValues(alpha: 0.07) : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? context.primary : AppColors.border,
                      width: active ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.label, style: AppTextStyles.bodySemi),
                            const SizedBox(height: 3),
                            Text(
                              opt.desc,
                              style: AppTextStyles.caption.copyWith(color: AppColors.grey2),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        Icon(Icons.check_circle_rounded, color: context.primary, size: 22),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // ── Student verification ───────────────────────────────────────
            Text('Student Verification', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Verified students get a badge and appear higher in searches.',
              style: AppTextStyles.body.copyWith(color: AppColors.grey2),
            ),
            const SizedBox(height: 16),
            const _InfoTile(
              icon: Icons.badge_outlined,
              iconColor: Color(0xFF3B82F6),
              title: 'Verification Status',
              subtitle: 'Student verification is coming soon',
            ),
            const SizedBox(height: 10),
            const _InfoTile(
              icon: Icons.school_outlined,
              iconColor: Color(0xFF10B981),
              title: 'Student ID',
              subtitle: 'Required for verification — not yet collected',
            ),

            const SizedBox(height: 32),

            // ── Data & account ─────────────────────────────────────────────
            Text('Data & Account', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            const _InfoTile(
              icon: Icons.visibility_outlined,
              iconColor: Color(0xFF8B5CF6),
              title: 'Profile Views',
              subtitle: 'Other students can see that you viewed their profile',
            ),
            const SizedBox(height: 10),
            const _InfoTile(
              icon: Icons.analytics_outlined,
              iconColor: Color(0xFFF59E0B),
              title: 'Analytics',
              subtitle: 'Profile analytics and insights coming soon',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.20), width: 0.8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemi),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.grey2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
