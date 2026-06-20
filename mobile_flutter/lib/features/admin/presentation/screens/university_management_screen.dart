import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/university_model.dart';
import '../../presentation/providers/admin_provider.dart';
import '../../presentation/widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/errors/error_mapper.dart';

class UniversityManagementScreen extends ConsumerWidget {
  const UniversityManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universitiesAsync = ref.watch(universitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showUniversityDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(universitiesProvider),
        child: universitiesAsync.when(
          data: (universities) {
            if (universities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_rounded, size: 64, color: context.borderCol),
                    const SizedBox(height: 16),
                    Text('No universities registered', style: TextStyle(fontSize: 16, color: context.textSecondary)),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _showUniversityDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add University'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: universities.length,
              itemBuilder: (_, i) => _UniversityCard(university: universities[i]),
            );
          },
          loading: () => const AppLoadingWidget.list(),
          error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(universitiesProvider)),
        ),
      ),
    );
  }

  Future<void> _showUniversityDialog(BuildContext context, WidgetRef ref, {UniversityModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final shortNameCtrl = TextEditingController(text: existing?.shortName ?? '');
    final countryCtrl = TextEditingController(text: existing?.country ?? '');
    final regionCtrl = TextEditingController(text: existing?.region ?? '');
    final websiteCtrl = TextEditingController(text: existing?.website ?? '');
    final domainCtrl = TextEditingController(text: existing?.verificationDomain ?? '');
    final logoCtrl = TextEditingController(text: existing?.logoUrl ?? '');
    final isLoading = ValueNotifier(false);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existing != null ? 'Edit University' : 'Add University'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'University Name', 'e.g. University of Ghana'),
              _dialogField(shortNameCtrl, 'Short Name', 'e.g. UG'),
              _dialogField(countryCtrl, 'Country', 'e.g. Ghana'),
              _dialogField(regionCtrl, 'Region', 'e.g. Greater Accra'),
              _dialogField(websiteCtrl, 'Website', 'e.g. https://ug.edu.gh'),
              _dialogField(domainCtrl, 'Verification Domain', 'e.g. ug.edu.gh'),
              _dialogField(logoCtrl, 'Logo URL', 'Optional image URL'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (_, loading, __) => FilledButton(
              onPressed: loading ? null : () async {
                if (nameCtrl.text.trim().isEmpty) return;
                isLoading.value = true;
                final repo = ref.read(adminRepositoryProvider);
                final data = {
                  'name': nameCtrl.text.trim(),
                  if (shortNameCtrl.text.trim().isNotEmpty) 'short_name': shortNameCtrl.text.trim(),
                  if (countryCtrl.text.trim().isNotEmpty) 'country': countryCtrl.text.trim(),
                  if (regionCtrl.text.trim().isNotEmpty) 'region': regionCtrl.text.trim(),
                  if (websiteCtrl.text.trim().isNotEmpty) 'website': websiteCtrl.text.trim(),
                  if (domainCtrl.text.trim().isNotEmpty) 'verification_domain': domainCtrl.text.trim(),
                  if (logoCtrl.text.trim().isNotEmpty) 'logo_url': logoCtrl.text.trim(),
                };
                try {
                  if (existing != null) {
                    await repo.updateUniversity(existing.id, data);
                  } else {
                    await repo.createUniversity(data);
                  }
                  ref.invalidate(universitiesProvider);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    UnifySnackbar.error(ctx, ErrorMapper.toUserMessage(e));
                  }
                }
                isLoading.value = false;
              },
              child: Text(existing != null ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      ref.invalidate(universitiesProvider);
    }
  }
}

class _UniversityCard extends ConsumerWidget {
  final UniversityModel university;
  const _UniversityCard({required this.university});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_rounded, color: context.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(university.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      const SizedBox(height: 2),
                      if (university.country != null || university.shortName != null)
                        Text(
                          [university.shortName, university.country].where((e) => e != null).join(' · '),
                          style: TextStyle(fontSize: 12, color: context.textSecondary),
                        ),
                    ],
                  ),
                ),
                StatusBadge(university.isActive ? 'active' : 'inactive'),
              ],
            ),
          ),
          if (university.website != null || university.verificationDomain != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  if (university.website != null)
                    Expanded(
                      child: _infoChip(context, Icons.language_rounded, university.website!),
                    ),
                  if (university.website != null && university.verificationDomain != null)
                    const SizedBox(width: 8),
                  if (university.verificationDomain != null)
                    Expanded(
                      child: _infoChip(context, Icons.verified_rounded, university.verificationDomain!),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _actionRow(context, ref),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontSize: 11, color: context.textPrimary), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: Row(
        children: [
          Expanded(child: _actionButton(context, Icons.edit_rounded, 'Edit', () => _edit(context, ref))),
          Container(width: 1, height: 36, color: context.borderCol),
          Expanded(child: _actionButton(context, Icons.delete_rounded, 'Delete', () => _delete(context, ref), color: AppColors.error)),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.grey1),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color ?? AppColors.grey1, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _edit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit University'),
        content: const Text('Edit functionality triggered.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete University?'),
        content: Text('Are you sure you want to delete "${university.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteUniversity(university.id);
      ref.invalidate(universitiesProvider);
    }
  }
}

Widget _dialogField(TextEditingController ctrl, String label, String hint) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    ),
  );
}