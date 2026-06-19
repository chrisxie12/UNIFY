import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

class CourseFormScreen extends ConsumerStatefulWidget {
  const CourseFormScreen({super.key});

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _levelCtrl = TextEditingController();
  final _lecturerCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController(text: '3');
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _codeCtrl, _titleCtrl, _facultyCtrl, _deptCtrl,
      _levelCtrl, _lecturerCtrl, _creditsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Add Course',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            _label('Course code'),
            _field(_codeCtrl, 'e.g. DCIT201', validator: _required),
            const SizedBox(height: 16),
            _label('Course title'),
            _field(_titleCtrl, 'e.g. Database Systems', validator: _required),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Faculty'),
                      _field(_facultyCtrl, 'e.g. Computing'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Department'),
                      _field(_deptCtrl, 'e.g. IT'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Level'),
                      _field(_levelCtrl, 'e.g. 200'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Credits'),
                      _field(_creditsCtrl, 'e.g. 3',
                          keyboard: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Lecturer (optional)'),
            _field(_lecturerCtrl, 'e.g. Dr. Mensah'),
            const SizedBox(height: 24),
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
                  : const Text('Add course',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      final course = CourseModel(
        id: '',
        code: _codeCtrl.text.trim().toUpperCase(),
        name: _titleCtrl.text.trim(),
        credits: int.tryParse(_creditsCtrl.text.trim()) ?? 3,
        faculty: _facultyCtrl.text.trim().isEmpty ? null : _facultyCtrl.text.trim(),
        department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
        level: _levelCtrl.text.trim().isEmpty ? null : _levelCtrl.text.trim(),
        lecturerName: _lecturerCtrl.text.trim().isEmpty ? null : _lecturerCtrl.text.trim(),
        lecturerId: user.id,
        communityId: null,
        createdBy: user.id,
        createdAt: DateTime.now(),
      );
      await ref.read(academicRepositoryProvider).createCourse(course);
      ref.invalidate(coursesProvider);
      ref.invalidate(facultiesProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Course added'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not add: $e'),
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
      {TextInputType? keyboard, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
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
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
