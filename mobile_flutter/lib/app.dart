import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/providers/supabase_provider.dart';
import 'core/services/analytics_service.dart';
import 'features/system/presentation/widgets/update_gate.dart';
import 'features/notifications/presentation/providers/push_notification_provider.dart';
import 'features/notifications/domain/services/push_notification_service.dart';

class UnifyApp extends ConsumerStatefulWidget {
  const UnifyApp({super.key});

  @override
  ConsumerState<UnifyApp> createState() => _UnifyAppState();
}

class _UnifyAppState extends ConsumerState<UnifyApp>
    with WidgetsBindingObserver {
  String? _lastUserId;
  ProviderSubscription<AsyncValue<AuthState>>? _authSub;

  @override
  void initState() {
    debugPrint('[STARTUP] _UnifyAppState.initState() entered');
    super.initState();
    debugPrint('[STARTUP] _UnifyAppState.initState() super done, adding observer...');
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[STARTUP] _UnifyAppState.initState() observer added, scheduling postFrameCallback...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[STARTUP] _UnifyAppState postFrameCallback fired');
      _startAuthListener();
      try {
        debugPrint('[STARTUP] _UnifyAppState calling analyticsServiceProvider.log...');
        ref.read(analyticsServiceProvider).log('app_launched', feature: 'app');
        debugPrint('[STARTUP] _UnifyAppState analyticsServiceProvider.log done');
      } catch (e) {
        debugPrint('[STARTUP] _UnifyAppState analyticsServiceProvider.log ERROR: $e');
      }
    });
    debugPrint('[STARTUP] _UnifyAppState.initState() done');
  }

  void _startAuthListener() {
    debugPrint('[STARTUP] _UnifyAppState._startAuthListener() entered');
    _authSub = ref.listenManual(authStateProvider, (_, next) {
      next.whenData((authState) {
        final userId = authState.session?.user.id;
        final pushService = ref.read(pushNotificationServiceProvider);
        if (userId != null && userId != _lastUserId) {
          _lastUserId = userId;
          pushService.init(userId, onTap: (data) {
            final route = PushNotificationService.routeFromData(data);
            if (route != null) {
              ref.read(pendingPushRouteProvider.notifier).state = route;
            }
          });
        } else if (userId == null && _lastUserId != null) {
          _lastUserId = null;
          pushService.dispose();
        }
      });
    });
    debugPrint('[STARTUP] _UnifyAppState._startAuthListener() done');
  }

  @override
  void dispose() {
    _authSub?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          Supabase.instance.client.auth.refreshSession();
        }
      } catch (_) {
        // Supabase not initialized — nothing to refresh.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[STARTUP] _UnifyAppState.build() entered');
    debugPrint('[STARTUP] _UnifyAppState.build() calling ref.watch(appRouterProvider)...');
    final router = ref.watch(appRouterProvider);
    debugPrint('[STARTUP] _UnifyAppState.build() appRouterProvider done');
    debugPrint('[STARTUP] _UnifyAppState.build() calling ref.watch(themeNotifierProvider)...');
    final theme = ref.watch(themeNotifierProvider);
    debugPrint('[STARTUP] _UnifyAppState.build() themeNotifierProvider done');
    debugPrint('[STARTUP] _UnifyAppState.build() calling ref.watch(themeModeProvider)...');
    final mode = ref.watch(themeModeProvider);
    debugPrint('[STARTUP] _UnifyAppState.build() themeModeProvider done');

    ref.listen(pendingPushRouteProvider, (_, route) {
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go(route);
          ref.read(pendingPushRouteProvider.notifier).state = null;
        });
      }
    });

    debugPrint('[STARTUP] _UnifyAppState.build() returning MaterialApp.router');
    return MaterialApp.router(
      title: 'UNIFY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildFrom(theme),
      darkTheme: AppTheme.buildDark(theme),
      themeMode: mode,
      routerConfig: router,
      builder: (context, child) =>
          UpdateGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
