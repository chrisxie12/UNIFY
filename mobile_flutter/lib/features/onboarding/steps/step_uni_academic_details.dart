import 'package:flutter/material.dart';
import '../onboarding_screen.dart';

class StepUniAcademicDetails extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;
  final VoidCallback? onChanged;

  const StepUniAcademicDetails({
    super.key,
    required this.data,
    required this.animCtrl,
    this.onChanged,
  });

  @override
  State<StepUniAcademicDetails> createState() => _StepUniAcademicDetailsState();
}

class _StepUniAcademicDetailsState extends State<StepUniAcademicDetails> {
  late final TextEditingController _deptCtrl;
  late final TextEditingController _levelCtrl;
  late final TextEditingController _idCtrl;

  @override
  void initState() {
    super.initState();
    _deptCtrl = TextEditingController(text: widget.data.uniDepartment ?? '');
    _levelCtrl = TextEditingController(text: widget.data.uniLevel ?? '');
    _idCtrl = TextEditingController(text: widget.data.uniStudentId ?? '');
    _deptCtrl.addListener(_save);
    _levelCtrl.addListener(_save);
    _idCtrl.addListener(_save);
  }

  @override
  void dispose() {
    _deptCtrl.dispose();
    _levelCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.data.uniDepartment = _deptCtrl.text.trim();
    widget.data.uniLevel = _levelCtrl.text.trim();
    widget.data.uniStudentId = _idCtrl.text.trim();
    widget.onChanged?.call();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required String label,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Academic Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your program of study.',
            style: TextStyle(
              fontSize: 15,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildField(
            controller: _deptCtrl,
            label: 'Department / Programme',
            hint: 'e.g. Computer Science',
            prefixIcon: const Icon(Icons.menu_book_outlined, size: 20),
          ),
          const SizedBox(height: 20),
          _buildField(
            controller: _levelCtrl,
            label: 'Current Level',
            hint: 'e.g. Level 200',
            prefixIcon: const Icon(Icons.trending_up_outlined, size: 20),
          ),
          const SizedBox(height: 20),
          _buildField(
            controller: _idCtrl,
            label: 'Student ID Number',
            hint: 'e.g. 20241001',
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}
