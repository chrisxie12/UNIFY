import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';

class AcademicHubScreen extends ConsumerWidget {
  const AcademicHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _pins(context);
    final left = [items[0], items[2], items[4], items[6]];
    final right = [items[1], items[3], items[5], items[7]];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/academic/search'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(USpacing.base, USpacing.sm, USpacing.base, USpacing.x3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  left[0],
                  const SizedBox(height: USpacing.md),
                  left[1],
                  const SizedBox(height: USpacing.md),
                  left[2],
                  const SizedBox(height: USpacing.md),
                  left[3],
                ],
              ),
            ),
            const SizedBox(width: USpacing.md),
            Expanded(
              child: Column(
                children: [
                  right[0],
                  const SizedBox(height: USpacing.md),
                  right[1],
                  const SizedBox(height: USpacing.md),
                  right[2],
                  const SizedBox(height: USpacing.md),
                  right[3],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _pins(BuildContext context) => [
    _Pin.tall(
      context: context,
      icon: Icons.school,
      label: 'Courses',
      gradientColors: [context.success, context.success.withValues(alpha: 0.7)],
      onTap: () => context.push('/academic/courses'),
      child: Text('5 enrolled', style: UText.caption.copyWith(color: context.textSecondary)),
    ),
    _Pin.short(
      context: context,
      icon: Icons.library_books,
      label: 'Notes',
      color: context.primary,
      onTap: () => context.push('/academic/resources', extra: {'type': 'note'}),
    ),
    _Pin.tall(
      context: context,
      icon: Icons.assignment,
      label: 'Assignments',
      gradientColors: [context.warning, context.warning.withValues(alpha: 0.7)],
      onTap: () => context.push('/academic/assignments'),
      badge: '3 pending',
    ),
    _Pin.short(
      context: context,
      icon: Icons.quiz_outlined,
      label: 'Past Questions',
      color: context.info,
      onTap: () => context.push('/academic/resources', extra: {'type': 'past_question'}),
    ),
    _Pin.tall(
      context: context,
      icon: Icons.calculate,
      label: 'GPA',
      gradientColors: [context.primary, context.primary.withValues(alpha: 0.7)],
      onTap: () => context.push('/academic/gpa'),
      child: _GpaRing(),
    ),
    _Pin.short(
      context: context,
      icon: Icons.event_note,
      label: 'Exam Prep',
      color: context.error,
      onTap: () => context.push('/academic/exams'),
    ),
    _Pin.tall(
      context: context,
      icon: Icons.calendar_month,
      label: 'Study Planner',
      gradientColors: [context.info, context.info.withValues(alpha: 0.7)],
      onTap: () => context.push('/academic/planner'),
      child: Text('2 plans active', style: UText.caption.copyWith(color: context.textSecondary)),
    ),
    _Pin.short(
      context: context,
      icon: Icons.star,
      label: 'Top Resources',
      color: context.warning,
      onTap: () => context.push('/academic/resources', extra: {'type': null}),
    ),
  ];
}

// ── Pinterest-style pin card ─────────────────────────────────────────────────────

class _Pin extends StatelessWidget {
  final double height;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final Widget? child;
  final String? badge;
  final Color? color;

  const _Pin._({
    required this.height,
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradientColors,
    this.child,
    this.badge,
    this.color,
  });

  factory _Pin.tall({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    String? badge,
    Widget? child,
  }) => _Pin._(
    height: 200,
    icon: icon,
    label: label,
    onTap: onTap,
    gradientColors: gradientColors,
    badge: badge,
    child: child,
  );

  factory _Pin.short({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) => _Pin._(
    height: 110,
    icon: icon,
    label: label,
    onTap: onTap,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBg,
      borderRadius: BorderRadius.circular(URadius.md),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(URadius.md),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(URadius.md),
            border: Border.all(color: context.borderCol.withValues(alpha: 0.4)),
          ),
          clipBehavior: Clip.antiAlias,
          child: gradientColors != null
              ? _TallBody(
                  icon: icon,
                  label: label,
                  gradientColors: gradientColors!,
                  badge: badge,
                  child: child,
                )
              : _ShortBody(
                  icon: icon,
                  label: label,
                  color: color!,
                ),
        ),
      ),
    );
  }
}

class _TallBody extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final String? badge;
  final Widget? child;

  const _TallBody({
    required this.icon,
    required this.label,
    required this.gradientColors,
    this.badge,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: USpacing.md,
                  left: USpacing.md,
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                if (badge != null)
                  Positioned(
                    top: USpacing.md,
                    right: USpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(URadius.pill),
                      ),
                      child: Text(badge!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(USpacing.md, USpacing.sm, USpacing.md, USpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: UText.h4.copyWith(color: context.textPrimary)),
                if (child != null) ...[
                  const SizedBox(height: 4),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortBody extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ShortBody({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: USpacing.md),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(URadius.md),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: USpacing.md),
        Expanded(
          child: Text(label,
              style: UText.h4.copyWith(color: context.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        Icon(Icons.chevron_right, size: 18, color: context.textDisabled),
        const SizedBox(width: USpacing.sm),
      ],
    );
  }
}

// ── GPA mini ring ────────────────────────────────────────────────────────────────

class _GpaRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: 3.6 / 4.0,
                  strokeWidth: 3,
                  color: context.primary,
                  backgroundColor: context.borderCol.withValues(alpha: 0.3),
                ),
              ),
              Text('3.6', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.primary)),
            ],
          ),
        ),
        const SizedBox(width: USpacing.sm),
        Text('CGPA', style: UText.caption.copyWith(color: context.textSecondary)),
      ],
    );
  }
}
