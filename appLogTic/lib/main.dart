import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'widgets/notification_banner.dart';
import 'services/local_notification_service.dart';
import 'services/background_sync_service.dart';
import 'services/log_service.dart';
import 'providers/auth_provider.dart';
import 'providers/odoo_provider.dart';
import 'providers/route_provider.dart';
import 'providers/driver_monitor_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/notification_badge_provider.dart';
import 'providers/theme_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationService.instance.init();

  // Extraer título y cuerpo del payload de datos si existe, o usar uno por defecto
  final title = message.data['title'] ?? 'LogTic';
  
  // Si viene una ruta nueva, el payload trae route_count
  String body = message.data['body'] ?? 'Tienes actualizaciones en tus entregas.';
  if (message.data.containsKey('route_count')) {
    final count = message.data['route_count'];
    body = 'Te han asignado $count nueva(s) ruta(s).';
  }

  // Mostrar la notificación local
  await LocalNotificationService.instance.showFcmNotification(
    id: LocalNotificationService.generateId(message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString()),
    title: title,
    body: body,
    data: message.data,
  );

  try {
    LogService.instance.debug('FCM', '🔔 FCM Background: ${message.messageId}');
  } catch (_) {}

  // Store route data for when app opens
  if (message.data.containsKey('route') || message.data.containsKey('route_ids')) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_route', jsonEncode(message.data));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LogService.instance.init();
  } catch (e) {
    debugPrint('LogService init error: $e');
  }

  // Safe Firebase setup
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e, stack) {
    LogService.instance.exception('Firebase', e, stack);
  }

  // Safe Local Notifications setup
  try {
    await LocalNotificationService.instance.init();
  } catch (e, stack) {
    LogService.instance.exception('LocalNotification', e, stack);
  }

  // Restore theme preference before app starts
  final themeProvider = ThemeProvider();
  try {
    await themeProvider.loadPreference();
  } catch (e, stack) {
    LogService.instance.exception('Theme', e, stack);
  }

  // Restore session before app starts
  final authProvider = AuthProvider();
  try {
    await authProvider.restoreSession();
  } catch (e, stack) {
    LogService.instance.exception('Auth', e, stack);
  }

  runApp(LogticApp(
    authProvider: authProvider,
    themeProvider: themeProvider,
  ));
}

class LogticApp extends StatefulWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;
  const LogticApp({
    super.key,
    required this.authProvider,
    required this.themeProvider,
  });

  @override
  State<LogticApp> createState() => _LogticAppState();
}

class _LogticAppState extends State<LogticApp> {
  late final GoRouter _router;
  BackgroundSyncService? _bgSync;

  /// Listens to [AuthProvider] state changes so we can react when the user
  /// logs in or out (i.e. restart the background sync and consume any
  /// deep-link that was stored before authentication completed).
  void _onAuthChange() {
    if (!mounted) return;
    final auth = widget.authProvider;

    if (auth.isLoggedIn) {
      // Error 2.3: re-start the background sync service after login.
      // Without this it stays dead if the user was at the login screen
      // when the first timer tick fired and stopped the service.
      _bgSync?.reset();

      // Error 2.4: consume any deep-link that arrived before login.
      final pending = auth.consumePendingDeepLink();
      if (pending != null) {
        // Defer navigation until the router has settled.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _router.go(pending);
        });
      }
    } else {
      // User logged out — stop the service until the next login.
      _bgSync?.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    _router = AppRouter(authProvider: widget.authProvider).router;
    _initDeepLinks();

    // Escuchar rotación de tokens FCM
    widget.authProvider.listenTokenRefresh();

    // Handle notification taps from local notifications (foreground)
    LocalNotificationService.instance.onNotificationTap = (data) {
      _handleDeepLink(data);
    };

    // Error 2.3 + Error 2.4: react to auth state changes (login/logout).
    widget.authProvider.addListener(_onAuthChange);

    // Start background sync after the widget tree is built.
    // Storage permission request was removed: logs now use the app-private
    // documents directory, which requires no permissions on Android 10+.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBackgroundSync();
      // Error 2.1: load the persisted unread badge count.
      context.read<NotificationBadgeProvider>().load();
    });
  }

  void _initBackgroundSync() {
    if (!mounted) return;
    _bgSync?.stop();
    _bgSync = BackgroundSyncService(
      getDriverId: () => context.read<AuthProvider>().currentUser?.driverId,
      // Error 2.2: onSync now receives `since` (last sync timestamp) to pass
      // to the check-new endpoint, preventing every pending route from being
      // reported as "new" on each tick.
      onSync: (driverId, since) async {
        final odoo = context.read<OdooProvider>();
        final routeProvider = context.read<RouteProvider>();
        final badgeProvider = context.read<NotificationBadgeProvider>();

        // 1. Verificar si hay rutas nuevas (endpoint ligero)
        final hasNew = await odoo.checkNewRoutes(driverId, since: since);
        if (hasNew) {
          // 2. Solo sincronizar si hay rutas nuevas
          final routes = await odoo.syncRoutesFromOdoo(driverId, silent: true);
          if (routes.isNotEmpty) {
            routeProvider.setRoutesFromOdoo(routes);
            // 3. Incrementar badge si hay rutas nuevas
            badgeProvider.increment();
          }
          return routes.length;
        }
        return 0;
      },
    );
    // Only start immediately if the user is already logged in.
    // If they are at the login screen the service will be started by
    // _onAuthChange when authentication completes (Error 2.3).
    if (widget.authProvider.isLoggedIn) {
      _bgSync!.start();
    }
  }

  @override
  void dispose() {
    widget.authProvider.removeListener(_onAuthChange);
    _bgSync?.dispose();
    super.dispose();
  }

  void _initDeepLinks() {
    // Handle notification that opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleDeepLink(message.data);
        return;
      }
      // Check for pending route from background handler
      _checkPendingRoute();
    });

    // Handle notification tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleDeepLink(message.data);
    });

    // Handle foreground messages → show in-app banner
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  void _showForegroundNotification(RemoteMessage message) {
    if (!mounted) return;

    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Nueva notificación';
    // Mejora 7: Unificar manejo de route_count en foreground
    String body = notification?.body ?? message.data['body'] ?? '';
    if (message.data.containsKey('route_count')) {
      body = 'Te han asignado ${message.data['route_count']} nueva(s) ruta(s).';
    }


    // 1. Show local system notification (visible in notification shade)
    final notificationId = LocalNotificationService.generateId(message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString());
    LocalNotificationService.instance.showFcmNotification(
      id: notificationId,
      title: title,
      body: body,
      data: message.data,
    );

    // 2. Increment unread badge
    // (we need the provider context — try the root navigator)
    final badgeCtx = AppRouter.rootNavigatorKey.currentContext;
    if (badgeCtx != null) {
      badgeCtx.read<NotificationBadgeProvider>().increment();
    }

    // 3. Show in-app banner (visible while using the app)
    // Bug 1.3: build the onTap callback when there are route_ids OR route,
    // not only when the legacy 'route' key is present (Odoo sends route_ids).
    final ctx = AppRouter.rootNavigatorKey.currentContext;
    if (ctx == null) return;

    final bool hasDeepLink = message.data.containsKey('route') ||
        message.data.containsKey('route_ids');
    NotificationBanner.show(
      ctx,
      title: title,
      body: body,
      route: message.data['route'] as String?,
      onTap: hasDeepLink
          ? () {
              badgeCtx?.read<NotificationBadgeProvider>().markOneAsRead();
              _handleDeepLink(message.data);
            }
          : null,
    );
  }

  Future<void> _checkPendingRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString('pending_route');
    if (pending != null) {
      await prefs.remove('pending_route');
      final data = jsonDecode(pending) as Map<String, dynamic>;
      _handleDeepLink(data);
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    if (!mounted) return;

    // Bug 1.1: Odoo sends route_ids (IDs of mss.route records, not
    // mss.route.line). The old code built '/routes/{id}' which maps to
    // RouteLineDetailScreen and expects a *line* ID — causing "Entrega no
    // encontrada". The correct fix is to navigate to the routes list
    // (/routes) so the user sees all their assigned routes for today.
    //
    // If a specific 'route' path was already resolved (e.g. from a
    // custom server-side deep link), use it verbatim; otherwise go to /routes.
    String? route = data['route'] as String?;
    if (route == null) {
      if (data.containsKey('route_ids') || data.containsKey('type')) {
        // There is route data, but no explicit path — land on the routes tab.
        route = '/routes';
      }
    }
    if (route == null) return;

    // Ensure user is logged in before navigating
    if (!widget.authProvider.isLoggedIn) {
      // Store the deep link for after login; it will be consumed in
      // _onAuthChange when authentication succeeds (Error 2.4).
      widget.authProvider.setPendingDeepLink(route);
      return;
    }

    _router.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(create: (_) => OdooProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
        ChangeNotifierProvider.value(value: widget.themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'LogTic',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}