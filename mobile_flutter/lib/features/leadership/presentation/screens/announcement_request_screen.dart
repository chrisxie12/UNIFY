import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/leadership_provider.dart';
import 'package:unify/core/design_system/tokens.dart';

class AnnouncementRequestScreen extends ConsumerStatefulWidget {
  const AnnouncementRequestScreen({super.key});

  @override
  ConsumerState<AnnouncementRequestScreen> createState() => _AnnouncementRequestScreenState();
}

class _AnnouncementRequestScreenState extends ConsumerState<AnnouncementRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  String _category = 'general';
  bool _isUrgent = false;
  String? _targetAudience;
  bool _submitting = false;

  static const _categories = [
    ('lecture', 'Lecture', Icons.menu_book_rounded),
    ('quiz', 'Quiz', Icons.quiz_rounded),
    ('assignment', 'Assignment', Icons.assignment_rounded),
    ('project', 'Project', Icons.build_rounded),
    ('seminar', 'Seminar', Icons.groups_rounded),
    ('workshop', 'Workshop', Icons.handyman_rounded),
    ('exam', 'Exam', Icons.fact_check_rounded),
    ('emergency', 'Emergency', Icons.warning_amber_rounded),
    ('general', 'General', Icons.campaign_rounded),
  ];

  static const _audiences = [
    ('class', 'My Class'),
    ('department', 'Department'),
    ('faculty', 'Faculty'),
    ('all', 'Entire University'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
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
      await repo.createAnnouncementRequest({
        'requester_id': user.id,
        'university_id': profile['university_id'],
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'category': _category,
        'is_urgent': _isUrgent,
        'target_audience': _targetAudience,
      });

      ref.invalidate(myAnnouncementRequestsProvider);

      if (mounted) {
        UnifySnackbar.success(context, 'Announcement submitted for admin approval!');
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
      appBar: AppBar(title: const Text('New Announcement'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(USpacing.base),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: URadius.mdAll,
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_rounded, color: Color(0xFF7C3AED), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Announcements require admin approval before they appear in the feed.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D28D9), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _label('Announcement Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: _input('e.g. Lecture moved to Room 203'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _label('Category'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _input(null),
              items: _categories.map((c) => DropdownMenuItem(
                value: c.$1,
                child: Row(
                  children: [
                    Icon(c.$3, size: 18, color: context.primary),
                    const SizedBox(width: 8),
                    Text(c.$2),
                  ],
                ),
              )).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'general'),
            ),
            const SizedBox(height: 20),

            _label('Body'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyCtrl,
              decoration: _input('Write your announcement details here...'),
              maxLines: 6,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _label('Target Audience'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _targetAudience,
              decoration: _input(null),
              hint: const Text('Select audience (optional)'),
              items: _audiences.map((a) => DropdownMenuItem(value: a.$1, child: Text(a.$2))).toList(),
              onChanged: (v) => setState(() => _targetAudience = v),
            ),
            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Mark as Urgent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('Urgent announcements are highlighted in red', style: TextStyle(fontSize: 11, color: context.textSecondary)),
              value: _isUrgent,
              activeThumbColor: AppColors.error,
              onChanged: (v) => setState(() => _isUrgent = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Submit for Approval', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  InputDecoration _input(String? hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: _inputFillColor,
  );
}
