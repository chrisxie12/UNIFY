import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/opportunity_constants.dart';

class OpportunityTypeScreen extends ConsumerStatefulWidget {
  final String typeKey; // type key or 'all'
  const OpportunityTypeScreen({super.key, required this.typeKey});

  @override
  ConsumerState<OpportunityTypeScreen> createState() =>
      _OpportunityTypeScreenState();
}

class _OpportunityTypeScreenState
    extends ConsumerState<OpportunityTypeScreen> {
  OpportunityType? get _type =>
      widget.typeKey == 'all' ? null : OpportunityType.fromKey(widget.typeKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(opportunityFilterProvider.notifier).state =
          OpportunityFilter(type: _type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(opportunityFilterProvider);
    final async = ref.watch(opportunitiesProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: Text(_type?.label ?? 'All Opportunities',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: context.textPrimary)),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.tune_rounded, color: context.textPrimary),
                if (_activeFilterCount(filter) > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: context.primary, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filters',
            onPressed: () => _openFilters(filter),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort + count row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                async.maybeWhen(
                  data: (l) => Text('${l.length} results',
                      style: TextStyle(
                          fontSize: 13, color: context.textSecondary)),
                  orElse: () => const SizedBox.shrink(),
                ),
                const Spacer(),
                _SortMenu(
                  value: filter.sort,
                  onChanged: (v) => ref
                      .read(opportunityFilterProvider.notifier)
                      .state = filter.copyWith(sort: v),
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: (_type?.color ?? context.primary)
                                .withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_type?.icon ?? Icons.explore_rounded,
                              size: 32,
                              color: _type?.color ?? context.primary),
                        ),
                        const SizedBox(height: 14),
                        const Text('Nothing here yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Try adjusting your filters.',
                            style: TextStyle(
                                fontSize: 13, color: context.textSecondary)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: context.primary,
                  onRefresh: () async =>
                      ref.invalidate(opportunitiesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => OpportunityCard(
                      opportunity: items[i],
                      onTap: () => context
                          .push('/opportunities/detail/${items[i].id}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _activeFilterCount(OpportunityFilter f) {
    var n = 0;
    if (f.fundedOnly) n++;
    if (f.remoteOnly) n++;
    if (f.verifiedOnly) n++;
    if (f.field != null) n++;
    return n;
  }

  void _openFilters(OpportunityFilter filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        initial: filter,
        onApply: (f) =>
            ref.read(opportunityFilterProvider.notifier).state = f,
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SortMenu({required this.value, required this.onChanged});

  static const _labels = {
    'recent': 'Most recent',
    'deadline': 'Deadline (soonest)',
    'popular': 'Most viewed',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => _labels.entries
          .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      child: Row(
        children: [
          Icon(Icons.swap_vert_rounded, size: 18, color: context.primary),
          const SizedBox(width: 4),
          Text(_labels[value] ?? 'Sort',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.primary)),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final OpportunityFilter initial;
  final ValueChanged<OpportunityFilter> onApply;
  const _FilterSheet({required this.initial, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _funded = widget.initial.fundedOnly;
  late bool _remote = widget.initial.remoteOnly;
  late bool _verified = widget.initial.verifiedOnly;
  late String? _field = widget.initial.field;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const Text('Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _funded,
            onChanged: (v) => setState(() => _funded = v),
            title: const Text('Funded only', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: context.primary,
          ),
          SwitchListTile(
            value: _remote,
            onChanged: (v) => setState(() => _remote = v),
            title: const Text('Remote only', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: context.primary,
          ),
          SwitchListTile(
            value: _verified,
            onChanged: (v) => setState(() => _verified = v),
            title:
                const Text('Verified only', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: context.primary,
          ),
          const SizedBox(height: 12),
          const Text('Field of study',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kOpportunityFields.map((f) {
              final sel = _field == f;
              return ChoiceChip(
                label: Text(f),
                selected: sel,
                onSelected: (_) => setState(() => _field = sel ? null : f),
                selectedColor: context.primary.withValues(alpha: 0.12),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply(OpportunityFilter(
                      type: widget.initial.type,
                      query: widget.initial.query,
                      sort: widget.initial.sort,
                    ));
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(OpportunityFilter(
                      type: widget.initial.type,
                      query: widget.initial.query,
                      sort: widget.initial.sort,
                      fundedOnly: _funded,
                      remoteOnly: _remote,
                      verifiedOnly: _verified,
                      field: _field,
                    ));
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: context.primary,
                      minimumSize: const Size.fromHeight(48)),
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
