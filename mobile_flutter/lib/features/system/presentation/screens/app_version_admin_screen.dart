import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/system_models.dart';
import '../providers/system_provider.dart';

/// Admin manager for app version metadata used by the update gate.
class AppVersionAdminScreen extends ConsumerWidget {
  const AppVersionAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appVersionsProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        elevation: 0.6,
        title: Text(
          'App Versions',
          style: TextStyle(fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => _showNewVersionDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New version'),
      ),
      body: async.when(
        loading: () => const AppLoadingWidget.list(itemCount: 5),
        error: (e, _) => AppErrorWidget(e),
        data: (versions) {
          if (versions.isEmpty) {
            return const AppEmptyWidget(
              icon: Icons.inbox_rounded,
              title: 'No versions yet',
            );
          }
          // Group by platform.
          final grouped = <String, List<AppVersionInfo>>{};
          for (final v in versions) {
            grouped.putIfAbsent(v.platform, () => []).add(v);
          }
          final platforms = grouped.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              for (final p in platforms) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    p.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: context.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...grouped[p]!.map((v) => _versionCard(context, ref, v)),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _versionCard(BuildContext context, WidgetRef ref, AppVersionInfo v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'v${v.version}  (build ${v.buildNumber})',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: v.isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (val) async {
                  await ref
                      .read(systemRepositoryProvider)
                      .toggleAppVersion(v.id, val);
                  ref.invalidate(appVersionsProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip('min build ${v.minSupportedBuild}', AppColors.grey1),
              if (v.isMandatory) _chip('mandatory', AppColors.error),
              _chip(v.isActive ? 'active' : 'inactive',
                  v.isActive ? AppColors.success : AppColors.grey3),
            ],
          ),
          if (v.releaseNotes != null && v.releaseNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              v.releaseNotes!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _showNewVersionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const _NewVersionDialog(),
    );
  }
}

class _NewVersionDialog extends ConsumerStatefulWidget {
  const _NewVersionDialog();

  @override
  ConsumerState<_NewVersionDialog> createState() => _NewVersionDialogState();
}

class _NewVersionDialogState extends ConsumerState<_NewVersionDialog> {
  final _versionCtrl = TextEditingController();
  final _buildCtrl = TextEditingController();
  final _minBuildCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _downloadCtrl = TextEditingController();

  String _platform = 'android';
  bool _mandatory = false;
  bool _submitting = false;

  static const _platforms = ['android', 'ios', 'web'];

  @override
  void dispose() {
    _versionCtrl.dispose();
    _buildCtrl.dispose();
    _minBuildCtrl.dispose();
    _notesCtrl.dispose();
    _downloadCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final version = _versionCtrl.text.trim();
    final build = int.tryParse(_buildCtrl.text.trim());
    final minBuild = int.tryParse(_minBuildCtrl.text.trim());
    if (version.isEmpty || build == null || minBuild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Version, build and min build are required')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(systemRepositoryProvider).createAppVersion(
            platform: _platform,
            version: version,
            buildNumber: build,
            minSupportedBuild: minBuild,
            isMandatory: _mandatory,
            releaseNotes: _notesCtrl.text.trim(),
            downloadUrl: _downloadCtrl.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(appVersionsProvider);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardBg,
      title: const Text(
        'New version',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InputDecorator(
              decoration: _input('Platform'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _platform,
                  isDense: true,
                  isExpanded: true,
                  items: _platforms
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _platform = v!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _versionCtrl,
              decoration: _input('Version (e.g. 1.1.0)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _buildCtrl,
              keyboardType: TextInputType.number,
              decoration: _input('Build number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _minBuildCtrl,
              keyboardType: TextInputType.number,
              decoration: _input('Min supported build'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: Text('Mandatory',
                  style: TextStyle(fontSize: 14, color: context.textPrimary)),
              value: _mandatory,
              onChanged: (v) => setState(() => _mandatory = v),
            ),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              minLines: 2,
              decoration: _input('Release notes (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _downloadCtrl,
              keyboardType: TextInputType.url,
              decoration: _input('Download URL (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderCol),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}