import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_extensions.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Terms of Service',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              'These Terms of Service ("Terms") govern your use of the UNIFY '
              'mobile application and related services operated by UNIFY ("we", '
              '"our", "us"). By accessing or using UNIFY, you agree to be bound '
              'by these Terms. If you do not agree, please do not use the app.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Eligibility'),
            _paragraph(
              context,
              'You must be at least 18 years old or enrolled at a partner '
              'university to use UNIFY. By creating an account, you represent '
              'that you meet these requirements and that all information you '
              'provide is accurate and complete. You are responsible for '
              'maintaining the confidentiality of your account.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Acceptable Use'),
            _paragraph(
              context,
              'You agree to use UNIFY only for lawful purposes and in accordance '
              'with these Terms. You may not use the app to harass, abuse, or '
              'harm others; post inappropriate or misleading content; violate '
              'any applicable laws or university policies; or attempt to gain '
              'unauthorized access to any part of the system. We reserve the '
              'right to remove content and suspend accounts that violate these '
              'rules.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Intellectual Property'),
            _paragraph(
              context,
              'All content and materials available on UNIFY, including but not '
              'limited to text, graphics, logos, and software, are the property '
              'of UNIFY or its licensors and are protected by applicable '
              'intellectual property laws. You may not reproduce, distribute, or '
              'create derivative works without our prior written consent.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Limitation of Liability'),
            _paragraph(
              context,
              'UNIFY is provided "as is" without warranties of any kind, either '
              'express or implied. We shall not be liable for any indirect, '
              'incidental, special, or consequential damages arising from your '
              'use of the app. In no event shall our total liability exceed the '
              'amount you have paid us in the past twelve months.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Changes to Terms'),
            _paragraph(
              context,
              'We reserve the right to modify these Terms at any time. Changes '
              'will be effective immediately upon posting. Your continued use of '
              'UNIFY after any changes constitutes acceptance of the new Terms. '
              'We encourage you to review these Terms periodically.',
            ),
            const SizedBox(height: 16),
            _heading(context, 'Contact'),
            _paragraph(
              context,
              'If you have any questions about these Terms, please contact us at '
              'support@unify.app.',
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
