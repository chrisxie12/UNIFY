import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _accentBlue    = Color(0xFF00D4FF);
const _accentPurple  = Color(0xFF7C3AED);
const _textMuted     = Color(0xFF5A5A6E);
const _shimmerBase   = Color(0xFF1A1A2E);
const _shimmerHigh   = Color(0xFF2A2A3E);

// ── Loading skeleton for chat messages ────────────────────────────────────────

class ChatLoadingSkeleton extends StatefulWidget {
  const ChatLoadingSkeleton({super.key});

  @override
  State<ChatLoadingSkeleton> createState() => _ChatLoadingSkeletonState();
}

class _ChatLoadingSkeletonState extends State<ChatLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final highlight = Color.lerp(_shimmerBase, _shimmerHigh, _shimmer.value)!;
        return ListView(
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 64,
            bottom: 16,
          ),
          children: [
            _SkeletonGroup(highlight: highlight, align: Alignment.centerLeft, widths: const [220, 180]),
            _SkeletonGroup(highlight: highlight, align: Alignment.centerRight, widths: const [160], isMe: true),
            _SkeletonGroup(highlight: highlight, align: Alignment.centerLeft, widths: const [200, 240, 140]),
            _SkeletonGroup(highlight: highlight, align: Alignment.centerRight, widths: const [180, 120], isMe: true),
          ],
        );
      },
    );
  }
}

class _SkeletonGroup extends StatelessWidget {
  const _SkeletonGroup({
    required this.highlight,
    required this.align,
    required this.widths,
    this.isMe = false,
  });

  final Color highlight;
  final Alignment align;
  final List<double> widths;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 4),
              child: Text(
                'YAA DEBBY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _accentBlue,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ...widths.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe && e.key == 0) ...[
                  // Colored square placeholder avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _accentPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (!isMe) ...[
                  const SizedBox(width: 40),
                ],
                Container(
                  width: e.value,
                  height: 40,
                  decoration: BoxDecoration(
                    color: highlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Text(
                        'Loading ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _textMuted,
                        ),
                      ),
                      _PulsingDots(),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final opacity = ((_ctrl.value - i / 3 + 1) % 1).clamp(0.2, 1.0);
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Opacity(
              opacity: opacity,
              child: Text(
                '.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textMuted,
                  height: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
