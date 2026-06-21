import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../providers/search_provider.dart';

// ── Tab configuration ─────────────────────────────────────────────────────────

typedef _TabSpec = (SearchCategory, String, IconData);

const _kTabs = <_TabSpec>[
  (SearchCategory.all,         'All',          Icons.grid_view_rounded),
  (SearchCategory.people,      'People',       Icons.person_outlined),
  (SearchCategory.communities, 'Communities',  Icons.groups_outlined),
  (SearchCategory.events,      'Events',       Icons.event_outlined),
  (SearchCategory.academic,    'Academic',     Icons.school_outlined),
  (SearchCategory.marketplace, 'Marketplace',  Icons.storefront_outlined),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late final TabController _tabCtrl;
  Timer? _debounce;
  String _query = '';

  // Pagination state per category (excludes "all")
  final _items    = <SearchCategory, List<Map<String, dynamic>>>{};
  final _offsets  = <SearchCategory, int>{};
  final _hasMore  = <SearchCategory, bool>{};
  final _loading  = <SearchCategory, bool>{};
  final _loadingM = <SearchCategory, bool>{};
  final _loaded   = <SearchCategory, bool>{};
  final _errors   = <SearchCategory, Object?>{};
  final _scrolls  = <SearchCategory, ScrollController>{};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _kTabs.length, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
    for (final (cat, _, __) in _kTabs) {
      if (cat == SearchCategory.all) continue;
      _items[cat]    = [];
      _offsets[cat]  = 0;
      _hasMore[cat]  = true;
      _loading[cat]  = false;
      _loadingM[cat] = false;
      _loaded[cat]   = false;
      _errors[cat]   = null;
      _scrolls[cat]  = ScrollController()
        ..addListener(() => _onScroll(cat));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _tabCtrl.dispose();
    _debounce?.cancel();
    for (final s in _scrolls.values) s.dispose();
    super.dispose();
  }

  // ── Query handling ────────────────────────────────────────────────────────

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final q = v.trim();
      final changed = q != _query;
      setState(() => _query = q);
      if (q.length >= 2) {
        if (changed) _resetAll();
        final (cat, _, __) = _kTabs[_tabCtrl.index];
        if (cat != SearchCategory.all) _load(cat);
        ref.read(recentSearchesProvider.notifier).add(q);
      }
    });
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _query = '');
    _resetAll();
    _focus.requestFocus();
  }

  void _applyRecent(String q) {
    _ctrl.text = q;
    _ctrl.selection = TextSelection.collapsed(offset: q.length);
    _onChanged(q);
  }

  void _switchToTab(SearchCategory cat) {
    final i = _kTabs.indexWhere((t) => t.$1 == cat);
    if (i >= 0) _tabCtrl.animateTo(i);
  }

  void _onTabChanged() {
    if (_tabCtrl.indexIsChanging) return;
    final (cat, _, __) = _kTabs[_tabCtrl.index];
    if (cat != SearchCategory.all && _query.length >= 2 && !(_loaded[cat] ?? false)) {
      _load(cat);
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  void _resetAll() {
    setState(() {
      for (final (cat, _, __) in _kTabs) {
        if (cat == SearchCategory.all) continue;
        _items[cat]    = [];
        _offsets[cat]  = 0;
        _hasMore[cat]  = true;
        _loading[cat]  = false;
        _loadingM[cat] = false;
        _loaded[cat]   = false;
        _errors[cat]   = null;
      }
    });
  }

  Future<void> _load(SearchCategory cat, {bool more = false}) async {
    if (more) {
      if (_loadingM[cat] == true || _hasMore[cat] == false) return;
    } else {
      if (_loading[cat] == true) return;
    }

    final offset = more ? (_offsets[cat] ?? 0) : 0;

    setState(() {
      if (more) { _loadingM[cat] = true; }
      else      { _loading[cat] = true; _errors[cat] = null; }
    });

    try {
      final page = await ref.read(
        categorySearchProvider((query: _query, category: cat, offset: offset)).future,
      );
      if (!mounted) return;
      setState(() {
        final prev = more ? (_items[cat] ?? []) : <Map<String, dynamic>>[];
        _items[cat]   = [...prev, ...page.items];
        _offsets[cat] = offset + page.items.length;
        _hasMore[cat] = page.hasMore;
        if (more) { _loadingM[cat] = false; }
        else      { _loading[cat] = false; _loaded[cat] = true; }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingM[cat] = false;
        _loading[cat]  = false;
        if (!more) _errors[cat] = e;
      });
    }
  }

  void _onScroll(SearchCategory cat) {
    final s = _scrolls[cat];
    if (s == null || !s.hasClients) return;
    if (s.position.pixels >= s.position.maxScrollExtent - 280) {
      _load(cat, more: true);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _SearchBar(
          controller: _ctrl,
          focus: _focus,
          query: _query,
          onChanged: _onChanged,
          onClear: _clear,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _kTabs.map((t) {
              final (_, label, icon) = t;
              return Tab(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15),
                    const SizedBox(width: 5),
                    Text(label, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _kTabs.map((t) {
          final (cat, _, __) = t;
          if (cat == SearchCategory.all) {
            return _AllTab(
              query: _query,
              onSeeAll: _switchToTab,
              onRecentTap: _applyRecent,
            );
          }
          return _CategoryTab(
            category: cat,
            query: _query,
            items: _items[cat] ?? [],
            isLoading: _loading[cat] ?? false,
            isLoadingMore: _loadingM[cat] ?? false,
            hasMore: _hasMore[cat] ?? false,
            error: _errors[cat],
            scroll: _scrolls[cat]!,
            onRetry: () => _load(cat),
            onRecentTap: _applyRecent,
          );
        }).toList(),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focus,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      decoration: BoxDecoration(
        color: context.surfaceFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        focusNode: focus,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 15, color: context.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search students, events, courses…',
          hintStyle: TextStyle(color: context.textDisabled, fontSize: 15),
          prefixIcon: Icon(Icons.search, size: 20, color: context.textDisabled),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.cancel, size: 18, color: context.textDisabled),
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── All Tab ───────────────────────────────────────────────────────────────────

class _AllTab extends ConsumerWidget {
  const _AllTab({
    required this.query,
    required this.onSeeAll,
    required this.onRecentTap,
  });

  final String query;
  final void Function(SearchCategory) onSeeAll;
  final ValueChanged<String> onRecentTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.length < 2) {
      return _RecentPanel(onTap: onRecentTap);
    }

    final async = ref.watch(globalSearchProvider(query));
    return async.when(
      loading: () => const AppLoadingWidget.list(itemCount: 5),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(globalSearchProvider(query)),
      ),
      data: (results) {
        if (results.isEmpty) return _EmptyState(query: query);
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (results.students.isNotEmpty)
              _Section(
                title: 'People',
                count: results.students.length,
                category: SearchCategory.people,
                onSeeAll: onSeeAll,
                children: results.students.map((d) => _PersonTile(data: d)).toList(),
              ),
            if (results.communities.isNotEmpty)
              _Section(
                title: 'Communities',
                count: results.communities.length,
                category: SearchCategory.communities,
                onSeeAll: onSeeAll,
                children: results.communities.map((d) => _CommunityTile(data: d)).toList(),
              ),
            if (results.events.isNotEmpty)
              _Section(
                title: 'Events',
                count: results.events.length,
                category: SearchCategory.events,
                onSeeAll: onSeeAll,
                children: results.events.map((d) => _EventTile(data: d)).toList(),
              ),
            if (results.courses.isNotEmpty || results.resources.isNotEmpty)
              _Section(
                title: 'Academic',
                count: results.courses.length + results.resources.length,
                category: SearchCategory.academic,
                onSeeAll: onSeeAll,
                children: [
                  ...results.courses.map((d) => _CourseTile(data: d)),
                  ...results.resources.map((d) => _ResourceTile(data: d)),
                ],
              ),
            if (results.listings.isNotEmpty || results.freelancers.isNotEmpty)
              _Section(
                title: 'Marketplace',
                count: results.listings.length + results.freelancers.length,
                category: SearchCategory.marketplace,
                onSeeAll: onSeeAll,
                children: [
                  ...results.listings.map((d) => _ListingTile(data: d)),
                  ...results.freelancers.map((d) => _FreelancerTile(data: d)),
                ],
              ),
            if (results.opportunities.isNotEmpty)
              _Section(
                title: 'Opportunities',
                count: results.opportunities.length,
                category: null,
                onSeeAll: onSeeAll,
                children: results.opportunities.map((d) => _OpportunityTile(data: d)).toList(),
              ),
          ],
        );
      },
    );
  }
}

// ── Category Tab ──────────────────────────────────────────────────────────────

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.category,
    required this.query,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
    required this.scroll,
    required this.onRetry,
    required this.onRecentTap,
  });

  final SearchCategory category;
  final String query;
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
  final ScrollController scroll;
  final VoidCallback onRetry;
  final ValueChanged<String> onRecentTap;

  @override
  Widget build(BuildContext context) {
    if (query.length < 2) {
      return _RecentPanel(onTap: onRecentTap);
    }
    if (isLoading) {
      return const AppLoadingWidget.list(itemCount: 6);
    }
    if (error != null) {
      return _ErrorState(onRetry: onRetry);
    }
    if (items.isEmpty) {
      return _EmptyState(query: query, category: category);
    }

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final d = items[i];
        return switch (category) {
          SearchCategory.people      => _PersonTile(data: d),
          SearchCategory.communities => _CommunityTile(data: d),
          SearchCategory.events      => _EventTile(data: d),
          SearchCategory.academic    => _academicTile(d),
          SearchCategory.marketplace => _marketplaceTile(d),
          SearchCategory.all         => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _academicTile(Map<String, dynamic> d) {
    return d['_type'] == 'course'
        ? _CourseTile(data: d)
        : _ResourceTile(data: d);
  }

  Widget _marketplaceTile(Map<String, dynamic> d) {
    return d['_type'] == 'listing'
        ? _ListingTile(data: d)
        : _FreelancerTile(data: d);
  }
}

// ── Section wrapper (All tab) ─────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.count,
    required this.category,
    required this.onSeeAll,
    required this.children,
  });

  final String title;
  final int count;
  final SearchCategory? category;
  final void Function(SearchCategory) onSeeAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      )),
              const SizedBox(width: 6),
              _CountBadge(count: count),
              const Spacer(),
              if (category != null)
                TextButton(
                  onPressed: () => onSeeAll(category!),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See all',
                          style: TextStyle(fontSize: 13, color: context.primary)),
                      Icon(Icons.chevron_right, size: 16, color: context.primary),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.primary,
        ),
      ),
    );
  }
}

// ── Recent searches panel ─────────────────────────────────────────────────────

class _RecentPanel extends ConsumerWidget {
  const _RecentPanel({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentSearchesProvider);
    final notifier = ref.read(recentSearchesProvider.notifier);

    if (recents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 64,
                color: context.textDisabled),
            const SizedBox(height: 12),
            Text('Search everything',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
            const SizedBox(height: 6),
            Text(
              'Students, communities, events, courses\nand more across UNIFY',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
          child: Row(
            children: [
              Text('Recent',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700, color: context.textPrimary)),
              const Spacer(),
              TextButton(
                onPressed: notifier.clear,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
                child: Text('Clear all',
                    style: TextStyle(fontSize: 13, color: context.textSecondary)),
              ),
            ],
          ),
        ),
        ...recents.map((q) => ListTile(
              dense: true,
              leading: Icon(Icons.history, size: 20, color: context.textSecondary),
              title: Text(q, style: TextStyle(fontSize: 14, color: context.textPrimary)),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 16, color: context.textDisabled),
                onPressed: () => notifier.remove(q),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              onTap: () => onTap(q),
            )),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, this.category});
  final String query;
  final SearchCategory? category;

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {
      SearchCategory.people      => 'people',
      SearchCategory.communities => 'communities',
      SearchCategory.events      => 'events',
      SearchCategory.academic    => 'academic content',
      SearchCategory.marketplace => 'marketplace items',
      _                          => 'results',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: context.textDisabled),
          const SizedBox(height: 12),
          Text('No $label found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 6),
          Text(
            'Try different keywords for "$query"',
            style: TextStyle(fontSize: 14, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: context.textDisabled),
          const SizedBox(height: 12),
          Text('Search failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 6),
          Text('Check your connection and try again',
              style: TextStyle(fontSize: 14, color: context.textSecondary)),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Result tiles ──────────────────────────────────────────────────────────────

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final subtitle = [data['programme'], data['department']]
        .whereType<String>()
        .join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _Avatar(url: data['avatar_url'] as String?, fallback: Icons.person),
      title: Text(data['full_name'] ?? 'Unknown',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: Icon(Icons.chevron_right, size: 18, color: context.textDisabled),
      onTap: () => context.push('/app/profile'),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final members = data['member_count'] as int? ?? 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _Avatar(url: data['avatar_url'] as String?, fallback: Icons.groups),
      title: Text(data['name'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: Text('$members member${members == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 12, color: context.textSecondary)),
      trailing: Icon(Icons.chevron_right, size: 18, color: context.textDisabled),
      onTap: () {
        final id = data['id'] as String?;
        if (id != null) context.push('/community/$id');
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final venue = data['venue'] as String?;
    final date  = data['event_date'] as String?;
    final sub   = [date, venue].whereType<String>().join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: Icons.event_rounded, color: context.catEvents),
      title: Text(data['title'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: sub.isNotEmpty
          ? Text(sub,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: Icon(Icons.chevron_right, size: 18, color: context.textDisabled),
      onTap: () {
        final id = data['id'] as String?;
        if (id != null) context.push('/event/$id');
      },
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final code = data['code'] as String? ?? '';
    final dept = data['department'] as String? ?? '';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: Icons.menu_book_rounded, color: context.primary),
      title: Text(data['name'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: Text('$code${dept.isNotEmpty ? ' · $dept' : ''}',
          style: TextStyle(fontSize: 12, color: context.textSecondary),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chevron_right, size: 18, color: context.textDisabled),
      onTap: () {
        final id = data['id'] as String?;
        if (id != null) context.push('/academic/course/$id');
      },
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final fileType = data['file_type'] as String? ?? 'file';
    final icon = switch (fileType) {
      'pdf'   => Icons.picture_as_pdf_rounded,
      'video' => Icons.videocam_rounded,
      'image' => Icons.image_rounded,
      _       => Icons.description_rounded,
    };
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: icon, color: context.primary.withValues(alpha: 0.7)),
      title: Text(data['title'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: Text(fileType.toUpperCase(),
          style: TextStyle(fontSize: 12, color: context.textSecondary)),
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final price = data['price'];
    final condition = data['condition'] as String?;
    final priceStr = price != null ? 'GH₵ $price' : '';
    final sub = [priceStr, condition].where((s) => s != null && s.isNotEmpty).join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: Icons.sell_rounded, color: Colors.orange),
      title: Text(data['title'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: sub.isNotEmpty
          ? Text(sub, style: TextStyle(fontSize: 12, color: context.textSecondary))
          : null,
    );
  }
}

class _FreelancerTile extends StatelessWidget {
  const _FreelancerTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final rate = data['hourly_rate'];
    final rateStr = rate != null ? 'GH₵ $rate/hr' : '';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _Avatar(url: data['profile_image_url'] as String?, fallback: Icons.work),
      title: Text(data['headline'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: rateStr.isNotEmpty
          ? Text(rateStr, style: TextStyle(fontSize: 12, color: context.textSecondary))
          : null,
    );
  }
}

class _OpportunityTile extends StatelessWidget {
  const _OpportunityTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final sub = [data['organization'], data['type']]
        .whereType<String>()
        .join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: Icons.work_outline_rounded, color: Colors.green),
      title: Text(data['title'] ?? '',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.textPrimary)),
      subtitle: sub.isNotEmpty
          ? Text(sub,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
    );
  }
}

// ── Shared tile atoms ─────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallback});
  final String? url;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: context.surfaceFill,
      backgroundImage: url != null ? CachedNetworkImageProvider(url!) : null,
      child: url == null
          ? Icon(fallback, size: 20, color: context.textSecondary)
          : null,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
