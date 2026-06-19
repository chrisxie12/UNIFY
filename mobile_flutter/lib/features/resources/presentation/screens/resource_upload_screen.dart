import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../providers/resource_provider.dart';

class ResourceUploadScreen extends ConsumerStatefulWidget {
  final String communityId;

  const ResourceUploadScreen({super.key, required this.communityId});

  @override
  ConsumerState<ResourceUploadScreen> createState() => _ResourceUploadScreenState();
}

class _ResourceUploadScreenState extends ConsumerState<ResourceUploadScreen> {
  final _titleController = TextEditingController();
  String _resourceType = 'lecture_note';
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0;

  final List<_ResourceTypeOption> _resourceTypes = [
    const _ResourceTypeOption('lecture_note', 'Lecture Notes', Icons.menu_book),
    const _ResourceTypeOption('past_question', 'Past Questions', Icons.quiz),
    const _ResourceTypeOption('assignment', 'Assignments', Icons.assignment),
    const _ResourceTypeOption('project', 'Projects', Icons.folder_special),
    const _ResourceTypeOption('textbook', 'Textbooks', Icons.book),
    const _ResourceTypeOption('study_guide', 'Study Guides', Icons.lightbulb),
    const _ResourceTypeOption('tutorial', 'Tutorials', Icons.school),
    const _ResourceTypeOption('document', 'Documents', Icons.description),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _isValid => _titleController.text.trim().isNotEmpty && _selectedFile != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Resource'),
        actions: [
          TextButton(
            onPressed: _isValid && !_isUploading ? _uploadResource : null,
            child: _isUploading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Upload',
                    style: TextStyle(
                      color: _isValid ? Theme.of(context).colorScheme.primary : Colors.grey[400],
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
                hintText: 'Resource title',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Resource Type',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _resourceType,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _resourceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type.id,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 20, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(type.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _resourceType = v);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'File',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null ? Theme.of(context).colorScheme.primary : Colors.grey[200]!,
                    width: _selectedFile != null ? 1.5 : 1,
                  ),
                ),
                child: _selectedFile != null
                    ? Column(
                        children: [
                          Icon(
                            _fileIcon(_selectedFile!.extension ?? ''),
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFile!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatFileSize(_selectedFile!.size),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(() => _selectedFile = null),
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[400],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to select a file',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDF, DOCX, PPT, Images, ZIP',
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ),
              ),
            ),
            if (_isUploading) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _uploadResource() async {
    if (!_isValid || _isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final bytes = _selectedFile!.bytes ?? await File(_selectedFile!.path!).readAsBytes();
      final ext = _selectedFile!.extension ?? 'bin';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'community_resources/${widget.communityId}/$fileName';

      await supabase.storage.from('resources').uploadBinary(
        storagePath,
        bytes,
        fileOptions: FileOptions(contentType: _mimeType(ext)),
      );

      _uploadProgress = 0.7;
      if (mounted) setState(() {});

      final fileUrl = supabase.storage.from('resources').getPublicUrl(storagePath);

      await supabase.from('community_resources').insert({
        'community_id': widget.communityId,
        'uploader_id': userId,
        'title': _titleController.text.trim(),
        'file_type': ext,
        'file_url': fileUrl,
        'file_size': bytes.length,
        'resource_type': _resourceType,
      });

      _uploadProgress = 1.0;
      if (mounted) setState(() {});

      ref.invalidate(communityResourcesProvider(widget.communityId));

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt': return 'application/vnd.ms-powerpoint';
      case 'pptx': return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'zip': return 'application/zip';
      case 'mp4': return 'video/mp4';
      default: return 'application/octet-stream';
    }
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'jpg': case 'jpeg': case 'png': return Icons.image;
      case 'zip': case 'rar': return Icons.folder_zip;
      case 'mp4': return Icons.videocam;
      default: return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}

class _ResourceTypeOption {
  final String id;
  final String label;
  final IconData icon;

  const _ResourceTypeOption(this.id, this.label, this.icon);
}
