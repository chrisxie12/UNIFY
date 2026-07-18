import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../data/models/event_model.dart';
import '../providers/event_provider.dart';

IconData _categoryIcon(String category) {
  switch (category) {
    case 'academic':
      return Icons.school;
    case 'career':
      return Icons.work;
    case 'technology':
      return Icons.computer;
    case 'entertainment':
      return Icons.celebration;
    case 'sports':
      return Icons.sports_soccer;
    case 'religious':
      return Icons.church;
    case 'club_activities':
      return Icons.groups;
    case 'community_activities':
      return Icons.diversity_3;
    case 'workshops':
      return Icons.handyman;
    case 'seminars':
      return Icons.mic;
    case 'conferences':
      return Icons.forum;
    default:
      return Icons.event;
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'academic':
      return const Color(0xFF3B82F6);
    case 'career':
      return const Color(0xFF10B981);
    case 'technology':
      return const Color(0xFF8B5CF6);
    case 'entertainment':
      return const Color(0xFFF59E0B);
    case 'sports':
      return const Color(0xFFEF4444);
    case 'religious':
      return const Color(0xFFEC4899);
    case 'club_activities':
      return const Color(0xFF06B6D4);
    case 'community_activities':
      return const Color(0xFF2563EB);
    case 'workshops':
      return const Color(0xFFF97316);
    case 'seminars':
      return const Color(0xFF6366F1);
    case 'conferences':
      return const Color(0xFF14B8A6);
    default:
      return const Color(0xFF2563EB);
  }
}

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Trending'),
                  Tab(text: 'Featured'),
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
            scope: _selectedScope,
            category: _selectedCategory,
          ),
          _EventList(
            provider: trendingEventsProvider,
            scope: _selectedScope,
            category: _selectedCategory,
          ),
          _EventList(
            provider: featuredEventsProvider,
            scope: _selectedScope,
            category: _selectedCategory,
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          'all',
          'community',
          'faculty',
          'university',
          'campus',
        ].map((scope) {
          final active = _selectedScope == scope;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                scope == 'all'
                    ? 'All'
                    : scope[0].toUpperCase() + scope.substring(1),
                style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : null,
                ),
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
    required this.provider,
    this.scope = 'all',
    this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(provider);
    return eventsAsync.when(
      loading: () => const AppLoadingWidget.list(),
      error: (e, _) =>
          AppErrorWidget(e, onRetry: () => ref.invalidate(provider)),
      data: (events) {
        var filtered = events;
        if (scope != 'all') {
          filtered = filtered.where((e) => e.scope == scope).toList();
        }
        if (category != null) {
          filtered = filtered.where((e) => e.category == category).toList();
        }
        if (filtered.isEmpty) {
          return const AppEmptyWidget(
            icon: Icons.event_busy,
            title: 'No events found',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _EventCard(event: filtered[i]),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(event.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(_categoryIcon(event.category),
                  size: 48, color: catColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      event.formattedDate,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    if (event.location != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.location!,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text('Interested',
                          style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text('Going',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
