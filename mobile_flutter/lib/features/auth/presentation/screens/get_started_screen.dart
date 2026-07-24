import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/unify_wordmark.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [context.primaryLight, context.primaryDark],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: screenH * 0.06,
            left: -40,
            child: _glassCircle(context, 200),
          ),
          Positioned(
            top: screenH * 0.18,
            right: -60,
            child: _glassCircle(context, 160),
          ),

          // Hero icon
          Positioned(
            top: screenH * 0.12,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const UnifyWordmark(
                  size: WordmarkSize.large,
                  style: WordmarkStyle.light,
                  vertical: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your campus, connected.',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.80),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenH * 0.46,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to\nUNIFY', style: AppTextStyles.h1),
                  const SizedBox(height: 10),
                  Text(
                    'Stay updated with announcements, connect with peers, and never miss what matters on campus.',
                    style: AppTextStyles.body,
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Get Started',
                    onTap: () => context.push('/auth?mode=signup'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'I already have an account',
                    variant: AppButtonVariant.secondary,
                    onTap: () => context.push('/auth?mode=login'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'By continuing you agree to our Terms & Privacy Policy',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCircle(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.cardBg.withValues(alpha: 0.07),
      ),
    );
  }
}