import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/extensions/theme_extensions.dart';
import '../providers/event_provider.dart';
import '../../../../core/guards/admin_guard.dart';

class AdminEventDashboardScreen extends ConsumerWidget {
  const AdminEventDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Event Admin')),
        body: eventsAsync.when(
          loading: () => const AppLoadingWidget.list(),
          error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(upcomingEventsProvider)),
          data: (events) {
            final pending = events.where((e) => !e.isApproved && e.scope != 'community').toList();

            return ListView(
              padding: const EdgeInsets.all(USpacing.base),
              children: [
                Text('Pending Approval', style: UText.h4.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(height: USpacing.sm),
                if (pending.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(USpacing.xl),
                    child: AppEmptyWidget(
                      icon: Icons.event_busy_rounded,
                      title: 'No pending events',
                    ),
                  )
                else
                  ...pending.map((event) => Card(
                    margin: const EdgeInsets.only(bottom: USpacing.sm),
                    child: ListTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: URadius.smAll,
                        ),
                        child: const Icon(Icons.pending, color: Colors.orange, size: 20),
                      ),
                      title: Text(event.title, style: UText.bodyS),
                      subtitle: Text('${event.scopeLabel} · ${event.formattedDate}', style: UText.bodyXS.copyWith(color: context.textSecondary)),
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
                            onPressed: () async {
                              final reason = await _showRejectDialog(context);
                              if (reason == null) return;
                              await ref.read(eventRepositoryProvider).rejectEvent(
                                event.id,
                                reason: reason.trim().isEmpty ? null : reason.trim(),
                              );
                              ref.invalidate(upcomingEventsProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
                const SizedBox(height: USpacing.xl),
                Text('All Events', style: UText.h4.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(height: USpacing.sm),
                ...events.map((event) => Card(
                  margin: const EdgeInsets.only(bottom: USpacing.xs),
                  child: ListTile(
                    dense: true,
                    title: Text(event.title, style: UText.bodyXS),
                    subtitle: Text('${event.scopeLabel} · ${event.attendeeCount} attendees · ${event.isApproved ? "Approved" : "Pending"}', style: UText.bodyXS.copyWith(color: context.textSecondary)),
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
      ),
    );
  }
}

Future<String?> _showRejectDialog(BuildContext context) async {
  final ctrl = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Event'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Explain why this event is being rejected',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  } finally {
    ctrl.dispose();
  }
}
