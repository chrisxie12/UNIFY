import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin_role_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';

class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(administratorsProvider);
    final rolesAsync = ref.watch(adminRolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _assignAdmin(context, ref, rolesAsync),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(administratorsProvider);
          ref.invalidate(adminRolesProvider);
        },
        child: adminsAsync.when(
          data: (admins) {
            if (admins.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, size: 48, color: context.borderCol),
                    SizedBox(height: 12),
                    Text('No administrators assigned', style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admins.length,
              itemBuilder: (_, i) => _AdminCard(admin: admins[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(administratorsProvider)),
        ),
      ),
    );
  }

  Future<void> _assignAdmin(BuildContext context, WidgetRef ref, AsyncValue<List> rolesAsync) async {
    final roles = (rolesAsync.valueOrNull ?? []) as List<AdminRoleModel>;
    final userIdCtrl = TextEditingController();
    String? selectedRoleId = roles.isNotEmpty ? roles.first.id : null;

    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Assign Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdCtrl,
              decoration: InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter user UUID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            if (roles.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: selectedRoleId,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                items: (roles).map((r) => DropdownMenuItem<String>(
                  value: r.id,
                  child: Text(r.role.replaceAll('_', ' ')),
                )).toList(),
                onChanged: (v) => selectedRoleId = v,
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (userIdCtrl.text.trim().isEmpty || selectedRoleId == null) return;
              final repo = ref.read(adminRepositoryProvider);
              await repo.assignAdminRole({
                'user_id': userIdCtrl.text.trim(),
                'role_id': selectedRoleId,
              });
              ref.invalidate(administratorsProvider);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends ConsumerWidget {
  final dynamic admin;
  const _AdminCard({required this.admin});

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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.primary.withValues(alpha: 0.1),
                  backgroundImage: admin.userAvatarUrl != null
                      ? NetworkImage(admin.userAvatarUrl!) : null,
                  child: admin.userAvatarUrl == null
                      ? Icon(Icons.admin_panel_settings_rounded, color: context.primary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(admin.userFullName ?? 'Unknown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Text(admin.roleName?.replaceAll('_', ' ') ?? '', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(admin.isActive ? 'active' : 'inactive'),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: context.borderCol))),
            child: Row(
              children: [
                Expanded(child: _actionBtn(context, admin.isActive ? 'Deactivate' : 'Activate', AppColors.warning, () => _toggleStatus(context, ref))),
                Container(width: 1, height: 36, color: context.borderCol),
                Expanded(child: _actionBtn(context, 'Remove', AppColors.error, () => _remove(context, ref))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateAdminStatus(admin.id, !admin.isActive);
    ref.invalidate(administratorsProvider);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Admin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      final repo = ref.read(adminRepositoryProvider);
      await repo.removeAdmin(admin.id);
      ref.invalidate(administratorsProvider);
    }
  }
}
