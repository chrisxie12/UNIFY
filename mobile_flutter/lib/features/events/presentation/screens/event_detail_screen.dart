import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/models/event_model.dart';
import '../providers/event_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  String? _selectedRsvp;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final userId = ref.read(supabaseProvider).auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (event) {
          _selectedRsvp ??= event.myRsvpStatus;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.coverUrl != null)
                  ClipRRect(
                    child: Image.network(
                      event.coverUrl!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey[100],
                        child: Center(child: Icon(Icons.event, size: 48, color: Colors.grey[400])),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 220,
                          color: Colors.grey[100],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0066FF),
                          const Color(0xFF0066FF).withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.event, size: 48, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 74,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _monthAbbr(event.eventDate),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event.eventDate.day.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        event.eventTypeLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0066FF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: '${DateFormat('EEEE, MMMM d, yyyy').format(event.eventDate)}',
                        value: '${event.formattedTime}${event.endDate != null ? ' - ${DateFormat('h:mm a').format(event.endDate!)}' : ''}',
                      ),
                      if (event.location != null) ...[
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: event.location!,
                          value: null,
                        ),
                      ],
                      if (event.isVirtual && event.meetingLink != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.videocam, color: const Color(0xFFFF6B35), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Virtual Event',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFFFF6B35),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event.meetingLink!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Join',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (event.description != null) ...[
                        Text(
                          event.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 18, color: Colors.grey[500]),
                          const SizedBox(width: 8),
                          Text(
                            '${event.rsvpCount} attending',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (event.maxAttendees != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              '/ ${event.maxAttendees} max',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                      if (event.maxAttendees != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: event.maxAttendees! > 0 ? event.rsvpCount / event.maxAttendees! : 0,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (event.location != null) ...[
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined, size: 36, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  event.location!,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        'Your RSVP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _RsvpChip(
                            label: 'Going',
                            icon: Icons.check_circle_outline,
                            selected: _selectedRsvp == 'going',
                            color: const Color(0xFF0066FF),
                            onTap: () => _updateRsvp(event.id, 'going', userId),
                          ),
                          const SizedBox(width: 8),
                          _RsvpChip(
                            label: 'Maybe',
                            icon: Icons.help_outline,
                            selected: _selectedRsvp == 'maybe',
                            color: const Color(0xFFFF6B35),
                            onTap: () => _updateRsvp(event.id, 'maybe', userId),
                          ),
                          const SizedBox(width: 8),
                          _RsvpChip(
                            label: 'Not Going',
                            icon: Icons.cancel_outlined,
                            selected: _selectedRsvp == 'declined',
                            color: Colors.red,
                            onTap: () => _updateRsvp(event.id, 'declined', userId),
                          ),
                        ],
                      ),
                      if (_selectedRsvp != null) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _updateRsvp(event.id, null, userId),
                          child: Text(
                            'Clear RSVP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateRsvp(String eventId, String? status, String? userId) async {
    if (userId == null) return;

    final repo = ref.read(eventRepositoryProvider);
    if (status == null) {
      await repo.cancelRsvp(eventId, userId);
    } else {
      await repo.rsvpEvent(eventId, userId, status);
    }

    setState(() => _selectedRsvp = status);
    ref.invalidate(eventDetailProvider(widget.eventId));
  }

  String _monthAbbr(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value != null) ...[
                const SizedBox(height: 2),
                Text(
                  value!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RsvpChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _RsvpChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.grey[200]!,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? color : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
