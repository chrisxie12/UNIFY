import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/event_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

class TicketScreen extends ConsumerWidget {
  final String ticketId;
  const TicketScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (tickets) {
          final ticket = tickets.where((t) => t.id == ticketId).firstOrNull;
          if (ticket == null) {
            return const Center(child: Text('Ticket not found'));
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TicketCard(ticket: ticket, theme: theme),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Event'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final dynamic ticket;
  final ThemeData theme;
  const _TicketCard({required this.ticket, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.textSecondary),
        boxShadow: [
          BoxShadow(color: context.textPrimary.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Top colored section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const Icon(Icons.confirmation_number, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(ticket.eventTitle ?? 'Event Ticket', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                if (ticket.eventDate != null) ...[
                  const SizedBox(height: 4),
                  Text(ticket.eventDate!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          ),
          // QR Code area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.textSecondary),
              ),
              child: CustomPaint(
                painter: _QRPainter(ticket.qrCode as String),
                child: const Center(child: Text('QR', style: TextStyle(color: Colors.black26, fontSize: 24, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          // Ticket number area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.textSecondary), bottom: BorderSide(color: context.textSecondary)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ticket #', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                Text(ticket.ticketNumber as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ],
            ),
          ),
          // Bottom info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _TicketInfoRow(label: 'Registered', value: ticket.formattedTimestamp as String),
                _TicketInfoRow(label: 'Status', value: ticket.attended ? 'Checked In' : 'Not Checked In',
                  valueColor: ticket.attended ? Colors.green : Colors.orange),
                if (ticket.eventVenue != null)
                  _TicketInfoRow(label: 'Venue', value: ticket.eventVenue as String),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _TicketInfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }
}

class _QRPainter extends CustomPainter {
  final String data;
  _QRPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..strokeWidth = 2;
    final rng = Random(data.hashCode);
    final cellSize = size.width / 12;
    for (var row = 0; row < 12; row++) {
      for (var col = 0; col < 12; col++) {
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
