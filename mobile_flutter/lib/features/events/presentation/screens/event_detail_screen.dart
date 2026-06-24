import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
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
      loading: () => const Scaffold(body: AppLoadingWidget.list()),
      error: (e, _) => Scaffold(body: AppErrorWidget(e)),
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
      padding: const EdgeInsets.all(USpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(event: event, theme: theme),
          const SizedBox(height: USpacing.base),
          _InfoSection(event: event, theme: theme),
          const SizedBox(height: USpacing.base),
          _DescriptionSection(event: event, theme: theme),
          const SizedBox(height: USpacing.base),
          _CapacitySection(event: event, theme: theme),
          const SizedBox(height: USpacing.xl),
          _ActionButtons(event: event, theme: theme, ref: ref, eventId: eventId),
          const SizedBox(height: USpacing.base),
          _QuickLinks(event: event, theme: theme, ref: ref),
          const SizedBox(height: USpacing.base),
          _AttendeesPreview(event: event),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isOrganizer) {
    final userId = ref.read(currentUserIdProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(USpacing.base),
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
              const SizedBox(width: USpacing.md),
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
  final ThemeData theme;
  const _HeaderSection({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56, height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: URadius.mdAll,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(months[event.eventDate.month - 1], style: UText.caption.copyWith(color: Colors.white)),
              Text('${event.eventDate.day}', style: UText.h2.copyWith(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(width: USpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: UText.h2),
              const SizedBox(height: USpacing.xs),
              Row(children: [
                _Badge(text: event.categoryLabel, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                _Badge(text: event.scopeLabel, color: Colors.orange),
                if (event.isFeatured) ...[
                  const SizedBox(width: 6), const _Badge(text: 'Featured', color: Colors.amber),
                ],
                if (!event.isApproved && event.scope != 'community') ...[
                  SizedBox(width: 6), _Badge(text: 'Pending', color: context.textSecondary),
                ],
              ]),
              if (event.isCancelled) ...[
                const SizedBox(height: USpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: USpacing.sm, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: URadius.xsAll),
                  child: Text('Cancelled', style: TextStyle(fontSize: 11, color: Colors.red[700], fontWeight: FontWeight.w600)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: URadius.xsAll),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final EventModel event;
  final ThemeData theme;
  const _InfoSection({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(USpacing.md),
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
      padding: const EdgeInsets.symmetric(vertical: USpacing.xs),
      child: Row(children: [
        Icon(icon, size: 16, color: context.textSecondary),
        const SizedBox(width: USpacing.sm),
        Expanded(child: Text(text, style: UText.bodyXS.copyWith(color: context.textSecondary))),
      ]),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final EventModel event;
  final ThemeData theme;
  const _DescriptionSection({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: UText.h4.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: USpacing.sm),
        Text(event.description ?? 'No description provided.', style: UText.bodyS.copyWith(height: 1.5)),
      ],
    );
  }
}

class _CapacitySection extends StatelessWidget {
  final EventModel event;
  final ThemeData theme;
  const _CapacitySection({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (event.capacity == null) return const SizedBox.shrink();
    final percentage = event.capacity! > 0 ? event.attendeeCount / event.capacity! : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.people, size: 16, color: context.textSecondary),
          const SizedBox(width: USpacing.xs),
          Text('${event.attendeeCount} / ${event.capacity} registered', style: UText.bodyXS.copyWith(color: context.textSecondary)),
          const Spacer(),
          Text('${(percentage * 100).toInt()}%', style: UText.bodyXS.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: URadius.xsAll,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: context.borderCol,
            color: percentage >= 1 ? Colors.red : theme.colorScheme.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final EventModel event;
  final ThemeData theme;
  final WidgetRef ref;
  final String eventId;
  const _ActionButtons({required this.event, required this.theme, required this.ref, required this.eventId});

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
                  ListTile(leading: const Icon(Icons.check, color: Colors.green), title: const Text('Going'), onTap: () async {
                    await ref.read(eventRepositoryProvider).rsvpEvent(event.id, userId, 'going');
                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(eventDetailProvider(eventId));
                  }),
                  ListTile(leading: const Icon(Icons.help, color: Colors.orange), title: const Text('Maybe'), onTap: () async {
                    await ref.read(eventRepositoryProvider).rsvpEvent(event.id, userId, 'maybe');
                    if (context.mounted) Navigator.pop(context);
                    ref.invalidate(eventDetailProvider(eventId));
                  }),
                  ListTile(leading: const Icon(Icons.close, color: Colors.red), title: const Text('Not Going'), onTap: () async {
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
      const SizedBox(width: USpacing.sm),
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
  final ThemeData theme;
  final WidgetRef ref;
  const _QuickLinks({required this.event, required this.theme, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _QuickLinkCard(icon: Icons.chat, label: 'Discuss', onTap: () => context.push('/events/${event.id}/discussions')),
      const SizedBox(width: USpacing.sm),
      _QuickLinkCard(icon: Icons.photo_library, label: 'Media', onTap: () => context.push('/events/${event.id}/media')),
      const SizedBox(width: USpacing.sm),
      _QuickLinkCard(icon: Icons.share, label: 'Share', onTap: () {}),
      const SizedBox(width: USpacing.sm),
      _QuickLinkCard(icon: Icons.notifications, label: 'Remind', onTap: () {
        final userId = ref.read(currentUserIdProvider);
        if (userId == null) return;
        for (final offset in [const Duration(days: 7), const Duration(days: 3), const Duration(days: 1), const Duration(hours: 1)]) {
          final remindAt = event.eventDate.subtract(offset);
          if (remindAt.isAfter(DateTime.now())) {
            ref.read(eventRepositoryProvider).setReminder(event.id, userId, remindAt);
          }
        }
        UnifySnackbar.success(context, 'Reminders set!');
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
        borderRadius: URadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: USpacing.md),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: URadius.smAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Column(children: [
            Icon(icon, size: 20, color: context.textSecondary),
            const SizedBox(height: USpacing.xs),
            Text(label, style: TextStyle(fontSize: 10, color: context.textSecondary)),
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
    // Static preview — there is no standalone attendees screen yet, so this
    // row simply displays the count instead of navigating to a dead route.
    return Row(children: [
      SizedBox(
        height: 28,
        child: Stack(children: List.generate(3, (i) => Positioned(
          left: i * 16.0,
          child: CircleAvatar(radius: 14, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: 14, color: context.textSecondary)),
        ))),
      ),
      const SizedBox(width: USpacing.sm),
      Text('${event.attendeeCount} attending', style: UText.bodyXS.copyWith(color: context.textSecondary)),
    ]);
  }
}