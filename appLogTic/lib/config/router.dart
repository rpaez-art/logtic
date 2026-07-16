import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/tab_transition.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/routes/routes_screen.dart';
import '../screens/history/route_history_screen.dart';
import '../screens/routes/route_line_detail_screen.dart';
import '../screens/admin/driver_monitor_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/config/odoo_config_screen.dart';
import '../screens/tools/log_viewer_screen.dart';
import '../screens/shell_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authProvider,
    initialLocation: '/splash',
    redirect: _guard,
    routes: [
      // Splash route (outside shell)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login route (outside shell)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => _buildPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/routes',
            name: 'routes',
            pageBuilder: (context, state) => _buildPage(
              key: state.pageKey,
              child: const RoutesScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) => _buildPage(
              key: state.pageKey,
              child: const RouteHistoryScreen(),
            ),
          ),
        ],
      ),

      // Deep link: specific route line (pushed on top of shell)
      GoRoute(
        path: '/routes/:lineId',
        name: 'route-line',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final lineId = int.tryParse(state.pathParameters['lineId'] ?? '') ?? 0;
          return RouteLineDetailScreen(
            lineId: lineId,
            routeName: state.uri.queryParameters['name'] ?? '',
          );
        },
      ),

      // Tools: log viewer (pushed on top of shell)
      GoRoute(
        path: '/tools/logs',
        name: 'logs',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LogViewerScreen(),
      ),

      // Full-screen admin routes (pushed on top of shell)
      GoRoute(
        path: '/admin/monitor',
        name: 'admin-monitor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DriverMonitorScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/config',
        name: 'admin-config',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OdooConfigScreen(),
      ),
    ],
  );

  /// Auth guard: redirects unauthenticated users to login
  String? _guard(BuildContext context, GoRouterState state) {
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoading = authProvider.isLoading;
    final location = state.uri.toString();

    // Wait for session restoration
    if (isLoading) return null;

    // Not logged in → force splash (which will redirect to login)
    if (!isLoggedIn && location != '/splash' && location != '/login') return '/splash';

    // Logged in but at login → go to dashboard
    if (isLoggedIn && location == '/login') return '/dashboard';

    return null;
  }

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Publicly accessible root navigator key for showing overlays/SnackBars
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  static CustomTransitionPage _buildPage({
    required LocalKey key,
    required Widget child,
  }) {
    final direction = tabDirection.value;
    tabDirection.value = 0; // reset after consuming

    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combined slide + fade transition
        // Slide offset = 30% of screen width in the direction of travel
        final beginOffset = Offset(direction * 0.35, 0);

        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
