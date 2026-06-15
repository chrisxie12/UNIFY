import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryLight, AppColors.primaryDark],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: screenH * 0.06,
            left: -40,
            child: _glassCircle(200),
          ),
          Positioned(
            top: screenH * 0.18,
            right: -60,
            child: _glassCircle(160),
          ),

          // Hero icon
          Positioned(
            top: screenH * 0.12,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: SvgPicture.asset('assets/images/logo.svg'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'UNIFY',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your campus, connected.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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

  Widget _glassCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.07),
      ),
    );
  }
}
