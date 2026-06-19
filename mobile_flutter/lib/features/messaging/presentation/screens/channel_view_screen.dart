import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/features/messaging/data/models/channel_model.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

class ChannelViewScreen extends ConsumerWidget {
  final String conversationId;
  const ChannelViewScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsProvider(conversationId));
    final selectedChannelId = ref.watch(selectedChannelProvider);

    return Row(
      children: [
        Container(
          width: 200,
          color: context.textSecondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Channels', style: TextStyle(fontWeight: FontWeight.w600, color: context.textSecondary)),
              ),
              const Divider(height: 1),
              Expanded(
                child: channelsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(channelsProvider(conversationId))),
                  data: (channels) {
                    if (channels.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No channels yet', style: TextStyle(color: context.textSecondary, fontSize: 13)),
                      );
                    }
                    return ListView.builder(
                      itemCount: channels.length,
                      itemBuilder: (_, i) => _ChannelItem(
                        channel: channels[i],
                        isSelected: channels[i].id == selectedChannelId,
                        onTap: () {
                          ref.read(selectedChannelProvider.notifier).state = channels[i].id;
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedChannelId != null
              ? _ChannelMessageView(conversationId: conversationId, channelId: selectedChannelId)
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tag, size: 48, color: context.textSecondary),
                      const SizedBox(height: 12),
                      Text('Select a channel', style: TextStyle(color: context.textSecondary)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ChannelItem extends StatelessWidget {
  final ChannelModel channel;
  final bool isSelected;
  final VoidCallback onTap;
  const _ChannelItem({required this.channel, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.08),
      leading: Icon(
        channel.isAnnouncement ? Icons.campaign : Icons.tag,
        size: 18,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
      ),
      title: Text(
        channel.displayName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: channel.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          color: channel.unreadCount > 0 ? Colors.black87 : Colors.grey[700],
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ChannelMessageView extends ConsumerWidget {
  final String conversationId;
  final String channelId;
  const _ChannelMessageView({required this.conversationId, required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(channelsProvider(conversationId)).valueOrNull
        ?.where((c) => c.id == channelId)
        .firstOrNull;

    if (channel == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.cardBg,
            border: Border(bottom: BorderSide(color: context.textSecondary)),
          ),
          child: Row(
            children: [
              Text(
                channel.displayName,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              if (channel.isAnnouncement)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Announcements', style: TextStyle(fontSize: 10, color: Colors.red[700])),
                  ),
                ),
            ],
          ),
        ),
        const Expanded(child: Center(child: Text('Messages will appear here'))),
      ],
    );
  }
}
