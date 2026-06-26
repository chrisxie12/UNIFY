import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/attendance_provider.dart';

class StartAttendanceSessionScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String? lecturerId;
  final String? lecturerName;
  final String? university;
  final int enrolledCount;

  const StartAttendanceSessionScreen({
    super.key,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.lecturerId,
    this.lecturerName,
    this.university,
    this.enrolledCount = 0,
  });

  @override
  ConsumerState<StartAttendanceSessionScreen> createState() =>
      _StartAttendanceSessionScreenState();
}

class _StartAttendanceSessionScreenState
    extends ConsumerState<StartAttendanceSessionScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _roomCtl  = TextEditingController();
  final _buildCtl = TextEditingController();

  DateTime _start = DateTime.now();
  DateTime _end   = DateTime.now().add(const Duration(hours: 2));
  bool _saving    = false;

  @override
  void dispose() {
    _titleCtl.dispose();
    _roomCtl.dispose();
    _buildCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final uid = ref.read(supabaseProvider).auth.currentUser!.id;
      final session = await ref
          .read(attendanceSessionNotifierProvider.notifier)
          .startSession(
            courseId:        widget.courseId,
            courseCode:      widget.courseCode,
            courseName:      widget.courseName,
            title:           _titleCtl.text.trim(),
            scheduledStart:  _start,
            scheduledEnd:    _end,
            createdBy:       uid,
            building:        _buildCtl.text.trim().isEmpty ? null : _buildCtl.text.trim(),
            room:            _roomCtl.text.trim().isEmpty ? null : _roomCtl.text.trim(),
            university:      widget.university,
            lecturerId:      widget.lecturerId,
            lecturerName:    widget.lecturerName,
            totalRegistered: widget.enrolledCount,
          );
      if (mounted) {
        context.pushReplacement('/attendance/session/${session.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start session: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now  = DateTime.now();
    final init = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: now.subtract(const Duration(hours: 1)),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
    );
    if (time == null || !mounted) return;

    final picked =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start.add(const Duration(hours: 2));
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('EEE, MMM d · HH:mm');

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Start Attendance Session',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: context.appBarBg,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(USpacing.base),
          children: [
            // Course pill
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: USpacing.base, vertical: USpacing.sm),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.10),
                borderRadius: URadius.mdAll,
              ),
              child: Row(
                children: [
                  Icon(Icons.school_rounded, color: context.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.courseCode} – ${widget.courseName}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: context.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: USpacing.lg),

            _SectionLabel('Session Details'),
            const SizedBox(height: USpacing.sm),

            TextFormField(
              controller: _titleCtl,
              decoration: _inputDeco(context,
                  label: 'Session Title',
                  hint: 'e.g., Week 5 Attendance',
                  icon: Icons.title_rounded),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: USpacing.md),

            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _buildCtl,
                  decoration: _inputDeco(context,
                      label: 'Building',
                      hint: 'Block A',
                      icon: Icons.location_city_rounded),
                ),
              ),
              const SizedBox(width: USpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _roomCtl,
                  decoration: _inputDeco(context,
                      label: 'Room',
                      hint: '101',
                      icon: Icons.door_front_door_rounded),
                ),
              ),
            ]),
            const SizedBox(height: USpacing.lg),

            _SectionLabel('Schedule'),
            const SizedBox(height: USpacing.sm),

            _DateTimeRow(
              label: 'Start Time',
              value: timeFmt.format(_start),
              icon: Icons.play_circle_rounded,
              color: context.success,
              onTap: () => _pickDateTime(isStart: true),
            ),
            const SizedBox(height: USpacing.sm),
            _DateTimeRow(
              label: 'End Time',
              value: timeFmt.format(_end),
              icon: Icons.stop_circle_rounded,
              color: context.error,
              onTap: () => _pickDateTime(isStart: false),
            ),

            if (widget.enrolledCount > 0) ...[
              const SizedBox(height: USpacing.lg),
              _InfoRow(
                  icon: Icons.people_alt_rounded,
                  label: 'Enrolled students',
                  value: '${widget.enrolledCount}'),
            ],

            const SizedBox(height: USpacing.x2),
            AppButton(
              label: _saving ? 'Starting…' : 'Start Session',
              onPressed: _saving ? null : _submit,
              icon: Icons.how_to_reg_rounded,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(BuildContext context,
      {required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: URadius.mdAll),
      filled: true,
      fillColor: context.surfaceFill,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: context.textSecondary,
            letterSpacing: 0.5));
  }
}

class _DateTimeRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DateTimeRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: URadius.mdAll,
      child: Container(
        padding: const EdgeInsets.all(USpacing.base),
        decoration: BoxDecoration(
          color: context.surfaceFill,
          borderRadius: URadius.mdAll,
          border: Border.all(color: context.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 16, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(USpacing.base),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: URadius.mdAll,
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ',
              style: TextStyle(color: context.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
