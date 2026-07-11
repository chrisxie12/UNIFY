import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/verification_request_model.dart';
class VerificationRequestScreen extends ConsumerStatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  ConsumerState<VerificationRequestScreen> createState() => _VerificationRequestScreenState();
}

class _VerificationRequestScreenState extends ConsumerState<VerificationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _positionCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();

  String _academicYear = '2025/2026';
  String _evidenceType = 'appointment_letter';
  File? _evidenceFile;
  bool _submitting = false;

  static const _academicYears = ['2024/2025', '2025/2026', '2026/2027'];
  static const _positions = [
    'Class Representative',
    'Assistant Class Representative',
    'Course Representative',
    'Department Representative',
    'Faculty Representative',
    'SRC Executive',
    'Hall Representative',
    'Club President',
    'Department Executive',
  ];
  static const _evidenceTypes = [
    ('appointment_letter', 'Appointment Letter'),
    ('screenshot', 'Screenshot from Class Group'),
    ('official_doc', 'Official Document'),
  ];

  @override
  void dispose() {
    _positionCtrl.dispose();
    _classCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (file != null) {
      setState(() => _evidenceFile = File(file.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_evidenceFile == null) {
      UnifySnackbar.error(context, 'Please upload evidence to support your application');
      return;
    }

    setState(() => _submitting = true);

    try {
      final client = ref.read(supabaseProvider);
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final profile = await client
          .from('profiles')
          .select('university_id')
          .eq('id', user.id)
          .maybeSingle();
      if (profile == null) throw Exception('Profile not found');

      // Upload evidence
      final ext = _evidenceFile!.path.split('.').last;
      final fileBytes = await _evidenceFile!.readAsBytes();
      final storagePath = 'verification/${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await client.storage.from('verification_evidence').uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      final evidenceUrl = client.storage.from('verification_evidence').getPublicUrl(storagePath);

      // Create request
      final request = VerificationRequestModel(
        id: '',
        userId: user.id,
        universityId: profile['university_id'] as String,
        position: _positionCtrl.text.trim(),
        classRepresented: _classCtrl.text.trim().isEmpty ? null : _classCtrl.text.trim(),
        department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
        academicYear: _academicYear,
        evidenceUrl: evidenceUrl,
        evidenceType: _evidenceType,
        createdAt: DateTime.now(),
      );

      await client.from('verification_requests').insert(request.toInsertJson());

      // Update profile verification status
      await client.from('profiles').update({
        'verification_status': 'pending',
      }).eq('id', user.id);

      if (mounted) {
        UnifySnackbar.success(context, 'Verification request submitted! An admin will review it shortly.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _inputFillColor = context.cardBg;
    _labelColor = context.textPrimary;
    return Scaffold(
      appBar: AppBar(title: const Text('Request Verification'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFD4FF)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Submit your leadership evidence to get verified. Only verified leaders can create official communities.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _label('Position'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _positionCtrl.text.isEmpty ? null : _positionCtrl.text,
              decoration: _input(),
              hint: const Text('Select your position'),
              items: _positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => _positionCtrl.text = v ?? '',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _label('Class / Group Represented (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _classCtrl,
              decoration: _input(hint: 'e.g. BSc IT Level 200'),
            ),
            const SizedBox(height: 20),

            _label('Department (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _deptCtrl,
              decoration: _input(hint: 'e.g. Information Technology'),
            ),
            const SizedBox(height: 20),

            _label('Academic Year'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _academicYear,
              decoration: _input(),
              items: _academicYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (v) => setState(() => _academicYear = v ?? '2025/2026'),
            ),
            const SizedBox(height: 24),

            // Evidence upload
            _label('Evidence Upload'),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _evidenceType,
              onChanged: (v) { if (v != null) setState(() => _evidenceType = v); },
              child: Column(
                children: _evidenceTypes.map((t) => RadioListTile<String>(
                  title: Text(t.$2, style: const TextStyle(fontSize: 14)),
                  value: t.$1,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: _evidenceFile != null ? const Color(0xFFEFF4FF) : context.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _evidenceFile != null ? Theme.of(context).colorScheme.primary : context.borderCol,
                    width: _evidenceFile != null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _evidenceFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                      size: 32,
                      color: _evidenceFile != null ? Theme.of(context).colorScheme.primary : context.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _evidenceFile != null ? _evidenceFile!.path.split('/').last : 'Tap to upload evidence',
                      style: TextStyle(
                        fontSize: 13,
                        color: _evidenceFile != null ? Theme.of(context).colorScheme.primary : context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_evidenceFile != null) ...[
                      const SizedBox(height: 4),
                      Text('Tap to change', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Submit for Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color? _inputFillColor;
  Color? _labelColor;

  Widget _label(String text) => Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _labelColor));

  InputDecoration _input({String? hint}) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: _inputFillColor,
  );
}
