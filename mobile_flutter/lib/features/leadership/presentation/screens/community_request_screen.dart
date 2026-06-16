import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/leadership_provider.dart';

class CommunityRequestScreen extends ConsumerStatefulWidget {
  const CommunityRequestScreen({super.key});

  @override
  ConsumerState<CommunityRequestScreen> createState() => _CommunityRequestScreenState();
}

class _CommunityRequestScreenState extends ConsumerState<CommunityRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _estCountCtrl = TextEditingController();

  String _type = 'class';
  String? _faculty;
  String? _department;
  String? _programme;
  String? _level;
  String? _academicYear;
  bool _submitting = false;

  static const _types = [
    ('class', 'Class Community'),
    ('level', 'Level-based Community'),
    ('department', 'Department Community'),
    ('faculty', 'Faculty Community'),
    ('club', 'Club'),
    ('university', 'University Community'),
  ];

  static const _levels = ['100', '200', '300', '400', 'pg'];
  static const _academicYears = ['2024/2025', '2025/2026', '2026/2027'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _purposeCtrl.dispose();
    _estCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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

      final repo = ref.read(leadershipRepositoryProvider);
      await repo.createRequest({
        'requester_id': user.id,
        'university_id': profile['university_id'],
        'community_name': _nameCtrl.text.trim(),
        'community_type': _type,
        'faculty': _faculty,
        'department': _department,
        'programme': _programme,
        'level': _level,
        'academic_year': _academicYear,
        'estimated_student_count': int.tryParse(_estCountCtrl.text),
        'purpose': _purposeCtrl.text.trim(),
      });

      ref.invalidate(myCommunityRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted! An admin will review it shortly.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Community'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('Community Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: _input('e.g. Level 100 Computer Science'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            const _SectionLabel('Community Type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: _input(null),
              items: _types.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
              onChanged: (v) => setState(() => _type = v ?? 'class'),
            ),
            const SizedBox(height: 20),

            if (_type == 'class' || _type == 'level' || _type == 'department' || _type == 'faculty') ...[
              _SectionLabel(_type == 'faculty' ? 'Faculty' : 'Faculty (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _input('e.g. Faculty of Computing'),
                onChanged: (v) => _faculty = v.isEmpty ? null : v,
              ),
              const SizedBox(height: 16),
            ],
            if (_type == 'class' || _type == 'level' || _type == 'department') ...[
              _SectionLabel(_type == 'department' ? 'Department' : 'Department (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _input('e.g. Information Technology'),
                onChanged: (v) => _department = v.isEmpty ? null : v,
              ),
              const SizedBox(height: 16),
            ],
            if (_type == 'class' || _type == 'level') ...[
              _SectionLabel('Programme (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _input('e.g. BSc Information Technology'),
                onChanged: (v) => _programme = v.isEmpty ? null : v,
              ),
              const SizedBox(height: 16),
              _SectionLabel('Level'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: _input(null),
                hint: const Text('Select level'),
                items: _levels.map((l) => DropdownMenuItem(value: l, child: Text('Level $l'))).toList(),
                onChanged: (v) => setState(() => _level = v),
              ),
              const SizedBox(height: 16),
            ],
            if (_type != 'club') ...[
              _SectionLabel('Academic Year'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _academicYear,
                decoration: _input(null),
                hint: const Text('Select academic year'),
                items: _academicYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (v) => setState(() => _academicYear = v),
              ),
              const SizedBox(height: 16),
            ],

            _SectionLabel('Estimated Student Count (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _estCountCtrl,
              decoration: _input('e.g. 150'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            _SectionLabel('Purpose'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _purposeCtrl,
              decoration: _input('Explain why this community should be created'),
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String? hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: AppColors.white,
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark));
  }
}
