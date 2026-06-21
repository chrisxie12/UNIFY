import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/design_system/components.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/ambassador_models.dart';
import '../providers/ambassador_provider.dart';
import '../../../../core/guards/admin_guard.dart';

class AmbassadorAdminScreen extends ConsumerWidget {
  const AmbassadorAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambassadorsAsync = ref.watch(ambassadorsProvider);
    final statsAsync = ref.watch(ambassadorStatsProvider);

    final active = statsAsync.valueOrNull?['active'] ?? 0;
    final totalReferrals = statsAsync.valueOrNull?['totalReferrals'] ?? 0;
    final totalEvents = statsAsync.valueOrNull?['totalEvents'] ?? 0;

    return AdminGuard(
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          elevation: 0.6,
          shadowColor: context.borderCol,
          title: const Text('Campus Ambassadors',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: context.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add ambassador'),
          onPressed: () => _showAddAmbassadorSheet(context, ref),
        ),
        body: ambassadorsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorWidget(e),
          data: (ambassadors) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(ambassadorsProvider);
                ref.invalidate(ambassadorStatsProvider);
              },
              child: ListView(
                padding: EdgeInsets.fromLTRB(USpacing.md, USpacing.md, USpacing.md, 88),
                children: [
                  Row(
                    children: [
                      _StatTile(
                        icon: Icons.verified_user_rounded,
                        value: '$active',
                        label: 'Active',
                        color: AppColors.success,
                      ),
                      _StatTile(
                        icon: Icons.people_alt_rounded,
                        value: '$totalReferrals',
                        label: 'Referrals',
                        color: AppColors.info,
                      ),
                      _StatTile(
                        icon: Icons.event_rounded,
                        value: '$totalEvents',
                        label: 'Events',
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: USpacing.md),
                  if (ambassadors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: UEmptyState(icon: Icons.campaign_rounded, title: 'No ambassadors yet'),
                    )
                  else
                    ...ambassadors.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AmbassadorCard(ambassador: a),
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AmbassadorCard extends StatelessWidget {
  final Ambassador ambassador;
  const _AmbassadorCard({required this.ambassador});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(ambassador.status);
    final subtitle = [
      ambassador.universityName,
      ambassador.faculty,
      ambassador.department,
    ].where((s) => s != null && s.isNotEmpty).join(' • ');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/launch/ambassador/${ambassador.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderCol),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(url: ambassador.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ambassador.fullName?.isNotEmpty == true
                            ? ambassador.fullName!
                            : 'Ambassador',
                        style: UText.label.copyWith(color: context.textPrimary),
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle,
                              style: UText.caption.copyWith(color: context.textSecondary)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: USpacing.sm),
                _StatusChip(label: ambassador.status, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniChip(
                  icon: Icons.people_alt_rounded,
                  label: '${ambassador.referralCount} referrals',
                  color: AppColors.info,
                ),
                const SizedBox(width: USpacing.sm),
                _MiniChip(
                  icon: Icons.event_rounded,
                  label: '${ambassador.eventsOrganized} events',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Add ambassador flow
// ══════════════════════════════════════════════════════════════

Future<void> _showAddAmbassadorSheet(
    BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: const _AddAmbassadorForm(),
    ),
  );
}

class _AddAmbassadorForm extends ConsumerStatefulWidget {
  const _AddAmbassadorForm();

  @override
  ConsumerState<_AddAmbassadorForm> createState() => _AddAmbassadorFormState();
}

class _AddAmbassadorFormState extends ConsumerState<_AddAmbassadorForm> {
  final _searchController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _bioController = TextEditingController();
  final _contactController = TextEditingController();

  List<Map<String, dynamic>> _results = [];
  Map<String, dynamic>? _selected;
  bool _searching = false;
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(ambassadorRepositoryProvider).searchProfiles(q);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _save() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    try {
      await ref.read(ambassadorRepositoryProvider).createAmbassador(
            userId: selected['id'] as String,
            universityName: _nullable(_universityController.text),
            faculty: _nullable(_facultyController.text),
            department: _nullable(_departmentController.text),
            bio: _nullable(_bioController.text),
            contact: _nullable(_contactController.text),
          );
      ref.invalidate(ambassadorsProvider);
      ref.invalidate(ambassadorStatsProvider);
      navigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }

  String? _nullable(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(USpacing.base),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add ambassador',
                  style: UText.h3.copyWith(color: context.textPrimary)),
              const SizedBox(height: USpacing.base),
              if (selected == null) ...[
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _runSearch(),
                  decoration: InputDecoration(
                    labelText: 'Search by name or email',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: _searching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search_rounded),
                      onPressed: _searching ? null : _runSearch,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ..._results.map((p) {
                  final name = p['full_name'] as String? ?? 'User';
                  final email = p['email'] as String? ?? '';
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: context.cardBg,
                      child: Icon(Icons.person_rounded,
                          color: context.textSecondary, size: 20),
                    ),
                    title: Text(name, style: UText.label),
                    subtitle: Text(email, style: UText.caption),
                    onTap: () => setState(() => _selected = p),
                  );
                }),
                if (!_searching && _results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: USpacing.sm),
                    child: Text('Search for a user to promote.',
                        style: UText.caption.copyWith(color: context.textSecondary)),
                  ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(USpacing.base),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: URadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: context.cardBg,
                        child: Icon(Icons.person_rounded,
                            color: context.textSecondary, size: 20),
                      ),
                      const SizedBox(width: USpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected['full_name'] as String? ?? 'User',
                                style: UText.label.copyWith(color: context.textPrimary)),
                            Text(selected['email'] as String? ?? '',
                                style: UText.caption.copyWith(color: context.textSecondary)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _selected = null),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: USpacing.md),
                _field(_universityController, 'University name'),
                const SizedBox(height: USpacing.md),
                _field(_facultyController, 'Faculty'),
                const SizedBox(height: USpacing.md),
                _field(_departmentController, 'Department'),
                const SizedBox(height: USpacing.md),
                _field(_bioController, 'Bio', maxLines: 3),
                const SizedBox(height: USpacing.md),
                _field(_contactController, 'Contact'),
                const SizedBox(height: USpacing.base),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Add ambassador'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared widgets
// ══════════════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(url!));
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: context.primary, size: 20),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: URadius.mdAll,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: UText.h2.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: UText.tiny.copyWith(color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: URadius.mdAll,
      ),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'active':
      return AppColors.success;
    case 'pending':
      return AppColors.warning;
    case 'inactive':
      return AppColors.grey2;
    default:
      return AppColors.grey2;
  }
}
