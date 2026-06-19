import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';
import '../widgets/opportunity_constants.dart';

class OpportunityDetailScreen extends ConsumerStatefulWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  ConsumerState<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends ConsumerState<OpportunityDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(opportunitiesRepositoryProvider)
          .recordView(widget.opportunityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(opportunityDetailProvider(widget.opportunityId));
    return Scaffold(
      backgroundColor: context.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (o) =>
            o == null ? const Center(child: Text('Not found')) : _content(o),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (o) => o == null ? null : _bottomBar(o),
        orElse: () => null,
      ),
    );
  }

  Widget _content(OpportunityModel o) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          leading: _circleBtn(Icons.arrow_back_rounded, () => context.pop()),
          actions: [
            _circleBtn(Icons.flag_outlined, () => _report(o)),
            const SizedBox(width: 8),
          ],
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    o.type.color,
                    Color.alphaBlend(
                        Colors.black.withValues(alpha: 0.22), o.type.color),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: o.coverUrl != null && o.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: o.coverUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.25),
                      colorBlendMode: BlendMode.darken,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    )
                  : Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(o.type.icon,
                            size: 56,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: context.cardBg,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _tag(o.type.label, o.type.color),
                    const SizedBox(width: 6),
                    if (o.isVerified)
                      Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 16, color: o.type.color),
                          const SizedBox(width: 3),
                          Text('Verified',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: o.type.color)),
                        ],
                      ),
                    const Spacer(),
                    Row(children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: AppColors.grey3),
                      const SizedBox(width: 4),
                      Text('${o.viewCount}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grey3)),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                Text(o.title,
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: context.textPrimary)),
                if (o.organization != null) ...[
                  const SizedBox(height: 6),
                  Text(o.organization!,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary)),
                ],
                const SizedBox(height: 14),
                // Deadline banner
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: o.isClosingSoon
                        ? AppColors.error.withValues(alpha: 0.08)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded,
                          size: 18,
                          color: o.isClosingSoon
                              ? AppColors.error
                              : AppColors.grey1),
                      const SizedBox(width: 8),
                      Text(
                        o.isRolling
                            ? 'Rolling deadline'
                            : 'Deadline: ${o.deadlineLabel}',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: o.isClosingSoon
                                ? AppColors.error
                                : context.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick facts
        SliverToBoxAdapter(child: _facts(o)),

        // Summary / description
        if ((o.summary != null && o.summary!.isNotEmpty) ||
            (o.description != null && o.description!.isNotEmpty))
          SliverToBoxAdapter(
            child: _sectionCard('About this opportunity',
                o.description?.isNotEmpty == true
                    ? o.description!
                    : o.summary!),
          ),

        // Eligibility
        if (o.eligibility != null && o.eligibility!.isNotEmpty)
          SliverToBoxAdapter(
            child: _sectionCard('Eligibility', o.eligibility!),
          ),

        // Fields / tags
        if (o.fields.isNotEmpty || o.tags.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: _cardDeco(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fields & tags',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [...o.fields, ...o.tags]
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _facts(OpportunityModel o) {
    final facts = <(IconData, String, String)>[
      if (o.location != null && o.location!.isNotEmpty)
        (Icons.location_on_outlined, 'Location', o.location!),
      if (o.isRemote) (Icons.wifi_rounded, 'Format', 'Remote'),
      if (o.funding != null && o.funding!.isNotEmpty)
        (Icons.payments_outlined, 'Funding', o.funding!),
      if (o.levels.isNotEmpty)
        (Icons.grade_outlined, 'Levels', o.levels.join(', ')),
      if (o.startsAt != null)
        (Icons.play_circle_outline_rounded, 'Starts',
            OpportunityModel(id: '', type: o.type, title: '', createdAt: o.startsAt!)
                .createdAt
                .toString()
                .split(' ')
                .first),
    ];
    if (facts.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            Row(
              children: [
                Icon(facts[i].$1, size: 18, color: context.textSecondary),
                const SizedBox(width: 10),
                Text(facts[i].$2,
                    style: TextStyle(
                        fontSize: 13, color: context.textSecondary)),
                const Spacer(),
                Flexible(
                  child: Text(facts[i].$3,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary)),
                ),
              ],
            ),
            if (i < facts.length - 1)
              Divider(height: 18, color: context.borderCol),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard(String title, String body) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body,
                style: TextStyle(
                    fontSize: 14, height: 1.5, color: context.textSecondary)),
          ],
        ),
      );

  // ── Bottom action bar ────────────────────────────────────────

  Widget _bottomBar(OpportunityModel o) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border(top: BorderSide(color: context.borderCol)),
        ),
        child: Row(
          children: [
            _IconAction(
              icon: o.isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: o.isSaved ? context.primary : context.textSecondary,
              onTap: () async {
                await ref
                    .read(opportunitySaveControllerProvider.notifier)
                    .toggle(o.id);
              },
            ),
            const SizedBox(width: 10),
            _ReminderAction(opportunity: o),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () => _apply(o),
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  o.stage == null ? 'Apply / Track' : 'Update status',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Apply & track flow ───────────────────────────────────────

  void _apply(OpportunityModel o) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ApplySheet(opportunity: o),
    );
  }

  void _report(OpportunityModel o) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReportSheet(opportunityId: o.id),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.white.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: context.textPrimary, size: 20),
            onPressed: onTap,
          ),
        ),
      );

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      );

  BoxDecoration _cardDeco() => BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderCol),
      );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

// ── Reminder toggle ────────────────────────────────────────────

class _ReminderAction extends ConsumerWidget {
  final OpportunityModel opportunity;
  const _ReminderAction({required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (opportunity.deadline == null) return const SizedBox.shrink();
    final hasReminder =
        ref.watch(reminderStateProvider(opportunity.id)).valueOrNull ?? false;
    return GestureDetector(
      onTap: () => _toggle(context, ref, hasReminder),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: hasReminder
              ? context.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          hasReminder ? Icons.notifications_active_rounded : Icons.alarm_add_rounded,
          color: hasReminder ? context.primary : context.textSecondary,
        ),
      ),
    );
  }

  Future<void> _toggle(
      BuildContext context, WidgetRef ref, bool hasReminder) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final repo = ref.read(opportunitiesRepositoryProvider);
    if (hasReminder) {
      await repo.clearReminders(user.id, opportunity.id);
      ref.invalidate(reminderStateProvider(opportunity.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reminders cleared'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
    final choice = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Remind me',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('We\'ll notify you before the deadline.',
                style: TextStyle(fontSize: 13, color: context.textSecondary)),
            const SizedBox(height: 12),
            ...kReminderOffsets.map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.alarm_rounded,
                      color: context.textSecondary),
                  title: Text(r.$1),
                  onTap: () => Navigator.pop(context, r.$2),
                )),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final remindAt =
        opportunity.deadline!.subtract(Duration(days: choice));
    await repo.setReminder(
      userId: user.id,
      opportunityId: opportunity.id,
      remindAt: remindAt,
    );
    ref.invalidate(reminderStateProvider(opportunity.id));
    ref.invalidate(upcomingDeadlinesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Reminder set'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

// ── Apply / track sheet ────────────────────────────────────────

class _ApplySheet extends ConsumerStatefulWidget {
  final OpportunityModel opportunity;
  const _ApplySheet({required this.opportunity});

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  late ApplicationStage _stage =
      widget.opportunity.stage ?? ApplicationStage.saved;
  final _notesCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.opportunity;
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: context.borderCol,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Apply & track',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          if (o.applicationUrl != null && o.applicationUrl!.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: o.applicationUrl!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Application link copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                ));
              },
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text('Copy application link'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),
          ],

          const Text('Your status',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ApplicationStage.values.map((s) {
              final sel = _stage == s;
              return ChoiceChip(
                label: Text(s.label),
                selected: sel,
                onSelected: (_) => setState(() => _stage = s),
                selectedColor: s.color.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                    color: sel ? s.color : context.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Notes (optional) — e.g. referee, documents needed',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (o.stage != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : _remove,
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: AppColors.error),
                    child: const Text('Remove'),
                  ),
                ),
              if (o.stage != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  style: FilledButton.styleFrom(
                      backgroundColor: context.primary,
                      minimumSize: const Size.fromHeight(48)),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save to tracker'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(opportunitiesRepositoryProvider).setStage(
            userId: user.id,
            opportunityId: widget.opportunity.id,
            stage: _stage,
            notes: _notesCtrl.text.trim(),
          );
      ref.invalidate(applicationsProvider);
      ref.invalidate(opportunityDetailProvider(widget.opportunity.id));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Saved to your tracker'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }

  Future<void> _remove() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    await ref
        .read(opportunitiesRepositoryProvider)
        .removeApplication(user.id, widget.opportunity.id);
    ref.invalidate(applicationsProvider);
    ref.invalidate(opportunityDetailProvider(widget.opportunity.id));
    if (mounted) Navigator.pop(context);
  }
}

// ── Report sheet ───────────────────────────────────────────────

class _ReportSheet extends ConsumerStatefulWidget {
  final String opportunityId;
  const _ReportSheet({required this.opportunityId});

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  String? _reason;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: context.borderCol,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Report opportunity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...kOpportunityReportReasons.map((r) {
            final sel = _reason == r;
            return InkWell(
              onTap: () => setState(() => _reason = r),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      sel
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 20,
                      color: sel ? AppColors.error : AppColors.grey3,
                    ),
                    const SizedBox(width: 12),
                    Text(r, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _reason == null || _busy ? null : _submit,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Submit report'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(opportunitiesRepositoryProvider).report(
            opportunityId: widget.opportunityId,
            reporterId: user.id,
            reason: _reason!,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Report submitted. Thank you.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }
}
