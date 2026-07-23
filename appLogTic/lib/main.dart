import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
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
  await Firebase.initializeApp();
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
  if (message.data.containsKey('route')) {
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
    await Firebase.initializeApp();
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

  @override
  void initState() {
    super.initState();
    _router = AppRouter(authProvider: widget.authProvider).router;
    _initDeepLinks();

    // Handle notification taps from local notifications (foreground)
    LocalNotificationService.instance.onNotificationTap = (data) {
      _handleDeepLink(data);
    };

    // Start background sync and request permissions after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBackgroundSync();
      LogService.instance.requestPermissionsAndInit();
    });
  }

  void _initBackgroundSync() {
    if (!mounted) return;
    _bgSync?.stop();
    _bgSync = BackgroundSyncService(
      getDriverId: () => context.read<AuthProvider>().currentUser?.driverId,
      onSync: (driverId) async {
        final odoo = context.read<OdooProvider>();
        final routeProvider = context.read<RouteProvider>();
        final routes = await odoo.syncRoutesFromOdoo(driverId, silent: true);
        if (routes.isNotEmpty) {
          routeProvider.setRoutesFromOdoo(routes);
        }
        return routes.length;
      },
    );
    _bgSync!.start();
  }

  @override
  void dispose() {
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
    final body = notification?.body ?? message.data['body'] ?? '';
    final route = message.data['route'] as String?;

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
    final ctx = AppRouter.rootNavigatorKey.currentContext;
    if (ctx == null) return;

    NotificationBanner.show(
      ctx,
      title: title,
      body: body,
      route: route,
      onTap: route != null
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
    final route = data['route'] as String?;
    if (route == null || !mounted) return;

    // Ensure user is logged in before navigating
    if (!widget.authProvider.isLoggedIn) {
      // Store the deep link for after login
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
      child: MaterialApp.router(
        title: 'LogTic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.themeProvider.themeMode,
        routerConfig: _router,
      ),
    );
  }
}