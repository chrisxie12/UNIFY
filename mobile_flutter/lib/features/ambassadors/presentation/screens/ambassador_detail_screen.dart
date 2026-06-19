import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ambassador_models.dart';
import '../providers/ambassador_provider.dart';
import 'ambassador_admin_screen.dart' show statusColor;

class AmbassadorDetailScreen extends ConsumerWidget {
  final String ambassadorId;
  const AmbassadorDetailScreen({super.key, required this.ambassadorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ambassadorDetailProvider(ambassadorId));
    final eventsAsync = ref.watch(ambassadorEventsProvider(ambassadorId));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Ambassador',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          detailAsync.maybeWhen(
            data: (a) => PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: context.textSecondary),
              onSelected: (status) async {
                await ref
                    .read(ambassadorRepositoryProvider)
                    .setAmbassadorStatus(ambassadorId, status);
                ref.invalidate(ambassadorDetailProvider(ambassadorId));
                ref.invalidate(ambassadorsProvider);
                ref.invalidate(ambassadorStatsProvider);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'active', child: Text('Mark Active')),
                PopupMenuItem(value: 'inactive', child: Text('Mark Inactive')),
                PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add event'),
        onPressed: () =>
            showAddEventDialog(context, ref, ambassadorId: ambassadorId),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (ambassador) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ambassadorDetailProvider(ambassadorId));
              ref.invalidate(ambassadorEventsProvider(ambassadorId));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(USpacing.md, USpacing.md, USpacing.md, 88),
              children: [
                _Header(ambassador: ambassador),
                const SizedBox(height: USpacing.base),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Events',
                      style: UText.h4.copyWith(color: context.textPrimary)),
                ),
                const SizedBox(height: USpacing.sm),
                eventsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(child: Text('Could not load events: $e')),
                  ),
                  data: (events) {
                    if (events.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text('No events yet',
                              style: UText.bodyXS.copyWith(color: context.textSecondary)),
                        ),
                      );
                    }
                    return Column(
                      children: events
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _EventCard(
                                  event: e,
                                  ambassadorId: ambassadorId,
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Ambassador ambassador;
  const _Header({required this.ambassador});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(ambassador.status);
    final subtitle = [
      ambassador.universityName,
      ambassador.faculty,
      ambassador.department,
    ].where((s) => s != null && s.isNotEmpty).join(' • ');

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(USpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (ambassador.avatarUrl != null &&
                  ambassador.avatarUrl!.isNotEmpty)
                CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(ambassador.avatarUrl!))
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_rounded,
                      color: context.primary, size: 26),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ambassador.fullName?.isNotEmpty == true
                          ? ambassador.fullName!
                          : 'Ambassador',
                      style: UText.h3.copyWith(color: context.textPrimary),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle,
                            style: UText.caption.copyWith(color: context.textSecondary)),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: URadius.mdAll,
                ),
                child: Text(ambassador.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          if (ambassador.bio != null && ambassador.bio!.isNotEmpty) ...[
            const SizedBox(height: USpacing.md),
            Text(ambassador.bio!,
                style: UText.bodyXS.copyWith(color: context.textSecondary)),
          ],
          if (ambassador.contact != null &&
              ambassador.contact!.isNotEmpty) ...[
            const SizedBox(height: USpacing.sm),
            Row(
              children: [
                Icon(Icons.alternate_email_rounded,
                    size: 15, color: context.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(ambassador.contact!,
                      style: UText.caption.copyWith(color: context.textSecondary)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _StatTile(
                icon: Icons.people_alt_rounded,
                value: '${ambassador.referralCount}',
                label: 'Referrals',
                color: AppColors.info,
              ),
              _StatTile(
                icon: Icons.event_rounded,
                value: '${ambassador.eventsOrganized}',
                label: 'Events',
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final AmbassadorEvent event;
  final String ambassadorId;
  const _EventCard({required this.event, required this.ambassadorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = event.eventDate;
    final dateLabel =
        date == null ? null : '${date.day}/${date.month}/${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_rounded,
                color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: USpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: UText.label.copyWith(color: context.textPrimary)),
                if (event.description != null &&
                    event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(event.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: UText.caption.copyWith(color: context.textSecondary)),
                  ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (dateLabel != null) dateLabel,
                    '${event.attendance} attended',
                  ].join(' • '),
                  style: UText.tiny.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: context.textSecondary),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete event?'),
                  content: Text('Remove "${event.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              await ref
                  .read(ambassadorRepositoryProvider)
                  .deleteEvent(event.id);
              ref.invalidate(ambassadorEventsProvider(ambassadorId));
              ref.invalidate(ambassadorDetailProvider(ambassadorId));
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: URadius.mdAll,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: UText.h2.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: UText.tiny.copyWith(color: context.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared Add-event dialog (used by detail + profile screens)
// ══════════════════════════════════════════════════════════════

Future<void> showAddEventDialog(
  BuildContext context,
  WidgetRef ref, {
  required String ambassadorId,
}) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final attendanceController = TextEditingController(text: '0');
  DateTime? eventDate;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Add event',
                style: TextStyle(fontWeight: FontWeight.w800)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: USpacing.md),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: USpacing.md),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: eventDate ?? now,
                        firstDate: DateTime(now.year - 2),
                        lastDate: DateTime(now.year + 2),
                      );
                      if (picked != null) {
                        setState(() => eventDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date (optional)',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        eventDate == null
                            ? 'Pick a date'
                            : '${eventDate!.day}/${eventDate!.month}/${eventDate!.year}',
                        style: TextStyle(
                          color: eventDate == null
                              ? ctx.textSecondary
                              : ctx.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: USpacing.md),
                  TextField(
                    controller: attendanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Attendance',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  final attendance =
                      int.tryParse(attendanceController.text.trim()) ?? 0;
                  final description = descriptionController.text.trim();
                  final navigator = Navigator.of(ctx);
                  try {
                    await ref.read(ambassadorRepositoryProvider).addEvent(
                          ambassadorId: ambassadorId,
                          title: title,
                          description:
                              description.isEmpty ? null : description,
                          eventDate: eventDate,
                          attendance: attendance,
                        );
                    ref.invalidate(ambassadorEventsProvider(ambassadorId));
                    ref.invalidate(ambassadorDetailProvider(ambassadorId));
                    ref.invalidate(myAmbassadorProvider);
                    navigator.pop();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Could not add event: $e')),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
