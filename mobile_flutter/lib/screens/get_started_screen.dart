import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/colors.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heroH = size.height * 0.52;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen blue gradient
          Container(decoration: const BoxDecoration(gradient: kGradient)),

          // White bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.51,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Your campus,\nconnected.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kDark,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Announcements, updates, and community — built for GCTU students.',
                    style: TextStyle(fontSize: 14, color: kGrey2, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  _PrimaryBtn(
                    label: 'Get Started',
                    onTap: () => context.push('/auth?mode=signup'),
                  ),
                  const SizedBox(height: 12),
                  _SecondaryBtn(
                    label: 'I already have an account',
                    onTap: () => context.push('/auth?mode=login'),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: kGrey3, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logo (top-left, inside blue area)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroH,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'UNIFY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    // Illustration — centered in remaining hero space
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 40,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('📢', style: TextStyle(fontSize: 68)),
                              ),
                            ),
                            // Sparkle top-right of circle
                            const Positioned(
                              top: 0,
                              right: 0,
                              child: Text(
                                '✦',
                                style: TextStyle(color: Colors.white, fontSize: 26),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: kGrey1,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
