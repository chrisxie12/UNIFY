import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

class GpaCalculatorScreen extends ConsumerWidget {
  const GpaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gpaProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('GPA Calculator',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCourse(context, ref),
        backgroundColor: context.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add course',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (summary) {
          final semesters = summary.semesterGpa.keys.toList()..sort();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // CGPA hero
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primary,
                      Color.alphaBlend(
                          Colors.black.withValues(alpha: 0.20), context.primary),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cumulative GPA',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(summary.cgpa.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${summary.totalCredits.toStringAsFixed(0)} credits',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${summary.entries.length} courses',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(_classification(summary.cgpa),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (summary.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.calculate_outlined,
                            size: 56, color: context.primary),
                        const SizedBox(height: 14),
                        const Text('Add your courses to calculate GPA',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        const Text(
                            'Enter the course, credits and grade for each.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.grey2)),
                      ],
                    ),
                  ),
                )
              else
                ...semesters.map((sem) {
                  final entries =
                      summary.entries.where((e) => e.semester == sem).toList();
                  return _SemesterCard(
                    semester: sem,
                    gpa: summary.semesterGpa[sem] ?? 0,
                    entries: entries,
                    onDelete: (id) async {
                      await ref
                          .read(academicRepositoryProvider)
                          .deleteGpaEntry(id);
                      ref.invalidate(gpaProvider);
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  String _classification(double cgpa) {
    if (cgpa >= 3.6) return 'First Class';
    if (cgpa >= 3.0) return 'Second Upper';
    if (cgpa >= 2.5) return 'Second Lower';
    if (cgpa >= 2.0) return 'Third Class';
    if (cgpa > 0) return 'Pass';
    return '—';
  }

  void _addCourse(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddCourseSheet(),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final String semester;
  final double gpa;
  final List<GpaEntry> entries;
  final Future<void> Function(String id) onDelete;
  const _SemesterCard({
    required this.semester,
    required this.gpa,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(semester,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('GPA ${gpa.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: context.primary)),
                ),
              ],
            ),
          ),
          ...entries.map((e) => ListTile(
                dense: true,
                title: Text(e.courseName,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${e.credits.toStringAsFixed(0)} credits · ${e.gradeLabel ?? e.gradePoint.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 11.5)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.grey3),
                  onPressed: () => onDelete(e.id),
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AddCourseSheet extends ConsumerStatefulWidget {
  const _AddCourseSheet();

  @override
  ConsumerState<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends ConsumerState<_AddCourseSheet> {
  final _nameCtrl = TextEditingController();
  final _semCtrl = TextEditingController(text: 'Level 100 · Sem 1');
  double _credits = 3;
  ({String label, double point}) _grade = kGrades.first;
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _semCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add course',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtrl,
            decoration: _dec('Course name / code'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _semCtrl,
            decoration: _dec('Semester label (e.g. Level 200 · Sem 1)'),
          ),
          const SizedBox(height: 16),
          Text('Credits: ${_credits.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          Slider(
            value: _credits,
            min: 1,
            max: 6,
            divisions: 5,
            label: _credits.toStringAsFixed(0),
            activeColor: context.primary,
            onChanged: (v) => setState(() => _credits = v),
          ),
          const SizedBox(height: 8),
          const Text('Grade',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kGrades.map((g) {
              final sel = _grade.label == g.label;
              return ChoiceChip(
                label: Text('${g.label} (${g.point.toStringAsFixed(1)})'),
                selected: sel,
                onSelected: (_) => setState(() => _grade = g),
                selectedColor: context.primary.withValues(alpha: 0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Add course'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(academicRepositoryProvider).addGpaEntry({
        'user_id': user.id,
        'semester': _semCtrl.text.trim(),
        'course_name': _nameCtrl.text.trim(),
        'credits': _credits,
        'grade_point': _grade.point,
        'grade_label': _grade.label,
      });
      ref.invalidate(gpaProvider);
      if (mounted) Navigator.pop(context);
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

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      );
}
