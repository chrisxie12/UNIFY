import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unify/features/academic/data/models/academic_models.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';

// Gradient pairs assigned to cards by index — cycles every 8
const _kGradients = [
  [Color(0xFF667EEA), Color(0xFF764BA2)],
  [Color(0xFFF093FB), Color(0xFFF5576C)],
  [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  [Color(0xFF43E97B), Color(0xFF38F9D7)],
  [Color(0xFFFFA726), Color(0xFFFF7043)],
  [Color(0xFFFC5C7D), Color(0xFF6A3093)],
  [Color(0xFF2196F3), Color(0xFF21CBF3)],
  [Color(0xFFA8FF78), Color(0xFF78FFD6)],
];

const _kEmojis = ['📚', '🎯', '💡', '🧪', '📝', '🔬', '📐', '🎓'];

enum _Filter { all, active, done, examSoon }

class StudyPlannerScreen extends ConsumerStatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  ConsumerState<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends ConsumerState<StudyPlannerScreen> {
  final _titleController = TextEditingController();
  DateTime? _examDate;
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _createPlan() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    ref.read(academicProvider.notifier).createStudyPlan(title, examDate: _examDate);
    _titleController.clear();
    setState(() => _examDate = null);
    ref.invalidate(studyPlansProvider);
  }

  List<StudyPlanModel> _filtered(List<StudyPlanModel> all) {
    final now = DateTime.now();
    switch (_filter) {
      case _Filter.active:
        return all.where((p) => p.isActive && p.progress < 1.0).toList();
      case _Filter.done:
        return all.where((p) => p.progress >= 1.0).toList();
      case _Filter.examSoon:
        final cutoff = now.add(const Duration(days: 7));
        return all.where((p) =>
            p.examDate != null &&
            p.examDate!.isAfter(now) &&
            p.examDate!.isBefore(cutoff)).toList();
      case _Filter.all:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(studyPlansProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: plansAsync.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(studyPlansProvider)),
        data: (all) {
          final plans = _filtered(all);
          return CustomScrollView(
            slivers: [
              _AppBar(total: all.length),
              SliverToBoxAdapter(child: _FilterRow(
                current: _filter,
                all: all,
                onChanged: (f) => setState(() => _filter = f),
              )),
              if (plans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onAdd: () => _showSheet(context)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 96),
                  sliver: SliverToBoxAdapter(
                    child: _MasonryGrid(plans: plans),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderSubtle,
                    borderRadius: URadius.pillAll,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('New Study Plan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g., Database Systems Revision',
                  prefixIcon: const Icon(Icons.auto_stories_rounded),
                  border: OutlineInputBorder(borderRadius: URadius.mdAll),
                  filled: true,
                  fillColor: context.surfaceFill,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _examDate = date);
                    setSheet(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.surfaceFill,
                    borderRadius: URadius.mdAll,
                    border: Border.all(color: context.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded,
                          size: 18, color: context.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _examDate != null
                              ? 'Exam: ${DateFormat('MMM d, yyyy').format(_examDate!)}'
                              : 'Set exam date (optional)',
                          style: TextStyle(
                            color: _examDate != null
                                ? context.textPrimary
                                : context.textSecondary,
                          ),
                        ),
                      ),
                      if (_examDate != null)
                        GestureDetector(
                          onTap: () {
                            setState(() => _examDate = null);
                            setSheet(() {});
                          },
                          child: Icon(Icons.close_rounded,
                              size: 16, color: context.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createPlan();
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: URadius.mdAll),
                  ),
                  child: const Text('Create Plan',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final int total;
  const _AppBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.appBarBg,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Study Plans',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          Text('$total plan${total == 1 ? '' : 's'}',
              style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w400)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Filter',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.surfaceFill,
              borderRadius: URadius.smAll,
            ),
            child: const Icon(Icons.tune_rounded, size: 18),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Filter chips row ─────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final _Filter current;
  final List<StudyPlanModel> all;
  final ValueChanged<_Filter> onChanged;

  const _FilterRow(
      {required this.current, required this.all, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));

    final chips = [
      (_Filter.all, 'All', all.length, context.primary),
      (_Filter.active, 'Active',
          all.where((p) => p.isActive && p.progress < 1.0).length,
          context.info),
      (_Filter.done, 'Done',
          all.where((p) => p.progress >= 1.0).length, context.success),
      (_Filter.examSoon, 'Exam Soon',
          all.where((p) =>
              p.examDate != null &&
              p.examDate!.isAfter(now) &&
              p.examDate!.isBefore(soon)).length,
          context.error),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((c) {
            final selected = current == c.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(c.$1),
                child: AnimatedContainer(
                  duration: UMotion.fast,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? c.$4 : context.surfaceFill,
                    borderRadius: URadius.pillAll,
                    border: Border.all(
                      color: selected ? c.$4 : context.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : context.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.25)
                              : context.surfaceDivider,
                          borderRadius: URadius.pillAll,
                        ),
                        child: Text(
                          '${c.$3}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Two-column masonry grid ──────────────────────────────────────────────────

class _MasonryGrid extends StatelessWidget {
  final List<StudyPlanModel> plans;
  const _MasonryGrid({required this.plans});

  @override
  Widget build(BuildContext context) {
    final left = <(int, StudyPlanModel)>[];
    final right = <(int, StudyPlanModel)>[];
    for (var i = 0; i < plans.length; i++) {
      (i.isEven ? left : right).add((i, plans[i]));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: left
                .map((e) => _PinCard(
                    plan: e.$2,
                    gradientIndex: e.$1 % _kGradients.length))
                .toList(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: right
                .map((e) => _PinCard(
                    plan: e.$2,
                    gradientIndex: e.$1 % _kGradients.length))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Individual pin card ──────────────────────────────────────────────────────

class _PinCard extends StatelessWidget {
  final StudyPlanModel plan;
  final int gradientIndex;
  const _PinCard({required this.plan, required this.gradientIndex});

  @override
  Widget build(BuildContext context) {
    final colors = _kGradients[gradientIndex];
    final emoji = _kEmojis[gradientIndex % _kEmojis.length];
    final progress = plan.progress;
    final done = plan.items.where((i) => i.isCompleted).length;
    final daysLeft = plan.examDate != null
        ? plan.examDate!.difference(DateTime.now()).inDays
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: URadius.lgAll,
        boxShadow: context.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gradient header with progress ring ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.30),
                            color: Colors.white,
                            strokeWidth: 3.5,
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Task count
                    if (plan.items.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _Chip(
                        label: '$done/${plan.items.length} tasks',
                        bg: context.surfaceFill,
                        fg: context.textSecondary,
                      ),
                    ],

                    // Exam countdown
                    if (daysLeft != null) ...[
                      const SizedBox(height: 5),
                      _ExamChip(daysLeft: daysLeft),
                    ],

                    // Task preview
                    if (plan.items.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...plan.items.take(3).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  item.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  size: 12,
                                  color: item.isCompleted
                                      ? colors[0]
                                      : context.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: item.isCompleted
                                          ? context.textSecondary
                                          : context.textPrimary,
                                      decoration: item.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (plan.items.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '+${plan.items.length - 3} more',
                            style: TextStyle(
                                fontSize: 10,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable chip ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: URadius.pillAll),
      child: Text(label,
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Exam countdown chip ───────────────────────────────────────────────────────

class _ExamChip extends StatelessWidget {
  final int daysLeft;
  const _ExamChip({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final Color accent;
    final Color bg;
    final String label;

    if (daysLeft < 0) {
      accent = context.textSecondary;
      bg = context.surfaceFill;
      label = 'Exam passed';
    } else if (daysLeft == 0) {
      accent = context.error;
      bg = context.errorBg;
      label = 'Exam today!';
    } else if (daysLeft <= 7) {
      accent = context.error;
      bg = context.errorBg;
      label = '${daysLeft}d left';
    } else if (daysLeft <= 30) {
      accent = context.warning;
      bg = context.warningBg;
      label = '${daysLeft}d left';
    } else {
      accent = context.info;
      bg = context.infoBg;
      label = '${daysLeft}d left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: URadius.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, size: 10, color: accent),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: URadius.xlAll,
            ),
            child: const Icon(Icons.auto_stories_rounded,
                size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text('No study plans yet',
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Tap + New Plan to get started',
              style:
                  TextStyle(color: context.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create your first plan',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: URadius.pillAll),
            ),
          ),
        ],
      ),
    );
  }
}
