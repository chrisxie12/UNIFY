import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/listing_card.dart';
import '../widgets/marketplace_constants.dart';

/// Browse + filter listings for one category (or 'all').
class CategoryListingsScreen extends ConsumerStatefulWidget {
  final String categoryKey; // category key or 'all'
  const CategoryListingsScreen({super.key, required this.categoryKey});

  @override
  ConsumerState<CategoryListingsScreen> createState() =>
      _CategoryListingsScreenState();
}

class _CategoryListingsScreenState
    extends ConsumerState<CategoryListingsScreen> {
  MarketCategory? get _category =>
      widget.categoryKey == 'all' ? null : MarketCategory.fromKey(widget.categoryKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingFilterProvider.notifier).state =
          ListingFilter(category: _category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(listingFilterProvider);
    final listingsAsync = ref.watch(listingsProvider);
    final subs = _category != null ? kSubcategories[_category!] ?? const [] : const <String>[];

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: Text(_category?.label ?? 'All Listings',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: context.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: context.textPrimary),
            tooltip: 'Filters',
            onPressed: () => _openFilters(context, filter),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subcategory chips
          if (subs.isNotEmpty)
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _chip(
                    label: 'All',
                    selected: filter.subcategory == null,
                    onTap: () => ref
                        .read(listingFilterProvider.notifier)
                        .state = filter.copyWith(clearSub: true),
                  ),
                  for (final s in subs)
                    _chip(
                      label: s,
                      selected: filter.subcategory == s,
                      onTap: () => ref
                          .read(listingFilterProvider.notifier)
                          .state = filter.copyWith(subcategory: s),
                    ),
                ],
              ),
            ),

          // Sort row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            child: Row(
              children: [
                listingsAsync.maybeWhen(
                  data: (l) => Text('${l.length} results',
                      style: TextStyle(
                          fontSize: 13, color: context.textSecondary)),
                  orElse: () => const SizedBox.shrink(),
                ),
                const Spacer(),
                _SortDropdown(
                  value: filter.sort,
                  onChanged: (v) => ref
                      .read(listingFilterProvider.notifier)
                      .state = filter.copyWith(sort: v),
                ),
              ],
            ),
          ),

          Expanded(
            child: listingsAsync.when(
              loading: () => const AppLoadingWidget.list(),
              error: (e, _) => _errorState(e),
              data: (items) {
                if (items.isEmpty) return _emptyState();
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(listingsProvider),
                  color: context.primary,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 110),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ListingCard(
                      listing: items[i],
                      onTap: () => context
                          .push('/marketplace/listing/${items[i].id}'),
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

  Widget _chip(
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? context.primary
                : context.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? context.primary : context.borderCol),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : context.textSecondary)),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(_category?.icon ?? Icons.storefront_rounded,
                  size: 34, color: context.primary),
            ),
            const SizedBox(height: 14),
            Text('No listings yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary)),
            const SizedBox(height: 6),
            Text('Be the first to post in this category.',
                style: TextStyle(fontSize: 13, color: context.textSecondary)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.push('/marketplace/sell'),
              style: FilledButton.styleFrom(backgroundColor: context.primary),
              child: const Text('Create a listing'),
            ),
          ],
        ),
      );

  Widget _errorState(Object e) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 40, color: context.textDisabled),
              const SizedBox(height: 12),
              Text(ErrorMapper.toUserMessage(e),
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, color: context.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(listingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );

  void _openFilters(BuildContext context, ListingFilter filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        initial: filter,
        showCondition: _category?.usesCondition ?? true,
        onApply: (f) =>
            ref.read(listingFilterProvider.notifier).state = f,
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  static const _labels = {
    'recent': 'Most recent',
    'price_asc': 'Price: low to high',
    'price_desc': 'Price: high to low',
    'popular': 'Most popular',
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
  final ListingFilter initial;
  final bool showCondition;
  final ValueChanged<ListingFilter> onApply;
  const _FilterSheet({
    required this.initial,
    required this.showCondition,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final _minCtrl =
      TextEditingController(text: widget.initial.minPrice?.toStringAsFixed(0));
  late final _maxCtrl =
      TextEditingController(text: widget.initial.maxPrice?.toStringAsFixed(0));
  late final _locCtrl =
      TextEditingController(text: widget.initial.location);
  late String? _condition = widget.initial.condition;

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text('Price range (GHS)',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _numField(context, _minCtrl, 'Min')),
                const SizedBox(width: 12),
                Expanded(child: _numField(context, _maxCtrl, 'Max')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Location',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _locCtrl,
              decoration: _dec(context, 'e.g. Main campus, hostel name'),
            ),
            if (widget.showCondition) ...[
              const SizedBox(height: 16),
              const Text('Condition',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kConditions.map((c) {
                  final sel = _condition == c.$1;
                  return ChoiceChip(
                    label: Text(c.$2),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _condition = sel ? null : c.$1),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Build a fresh filter so price / location / condition
                      // actually clear (copyWith ignores nulls by design).
                      widget.onApply(ListingFilter(
                        category: widget.initial.category,
                        subcategory: widget.initial.subcategory,
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
                      widget.onApply(ListingFilter(
                        category: widget.initial.category,
                        subcategory: widget.initial.subcategory,
                        query: widget.initial.query,
                        sort: widget.initial.sort,
                        minPrice: double.tryParse(_minCtrl.text),
                        maxPrice: double.tryParse(_maxCtrl.text),
                        location: _locCtrl.text.trim().isEmpty
                            ? null
                            : _locCtrl.text.trim(),
                        condition: _condition,
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
      ),
    );
  }

  Widget _numField(BuildContext context, TextEditingController c, String hint) =>
      TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: _dec(context, hint),
      );

  InputDecoration _dec(BuildContext context, String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
      );
}