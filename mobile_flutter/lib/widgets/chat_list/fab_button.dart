import 'package:flutter/material.dart';

const _primary = Color(0xFF2563EB);

class ChatFab extends StatelessWidget {
  const ChatFab({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
