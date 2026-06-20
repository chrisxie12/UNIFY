import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../providers/event_provider.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/design_system/components.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: ticketsAsync.when(
        loading: () => const AppLoadingWidget.list(),
        error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(myTicketsProvider)),
        data: (tickets) {
          if (tickets.isEmpty) {
            return UEmptyState(
              icon: Icons.confirmation_number_outlined,
              title: 'No tickets yet',
              actionLabel: 'Browse Events',
              onAction: () => context.pop(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(USpacing.md),
            itemCount: tickets.length,
            itemBuilder: (_, i) {
              final ticket = tickets[i];
              return Card(
                margin: const EdgeInsets.only(bottom: USpacing.md),
                child: InkWell(
                  borderRadius: URadius.mdAll,
                  onTap: () => context.push('/events/ticket/${ticket.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(USpacing.base),
                    child: Row(
                      children: [
                        Container(
                          width: USpacing.xs,
                          height: 60,
                          decoration: BoxDecoration(
                            color: ticket.attended ? Colors.green : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: USpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ticket.eventTitle ?? 'Event', style: UText.labelL),
                              const SizedBox(height: USpacing.xs),
                              if (ticket.eventDate != null)
                                Text(ticket.eventDate!, style: UText.caption.copyWith(color: context.textSecondary)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ticket.attended ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ticket.attended ? 'Attended' : 'Not Checked In',
                                      style: UText.tiny.copyWith(color: ticket.attended ? Colors.green : Colors.blue, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('#${ticket.ticketNumber.substring(ticket.ticketNumber.length - 8)}', style: UText.tiny.copyWith(color: context.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: context.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
