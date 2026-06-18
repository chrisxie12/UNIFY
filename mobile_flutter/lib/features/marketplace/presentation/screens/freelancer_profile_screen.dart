import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/marketplace_constants.dart';

/// Create / edit the current user's freelancer (service provider) profile.
class FreelancerProfileScreen extends ConsumerStatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  ConsumerState<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState
    extends ConsumerState<FreelancerProfileScreen> {
  final _headlineCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final Set<String> _categories = {};
  bool _available = true;
  bool _loaded = false;
  bool _busy = false;

  @override
  void dispose() {
    _headlineCtrl.dispose();
    _bioCtrl.dispose();
    _skillsCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myFreelancerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Freelancer Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (profile) {
          if (!_loaded && profile != null) {
            _headlineCtrl.text = profile.headline ?? '';
            _bioCtrl.text = profile.bio ?? '';
            _skillsCtrl.text = profile.skills.join(', ');
            _rateCtrl.text = profile.hourlyRate?.toStringAsFixed(0) ?? '';
            _categories.addAll(profile.categories);
            _available = profile.isAvailable;
            _loaded = true;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              _label('Headline'),
              _field(_headlineCtrl,
                  'e.g. Graphic Designer & Brand Strategist'),
              const SizedBox(height: 16),
              _label('About you'),
              _field(_bioCtrl,
                  'Tell students about your experience and what you offer…',
                  maxLines: 4),
              const SizedBox(height: 16),
              _label('Service categories'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kServiceCategories.map((c) {
                  final sel = _categories.contains(c);
                  return FilterChip(
                    label: Text(c),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      sel ? _categories.remove(c) : _categories.add(c);
                    }),
                    selectedColor: context.primary.withValues(alpha: 0.12),
                    checkmarkColor: context.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _label('Skills (comma separated)'),
              _field(_skillsCtrl, 'e.g. Figma, Photoshop, Branding'),
              const SizedBox(height: 16),
              _label('Hourly rate (GHS)'),
              _field(_rateCtrl, 'e.g. 50',
                  keyboard: TextInputType.number),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _available,
                onChanged: (v) => setState(() => _available = v),
                title: const Text('Available for work',
                    style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: context.primary,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save profile',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    final skills = _skillsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    try {
      await ref.read(marketplaceRepositoryProvider).upsertFreelancer(
            userId: user.id,
            headline: _headlineCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            skills: skills,
            categories: _categories.toList(),
            hourlyRate: double.tryParse(_rateCtrl.text.trim()),
            isAvailable: _available,
          );
      ref.invalidate(myFreelancerProfileProvider);
      ref.invalidate(freelancersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Freelancer profile saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      );

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primary, width: 1.5)),
      ),
    );
  }
}
