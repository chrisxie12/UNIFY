import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/snapshot_provider.dart';

class StoryCreateScreen extends ConsumerStatefulWidget {
  const StoryCreateScreen({super.key});

  @override
  ConsumerState<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends ConsumerState<StoryCreateScreen> {
  final _textCtrl = TextEditingController();
  bool _isText = true;
  File? _imageFile;
  Color _bgColor = const Color(0xFF1E40AF);
  bool _uploading = false;

  static const _bgColors = [
    Color(0xFF1E40AF),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
    Color(0xFF111827),
  ];

  static String _colorHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _imageFile = File(file.path);
      _isText = false;
    });
  }

  Future<void> _post() async {
    if (_uploading) return;
    if (_isText && _textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something for your story.')),
      );
      return;
    }
    if (!_isText && _imageFile == null) return;

    setState(() => _uploading = true);
    bool ok;
    if (_isText) {
      ok = await ref.read(storyGroupsProvider.notifier).createTextStory(
            text: _textCtrl.text.trim(),
            backgroundColor: _colorHex(_bgColor),
          );
    } else {
      ok = await ref.read(storyGroupsProvider.notifier).createPhotoStory(
            imageFile: _imageFile!,
          );
    }
    if (!mounted) return;
    setState(() => _uploading = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not post story. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('New Story', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _uploading ? null : _post,
            child: _uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Mode selector ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _ModeChip(
                    label: 'Text',
                    icon: Icons.text_fields_rounded,
                    selected: _isText,
                    onTap: () => setState(() => _isText = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeChip(
                    label: 'Photo',
                    icon: Icons.photo_outlined,
                    selected: !_isText,
                    onTap: _pickImage,
                  ),
                ),
              ],
            ),
          ),

          // ── Preview ───────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isText ? _TextPreview(bgColor: _bgColor, ctrl: _textCtrl) : _PhotoPreview(file: _imageFile),
              ),
            ),
          ),

          // ── Color picker (text mode only) ─────────────────────────────────
          if (_isText)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _bgColors.map((c) {
                  final selected = c == _bgColor;
                  return GestureDetector(
                    onTap: () => setState(() => _bgColor = c),
                    child: Container(
                      width: selected ? 36 : 28,
                      height: selected ? 36 : 28,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(color: Colors.white30, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.black : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextPreview extends StatelessWidget {
  const _TextPreview({required this.bgColor, required this.ctrl});

  final Color bgColor;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bgColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLines: null,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.4),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Type something…',
          hintStyle: TextStyle(color: Colors.white54, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        cursorColor: Colors.white,
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({this.file});

  final File? file;

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return GestureDetector(
        child: Container(
          color: Colors.white12,
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.white54),
              SizedBox(height: 8),
              Text('Tap to pick a photo', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    return Image.file(file!, fit: BoxFit.cover, width: double.infinity);
  }
}
