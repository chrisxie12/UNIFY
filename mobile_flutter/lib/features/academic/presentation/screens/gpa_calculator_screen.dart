import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

const _gradeMap = {
  'A': 4.0, 'B+': 3.5, 'B': 3.0, 'C+': 2.5,
  'C': 2.0, 'D+': 1.5, 'D': 1.0, 'E': 0.5, 'F': 0.0,
};

class GPACalculatorScreen extends ConsumerStatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  ConsumerState<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends ConsumerState<GPACalculatorScreen> {
  final _semesterController = TextEditingController(text: 'Semester 1');
  final _courses = <_CourseEntry>[];
  bool _isCgpa = false;

  @override
  void dispose() {
    _semesterController.dispose();
    super.dispose();
  }

  void _addCourse() {
    setState(() => _courses.add(_CourseEntry()));
  }

  void _removeCourse(int index) {
    setState(() => _courses.removeAt(index));
  }

  double _calculateGPA() {
    if (_courses.isEmpty) return 0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final c in _courses) {
      if (c.credits > 0 && _gradeMap.containsKey(c.grade)) {
        totalPoints += _gradeMap[c.grade]! * c.credits;
        totalCredits += c.credits;
      }
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  void _save() {
    final gpa = _calculateGPA();
    final courses = _courses
        .where((c) => c.credits > 0 && _gradeMap.containsKey(c.grade))
        .map((c) => GPACourse(
              id: '',
              courseName: c.nameController.text,
              courseCode: c.codeController.text,
              credits: c.credits,
              grade: c.grade,
              gradePoint: _gradeMap[c.grade]!,
            ))
        .toList();

    if (courses.isEmpty) return;
    ref.read(academicProvider.notifier).saveGPA(
      _semesterController.text, null, _isCgpa, courses,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('GPA saved: ${gpa.toStringAsFixed(2)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gpa = _calculateGPA();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('Your GPA', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  gpa.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_courses.length} course${_courses.length == 1 ? '' : 's'} · ${_courses.fold<int>(0, (s, c) => s + c.credits)} credits',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _semesterController,
            decoration: InputDecoration(
              labelText: 'Semester',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Calculate as CGPA'),
            value: _isCgpa,
            onChanged: (v) => setState(() => _isCgpa = v),
            activeThumbColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Courses', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
              TextButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Course'),
              ),
            ],
          ),
          ..._courses.asMap().entries.map((entry) => _CourseInputCard(
                index: entry.key,
                entry: entry.value,
                onRemove: () => _removeCourse(entry.key),
              )),
          if (_courses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text('Tap "Add Course" to start', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseEntry {
  final TextEditingController nameController;
  final TextEditingController codeController;
  String grade = '';
  int credits = 3;

  _CourseEntry()
      : nameController = TextEditingController(),
        codeController = TextEditingController();
}

class _CourseInputCard extends StatelessWidget {
  final int index;
  final _CourseEntry entry;
  final VoidCallback onRemove;
  const _CourseInputCard({required this.index, required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Course ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onRemove),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: entry.nameController,
                    decoration: const InputDecoration(
                      hintText: 'Course name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: entry.codeController,
                    decoration: const InputDecoration(
                      hintText: 'Code',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: entry.credits,
                    items: [1, 2, 3, 4, 5, 6].map((c) => DropdownMenuItem(value: c, child: Text('$c credits'))).toList(),
                    onChanged: (v) => entry.credits = v ?? 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: entry.grade,
                    items: _gradeMap.keys.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => entry.grade = v ?? 'A',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
