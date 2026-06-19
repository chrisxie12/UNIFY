import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/event_model.dart';
import '../providers/event_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return eventAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (event) => _EventDetailContent(
        event: event, theme: theme, ref: ref, eventId: widget.eventId,
      ),
    );
  }
}

class _EventDetailContent extends ConsumerWidget {
  final EventModel event;
  final ThemeData theme;
  final WidgetRef ref;
  final String eventId;

  const _EventDetailContent({
    required this.event, required this.theme, required this.ref, required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final isOrganizer = event.creatorId == ref.read(currentUserIdProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isOrganizer),
          SliverToBoxAdapter(child: _buildBody(context, isOrganizer)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, isOrganizer),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isOrganizer) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (isOrganizer)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'edit') context.push('/events/$eventId/edit');
              if (v == 'dashboard') context.push('/events/$eventId/dashboard');
              if (v == 'discard') {
                ref.read(eventRepositoryProvider).deleteEvent(eventId);
                context.pop();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Event')),
              const PopupMenuItem(value: 'dashboard', child: Text('Organizer Dashboard')),
              const PopupMenuItem(value: 'discard', child: Text('Delete Event')),
            ],
          ),
        IconButton(
          icon: Icon(
            event.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: () {
            final userId = ref.read(currentUserIdProvider);
            if (userId == null) return;
            if (event.isSaved) {
              ref.read(eventRepositoryProvider).unSaveEvent(event.id, userId);
            } else {
              ref.read(eventRepositoryProvider).saveEvent(event.id, userId);
            }
            ref.invalidate(eventDetailProvider(eventId));
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: event.coverUrl != null
            ? Image.network(event.coverUrl!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isOrganizer) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(event: event),
          const SizedBox(height: 16),
          _InfoSection(event: event),
          const SizedBox(height: 16),
          _DescriptionSection(event: event),
          const SizedBox(height: 16),
          _CapacitySection(event: event),
          const SizedBox(height: 24),
          _ActionButtons(event: event, ref: ref, eventId: eventId),
          const SizedBox(height: 16),
          _QuickLinks(event: event, ref: ref),
          const SizedBox(height: 16),
          _AttendeesPreview(event: event),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isOrganizer) {
    final userId = ref.read(currentUserIdProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: event.isCancelled || event.isPast ? null : () async {
                  if (userId == null) return;
                  if (event.registrationType == 'free') {
                    final ticket = await ref.read(eventRepositoryProvider).registerForEvent(event.id, userId);
                    if (ticket != null && context.mounted) {
                      context.push('/events/ticket/${ticket.id}');
                    }
                  }
                },
                icon: Icon(event.myTicketId != null ? Icons.confirmation_number : Icons.event),
                label: Text(event.myTicketId != null ? 'View Ticket' : event.isPast ? 'Event Ended' : 'Register Now'),
              ),
            ),
            if (isOrganizer) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/events/$eventId/dashboard'),
                icon: const Icon(Icons.dashboard),
                label: const Text('Manage'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final EventModel event;
  const _HeaderSection({required this.event});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56, height: 64,
          decoration: BoxDecoration(
            color: context.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(months[event.eventDate.month - 1], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              Text('${event.eventDate.day}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(children: [
                _Badge(text: event.categoryLabel, color: context.primary),
                const SizedBox(width: 6),
                _Badge(text: event.scopeLabel, color: context.warning),
                if (event.isFeatured) ...[
                  const SizedBox(width: 6), _Badge(text: 'Featured', color: context.warning),
                ],
                if (!event.isApproved && event.scope != 'community') ...[
                  const SizedBox(width: 6), _Badge(text: 'Pending', color: context.textSecondary),
                ],
              ]),
              if (event.isCancelled) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: context.errorBg, borderRadius: BorderRadius.circular(4)),
                  child: Text('Cancelled', style: TextStyle(fontSize: 11, color: context.error, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final EventModel event;
  const _InfoSection({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          if (event.eventTime != null) _InfoRow(icon: Icons.access_time, text: '${event.formattedDate} at ${event.formattedTime}'),
          if (event.location != null) _InfoRow(icon: Icons.location_on, text: event.location!),
          if (event.organizerType != null) _InfoRow(icon: Icons.badge, text: event.organizerType!.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
          if (event.contactInfo != null) _InfoRow(icon: Icons.contact_phone, text: event.contactInfo!),
          _InfoRow(icon: Icons.monetization_on, text: event.registrationTypeLabel),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: context.textPrimary))),
      ]),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final EventModel event;
  const _DescriptionSection({required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.primary)),
        const SizedBox(height: 8),
        Text(event.description ?? 'No description provided.', style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}

class _CapacitySection extends StatelessWidget {
  final EventModel event;
  const _CapacitySection({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.capacity == null) return const SizedBox.shrink();
    final percentage = event.capacity! > 0 ? event.attendeeCount / event.capacity! : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.people, size: 16, color: context.textSecondary),
          const SizedBox(width: 4),
          Text('${event.attendeeCount} / ${event.capacity} registered', style: TextStyle(fontSize: 13, color: context.textSecondary)),
          const Spacer(),
          Text('${(percentage * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.primary)),
        ]),
        const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: context.surfaceFill,
              color: percentage >= 1 ? context.error : context.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final EventModel event;
  final WidgetRef ref;
  final String eventId;
  const _ActionButtons({required this.event, required this.ref, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(currentUserIdProvider);
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            if (userId == null) return;
            if (event.myRsvpStatus != null) {
              ref.read(eventRepositoryProvider).cancelRsvp(event.id, userId);
              ref.invalidate(eventDetailProvider(eventId));
            } else {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ListTile(leading: Icon(Icons.check, color: context.success), title: const Text('Going'), onTap: () async {
                    await ref.read(eventRepositoryProvider).rsvpEvent(event.id, userId, 'going');
                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(eventDetailProvider(eventId));
                  }),
                  ListTile(leading: Icon(Icons.help, color: context.warning), title: const Text('Maybe'), onTap: () async {
                    await ref.read(eventRepositoryProvider).rsvpEvent(event.id, userId, 'maybe');
                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(eventDetailProvider(eventId));
                  }),
                  ListTile(leading: Icon(Icons.close, color: context.error), title: const Text('Not Going'), onTap: () async {
                    await ref.read(eventRepositoryProvider).rsvpEvent(event.id, userId, 'not_going');
                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(eventDetailProvider(eventId));
                  }),
                ])),
              );
            }
          },
          icon: Icon(event.myRsvpStatus != null ? Icons.check_circle : Icons.event),
          label: Text(event.myRsvpStatus != null ? 'RSVPed (${event.myRsvpStatus})' : 'RSVP'),
        ),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () {
          // Calendar integration placeholder
        },
        icon: const Icon(Icons.calendar_month),
        label: const Text('Calendar'),
      ),
    ]);
  }
}

class _QuickLinks extends StatelessWidget {
  final EventModel event;
  final WidgetRef ref;
  const _QuickLinks({required this.event, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _QuickLinkCard(icon: Icons.chat, label: 'Discuss', onTap: () => context.push('/events/${event.id}/discussions')),
      const SizedBox(width: 8),
      _QuickLinkCard(icon: Icons.photo_library, label: 'Media', onTap: () => context.push('/events/${event.id}/media')),
      const SizedBox(width: 8),
      _QuickLinkCard(icon: Icons.share, label: 'Share', onTap: () {}),
      const SizedBox(width: 8),
      _QuickLinkCard(icon: Icons.notifications, label: 'Remind', onTap: () {
        final userId = ref.read(currentUserIdProvider);
        if (userId == null) return;
        for (final offset in [const Duration(days: 7), const Duration(days: 3), const Duration(days: 1), const Duration(hours: 1)]) {
          final remindAt = event.eventDate.subtract(offset);
          if (remindAt.isAfter(DateTime.now())) {
            ref.read(eventRepositoryProvider).setReminder(event.id, userId, remindAt);
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminders set!')));
      }),
    ]);
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickLinkCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: context.surfaceFill, borderRadius: BorderRadius.circular(8), border: Border.all(color: context.borderCol)),
          child: Column(children: [
            Icon(icon, size: 20, color: context.textPrimary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: context.textPrimary)),
          ]),
        ),
      ),
    );
  }
}

class _AttendeesPreview extends StatelessWidget {
  final EventModel event;
  const _AttendeesPreview({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/events/${event.id}/attendees'),
      child: Row(children: [
        SizedBox(
          height: 28,
          child: Stack(children: List.generate(3, (i) => Positioned(
            left: i * 16.0,
            child: CircleAvatar(radius: 14, backgroundColor: context.textDisabled, child: Icon(Icons.person, size: 14, color: context.textSecondary)),
          ))),
        ),
        const SizedBox(width: 8),
        Text('${event.attendeeCount} attending', style: TextStyle(fontSize: 13, color: context.textSecondary)),
      ]),
    );
  }
}
