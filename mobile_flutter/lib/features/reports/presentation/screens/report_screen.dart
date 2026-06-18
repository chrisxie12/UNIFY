import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_model.dart';
import '../../presentation/providers/report_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String reportType;
  final String? targetOwnerId;

  const ReportScreen({
    super.key,
    required this.targetId,
    required this.reportType,
    this.targetOwnerId,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _reasonController = TextEditingController();
  String _selectedReason = 'spam';
  bool _isSubmitting = false;

  final _reasons = [
    'spam',
    'harassment',
    'inappropriate',
    'misinformation',
    'fake_account',
    'hate_speech',
    'violence',
    'copyright',
    'other',
  ];

  final _reasonLabels = {
    'spam': 'Spam',
    'harassment': 'Harassment',
    'inappropriate': 'Inappropriate Content',
    'misinformation': 'Misinformation',
    'fake_account': 'Fake Account',
    'hate_speech': 'Hate Speech',
    'violence': 'Violent Content',
    'copyright': 'Copyright Violation',
    'other': 'Other',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Why are you reporting this?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your report is anonymous. ${ReportModel.reportTypeLabels[widget.reportType] ?? ''} will be reviewed.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          ..._reasons.map((reason) => RadioListTile<String>(
                title: Text(_reasonLabels[reason] ?? reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (v) => setState(() => _selectedReason = v!),
                dense: true,
                activeColor: Theme.of(context).colorScheme.primary,
              )),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Add more details (optional)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Report', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(reportRepositoryProvider);
      await repo.createReport(ReportModel(
        id: '',
        reporterId: '',
        reportType: widget.reportType,
        targetId: widget.targetId,
        targetOwnerId: widget.targetOwnerId,
        reason: _selectedReason,
        description: _reasonController.text.isNotEmpty ? _reasonController.text : null,
        createdAt: DateTime.now(),
      ));
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted. Thank you.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
