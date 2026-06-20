import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/theme_mode_provider.dart';
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
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set up push notification init AFTER the first frame so the router
    // Navigator is fully mounted before any navigation can be triggered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAuthListener());
  }

  void _startAuthListener() {
    _authSub = ref.listenManual(authStateProvider, (_, next) {
      next.whenData((authState) {
        final userId = authState.session?.user.id;
        final router = ref.read(appRouterProvider);
        final pushService = ref.read(pushNotificationServiceProvider);
        if (userId != null && userId != _lastUserId) {
          _lastUserId = userId;
          pushService.init(userId, onTap: (data) {
            final route = PushNotificationService.routeFromData(data);
            if (route != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                router.go(route);
              });
            }
          });
        } else if (userId == null && _lastUserId != null) {
          _lastUserId = null;
          pushService.dispose();
        }
      });
    });
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
    final mode = ref.watch(themeModeProvider);

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
