import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/event_model.dart';
import '../providers/event_provider.dart';

class StudentEventProfileScreen extends ConsumerWidget {
  final String? userId;
  const StudentEventProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uid = userId ?? ref.read(currentUserIdProvider);
    if (uid == null) return const Center(child: Text('Not logged in'));

    final ticketsAsync = ref.watch(myTicketsProvider);
    final certsAsync = ref.watch(userCertificatesProvider);
    final savedAsync = ref.watch(savedEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Event Activity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsRow(ticketsAsync: ticketsAsync, theme: theme),
          const SizedBox(height: 24),
          Text('Registered Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          ticketsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (tickets) {
              if (tickets.isEmpty) {
                return const _EmptyState(icon: Icons.confirmation_number_outlined, message: 'No events registered yet');
              }
              return Column(
                children: tickets.take(5).map((t) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: t.attended ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(t.attended ? Icons.check : Icons.confirmation_number, color: t.attended ? Colors.green : Colors.blue, size: 20),
                  ),
                  title: Text(t.eventTitle ?? 'Event', style: const TextStyle(fontSize: 14)),
                  subtitle: Text(t.attended ? 'Attended' : 'Registered', style: TextStyle(fontSize: 11, color: t.attended ? Colors.green : Colors.blue)),
                  trailing: Text(t.formattedTimestamp, style: TextStyle(fontSize: 11, color: context.textSecondary])),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Certificates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          certsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (certs) {
              if (certs.isEmpty) {
                return const _EmptyState(icon: Icons.card_membership_outlined, message: 'No certificates yet');
              }
              return Column(
                children: certs.map((c) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.card_membership, color: Colors.amber, size: 20),
                  ),
                  title: Text(c.title, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(c.certificateTypeLabel, style: TextStyle(fontSize: 11, color: context.textSecondary])),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Saved Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          savedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (events) {
              if (events.isEmpty) {
                return const _EmptyState(icon: Icons.bookmark_border, message: 'No saved events');
              }
              return Column(
                children: events.map((e) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.event, color: theme.colorScheme.primary, size: 20),
                  ),
                  title: Text(e.title, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(e.formattedDate, style: TextStyle(fontSize: 11, color: context.textSecondary])),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/event/${e.id}'),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AsyncValue<List<EventTicketModel>> ticketsAsync;
  final ThemeData theme;
  const _StatsRow({required this.ticketsAsync, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ticketsAsync.when(
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('$e'),
      data: (tickets) {
        final registered = tickets.length;
        final attended = tickets.where((t) => t.attended).length;
        final missed = registered - attended;
        return Row(children: [
          _StatCard(label: 'Registered', value: '$registered', color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          _StatCard(label: 'Attended', value: '$attended', color: Colors.green),
          const SizedBox(width: 8),
          _StatCard(label: 'Missed', value: '$missed', color: Colors.red),
        ]);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary])),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: context.textSecondary]),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: context.textSecondary], fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
