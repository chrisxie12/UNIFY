import 'package:flutter/material.dart';
import '../../../../core/extensions/theme_extensions.dart';

/// Animated 3-dot typing indicator (Telegram style).
/// Dots bounce vertically with a staggered 200 ms offset.
class TypingIndicator extends StatefulWidget {
  final Color? color;
  const TypingIndicator({super.key, this.color});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? context.textSecondary;
    return SizedBox(
      width: 30,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (i) => _Dot(ctrl: _ctrl, index: i, color: dotColor)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController ctrl;
  final int index;
  final Color color;

  const _Dot({required this.ctrl, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    // Each dot starts its bounce 200 ms later than the previous.
    final offsetFraction = index * 0.22;
    final animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -5.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -5.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(
          offsetFraction,
          (offsetFraction + 0.6).clamp(0.0, 1.0),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, animation.value),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// Shows a human-readable "typing..." status line beneath a chat header.
class TypingStatusText extends StatelessWidget {
  final int typingCount;

  const TypingStatusText({super.key, required this.typingCount});

  @override
  Widget build(BuildContext context) {
    assert(typingCount > 0);
    final label = typingCount == 1
        ? 'typing...'
        : '$typingCount people typing...';
    return Text(
      label,
      style: TextStyle(fontSize: 11, color: context.primary, fontStyle: FontStyle.italic),
    );
  }
}
