import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/event_model.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/design_system/components.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedScope = 'all';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/events/search'),
          ),
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined),
            onPressed: () => context.push('/events/my-tickets'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              _buildScopeChips(theme),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Upcoming'), Tab(text: 'Trending'), Tab(text: 'Featured'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: context.textSecondary,
                indicatorColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EventList(
            provider: upcomingEventsProvider,
            scope: _selectedScope, category: _selectedCategory,
          ),
          _EventList(
            provider: trendingEventsProvider,
            scope: _selectedScope, category: _selectedCategory,
          ),
          _EventList(
            provider: featuredEventsProvider,
            scope: _selectedScope, category: _selectedCategory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/events/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScopeChips(ThemeData theme) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: USpacing.base),
        children: [
          'all', 'community', 'faculty', 'university', 'campus',
        ].map((scope) {
          final active = _selectedScope == scope;
          return Padding(
            padding: const EdgeInsets.only(right: USpacing.sm),
            child: ChoiceChip(
              label: Text(
                scope == 'all' ? 'All' : scope[0].toUpperCase() + scope.substring(1),
                style: UText.caption.copyWith(color: active ? Colors.white : null),
              ),
              selected: active,
              selectedColor: theme.colorScheme.primary,
              onSelected: (_) => setState(() => _selectedScope = scope),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EventList extends ConsumerWidget {
  final FutureProvider<List<EventModel>> provider;
  final String scope;
  final String? category;

  const _EventList({
    required this.provider, this.scope = 'all', this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(provider);
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (events) {
        var filtered = events;
        if (scope != 'all') {
          filtered = filtered.where((e) => e.scope == scope).toList();
        }
        if (category != null) {
          filtered = filtered.where((e) => e.category == category).toList();
        }
        if (filtered.isEmpty) {
          return const UEmptyState(
            icon: Icons.event_busy,
            title: 'No events found',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(USpacing.md),
          itemCount: filtered.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: USpacing.md),
            child: EventCard(event: filtered[i]),
          ),
        );
      },
    );
  }
}
