import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/growth_models.dart';
import '../providers/growth_provider.dart';

class BetaAdminScreen extends ConsumerWidget {
  const BetaAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitlistAsync = ref.watch(waitlistProvider);
    final codesAsync = ref.watch(inviteCodesProvider);
    final testersAsync = ref.watch(betaTestersProvider);

    final waitingCount = waitlistAsync.valueOrNull
            ?.where((e) => e.status == 'waiting')
            .length ??
        0;
    final activeTesters = testersAsync.valueOrNull
            ?.where((t) => t.status == 'active')
            .length ??
        0;
    final activeCodes =
        codesAsync.valueOrNull?.where((c) => c.isActive).length ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          elevation: 0.6,
          shadowColor: context.borderCol,
          title: const Text('Beta & Waitlist',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Waitlist'),
              Tab(text: 'Invite Codes'),
              Tab(text: 'Beta Testers'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  _StatTile(
                    icon: Icons.hourglass_top_rounded,
                    value: '$waitingCount',
                    label: 'Waiting',
                    color: AppColors.warning,
                  ),
                  _StatTile(
                    icon: Icons.science_rounded,
                    value: '$activeTesters',
                    label: 'Active Testers',
                    color: AppColors.success,
                  ),
                  _StatTile(
                    icon: Icons.qr_code_rounded,
                    value: '$activeCodes',
                    label: 'Active Codes',
                    color: AppColors.info,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _WaitlistTab(waitlistAsync: waitlistAsync),
                  _InviteCodesTab(codesAsync: codesAsync),
                  _BetaTestersTab(testersAsync: testersAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Waitlist Tab
// ══════════════════════════════════════════════════════════════

class _WaitlistTab extends ConsumerWidget {
  final AsyncValue<List<WaitlistEntry>> waitlistAsync;
  const _WaitlistTab({required this.waitlistAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return waitlistAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (entries) {
        if (entries.isEmpty) {
          return const _EmptyState(
              icon: Icons.list_alt_rounded, message: 'No waitlist entries yet');
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(waitlistProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _WaitlistCard(entry: entries[i]),
          ),
        );
      },
    );
  }
}

class _WaitlistCard extends ConsumerWidget {
  final WaitlistEntry entry;
  const _WaitlistCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(entry.status);
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person_rounded, color: context.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fullName?.isNotEmpty == true
                      ? entry.fullName!
                      : entry.email,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(entry.email,
                    style:
                        const TextStyle(fontSize: 12, color: context.textSecondary)),
                if (entry.programme != null || entry.universityName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [entry.universityName, entry.programme, entry.level]
                          .where((s) => s != null && s.isNotEmpty)
                          .join(' • '),
                      style: const TextStyle(
                          fontSize: 11, color: context.textDisabled),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(label: entry.status, color: color),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: context.textSecondary),
            onSelected: (status) async {
              await ref
                  .read(growthRepositoryProvider)
                  .updateWaitlistStatus(entry.id, status);
              ref.invalidate(waitlistProvider);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'waiting', child: Text('Mark Waiting')),
              PopupMenuItem(value: 'invited', child: Text('Mark Invited')),
              PopupMenuItem(value: 'joined', child: Text('Mark Joined')),
              PopupMenuItem(value: 'rejected', child: Text('Reject')),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Invite Codes Tab
// ══════════════════════════════════════════════════════════════

class _InviteCodesTab extends ConsumerWidget {
  final AsyncValue<List<InviteCode>> codesAsync;
  const _InviteCodesTab({required this.codesAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Code'),
        onPressed: () => _showCreateCodeDialog(context, ref),
      ),
      body: codesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (codes) {
          if (codes.isEmpty) {
            return const _EmptyState(
                icon: Icons.qr_code_2_rounded,
                message: 'No invite codes yet');
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(inviteCodesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: codes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _InviteCodeCard(code: codes[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateCodeDialog(
      BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final codeController =
        TextEditingController(text: 'BETA${_randomCode(6)}');
    final maxUsesController = TextEditingController(text: '0');
    final noteController = TextEditingController();
    var type = 'beta';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Invite Code',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'beta', child: Text('Beta')),
                        DropdownMenuItem(
                            value: 'referral', child: Text('Referral')),
                        DropdownMenuItem(
                            value: 'ambassador', child: Text('Ambassador')),
                        DropdownMenuItem(
                            value: 'general', child: Text('General')),
                      ],
                      onChanged: (v) =>
                          setState(() => type = v ?? 'beta'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: maxUsesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max uses (0 = unlimited)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final code = codeController.text.trim().toUpperCase();
                    if (code.isEmpty) return;
                    final maxUses =
                        int.tryParse(maxUsesController.text.trim()) ?? 0;
                    final note = noteController.text.trim();
                    final navigator = Navigator.of(context);
                    try {
                      await ref.read(growthRepositoryProvider).createInviteCode(
                            code: code,
                            type: type,
                            maxUses: maxUses,
                            note: note.isEmpty ? null : note,
                            createdBy: user.id,
                          );
                      ref.invalidate(inviteCodesProvider);
                      navigator.pop();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not create code: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InviteCodeCard extends ConsumerWidget {
  final InviteCode code;
  const _InviteCodeCard({required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usesLabel = code.isUnlimited
        ? '${code.useCount} uses'
        : '${code.useCount}/${code.maxUses}';
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied ${code.code}')),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code.code,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: context.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded,
                          size: 14, color: context.textDisabled),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Pill(label: code.type, color: AppColors.info),
                    const SizedBox(width: 6),
                    Text(usesLabel,
                        style: const TextStyle(
                            fontSize: 12, color: context.textSecondary)),
                  ],
                ),
                if (code.note != null && code.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(code.note!,
                        style: const TextStyle(
                            fontSize: 11, color: context.textDisabled)),
                  ),
              ],
            ),
          ),
          Switch(
            value: code.isActive,
            activeThumbColor: AppColors.success,
            onChanged: (v) async {
              await ref
                  .read(growthRepositoryProvider)
                  .toggleInviteCode(code.id, v);
              ref.invalidate(inviteCodesProvider);
            },
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Beta Testers Tab
// ══════════════════════════════════════════════════════════════

class _BetaTestersTab extends ConsumerWidget {
  final AsyncValue<List<BetaTester>> testersAsync;
  const _BetaTestersTab({required this.testersAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return testersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (testers) {
        if (testers.isEmpty) {
          return const _EmptyState(
              icon: Icons.science_rounded, message: 'No beta testers yet');
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(betaTestersProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: testers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _BetaTesterCard(tester: testers[i]),
          ),
        );
      },
    );
  }
}

class _BetaTesterCard extends ConsumerWidget {
  final BetaTester tester;
  const _BetaTesterCard({required this.tester});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(tester.status);
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.person_rounded, color: context.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tester.fullName?.isNotEmpty == true
                      ? tester.fullName!
                      : 'Tester',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tester.cohort.isEmpty ? 'No cohort' : tester.cohort} • ${tester.feedbackCount} feedback',
                  style: const TextStyle(fontSize: 12, color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(label: tester.status, color: color),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: context.textSecondary),
            onSelected: (status) async {
              await ref
                  .read(growthRepositoryProvider)
                  .setBetaStatus(tester.userId, status);
              ref.invalidate(betaTestersProvider);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'active', child: Text('Mark Active')),
              PopupMenuItem(value: 'inactive', child: Text('Mark Inactive')),
              PopupMenuItem(value: 'removed', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared widgets & helpers
// ══════════════════════════════════════════════════════════════

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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: context.textSecondary)),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: context.borderCol),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(fontSize: 14, color: context.textDisabled)),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'waiting':
    case 'sent':
      return AppColors.warning;
    case 'invited':
    case 'accepted':
      return AppColors.info;
    case 'joined':
    case 'active':
      return AppColors.success;
    case 'rejected':
    case 'removed':
    case 'inactive':
      return AppColors.grey2;
    default:
      return AppColors.grey2;
  }
}

String _randomCode(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rnd = Random();
  return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
}
