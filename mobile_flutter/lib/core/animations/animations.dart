import 'package:flutter/material.dart';
import '../design/design_tokens.dart';

class FadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset offset;

  const FadeSlideTransition({
    super.key,
    required this.animation,
    required this.child,
    this.offset = const Offset(0, 20),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: offset * (1 - t),
            child: child,
          ),
        );
      },
    );
  }
}

class ScaleBounce extends StatefulWidget {
  final Widget child;
  final bool active;
  final double from;
  final double to;

  const ScaleBounce({
    super.key,
    required this.child,
    this.active = true,
    this.from = 0.8,
    this.to = 1.0,
  });

  @override
  State<ScaleBounce> createState() => _ScaleBounceState();
}

class _ScaleBounceState extends State<ScaleBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: UnifyAnim.slow,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    if (widget.active) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ScaleBounce old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Transform.scale(
          scale: widget.from + (widget.to - widget.from) * _anim.value,
          child: widget.child,
        );
      },
    );
  }
}

class StaggeredListEntrance extends StatelessWidget {
  final AnimationController controller;
  final List<Widget> children;
  final double itemDelay;

  const StaggeredListEntrance({
    super.key,
    required this.controller,
    required this.children,
    this.itemDelay = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = ((controller.value - (i * itemDelay)) / 0.4)
                .clamp(0.0, 1.0);
            final curveT = Curves.easeOutCubic.transform(t);
            return Opacity(
              opacity: curveT,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - curveT)),
                child: children[i],
              ),
            );
          },
        );
      }),
    );
  }
}
