import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';
import '../widgets/opportunity_card.dart';
import '../../../../core/extensions/theme_extensions.dart';

class OpportunitySearchScreen extends ConsumerStatefulWidget {
  const OpportunitySearchScreen({super.key});

  @override
  ConsumerState<OpportunitySearchScreen> createState() =>
      _OpportunitySearchScreenState();
}

class _OpportunitySearchScreenState
    extends ConsumerState<OpportunitySearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(opportunityFilterProvider.notifier).state =
          const OpportunityFilter();
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final f = ref.read(opportunityFilterProvider);
      ref.read(opportunityFilterProvider.notifier).state =
          f.copyWith(query: value.trim());
      setState(() => _searched = value.trim().isNotEmpty);
      if (value.trim().length > 2) {
        final uid = ref.read(currentUserProvider)?.id;
        ref.read(opportunitiesRepositoryProvider).logSearch(uid, value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(opportunitiesProvider);
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: context.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search opportunities…',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    _onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: context.textSecondary),
                ),
            ],
          ),
        ),
      ),
      body: !_searched
          ? _browseByType()
          : async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e),
              data: (items) => items.isEmpty
                  ? const Center(
                      child: Text('No results found',
                          style: TextStyle(color: context.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (_, i) => OpportunityCard(
                        opportunity: items[i],
                        onTap: () => context
                            .push('/opportunities/detail/${items[i].id}'),
                      ),
                    ),
            ),
    );
  }

  Widget _browseByType() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Browse by type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: OpportunityType.values
              .map((t) => GestureDetector(
                    onTap: () =>
                        context.push('/opportunities/type/${t.key}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 15, color: t.color),
                          const SizedBox(width: 6),
                          Text(t.label,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: t.color)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
