import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/event_provider.dart';

class AdminEventDashboardScreen extends ConsumerWidget {
  const AdminEventDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Event Admin')),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (events) {
          final pending = events.where((e) => !e.isApproved && e.scope != 'community').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Pending Approval', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('No pending events', style: TextStyle(color: Colors.grey[500])),
                    ),
                  ),
                )
              else
                ...pending.map((event) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pending, color: Colors.orange, size: 20),
                    ),
                    title: Text(event.title, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('${event.scopeLabel} · ${event.formattedDate}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          onPressed: () async {
                            await ref.read(eventRepositoryProvider).approveEvent(event.id);
                            ref.invalidate(upcomingEventsProvider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                          onPressed: () {
                            ref.read(eventRepositoryProvider).deleteEvent(event.id);
                            ref.invalidate(upcomingEventsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                )),
              const SizedBox(height: 24),
              Text('All Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              ...events.map((event) => Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  dense: true,
                  title: Text(event.title, style: const TextStyle(fontSize: 13)),
                  subtitle: Text('${event.scopeLabel} · ${event.attendeeCount} attendees · ${event.isApproved ? "Approved" : "Pending"}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'feature') {
                        ref.read(eventRepositoryProvider).featureEvent(event.id);
                        ref.invalidate(upcomingEventsProvider);
                      }
                      if (v == 'remove') {
                        ref.read(eventRepositoryProvider).deleteEvent(event.id);
                        ref.invalidate(upcomingEventsProvider);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'feature', child: Text('Feature Event')),
                      const PopupMenuItem(value: 'remove', child: Text('Remove Event')),
                    ],
                  ),
                  onTap: () => context.push('/event/${event.id}'),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
