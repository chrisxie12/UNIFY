import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_extensions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: June 2026',
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _paragraph(
              context,
              'UNIFY ("we", "our", "us") is committed to protecting your privacy. '
              'This Privacy Policy explains how we collect, use, disclose, and '
              'safeguard your information when you use our mobile application and '
              'services. By using UNIFY, you agree to the collection and use of '
              'information in accordance with this policy.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Information We Collect'),
            _paragraph(
              context,
              'We collect information you provide directly to us, including your '
              'name, email address, university affiliation, profile information, '
              'and any content you post or upload through the app. We also collect '
              'usage data such as your interactions with features, pages visited, '
              'and device information to improve our services. Location data may '
              'be collected if you enable event check-in features.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'How We Use Your Information'),
            _paragraph(
              context,
              'Your information is used to provide, maintain, and improve UNIFY\'s '
              'features — including personalized content, academic tools, event '
              'recommendations, and community management. We may use your email '
              'to send service-related communications, including updates, security '
              'alerts, and support responses. We do not sell your personal data to '
              'third parties.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Data Security'),
            _paragraph(
              context,
              'We implement industry-standard security measures to protect your '
              'data, including encryption in transit and at rest. However, no '
              'method of electronic storage or transmission is 100%% secure. '
              'You are responsible for maintaining the confidentiality of your '
              'account credentials.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Contact Us'),
            _paragraph(
              context,
              'If you have any questions about this Privacy Policy, please contact '
              'us at support@unify.app.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: context.textPrimary,
        ),
      ),
    );
  }

  Widget _paragraph(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: context.textPrimary,
      ),
    );
  }
}
