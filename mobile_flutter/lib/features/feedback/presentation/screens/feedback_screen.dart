import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/feedback_models.dart';
import '../providers/feedback_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  FeedbackType _type = FeedbackType.bug;
  Uint8List? _screenshot;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _screenshot = bytes);
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and description.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final repo = ref.read(feedbackRepositoryProvider);
    try {
      String? url;
      if (_screenshot != null) {
        url = await repo.uploadScreenshot(user.id, _screenshot!);
      }
      final platform = AnalyticsService.platform;
      await repo.submit(
        userId: user.id,
        type: _type.key,
        title: title,
        description: desc,
        screenshotUrl: url,
        deviceInfo: '$platform · v${AppConstants.appVersion}',
        appVersion: AppConstants.appVersion,
        platform: platform,
      );
      if (!mounted) return;
      _titleCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _screenshot = null;
        _type = FeedbackType.bug;
      });
      ref.invalidate(myFeedbackProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks! Your feedback was submitted.')),
      );
    } catch (e) {
      if (!mounted) return;
      UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mine = ref.watch(myFeedbackProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Feedback',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What kind of feedback?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final t in FeedbackType.values) ...[
                      Expanded(child: _typeChip(t)),
                      if (t != FeedbackType.values.last)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleCtrl,
                  decoration: _input('Title', 'Brief summary'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: _input('Description',
                      'Tell us what happened or what you would like'),
                ),
                const SizedBox(height: 12),
                _screenshotField(),
                const SizedBox(height: 8),
                Text(
                  'Device: ${AnalyticsService.platform} · v${AppConstants.appVersion}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey2),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit feedback',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('My submissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          mine.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Text(ErrorMapper.toUserMessage(e),
                style: const TextStyle(color: AppColors.grey2)),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('You have not submitted any feedback yet.',
                      style: TextStyle(color: AppColors.grey2)),
                );
              }
              return Column(
                children: [
                  for (final f in items) ...[
                    _submissionCard(f),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _typeChip(FeedbackType t) {
    final selected = _type == t;
    return InkWell(
      onTap: () => setState(() => _type = t),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? t.color.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? t.color : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(t.icon,
                size: 20, color: selected ? t.color : AppColors.grey2),
            const SizedBox(height: 4),
            Text(t.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? t.color : AppColors.grey1,
                )),
          ],
        ),
      ),
    );
  }

  Widget _screenshotField() {
    if (_screenshot == null) {
      return OutlinedButton.icon(
        onPressed: _pickScreenshot,
        icon: const Icon(Icons.add_a_photo_outlined, size: 18),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.grey1,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        label: const Text('Add screenshot (optional)'),
      );
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(_screenshot!,
              width: 64, height: 64, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: _pickScreenshot,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Change'),
        ),
        TextButton.icon(
          onPressed: () => setState(() => _screenshot = null),
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text('Remove'),
          style: TextButton.styleFrom(foregroundColor: context.error),
        ),
      ],
    );
  }

  Widget _submissionCard(FeedbackItem f) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(f.type.label, f.type.color, icon: f.type.icon),
              const SizedBox(width: 8),
              _chip(FeedbackStatus.label(f.status),
                  FeedbackStatus.color(f.status)),
              const Spacer(),
              if (f.voteCount > 0)
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        size: 14, color: AppColors.grey2),
                    const SizedBox(width: 2),
                    Text('${f.voteCount}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey2)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(f.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(f.description,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.grey1)),
          if (f.adminResponse != null && f.adminResponse!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Response from the team',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info)),
                  const SizedBox(height: 4),
                  Text(f.adminResponse!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.grey1)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: child,
    );
  }

  Widget _chip(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  InputDecoration _input(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.primary, width: 1.4),
      ),
    );
  }
}
