import 'package:flutter/material.dart';
import '../errors/error_mapper.dart';

/// Replaces raw `Text('Error: $e')` in Riverpod `AsyncValue.when(error:)`.
///
/// Usage:
/// ```dart
/// error: (e, _) => AppErrorWidget(e)
/// ```
class AppErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const AppErrorWidget(this.error, {super.key, this.onRetry, this.customMessage});

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? ErrorMapper.toUserMessage(error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
