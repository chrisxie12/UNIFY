import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/errors/error_mapper.dart';
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

  String _type = 'lecture_note';
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _lecturerCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  String? _courseId;
  String _semester = 'Semester 1';
  File? _image;
  bool _busy = false;

  static const _types = [
    ('lecture_note', 'Lecture Note', Icons.article_rounded, AppColors.primary),
    ('past_question', 'Past Question', Icons.quiz_rounded, AppColors.warning),
    ('study_guide', 'Study Guide', Icons.menu_book_rounded, AppColors.success),
    ('textbook', 'Textbook', Icons.book_rounded, AppColors.info),
    ('video', 'Video', Icons.play_circle_rounded, AppColors.error),
    ('reference', 'Reference', Icons.link_rounded, AppColors.catEvents),
  ];

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
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
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
              children: _types.map((t) {
                final sel = _type == t.$1;
                return ChoiceChip(
                  avatar: Icon(t.$3,
                      size: 16, color: sel ? Colors.white : t.$4),
                  label: Text(t.$2),
                  selected: sel,
                  onSelected: (_) => setState(() => _type = t.$1),
                  selectedColor: t.$4,
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
                      child: Text('${c.code} · ${c.name}',
                          overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) => setState(() => _courseId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            _label('File'),
            Text(
                'Upload an image, or paste a link (Google Drive, etc.)',
                style: TextStyle(fontSize: 12, color: context.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderCol),
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

    try {
      String? fileUrl;
      String fileType = 'link';
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        final ext = _image!.path.split('.').last;
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/upload.$ext');
        await tempFile.writeAsBytes(bytes);
        final uploadResult = await Supabase.instance.client.storage
            .from('academic-resources')
            .upload('${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext', tempFile);
        await tempFile.delete();
        fileUrl = Supabase.instance.client.storage
            .from('academic-resources')
            .getPublicUrl(uploadResult);
        fileType = 'image';
      }

      final resource = AcademicResourceModel(
        id: '',
        courseId: _courseId ?? '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        type: _type,
        fileUrl: fileUrl ?? _linkCtrl.text.trim(),
        fileType: fileType,
        uploadedBy: user.id,
        createdAt: DateTime.now(),
      );
      await ref.read(academicRepositoryProvider).uploadResource(resource);

      ref.invalidate(searchResourcesProvider(''));
      if (_courseId != null) {
        ref.invalidate(resourcesByCourseProvider(_courseId!));
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
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
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
        fillColor: context.inputFill,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primary, width: 1.5)),
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}