import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/listing_card.dart';

class MarketplaceSearchScreen extends ConsumerStatefulWidget {
  const MarketplaceSearchScreen({super.key});

  @override
  ConsumerState<MarketplaceSearchScreen> createState() =>
      _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState
    extends ConsumerState<MarketplaceSearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingFilterProvider.notifier).state = const ListingFilter();
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
      final filter = ref.read(listingFilterProvider);
      ref.read(listingFilterProvider.notifier).state =
          filter.copyWith(query: value.trim());
      setState(() => _searched = value.trim().isNotEmpty);
      if (value.trim().length > 2) {
        final uid = ref.read(currentUserProvider)?.id;
        ref.read(marketplaceRepositoryProvider).logSearch(uid, value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);

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
              Icon(Icons.search_rounded,
                  color: context.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search the marketplace…',
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
                  child: Icon(Icons.close_rounded,
                      size: 18, color: context.textSecondary),
                ),
            ],
          ),
        ),
      ),
      body: !_searched
          ? _suggestions()
          : listingsAsync.when(
              loading: () => const AppLoadingWidget.list(),
              error: (e, _) => AppErrorWidget(e),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text('No results found',
                        style: TextStyle(color: context.textSecondary)),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
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
                );
              },
            ),
    );
  }

  Widget _suggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Browse by category',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MarketCategory.values
              .map((c) => GestureDetector(
                    onTap: () =>
                        context.push('/marketplace/category/${c.key}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 15, color: c.color),
                          const SizedBox(width: 6),
                          Text(c.label,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: c.color)),
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
