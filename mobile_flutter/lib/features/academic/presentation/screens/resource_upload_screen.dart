import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

class ResourceUploadScreen extends ConsumerStatefulWidget {
  final String? courseId;
  const ResourceUploadScreen({super.key, this.courseId});

  @override
  ConsumerState<ResourceUploadScreen> createState() =>
      _ResourceUploadScreenState();
}

class _ResourceUploadScreenState
    extends ConsumerState<ResourceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  ResourceType _type = ResourceType.lectureNote;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _lecturerCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  String? _courseId;
  String _semester = 'Semester 1';
  File? _image;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _courseId = widget.courseId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    _lecturerCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Upload Resource',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            _label('Resource type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ResourceType.values.map((t) {
                final sel = _type == t;
                return ChoiceChip(
                  avatar: Icon(t.icon,
                      size: 16, color: sel ? Colors.white : t.color),
                  label: Text(t.label),
                  selected: sel,
                  onSelected: (_) => setState(() => _type = t),
                  selectedColor: t.color,
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : AppColors.grey1,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Title'),
            _field(_titleCtrl, 'e.g. Database Systems — Week 4 Notes',
                validator: _required),
            const SizedBox(height: 16),
            _label('Description'),
            _field(_descCtrl, 'What does this cover?', maxLines: 3),
            const SizedBox(height: 16),

            _label('Course (optional)'),
            coursesAsync.maybeWhen(
              data: (courses) => DropdownButtonFormField<String>(
                initialValue: _courseId,
                isExpanded: true,
                decoration: _dec('Link to a course'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...courses.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.code} · ${c.title}',
                          overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) => setState(() => _courseId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // File: image upload OR link
            _label('File'),
            const Text(
                'Upload an image, or paste a link (Google Drive, etc.)',
                style: TextStyle(fontSize: 12, color: AppColors.grey2)),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _image == null
                        ? Icon(Icons.add_photo_alternate_outlined,
                            color: context.primary, size: 26)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_linkCtrl, 'https://drive.google.com/…'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Lecturer (optional)'),
            _field(_lecturerCtrl, 'e.g. Dr. Mensah'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Academic year'),
                      _field(_yearCtrl, 'e.g. 2025/26'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Semester'),
                      DropdownButtonFormField<String>(
                        initialValue: _semester,
                        decoration: _dec(),
                        items: const [
                          DropdownMenuItem(
                              value: 'Semester 1', child: Text('Semester 1')),
                          DropdownMenuItem(
                              value: 'Semester 2', child: Text('Semester 2')),
                        ],
                        onChanged: (v) => setState(() => _semester = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Upload',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 2000);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null && _linkCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add an image or a link'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    final repo = ref.read(academicRepositoryProvider);
    final ctx = ref.read(academicContextProvider).valueOrNull;

    try {
      String? fileUrl;
      String fileType = 'link';
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        final ext = _image!.path.split('.').last;
        fileUrl = await repo.uploadFile(user.id, bytes, ext);
        fileType = 'image';
      }

      await repo.createResource({
        'uploader_id': user.id,
        'university_id': ctx?.universityId,
        'department': ctx?.department,
        if (_courseId != null) 'course_id': _courseId,
        'title': _titleCtrl.text.trim(),
        'description':
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'resource_type': _type.key,
        'file_type': fileType,
        if (fileUrl != null) 'file_url': fileUrl,
        if (_linkCtrl.text.trim().isNotEmpty) 'link_url': _linkCtrl.text.trim(),
        if (_lecturerCtrl.text.trim().isNotEmpty)
          'lecturer': _lecturerCtrl.text.trim(),
        if (_yearCtrl.text.trim().isNotEmpty)
          'academic_year': _yearCtrl.text.trim(),
        'semester': _semester,
        'verification': 'student',
      });

      ref.invalidate(resourcesProvider);
      if (_courseId != null) {
        ref.invalidate(courseResourcesProvider(_courseId!));
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Resource uploaded!'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      );

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      decoration: _dec(hint),
    );
  }

  InputDecoration _dec([String? hint]) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primary, width: 1.5)),
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
