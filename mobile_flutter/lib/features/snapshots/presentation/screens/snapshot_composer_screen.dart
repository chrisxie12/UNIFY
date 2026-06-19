import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../communities/presentation/providers/communities_provider.dart';
import '../providers/snapshots_provider.dart';

enum _SnapType { text, photo, poll, question }

const _bgColors = [
  '#1E40AF', '#0066FF', '#7C3AED', '#DB2777',
  '#DC2626', '#EA580C', '#0F766E', '#0F172A',
];

const _academicTemplates = <(String, String)>[
  ('📚 Exam Countdown', 'Exam coming up — let\'s lock in! 📚'),
  ('📝 Assignment Due', 'Assignment due soon — don\'t forget! 📝'),
  ('👥 Study Session', 'Study session today. Who\'s in? 👥'),
  ('🚀 Project Team', 'Looking for teammates for a project 🚀'),
  ('📖 Study Group', 'Join our study group this week 📖'),
];

class SnapshotComposerScreen extends ConsumerStatefulWidget {
  final String? communityId;
  const SnapshotComposerScreen({super.key, this.communityId});

  @override
  ConsumerState<SnapshotComposerScreen> createState() =>
      _SnapshotComposerScreenState();
}

class _SnapshotComposerScreenState
    extends ConsumerState<SnapshotComposerScreen> {
  _SnapType _type = _SnapType.text;
  String _bg = _bgColors.first;
  final _textCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
  final _pollQuestionCtrl = TextEditingController();
  final _pollOptions = [TextEditingController(), TextEditingController()];

  File? _photo;
  bool _posting = false;
  String? _selectedCommunityId;

  @override
  void initState() {
    super.initState();
    _selectedCommunityId = widget.communityId;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _captionCtrl.dispose();
    _pollQuestionCtrl.dispose();
    for (final c in _pollOptions) {
      c.dispose();
    }
    super.dispose();
  }

  Color _hex(String h) =>
      Color(0xFF000000 | int.parse(h.replaceFirst('#', ''), radix: 16));

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1440,
      imageQuality: 85,
    );
    if (file != null) setState(() => _photo = File(file.path));
  }

  bool get _canPost {
    switch (_type) {
      case _SnapType.text:
        return _textCtrl.text.trim().isNotEmpty;
      case _SnapType.photo:
        return _photo != null;
      case _SnapType.poll:
        return _pollQuestionCtrl.text.trim().isNotEmpty &&
            _pollOptions.where((o) => o.text.trim().isNotEmpty).length >= 2;
      case _SnapType.question:
        return _textCtrl.text.trim().isNotEmpty;
    }
  }

  Future<void> _post() async {
    if (!_canPost || _posting) return;
    final client = ref.read(supabaseProvider);
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    setState(() => _posting = true);
    final repo = ref.read(snapshotsRepositoryProvider);
    final isOfficial = ref.read(amVerifiedLeaderProvider).valueOrNull ?? false;
    final communityId = _selectedCommunityId;

    try {
      switch (_type) {
        case _SnapType.text:
          await repo.createTextSnapshot(
            authorId: uid,
            text: _textCtrl.text.trim(),
            backgroundColor: _bg,
            communityId: communityId,
            isOfficial: isOfficial,
          );
          break;
        case _SnapType.question:
          await repo.createQuestionSnapshot(
            authorId: uid,
            prompt: _textCtrl.text.trim(),
            communityId: communityId,
            isOfficial: isOfficial,
          );
          break;
        case _SnapType.poll:
          await repo.createPollSnapshot(
            authorId: uid,
            question: _pollQuestionCtrl.text.trim(),
            options: _pollOptions
                .map((o) => o.text.trim())
                .where((t) => t.isNotEmpty)
                .toList(),
            communityId: communityId,
            isOfficial: isOfficial,
          );
          break;
        case _SnapType.photo:
          final bytes = await _photo!.readAsBytes();
          final ext = _photo!.path.split('.').last;
          final url = await repo.uploadMedia(uid, bytes, ext);
          await repo.createPhotoSnapshot(
            authorId: uid,
            mediaUrl: url,
            caption: _captionCtrl.text.trim(),
            communityId: communityId,
            isOfficial: isOfficial,
          );
          break;
      }

      ref.invalidate(snapshotFeedProvider);
      if (communityId != null) {
        ref.invalidate(communitySnapshotsProvider(communityId));
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Snapshot posted — live for 24 hours'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _posting = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text('New Snapshot',
            style: TextStyle(fontWeight: FontWeight.w700, color: context.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton(
              onPressed: _canPost && !_posting ? _post : null,
              style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _posting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Share'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _typeSelector(),
          const SizedBox(height: 16),
          _audienceSelector(),
          const SizedBox(height: 16),
          _editor(),
        ],
      ),
    );
  }

  Widget _typeSelector() {
    final items = [
      (_SnapType.text, Icons.title_rounded, 'Text'),
      (_SnapType.photo, Icons.image_rounded, 'Photo'),
      (_SnapType.poll, Icons.poll_rounded, 'Poll'),
      (_SnapType.question, Icons.help_outline_rounded, 'Q&A'),
    ];
    return Row(
      children: items.map((it) {
        final active = _type == it.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = it.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? context.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: active ? context.primary : AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(it.$2,
                      size: 20,
                      color: active ? Colors.white : AppColors.grey2),
                  const SizedBox(height: 4),
                  Text(it.$3,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.grey2)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _audienceSelector() {
    // If launched from inside a community, the audience is locked.
    if (widget.communityId != null) {
      return _infoChip(Icons.groups_rounded, 'Posting to this community');
    }

    final myComms = ref.watch(myCommunitiesProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Icon(Icons.public_rounded, size: 18, color: context.primary),
          const SizedBox(width: 10),
          const Text('Audience',
              style: TextStyle(fontSize: 13, color: context.textSecondary)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedCommunityId,
              hint: const Text('Public'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Public'),
                ),
                ...myComms.maybeWhen(
                  data: (list) => list
                      .map((c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  orElse: () => const [],
                ),
              ],
              onChanged: (v) => setState(() => _selectedCommunityId = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.primary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: context.primary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _editor() {
    switch (_type) {
      case _SnapType.text:
      case _SnapType.question:
        return _textEditor();
      case _SnapType.photo:
        return _photoEditor();
      case _SnapType.poll:
        return _pollEditor();
    }
  }

  Widget _textEditor() {
    final isQuestion = _type == _SnapType.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live preview canvas
        Container(
          height: 280,
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_hex(_bg), Color.alphaBlend(Colors.black26, _hex(_bg))],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _textCtrl,
            onChanged: (_) => setState(() {}),
            maxLines: null,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.3),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isQuestion
                  ? 'Ask your question…'
                  : 'What\'s happening on campus?',
              hintStyle: const TextStyle(color: Colors.white70, fontSize: 22),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (!isQuestion) ...[
          const Text('Background',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _bgColors.map((c) {
              final active = _bg == c;
              return GestureDetector(
                onTap: () => setState(() => _bg = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _hex(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? AppColors.dark : Colors.white,
                      width: active ? 3 : 2,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Quick templates',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _academicTemplates.map((t) {
            return ActionChip(
              label: Text(t.$1, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.white,
              side: BorderSide(color: context.borderCol),
              onPressed: () {
                _textCtrl.text = t.$2;
                setState(() {});
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _photoEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.borderCol),
              image: _photo != null
                  ? DecorationImage(
                      image: FileImage(_photo!), fit: BoxFit.cover)
                  : null,
            ),
            child: _photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded,
                          size: 44, color: context.primary),
                      const SizedBox(height: 10),
                      const Text('Tap to choose a photo',
                          style: TextStyle(color: context.textSecondary)),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _captionCtrl,
          decoration: InputDecoration(
            hintText: 'Add a caption (optional)',
            filled: true,
            fillColor: context.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.borderCol),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.borderCol),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pollEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _pollQuestionCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Ask a question…',
            filled: true,
            fillColor: context.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.borderCol),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.borderCol),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_pollOptions.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pollOptions[i],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      filled: true,
                      fillColor: context.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.borderCol),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.borderCol),
                      ),
                    ),
                  ),
                ),
                if (_pollOptions.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: context.textDisabled),
                    onPressed: () => setState(() {
                      _pollOptions.removeAt(i).dispose();
                    }),
                  ),
              ],
            ),
          );
        }),
        if (_pollOptions.length < 4)
          TextButton.icon(
            onPressed: () =>
                setState(() => _pollOptions.add(TextEditingController())),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add option'),
          ),
      ],
    );
  }
}
