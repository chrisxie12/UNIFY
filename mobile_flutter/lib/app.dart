import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

class UnifyApp extends ConsumerStatefulWidget {
  const UnifyApp({super.key});

  @override
  ConsumerState<UnifyApp> createState() => _UnifyAppState();
}

class _UnifyAppState extends ConsumerState<UnifyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Refresh the Supabase session when the app comes back from background so
  // the Realtime client always has a valid JWT (prevents InvalidJWTToken errors).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Supabase.instance.client.auth.refreshSession();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      title: 'UNIFY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildFrom(theme),
      routerConfig: router,
    );
  }
}
