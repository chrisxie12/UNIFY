import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../extensions/theme_extensions.dart';
import '../widgets/app_loading_widget.dart';
import '../widgets/unify_wordmark.dart';

// ── Access-denied signal ──────────────────────────────────────────────────────
//
// Set to true by the GoRouter redirect when a non-admin attempts an admin path.
// MainShell listens and fires the branded snackbar, then resets to false.

final adminAccessDeniedProvider = StateProvider<bool>((ref) => false);

// ── Guard widget ──────────────────────────────────────────────────────────────
//
// Wraps every admin screen as a second layer of protection.
// Even if the router redirect is bypassed (deep link, programmatic nav),
// non-admin users see the access-denied UI — never admin content.

class AdminGuard extends ConsumerWidget {
  const AdminGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAppUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: AppLoadingWidget.card(),
      ),
      error: (_, __) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: context.error),
              const SizedBox(height: 12),
              Text('Failed to verify permissions',
                  style: TextStyle(color: context.textSecondary)),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null || !user.isAdmin) {
          return const _AccessDeniedScreen();
        }
        return child;
      },
    );
  }
}

// ── Branded access-denied screen ──────────────────────────────────────────────

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: context.error.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 44,
                  color: context.error,
                ),
              ),
              const SizedBox(height: 24),
              const UnifyWordmark(
                size: WordmarkSize.small,
                style: WordmarkStyle.auto,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'This area requires admin privileges.\n'
                'Contact your university administrator\n'
                'if you believe this is an error.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: context.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/app/feed'),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: const Text('Go Home'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
