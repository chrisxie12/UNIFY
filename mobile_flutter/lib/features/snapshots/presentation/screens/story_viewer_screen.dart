import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/snapshot_models.dart';
import '../providers/snapshot_provider.dart';

/// Full-screen Instagram-style story viewer.
///
/// Accepts `groups` (list of SnapshotGroup) and `initialGroupIndex` via
/// GoRouter's `extra` parameter (as a Map):
///   context.push('/stories/view', extra: {
///     'groups': groups,
///     'index': groupIndex,
///   });
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({super.key, required this.groups, required this.initialGroupIndex});

  final List<SnapshotGroup> groups;
  final int initialGroupIndex;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late int _groupIndex;
  int _storyIndex = 0;
  Timer? _timer;
  late AnimationController _progressAnim;
  static const _duration = Duration(seconds: 5);

  SnapshotGroup get _group => widget.groups[_groupIndex];
  SnapshotModel get _current => _group.snapshots[_storyIndex];

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroupIndex;
    _pageCtrl = PageController(initialPage: _groupIndex);
    _progressAnim = AnimationController(vsync: this, duration: _duration);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnim.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progressAnim.reset();
    _markViewed();
    _progressAnim.forward();
    _timer = Timer(_duration, _nextStory);
  }

  void _markViewed() {
    ref.read(storyGroupsProvider.notifier).markViewed(_current.id);
  }

  void _nextStory() {
    if (_storyIndex < _group.snapshots.length - 1) {
      setState(() => _storyIndex++);
      _startTimer();
    } else {
      _nextGroup();
    }
  }

  void _prevStory() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _startTimer();
    } else {
      _prevGroup();
    }
  }

  void _nextGroup() {
    if (_groupIndex < widget.groups.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _prevGroup() {
    if (_groupIndex > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onGroupChanged(int index) {
    setState(() {
      _groupIndex = index;
      _storyIndex = 0;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageCtrl,
        onPageChanged: _onGroupChanged,
        itemCount: widget.groups.length,
        itemBuilder: (_, gi) {
          final group = widget.groups[gi];
          final storyIdx = gi == _groupIndex ? _storyIndex : 0;
          final story = group.snapshots[storyIdx];
          return _StoryPage(
            group: group,
            story: story,
            storyIndex: storyIdx,
            progressAnim: gi == _groupIndex ? _progressAnim : null,
            onTapLeft: _prevStory,
            onTapRight: _nextStory,
            onClose: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  const _StoryPage({
    required this.group,
    required this.story,
    required this.storyIndex,
    required this.progressAnim,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onClose,
  });

  final SnapshotGroup group;
  final SnapshotModel story;
  final int storyIndex;
  final AnimationController? progressAnim;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Story content ────────────────────────────────────────────────
        _StoryContent(story: story),

        // ── Tap zones ────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(child: GestureDetector(onTap: onTapLeft, behavior: HitTestBehavior.opaque)),
            Expanded(child: GestureDetector(onTap: onTapRight, behavior: HitTestBehavior.opaque)),
          ],
        ),

        // ── Header overlay ───────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Column(
              children: [
                // Progress bars
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: List.generate(group.snapshots.length, (i) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _ProgressBar(
                            anim: i == storyIndex ? progressAnim : null,
                            isFilled: i < storyIndex,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Author info + close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: group.authorAvatar != null
                              ? CachedNetworkImage(
                                  imageUrl: group.authorAvatar!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.blueAccent,
                                  alignment: Alignment.center,
                                  child: Text(
                                    group.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.authorName ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                shadows: [Shadow(blurRadius: 4)],
                              ),
                            ),
                            Text(
                              _timeAgo(story.createdAt),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                shadows: [Shadow(blurRadius: 4)],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Caption overlay ──────────────────────────────────────────────
        if (story.caption != null && story.caption!.isNotEmpty)
          Positioned(
            bottom: 60,
            left: 16,
            right: 16,
            child: Text(
              story.caption!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 8)],
              ),
            ),
          ),
      ],
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent({required this.story});

  final SnapshotModel story;

  @override
  Widget build(BuildContext context) {
    if (story.hasMedia) {
      return CachedNetworkImage(
        imageUrl: story.mediaUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.black),
        errorWidget: (_, __, ___) => _TextContent(story: story),
      );
    }
    return _TextContent(story: story);
  }
}

class _TextContent extends StatelessWidget {
  const _TextContent({required this.story});

  final SnapshotModel story;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: story.bgColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        story.textContent ?? story.caption ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.4,
          shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({this.anim, required this.isFilled});

  final AnimationController? anim;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: anim != null
          ? AnimatedBuilder(
              animation: anim!,
              builder: (_, __) => LinearProgressIndicator(
                value: anim!.value,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 2,
              ),
            )
          : LinearProgressIndicator(
              value: isFilled ? 1.0 : 0.0,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 2,
            ),
    );
  }
}
