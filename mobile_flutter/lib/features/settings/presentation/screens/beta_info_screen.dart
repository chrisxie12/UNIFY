import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/unify_snackbar.dart';

class BetaInfoScreen extends ConsumerStatefulWidget {
  const BetaInfoScreen({super.key});

  @override
  ConsumerState<BetaInfoScreen> createState() => _BetaInfoScreenState();
}

class _BetaInfoScreenState extends ConsumerState<BetaInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('About UNIFY',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _sectionLabel('About'),
          _card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.unfold_more_rounded,
                            size: 26, color: context.primary),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            AppConstants.tagline,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UNIFY brings your campus together in one place. '
                    'Stay connected with your community, access academic resources, '
                    'discover events, collaborate on projects, and build your '
                    'reputation — all from a single app designed for university life.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel('App Info'),
          _card(
            child: Column(
              children: [
                _infoRow(
                  icon: Icons.info_outline_rounded,
                  iconColor: context.primary,
                  label: 'Version',
                  value: AppConstants.appVersion,
                ),
                Divider(
                    height: 1,
                    color: scheme.outlineVariant,
                    indent: 56),
                _infoRow(
                  icon: Icons.build_outlined,
                  iconColor: context.primary,
                  label: 'Build',
                  value: '${AppConstants.appBuildNumber}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel('Support'),
          _card(
            child: Column(
              children: [
                _LinkRow(
                  icon: Icons.mail_outline_rounded,
                  iconColor: context.primary,
                  label: 'Contact Support',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => _contactSupport(),
                ),
                Divider(
                    height: 1,
                    color: scheme.outlineVariant,
                    indent: 56),
                _LinkRow(
                  icon: Icons.feedback_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Send Feedback',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => context.push('/feedback'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel('Legal'),
          _card(
            child: Column(
              children: [
                _LinkRow(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF10B981),
                  label: 'Privacy Policy',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => context.push('/privacy'),
                ),
                Divider(
                    height: 1,
                    color: scheme.outlineVariant,
                    indent: 56),
                _LinkRow(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Terms of Service',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => context.push('/terms'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    if (!mounted) return;
    UnifySnackbar.info(context, 'Email us at support@unify.app');
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
