import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/leadership_provider.dart';

class CommunityRequestScreen extends ConsumerStatefulWidget {
  const CommunityRequestScreen({super.key});

  @override
  ConsumerState<CommunityRequestScreen> createState() => _CommunityRequestScreenState();
}

class _CommunityRequestScreenState extends ConsumerState<CommunityRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _classNameCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _estCountCtrl = TextEditingController();

  String _type = 'class';
  String? _faculty;
  String? _department;
  String? _programme;
  String? _level;
  String? _academicYear;
  bool _submitting = false;

  static const _typeOptions = [
    ('class', 'Class'),
    ('department', 'Department'),
    ('faculty', 'Faculty'),
    ('hostel', 'Hostel'),
    ('club', 'Club'),
    ('academic_group', 'Academic Group'),
  ];

  static const _levels = ['100', '200', '300', '400', 'pg'];
  static const _academicYears = ['2024/2025', '2025/2026', '2026/2027'];

  bool get _isAcademicType =>
      _type == 'class' || _type == 'department' || _type == 'faculty' || _type == 'academic_group';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _classNameCtrl.dispose();
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
        'class_name': _type == 'class' ? _classNameCtrl.text.trim() : null,
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
    final leadershipAsync = ref.watch(userLeadershipProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Community'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Leadership info card
            leadershipAsync.when(
              data: (roles) {
                if (roles.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Leadership Role Required', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
                              const SizedBox(height: 4),
                              Text(
                                'Community creation is restricted to verified student representatives.',
                                style: TextStyle(fontSize: 12, color: AppColors.grey2, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 18, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Verified Leader', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
                            Text(
                              roles.map((r) => r.role.title).join(', '),
                              style: const TextStyle(fontSize: 12, color: AppColors.grey2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox(height: 40),
            ),

            const _SectionLabel('Community Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: _input(_type == 'class' ? 'e.g. BSc IT Class of 2026' : 'e.g. Department of IT'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            const _SectionLabel('Community Type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: _input(null),
              items: _typeOptions.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 20),

            // Class Name field (only for class type)
            if (_type == 'class') ...[
              const _SectionLabel('Class Name'),
              const SizedBox(height: 4),
              Text('Enter the specific class this community represents (e.g. IT Level 100)', style: TextStyle(fontSize: 11, color: AppColors.grey3)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _classNameCtrl,
                decoration: _input('e.g. IT Level 100'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required for class communities' : null,
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: context.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Class communities require a Course Representative or Assistant Course Representative leadership position.',
                        style: TextStyle(fontSize: 12, color: AppColors.grey1, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Academic fields (faculty, department, programme, level)
            if (_isAcademicType) ...[
              if (_type == 'faculty' || _type == 'academic_group') ...[
                const _SectionLabel('Faculty'),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _input('e.g. Faculty of Computing'),
                  onChanged: (v) => _faculty = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 16),
              ],
              if (_type == 'department' || _type == 'academic_group') ...[
                const _SectionLabel('Department'),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _input('e.g. Information Technology'),
                  onChanged: (v) => _department = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 16),
              ],
              if (_type != 'faculty' && _type != 'department') ...[
                const _SectionLabel('Faculty (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _input('e.g. Faculty of Computing'),
                  onChanged: (v) => _faculty = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 16),
                if (_type != 'faculty') ...[
                  const _SectionLabel('Department (optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: _input('e.g. Information Technology'),
                    onChanged: (v) => _department = v.isEmpty ? null : v,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              if (_type == 'class') ...[
                const _SectionLabel('Programme (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: _input('e.g. BSc Information Technology'),
                  onChanged: (v) => _programme = v.isEmpty ? null : v,
                ),
                const SizedBox(height: 16),
                const _SectionLabel('Level'),
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
            ],

            // Hostel-specific fields
            if (_type == 'hostel') ...[
              const _SectionLabel('Hostel Name'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _input('e.g. SSNIT Hostel'),
                onChanged: (v) {
                  if (v.isNotEmpty) _faculty = v;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Club-specific fields
            if (_type == 'club') ...[
              const _SectionLabel('Club Category (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _input('e.g. Technology, Sports, Music'),
                onChanged: (v) => _department = v.isEmpty ? null : v,
              ),
              const SizedBox(height: 16),
            ],

            // Academic Year (hidden for clubs)
            if (_type != 'club') ...[
              const _SectionLabel('Academic Year'),
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

            const _SectionLabel('Estimated Student Count (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _estCountCtrl,
              decoration: _input('e.g. 150'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            const _SectionLabel('Purpose'),
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
