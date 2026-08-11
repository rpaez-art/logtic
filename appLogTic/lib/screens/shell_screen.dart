import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../utils/tab_transition.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_badge_provider.dart';
import '../widgets/animated_layout_switcher.dart';
import 'shell/widgets/badge_wrapper.dart';
import 'shell/widgets/drawer_navigation_widgets.dart';

/// Responsive shell that shows BottomNav on phones (narrow)
/// and a permanent Drawer on tablets (wide).
class ShellScreen extends StatefulWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const double _wideBreakpoint = 600;
  static const double _railBreakpoint = 900;

  int _prevLayout = 0;
  int _currentLayout = 0;

  int _layoutIndex(double width) {
    if (width < _wideBreakpoint) return 0;
    if (width >= _railBreakpoint) return 2;
    return 1;
  }

  int _indexFromRoute(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/routes')) return 1;
    if (location.startsWith('/history')) return 2;
    return 0;
  }

  void _navigate(int current, int index) {
    if (index == current) return;
    tabDirection.value = index > current ? 1 : -1;
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.read<NotificationBadgeProvider>().markAllAsRead();
        context.go('/routes');
        break;
      case 2:
        context.go('/history');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final current = _indexFromRoute(location);
    final badgeCount = context.watch<NotificationBadgeProvider>().unreadCount;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isAdmin = user?.username == 'admin';

    return LayoutBuilder(
      builder: (context, constraints) {
        final newLayout = _layoutIndex(constraints.maxWidth);
        if (newLayout != _currentLayout) {
          _prevLayout = _currentLayout;
          _currentLayout = newLayout;
        }

        final isWide = constraints.maxWidth >= _wideBreakpoint;

        Widget layout;

        if (!isWide) {
          layout = Scaffold(
            key: const ValueKey('layout_phone'),
            body: widget.child,
            bottomNavigationBar: _buildBottomNav(current, badgeCount),
          );
        } else if (constraints.maxWidth >= _railBreakpoint) {
          layout = KeyedSubtree(
            key: const ValueKey('layout_rail'),
            child: _buildNavigationRailLayout(current, badgeCount, user, isAdmin, auth),
          );
        } else {
          layout = Scaffold(
            key: const ValueKey('layout_drawer'),
            drawer: _buildDrawer(current, badgeCount, user, isAdmin, auth),
            body: widget.child,
          );
        }

        return AnimatedLayoutSwitcher(
          direction: _prevLayout < _currentLayout ? -1.0 : 1.0,
          child: layout,
        );
      },
    );
  }

  Widget _buildBottomNav(int current, int badgeCount) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: current,
        onTap: (index) => _navigate(current, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: BadgeWrapper(
              count: badgeCount,
              child: current == 1
                  ? const Icon(Icons.route)
                  : const Icon(Icons.route_outlined),
            ),
            activeIcon: BadgeWrapper(
              count: badgeCount,
              child: const Icon(Icons.route),
            ),
            label: 'Rutas',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRailLayout(
    int current,
    int badgeCount,
    dynamic user,
    bool isAdmin,
    AuthProvider auth,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: current,
            onDestinationSelected: (index) {
              if (index == current) return;
              if (index == 1) {
                context.read<NotificationBadgeProvider>().markAllAsRead();
              }
              _navigate(current, index);
            },
            leading: RailHeader(user: user, isAdmin: isAdmin),
            trailing: RailTrailing(auth: auth, isAdmin: isAdmin),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: const IconThemeData(color: AppColors.gray500),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: AppColors.gray500,
              fontSize: 12,
            ),
            minWidth: 80,
            destinations: [
              NavigationRailDestination(
                icon: Tooltip(
                  message: 'Resumen de actividad, rendimiento y estadísticas del día',
                  preferBelow: false,
                  child: const Icon(Icons.dashboard_outlined),
                ),
                selectedIcon: Tooltip(
                  message: 'Resumen de actividad, rendimiento y estadísticas del día',
                  preferBelow: false,
                  child: const Icon(Icons.dashboard),
                ),
                label: const Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: 'Rutas y entregas del día — consulta, inicia y completa cada entrega',
                  preferBelow: false,
                  child: BadgeWrapper(
                    count: badgeCount,
                    child: const Icon(Icons.route_outlined),
                  ),
                ),
                selectedIcon: Tooltip(
                  message: 'Rutas y entregas del día — consulta, inicia y completa cada entrega',
                  preferBelow: false,
                  child: BadgeWrapper(
                    count: badgeCount,
                    child: const Icon(Icons.route),
                  ),
                ),
                label: const Text('Rutas'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: 'Historial de rutas completadas con resumenes de entrega y duración',
                  preferBelow: false,
                  child: const Icon(Icons.history_outlined),
                ),
                selectedIcon: Tooltip(
                  message: 'Historial de rutas completadas con resumenes de entrega y duración',
                  preferBelow: false,
                  child: const Icon(Icons.history),
                ),
                label: const Text('Historial'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    int current,
    int badgeCount,
    dynamic user,
    bool isAdmin,
    AuthProvider auth,
  ) {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          ShellDrawerHeader(user: user, isAdmin: isAdmin),
          const RouteStatusSummary(),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  selected: current == 0,
                  onTap: () {
                    _navigate(current, 0);
                    Navigator.pop(context);
                  },
                ),
                ExpandableRutasItem(
                  current: current,
                  badgeCount: badgeCount,
                  onNavigateToRoutes: () {
                    context.read<NotificationBadgeProvider>().markAllAsRead();
                    _navigate(current, 1);
                  },
                ),
                DrawerItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'Historial',
                  selected: current == 2,
                  onTap: () {
                    _navigate(current, 2);
                    Navigator.pop(context);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 4),
                  child: Text(
                    'HERRAMIENTAS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                DrawerItem(
                  icon: Icons.bug_report_outlined,
                  activeIcon: Icons.bug_report,
                  label: 'Logs',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/tools/logs');
                  },
                ),
                if (isAdmin) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 4),
                    child: Text(
                      'ADMINISTRACIÓN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  DrawerItem(
                    icon: Icons.visibility_outlined,
                    activeIcon: Icons.visibility,
                    label: 'Monitor',
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/monitor');
                    },
                  ),
                  DrawerItem(
                    icon: Icons.supervisor_account_outlined,
                    activeIcon: Icons.supervisor_account,
                    label: 'Usuarios',
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/users');
                    },
                  ),
                  DrawerItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Configuración',
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/config');
                    },
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.gray200),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.pop(context);
                  context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray600,
                  side: const BorderSide(color: AppColors.gray300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}