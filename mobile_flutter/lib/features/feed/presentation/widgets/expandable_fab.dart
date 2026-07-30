import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ExpandableFab extends ConsumerStatefulWidget {
  const ExpandableFab({super.key});

  @override
  ConsumerState<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends ConsumerState<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;

  late final List<Animation<double>> _scales;
  late final List<Animation<Offset>> _slides;
  late final Animation<double> _rotate;
  late final Animation<double> _bgFade;

  static const _itemCount = 6;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rotate = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _bgFade = Tween<double>(begin: 0, end: 0.45).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.1, 0.4, curve: Curves.easeOut)),
    );

    _scales = List.generate(_itemCount, (i) {
      final start = i * 0.07;
      return Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(start, start + 0.25, curve: Curves.easeOutBack)),
      );
    });

    _slides = List.generate(_itemCount, (i) {
      final start = i * 0.07;
      return Tween<Offset>(
        begin: const Offset(0, 24), end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(start, start + 0.25, curve: Curves.easeOutCubic)),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _fabItems(context);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_open)
          AnimatedBuilder(
            animation: _bgFade,
            builder: (_, __) => GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.black.withValues(alpha: _bgFade.value)),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = items.length - 1; i >= 0; i--)
              _buildAction(context, items[i], i, cs),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedBuilder(
                animation: _rotate,
                builder: (_, child) => Transform.rotate(
                  angle: _rotate.value * 3.14159,
                  child: child,
                ),
                child: Icon(
                  _open ? PhosphorIconsBold.x : PhosphorIconsBold.plus,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context, _FabOption item, int i, ColorScheme cs) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final visible = _open || _ctrl.isAnimating;
        if (!visible) return const SizedBox.shrink();
        return Opacity(
          opacity: _scales[i].value.clamp(0, 1),
          child: Transform.scale(
            scale: _scales[i].value,
            child: SlideTransition(
              position: _slides[i],
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () {
                    _toggle();
                    item.onTap(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FabOption {
  final IconData icon;
  final Color color;
  final String label;
  final void Function(BuildContext context) onTap;

  const _FabOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
}

List<_FabOption> _fabItems(BuildContext context) => [
  _FabOption(
    icon: PhosphorIconsBold.fileText,
    color: const Color(0xFF2563EB),
    label: 'Post',
    onTap: (ctx) => ctx.push('/announcement/create'),
  ),
  _FabOption(
    icon: PhosphorIconsBold.camera,
    color: const Color(0xFF06B6D4),
    label: 'Story',
    onTap: (ctx) => ctx.push('/stories/create'),
  ),
  _FabOption(
    icon: PhosphorIconsBold.chartBar,
    color: const Color(0xFF22C55E),
    label: 'Poll',
    onTap: (ctx) => ctx.push('/announcement/create'),
  ),
  _FabOption(
    icon: PhosphorIconsBold.calendar,
    color: const Color(0xFFF59E0B),
    label: 'Event',
    onTap: (ctx) => ctx.push('/events/create'),
  ),
  _FabOption(
    icon: PhosphorIconsBold.usersThree,
    color: const Color(0xFF8B5CF6),
    label: 'Group',
    onTap: (ctx) => ctx.push('/communities'),
  ),
  _FabOption(
    icon: PhosphorIconsBold.megaphone,
    color: const Color(0xFFEC4899),
    label: 'Feedback',
    onTap: (ctx) => ctx.push('/beta-info'),
  ),
];