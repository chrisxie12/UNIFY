import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/snapshot_models.dart';
import '../providers/snapshots_provider.dart';
import '../widgets/snapshot_analytics_sheet.dart';
import '../../../../core/extensions/theme_extensions.dart';

const _reactionEmojis = ['👍', '🔥', '😂', '👏', '❤️', '🎉'];

String leadershipLabel(String? role) {
  switch (role) {
    case 'class_representative':
    case 'class_rep':
      return 'Course Rep';
    case 'assistant_class_rep':
      return 'Assistant Rep';
    case 'department_rep':
      return 'Dept. Rep';
    case 'src_executive':
      return 'SRC Executive';
    case 'hall_rep':
      return 'Hall Rep';
    case 'club_executive':
      return 'Club Executive';
    case 'administrator':
    case 'admin':
      return 'Administrator';
    default:
      return 'Verified Leader';
  }
}

class SnapshotViewerScreen extends ConsumerStatefulWidget {
  final List<SnapshotGroup> groups;
  final int startGroupIndex;

  const SnapshotViewerScreen({
    super.key,
    required this.groups,
    this.startGroupIndex = 0,
  });

  @override
  ConsumerState<SnapshotViewerScreen> createState() =>
      _SnapshotViewerScreenState();
}

class _SnapshotViewerScreenState extends ConsumerState<SnapshotViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _groupIndex;
  int _snapIndex = 0;
  late final AnimationController _progress;

  final _replyCtrl = TextEditingController();
  final _replyFocus = FocusNode();
  bool _paused = false;
  String? _myReaction;
  String? _myPollVote;

  SnapshotGroup get _group => widget.groups[_groupIndex];
  SnapshotModel get _snap => _group.snapshots[_snapIndex];

  String? get _supabaseUserId =>
      ref.read(supabaseProvider).auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.startGroupIndex;
    _progress = AnimationController(vsync: this)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      });
    _replyFocus.addListener(() {
      if (_replyFocus.hasFocus) {
        _pause();
      } else {
        _resume();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrent());
  }

  @override
  void dispose() {
    _progress.dispose();
    _replyCtrl.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  Duration get _duration => _snap.type == 'photo' || _snap.type == 'video'
      ? const Duration(seconds: 5)
      : const Duration(seconds: 7);

  Future<void> _loadCurrent() async {
    _progress.stop();
    _progress.duration = _duration;
    _progress.value = 0;
    setState(() {
      _myReaction = null;
      _myPollVote = null;
    });

    final uid = _supabaseUserId;
    final repo = ref.read(snapshotsRepositoryProvider);
    if (uid != null) {
      repo.recordView(_snap.id, uid);
      final react = await repo.myReaction(_snap.id, uid);
      final vote = _snap.isPoll ? await repo.myPollVote(_snap.id, uid) : null;
      if (mounted) {
        setState(() {
          _myReaction = react;
          _myPollVote = vote;
        });
      }
    }
    if (!_paused && mounted) _progress.forward();
  }

  void _next() {
    if (_snapIndex < _group.snapshots.length - 1) {
      setState(() => _snapIndex++);
      _loadCurrent();
    } else if (_groupIndex < widget.groups.length - 1) {
      setState(() {
        _groupIndex++;
        _snapIndex = 0;
      });
      _loadCurrent();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _prev() {
    if (_snapIndex > 0) {
      setState(() => _snapIndex--);
      _loadCurrent();
    } else if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _snapIndex = widget.groups[_groupIndex].snapshots.length - 1;
      });
      _loadCurrent();
    } else {
      // Restart current
      _loadCurrent();
    }
  }

  void _pause() {
    _paused = true;
    _progress.stop();
  }

  void _resume() {
    _paused = false;
    if (!_progress.isAnimating && _progress.value < 1.0) {
      _progress.forward();
    }
  }

  Future<void> _react(String emoji) async {
    final uid = _supabaseUserId;
    if (uid == null) return;
    final result = await ref
        .read(snapshotsRepositoryProvider)
        .toggleReaction(_snap.id, uid, emoji);
    if (mounted) setState(() => _myReaction = result);
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    final uid = _supabaseUserId;
    if (uid == null) return;
    _replyCtrl.clear();
    _replyFocus.unfocus();
    await ref.read(snapshotsRepositoryProvider).sendReply(
          snapshotId: _snap.id,
          senderId: uid,
          recipientId: _snap.authorId,
          body: text,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reply sent to ${_snap.authorName ?? 'author'}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _votePoll(SnapshotPollOption option) async {
    final uid = _supabaseUserId;
    if (uid == null || _myPollVote != null) return;
    setState(() => _myPollVote = option.id);
    await ref.read(snapshotsRepositoryProvider).votePoll(
          snapshotId: _snap.id,
          optionId: option.id,
          userId: uid,
        );
  }

  void _openMenu() {
    _pause();
    final uid = _supabaseUserId;
    final isOwn = uid != null && uid == _snap.authorId;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwn) ...[
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                title: const Text('View insights'),
                onTap: () {
                  Navigator.pop(context);
                  _showAnalytics();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: const Text('Delete snapshot'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(snapshotsRepositoryProvider)
                      .deleteSnapshot(_snap.id);
                  if (mounted) _next();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.warning),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _reportFlow();
                },
              ),
              ListTile(
                leading: Icon(Icons.volume_off_rounded, color: context.textPrimary),
                title: Text('Mute ${_snap.authorName ?? 'this user'}'),
                onTap: () async {
                  Navigator.pop(context);
                  if (uid != null) {
                    await ref
                        .read(snapshotsRepositoryProvider)
                        .muteAuthor(uid, _snap.authorId);
                  }
                  if (mounted) Navigator.of(context).maybePop();
                },
              ),
            ],
          ],
        ),
      ),
    ).whenComplete(_resume);
  }

  void _reportFlow() {
    _pause();
    const reasons = [
      'Spam or misleading',
      'Harassment or bullying',
      'Inappropriate content',
      'False information',
      'Other',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Report snapshot',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final r in reasons)
              ListTile(
                title: Text(r),
                onTap: () async {
                  Navigator.pop(context);
                  final uid = _supabaseUserId;
                  if (uid != null) {
                    await ref.read(snapshotsRepositoryProvider).reportSnapshot(
                          snapshotId: _snap.id,
                          reporterId: uid,
                          reason: r,
                        );
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thanks — our team will review this.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    ).whenComplete(_resume);
  }

  void _showAnalytics() {
    _pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SnapshotAnalyticsSheet(snapshotId: _snap.id),
    ).whenComplete(_resume);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTapUp: (d) {
          final w = media.size.width;
          if (d.globalPosition.dx < w * 0.33) {
            _prev();
          } else {
            _next();
          }
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 200) Navigator.of(context).maybePop();
        },
        child: Stack(
          children: [
            Positioned.fill(child: _content()),

            // Progress bars
            Positioned(
              top: media.padding.top + 8,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(_group.snapshots.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _ProgressSegment(
                        controller: _progress,
                        state: i < _snapIndex
                            ? 1
                            : i == _snapIndex
                                ? 2
                                : 0,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Header
            Positioned(
              top: media.padding.top + 22,
              left: 12,
              right: 8,
              child: _header(),
            ),

            // Bottom interaction bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _bottomBar(media),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: ClipOval(
            child: _group.authorAvatar != null && _group.authorAvatar!.isNotEmpty
                ? CachedNetworkImage(imageUrl: _group.authorAvatar!, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      _group.initials,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _group.authorName ?? 'Campus',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_group.isOfficial) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: Colors.white, size: 15),
                  ],
                ],
              ),
              Row(
                children: [
                  if (_group.isOfficial) ...[
                    Text(
                      leadershipLabel(_group.authorLeadershipRole),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const Text(' · ', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                  Text(
                    timeago.format(_snap.createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
          onPressed: _openMenu,
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _content() {
    final snap = _snap;
    if (snap.type == 'photo' || snap.type == 'video') {
      return Container(
        color: context.textPrimary,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            if (snap.hasMedia)
              Center(
                child: CachedNetworkImage(
                  imageUrl: snap.mediaUrl!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            if (snap.type == 'video')
              const Center(
                child: Icon(Icons.play_circle_outline_rounded,
                    color: Colors.white70, size: 64),
              ),
            if (snap.caption != null && snap.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.textSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    snap.caption!,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // text / poll / question — colored canvas
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [snap.bgColor, Color.alphaBlend(Colors.black26, snap.bgColor)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 120, 28, 150),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snap.isQuestion)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('❓ Ask me anything',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              Text(
                snap.textContent ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: snap.isText ? 26 : 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (snap.isPoll) ...[
                const SizedBox(height: 28),
                ..._snap.pollOptions.map(_pollOption),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _pollOption(SnapshotPollOption option) {
    final voted = _myPollVote != null;
    final isMine = _myPollVote == option.id;
    // Optimistically add the local vote to both numerator and denominator.
    final count = option.voteCount + (isMine ? 1 : 0);
    final total = _snap.totalPollVotes + (voted ? 1 : 0);
    final pct = total <= 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: voted ? null : () => _votePoll(option),
        child: Stack(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isMine ? Colors.white : Colors.white38,
                  width: isMine ? 2 : 1,
                ),
              ),
            ),
            if (voted)
              FractionallySizedBox(
                widthFactor: pct.clamp(0.0, 1.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.cardBg.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (voted)
                      Text('${(pct * 100).round()}%',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(MediaQueryData media) {
    final isOwn = _supabaseUserId == _snap.authorId;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, media.padding.bottom + 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
      child: isOwn
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statPill(Icons.remove_red_eye_rounded, '${_snap.viewCount}'),
                const SizedBox(width: 10),
                _statPill(Icons.favorite_rounded, '${_snap.reactionCount}'),
                const SizedBox(width: 10),
                _statPill(Icons.reply_rounded, '${_snap.replyCount}'),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showAnalytics,
                  child: _statPill(Icons.bar_chart_rounded, 'Insights'),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _reactionEmojis.map((e) {
                    final selected = _myReaction == e;
                    return GestureDetector(
                      onTap: () => _react(e),
                      child: AnimatedScale(
                        scale: selected ? 1.35 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Reply field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyCtrl,
                        focusNode: _replyFocus,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendReply(),
                        decoration: InputDecoration(
                          hintText: _snap.isQuestion
                              ? 'Type your answer…'
                              : 'Reply to ${_snap.authorName?.split(' ').first ?? 'story'}…',
                          hintStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: context.inputFill.withValues(alpha: 0.15),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: context.cardBg),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _sendReply,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _statPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Progress segment ─────────────────────────────────────────

class _ProgressSegment extends StatelessWidget {
  final AnimationController controller;
  final int state; // 0 = empty, 1 = full, 2 = animating
  const _ProgressSegment({required this.controller, required this.state});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: Stack(
          children: [
            Container(color: Colors.white38),
            if (state == 1)
              Container(color: context.cardBg)
            else if (state == 2)
              AnimatedBuilder(
                animation: controller,
                builder: (_, __) => FractionallySizedBox(
                  widthFactor: controller.value,
                  alignment: Alignment.centerLeft,
                  child: Container(color: context.cardBg),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
