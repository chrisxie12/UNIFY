import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/poll_model.dart';
import '../../../../core/extensions/theme_extensions.dart';

class PollCard extends ConsumerWidget {
  final PollModel poll;
  final String? selectedOptionId;
  final Function(String optionId)? onVote;

  const PollCard({
    super.key,
    required this.poll,
    this.selectedOptionId,
    this.onVote,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMultiple = poll.pollType == 'multiple';
    final isDisabled = poll.isLocked || poll.isExpired || selectedOptionId != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: context.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    poll.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (poll.isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.textSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Locked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (poll.description != null) ...[
              const SizedBox(height: 6),
              Text(
                poll.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...poll.options.map((option) {
              final percentage = poll.totalVotes > 0
                  ? (option.voteCount / poll.totalVotes * 100)
                  : 0.0;
              final isSelected = option.id == selectedOptionId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: isDisabled
                      ? null
                      : () => onVote?.call(option.id),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                          : Colors.white,
                    ),
                    child: Stack(
                      children: [
                        if (selectedOptionId != null || poll.isLocked || poll.isExpired)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: percentage / 100,
                                child: Container(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                      : Colors.grey[100],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              isMultiple
                                  ? Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 22,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey[400],
                                    )
                                  : Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      size: 22,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey[400],
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[800],
                                  ),
                                ),
                              ),
                              if (selectedOptionId != null || poll.isLocked || poll.isExpired)
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${poll.totalVotes} votes',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
                if (selectedOptionId == null && !poll.isLocked && !poll.isExpired) ...[
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: selectedOptionId != null
                          ? () => onVote?.call(selectedOptionId!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[400],
                      ),
                      child: const Text(
                        'Vote',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (poll.isExpired) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Expired',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
