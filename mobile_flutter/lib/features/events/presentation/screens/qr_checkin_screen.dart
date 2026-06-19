import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';

class QRCheckInScreen extends ConsumerStatefulWidget {
  final String eventId;
  const QRCheckInScreen({super.key, required this.eventId});
  @override
  ConsumerState<QRCheckInScreen> createState() => _QRCheckInScreenState();
}

class _QRCheckInScreenState extends ConsumerState<QRCheckInScreen> {
  final _ticketCodeCtrl = TextEditingController();
  String? _checkInMessage;
  bool _checkInSuccess = false;

  @override
  void dispose() {
    _ticketCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkIn() async {
    final code = _ticketCodeCtrl.text.trim();
    if (code.isEmpty) return;

    final tickets = await ref.read(eventRepositoryProvider).getEventTickets(widget.eventId);
    final ticket = tickets.where((t) => t.qrCode == code || t.ticketNumber == code).firstOrNull;

    if (ticket == null) {
      setState(() {
        _checkInMessage = 'Ticket not found';
        _checkInSuccess = false;
      });
      return;
    }

    if (ticket.attended) {
      setState(() {
        _checkInMessage = 'Already checked in';
        _checkInSuccess = false;
      });
      return;
    }

    final organizerId = ref.read(currentUserIdProvider);
    if (organizerId == null) return;

    final success = await ref.read(eventRepositoryProvider).checkInAttendee(ticket.id, organizerId);
    if (success) {
      ref.invalidate(eventTicketsProvider(widget.eventId));
      ref.invalidate(attendanceAnalyticsProvider(widget.eventId));
    }

    setState(() {
      _checkInMessage = success ? 'Check-in successful!' : 'Check-in failed';
      _checkInSuccess = success;
    });
    _ticketCodeCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: context.textSecondary),
            const SizedBox(height: 16),
            Text('Scan Ticket or Enter Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textSecondary])),
            const SizedBox(height: 8),
            Text('Enter the QR code or ticket number to verify attendance.', style: TextStyle(fontSize: 13, color: context.textSecondary]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(
              controller: _ticketCodeCtrl,
              decoration: InputDecoration(
                hintText: 'Enter ticket code',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.confirmation_number),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () {
                    // QR scanner placeholder
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _checkIn,
                icon: const Icon(Icons.check),
                label: const Text('Verify & Check In'),
              ),
            ),
            if (_checkInMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _checkInSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _checkInSuccess ? Icons.check_circle : Icons.error,
                      color: _checkInSuccess ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _checkInMessage!,
                        style: TextStyle(
                          color: _checkInSuccess ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _AttendeeListSection(eventId: widget.eventId, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _AttendeeListSection extends ConsumerWidget {
  final String eventId;
  final ThemeData theme;
  const _AttendeeListSection({required this.eventId, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(eventTicketsProvider(eventId));
    return ticketsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('$e'),
      data: (tickets) {
        final checkedIn = tickets.where((t) => t.attended).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Attendees', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                const Spacer(),
                Text('$checkedIn / ${tickets.length} checked in', style: TextStyle(fontSize: 12, color: context.textSecondary])),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: tickets.isEmpty
                  ? Center(child: Text('No registrations yet', style: TextStyle(color: context.textSecondary])))
                  : ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (_, i) {
                        final t = tickets[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: t.attended ? Colors.green.withValues(alpha: 0.1) : Colors.grey[100],
                            child: Icon(
                              t.attended ? Icons.check : Icons.hourglass_empty,
                              size: 16,
                              color: t.attended ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text('Ticket #${t.ticketNumber.substring(t.ticketNumber.length - 8)}', style: const TextStyle(fontSize: 13)),
                          subtitle: t.attended && t.checkedInAt != null
                              ? Text('Checked in at ${t.checkedInAt!.hour}:${t.checkedInAt!.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: context.textSecondary]))
                              : null,
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
