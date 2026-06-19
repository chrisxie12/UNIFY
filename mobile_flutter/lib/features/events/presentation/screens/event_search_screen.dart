import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/event_provider.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/design_system/components.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class EventSearchScreen extends ConsumerStatefulWidget {
  const EventSearchScreen({super.key});
  @override
  ConsumerState<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends ConsumerState<EventSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchEventsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.length < 2
          ? UEmptyState(
              icon: Icons.search,
              title: 'Search events',
              subtitle: 'Search by title, description, or location',
            )
          : resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (events) {
                if (events.isEmpty) {
                  return UEmptyState(
                    icon: Icons.search_off,
                    title: 'No results for "$_query"',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(USpacing.md),
                  itemCount: events.length,
                  itemBuilder: (_, i) {
                    final event = events[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: USpacing.sm),
                      child: ListTile(
                        leading: Container(
                          width: UIcon.x4, height: UIcon.x4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: URadius.smAll,
                          ),
                          child: Icon(Icons.event, color: theme.colorScheme.primary, size: UIcon.lg),
                        ),
                        title: Text(event.title, style: UText.bodyS),
                        subtitle: Text('${event.formattedDate} · ${event.scopeLabel}', style: UText.tiny.copyWith(color: context.textSecondary)),
                        trailing: const Icon(Icons.chevron_right, size: UIcon.md),
                        onTap: () => context.push('/event/${event.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
