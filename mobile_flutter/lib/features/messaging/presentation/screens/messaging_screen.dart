import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 56, color: AppColors.grey3),
            const SizedBox(height: 16),
            Text('Messaging coming soon', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('Connect with peers on your campus.', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
