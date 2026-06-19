import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/event_model.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/event_provider.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class OrganizerDashboardScreen extends ConsumerWidget {
  final String eventId;
  const OrganizerDashboardScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final analyticsAsync = ref.watch(attendanceAnalyticsProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Dashboard')),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(eventDetailProvider(eventId))),
        data: (event) {
          final userId = ref.read(currentUserIdProvider);
          final isOrganizer = event.creatorId == userId;
          if (!isOrganizer) {
            return const Center(child: Text('Only the event organizer can access this dashboard'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _EventSummaryCard(event: event, theme: theme),
              const SizedBox(height: 16),
              analyticsAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: AppErrorWidget(e)),
                data: (analytics) => _AnalyticsCards(analytics: analytics, theme: theme),
              ),
              const SizedBox(height: 16),
              _ActionGrid(event: event, theme: theme),
              const SizedBox(height: 16),
              _AttendeeListSection(eventId: eventId),
            ],
          );
        },
      ),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  final EventModel event;
  final ThemeData theme;
  const _EventSummaryCard({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.calendar_today, size: 14, color: context.textSecondary),
              const SizedBox(width: 4),
              Text(event.formattedDate, style: TextStyle(fontSize: 13, color: context.textSecondary)),
              const SizedBox(width: 12),
              Icon(Icons.people, size: 14, color: context.textSecondary),
              const SizedBox(width: 4),
              Text('${event.attendeeCount} attendees', style: TextStyle(fontSize: 13, color: context.textSecondary)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCards extends StatelessWidget {
  final EventAttendanceAnalytics analytics;
  final ThemeData theme;
  const _AnalyticsCards({required this.analytics, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _AnalyticCard(label: 'Registered', value: '${analytics.totalRegistrations}', color: theme.colorScheme.primary),
      const SizedBox(width: 8),
      _AnalyticCard(label: 'Checked In', value: '${analytics.totalCheckIns}', color: Colors.green),
      const SizedBox(width: 8),
      _AnalyticCard(label: 'Rate', value: '${analytics.attendanceRate.toStringAsFixed(0)}%', color: Colors.orange),
      const SizedBox(width: 8),
      _AnalyticCard(label: 'No-Shows', value: '${analytics.noShows}', color: Colors.red),
    ]);
  }
}

class _AnalyticCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AnalyticCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final EventModel event;
  final ThemeData theme;
  const _ActionGrid({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ActionCard(icon: Icons.edit, label: 'Edit Event', onTap: () => context.push('/events/${event.id}/edit'))),
          const SizedBox(width: 8),
          Expanded(child: _ActionCard(icon: Icons.qr_code_scanner, label: 'Check-In', onTap: () => context.push('/events/${event.id}/checkin'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _ActionCard(icon: Icons.download, label: 'Export List', onTap: () {})),
          const SizedBox(width: 8),
          Expanded(child: _ActionCard(icon: Icons.campaign, label: 'Announcement', onTap: () {})),
        ]),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.textSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.textSecondary),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: context.textSecondary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _AttendeeListSection extends ConsumerWidget {
  final String eventId;
  const _AttendeeListSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(eventTicketsProvider(eventId));
    return ticketsAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => AppErrorWidget(e),
      data: (tickets) {
        final checkedIn = tickets.where((t) => t.attended).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Registrations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$checkedIn / ${tickets.length}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
            ]),
            const SizedBox(height: 8),
            if (tickets.isEmpty)
              Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('No registrations yet', style: TextStyle(color: context.textSecondary))))
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (_, i) {
                    final t = tickets[i];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: t.attended ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(t.attended ? Icons.check : Icons.hourglass_empty, size: 16, color: t.attended ? Colors.green : Colors.orange),
                      ),
                      title: Text(t.ticketNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(t.registrationTimestamp.toString().substring(0, 16), style: TextStyle(fontSize: 11, color: context.textSecondary)),
                      trailing: Text(t.attended ? 'Checked In' : 'Pending', style: TextStyle(fontSize: 11, color: t.attended ? Colors.green : Colors.orange)),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
