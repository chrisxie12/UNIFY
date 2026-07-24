import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/theme_picker_sheet.dart';

/// App settings — appearance (light / dark / system + colour theme) and
/// quick links to account-related screens. Built entirely from the active
/// [Theme] so it renders correctly in both light and dark mode.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final preset = ref.watch(themeNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _sectionLabel(context, 'Appearance'),
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text('Theme mode',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: Row(
                    children: [
                      _ModeOption(
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                        selected: mode == ThemeMode.system,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.system),
                      ),
                      const SizedBox(width: 10),
                      _ModeOption(
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        selected: mode == ThemeMode.light,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 10),
                      _ModeOption(
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                        selected: mode == ThemeMode.dark,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant, indent: 16),
                _LinkRow(
                  icon: Icons.palette_outlined,
                  iconColor: preset.primary,
                  label: 'Colour theme',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${preset.emoji}  ${preset.name}',
                          style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded,
                          color: scheme.onSurface.withValues(alpha: 0.4)),
                    ],
                  ),
                  onTap: () => ThemePickerSheet.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel(context, 'Account'),
          _card(
            context,
            child: Column(
              children: [
                _LinkRow(
                  icon: Icons.edit_outlined,
                  iconColor: context.primary,
                  label: 'Edit profile',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => context.push('/app/profile/edit'),
                ),
                Divider(height: 1, color: scheme.outlineVariant, indent: 56),
                _LinkRow(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  label: 'Privacy',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => context.push('/app/profile/privacy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel(context, 'About'),
          _card(
            context,
            child: Column(
              children: [
                _LinkRow(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF6366F1),
                  label: 'About UNIFY',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.4)),
                  onTap: () => context.push('/beta-info'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );

  Widget _card(BuildContext context, {required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: child,
    );
  }
}

class _ModeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.12)
                : scheme.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 24,
                  color: selected
                      ? primary
                      : scheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? primary
                      : scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
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
