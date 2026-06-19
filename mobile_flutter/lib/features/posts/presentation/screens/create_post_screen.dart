import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../providers/post_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CreatePostScreen({super.key, required this.communityId});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _postType = 'text';
  File? _selectedImage;
  final _linkController = TextEditingController();
  bool _isSubmitting = false;

  final List<_PostTypeOption> _postTypes = [
    const _PostTypeOption('text', Icons.text_fields, 'Text'),
    const _PostTypeOption('image', Icons.image, 'Image'),
    const _PostTypeOption('link', Icons.link, 'Link'),
    const _PostTypeOption('poll', Icons.poll, 'Poll'),
    const _PostTypeOption('question', Icons.help_outline, 'Question'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  bool get _hasContent => _bodyController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _hasContent && !_isSubmitting ? _submitPost : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: _hasContent ? Theme.of(context).colorScheme.primary : Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title (optional)',
                hintStyle: TextStyle(color: context.textSecondary, fontSize: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: context.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15, height: 1.5),
              maxLines: 8,
              minLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Post type',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _postTypes.map((type) {
                  final selected = _postType == type.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (type.id == 'poll') {
                          context.push('/communities/${widget.communityId}/create-poll');
                          return;
                        }
                        if (type.id == 'image') {
                          _pickImage();
                        }
                        setState(() => _postType = type.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type.icon,
                              size: 18,
                              color: selected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (_postType == 'image' && _selectedImage != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.textSecondary),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.textPrimary.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_postType == 'link') ...[
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'https://',
                  hintStyle: TextStyle(color: context.textSecondary),
                  prefixIcon: Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.textSecondary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.textSecondary),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitPost() async {
    if (!_hasContent || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      String? mediaUrl;
      if (_selectedImage != null) {
        final ext = _selectedImage!.path.split('.').last;
        final path = 'post_images/${widget.communityId}/${DateTime.now().millisecondsSinceEpoch}.$ext';
        await supabase.storage.from('post-images').upload(path, _selectedImage!);
        mediaUrl = supabase.storage.from('post-images').getPublicUrl(path);
      }

      await supabase.from('community_posts').insert({
        'community_id': widget.communityId,
        'author_id': userId,
        if (_titleController.text.trim().isNotEmpty) 'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'post_type': _postType,
        if (mediaUrl != null) 'media_url': mediaUrl,
        if (_linkController.text.trim().isNotEmpty) 'link_url': _linkController.text.trim(),
      });

      ref.invalidate(communityPostsProvider(widget.communityId));

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _PostTypeOption {
  final String id;
  final IconData icon;
  final String label;

  const _PostTypeOption(this.id, this.icon, this.label);
}
