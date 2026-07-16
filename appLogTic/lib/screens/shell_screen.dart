import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../utils/tab_transition.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_badge_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/route_provider.dart';
import '../models/route.dart';
import '../widgets/animated_layout_switcher.dart';

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

  /// Layout index for transition direction:
  /// 0 = phone, 1 = drawer, 2 = rail
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
          // ── Phone layout: BottomNavigationBar ──
          layout = Scaffold(
            key: const ValueKey('layout_phone'),
            body: widget.child,
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeToggleStrip(),
                _buildBottomNav(current, badgeCount),
              ],
            ),
          );
        } else if (constraints.maxWidth >= _railBreakpoint) {
          // ── Wide tablet / landscape layout: NavigationRail permanent ──
          layout = KeyedSubtree(
            key: const ValueKey('layout_rail'),
            child: _buildNavigationRailLayout(
              current, badgeCount, user, isAdmin, auth,
            ),
          );
        } else {
          // ── Medium tablet layout: Drawer (temporary) ──
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
      ),        child: BottomNavigationBar(
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
            icon: _BadgeWrapper(
              count: badgeCount,
              child: current == 1
                  ? const Icon(Icons.route)
                  : const Icon(Icons.route_outlined),
            ),
            activeIcon: _BadgeWrapper(
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
    User? user,
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
                context
                    .read<NotificationBadgeProvider>()
                    .markAllAsRead();
              }
              _navigate(current, index);
            },
            leading: _RailHeader(
              user: user,
              isAdmin: isAdmin,
            ),
            trailing: _RailTrailing(
              auth: auth,
              isAdmin: isAdmin,
            ),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            selectedIconTheme: const IconThemeData(
              color: AppColors.primary,
            ),
            unselectedIconTheme: const IconThemeData(
              color: AppColors.gray500,
            ),
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
                  message:
                      'Resumen de actividad, rendimiento y estadísticas del día',
                  preferBelow: false,
                  child: const Icon(Icons.dashboard_outlined),
                ),
                selectedIcon: Tooltip(
                  message:
                      'Resumen de actividad, rendimiento y estadísticas del día',
                  preferBelow: false,
                  child: const Icon(Icons.dashboard),
                ),
                label: const Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message:
                      'Rutas y entregas del día — consulta, inicia y completa cada entrega',
                  preferBelow: false,
                  child: _BadgeWrapper(
                    count: badgeCount,
                    child: const Icon(Icons.route_outlined),
                  ),
                ),
                selectedIcon: Tooltip(
                  message:
                      'Rutas y entregas del día — consulta, inicia y completa cada entrega',
                  preferBelow: false,
                  child: _BadgeWrapper(
                    count: badgeCount,
                    child: const Icon(Icons.route),
                  ),
                ),
                label: const Text('Rutas'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message:
                      'Historial de rutas completadas con resumenes de entrega y duración',
                  preferBelow: false,
                  child: const Icon(Icons.history_outlined),
                ),
                selectedIcon: Tooltip(
                  message:
                      'Historial de rutas completadas con resumenes de entrega y duración',
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
    User? user,
    bool isAdmin,
    AuthProvider auth,
  ) {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          // ── User Profile Header ──
          _DrawerHeader(user: user, isAdmin: isAdmin),

          // ── Route Status Summary ──
          _RouteStatusSummary(),
          const SizedBox(height: 4),

          // ── Navigation Items ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  selected: current == 0,
                  onTap: () {
                    _navigate(current, 0);
                    Navigator.pop(context);
                  },
                ),
                _ExpandableRutasItem(
                  current: current,
                  badgeCount: badgeCount,
                  onNavigateToRoutes: () {
                    context
                        .read<NotificationBadgeProvider>()
                        .markAllAsRead();
                    _navigate(current, 1);
                  },
                ),
                _DrawerItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'Historial',
                  selected: current == 2,
                  onTap: () {
                    _navigate(current, 2);
                    Navigator.pop(context);
                  },
                ),

                // ── Herramientas Section ──
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
                _DrawerItem(
                  icon: Icons.bug_report_outlined,
                  activeIcon: Icons.bug_report,
                  label: 'Logs',
                  selected: false,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/tools/logs');
                  },
                ),

                // ── Admin Section ──
                if (isAdmin) ...[
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  _DrawerItem(
                    icon: Icons.visibility_outlined,
                    activeIcon: Icons.visibility,
                    label: 'Monitor',
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/monitor');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.supervisor_account_outlined,
                    activeIcon: Icons.supervisor_account,
                    label: 'Usuarios',
                    selected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/users');
                    },
                  ),
                  _DrawerItem(
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

          // ── Dark Mode Toggle ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  context.watch<ThemeProvider>().isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  size: 20,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tema oscuro',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ),
                Switch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (_) =>
                      context.read<ThemeProvider>().toggle(),
                  activeThumbColor: AppColors.corpGold,
                  activeTrackColor:
                      AppColors.corpGold.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),

          // ── Logout ──
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

/// ── Route status summary strip showing active vs completed counts ──
class _RouteStatusSummary extends StatelessWidget {
  const _RouteStatusSummary();

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final allRoutes = routeProvider.allRoutes;

    final activeCount = allRoutes
        .where((r) => r.status == RouteStatus.pending || r.status == RouteStatus.inProgress)
        .length;
    final completedCount = allRoutes
        .where((r) => r.status == RouteStatus.completed)
        .length;
    final totalCount = allRoutes.length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Active indicator
          _StatusChip(
            icon: Icons.play_circle_filled,
            iconColor: AppColors.statusInProgress,
            count: activeCount,
            label: 'Activas',
          ),
          const SizedBox(width: 8),
          // Divider
          Container(
            width: 1,
            height: 24,
            color: AppColors.gray200,
          ),
          const SizedBox(width: 8),
          // Completed indicator
          _StatusChip(
            icon: Icons.check_circle,
            iconColor: AppColors.statusCompletedLight,
            count: completedCount,
            label: 'Completadas',
          ),
          const Spacer(),
          // Total pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$totalCount total',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small chip showing an icon + count + label inside the status summary
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const _StatusChip({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.corpDarkGray,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}

/// ── Drawer Profile Header ──
class _DrawerHeader extends StatelessWidget {
  final User? user;
  final bool isAdmin;

  const _DrawerHeader({required this.user, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : user?.username ?? 'Conductor';
    final initial = name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.corpGreen, AppColors.corpDarkGray],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.corpGold.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.corpGold.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                user?.driverCode.isNotEmpty == true
                    ? 'Código: ${user!.driverCode}'
                    : '@${user?.username ?? ''}',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.corpGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.corpGold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// ── Single Drawer Navigation Item ──
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.trailing,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          selected ? activeIcon : icon,
          color: selected ? AppColors.primary : AppColors.gray500,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.gray700,
          ),
        ),
        trailing: trailing,
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        horizontalTitleGap: 12,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// ── Expandable drawer item for 'Rutas' with active route sub-items ──
class _ExpandableRutasItem extends StatefulWidget {
  final int current;
  final int badgeCount;
  final VoidCallback onNavigateToRoutes;

  const _ExpandableRutasItem({
    required this.current,
    required this.badgeCount,
    required this.onNavigateToRoutes,
  });

  @override
  State<_ExpandableRutasItem> createState() => _ExpandableRutasItemState();
}

class _ExpandableRutasItemState extends State<_ExpandableRutasItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main header item
        _DrawerItem(
          icon: Icons.route_outlined,
          activeIcon: Icons.route,
          label: 'Rutas',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.expand_more,
                  size: 20,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
          selected: widget.current == 1,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
        // Expandable sub-items
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? _buildSubItems()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubItems() {
    final routeProvider = context.watch<RouteProvider>();
    final activeRoutes = routeProvider.allRoutes
        .where((r) =>
            r.status == RouteStatus.pending ||
            r.status == RouteStatus.inProgress)
        .toList();

    if (activeRoutes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 56, right: 16, bottom: 12),
        child: Text(
          'Sin rutas activas hoy',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray400,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: activeRoutes.map(_buildRouteLineTile).toList(),
      ),
    );
  }

  Widget _buildRouteLineTile(RouteModel route) {
    final isInProgress = route.status == RouteStatus.inProgress;
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 8, bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            widget.onNavigateToRoutes();
            Navigator.pop(context);
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Status dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isInProgress
                        ? AppColors.statusInProgress
                        : AppColors.gray400,
                    boxShadow: isInProgress
                        ? [
                            BoxShadow(
                              color: AppColors.statusInProgress
                                  .withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                // Client info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.clientName.isNotEmpty
                            ? route.clientName
                            : 'Ruta #${route.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.corpDarkGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        route.address.isNotEmpty
                            ? route.address
                            : 'Sin dirección',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.gray400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Scheduled time
                Text(
                  route.scheduledTime.length >= 5
                      ? route.scheduledTime.substring(0, 5)
                      : '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ── Thin theme toggle strip shown above BottomNav on phones ──
class _ThemeToggleStrip extends StatelessWidget {
  const _ThemeToggleStrip();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.gray200.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 16,
            color: AppColors.gray500,
          ),
          const SizedBox(width: 8),
          const Text(
            'Tema oscuro',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            height: 28,
            child: Switch(
              value: isDark,
              onChanged: (_) => context.read<ThemeProvider>().toggle(),
              activeThumbColor: AppColors.corpGold,
              activeTrackColor: AppColors.corpGold.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Compact rail header: avatar + name + route status ──
class _RailHeader extends StatelessWidget {
  final User? user;
  final bool isAdmin;

  const _RailHeader({
    required this.user,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : user?.username ?? 'Conductor';
    final initial = name.toString().isNotEmpty
        ? name.toString()[0].toUpperCase()
        : '?';
    final routeProvider = context.watch<RouteProvider>();
    final allRoutes = routeProvider.allRoutes;
    final activeCount = allRoutes
        .where((r) =>
            r.status == RouteStatus.pending ||
            r.status == RouteStatus.inProgress)
        .length;
    final completedCount = allRoutes
        .where((r) => r.status == RouteStatus.completed)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.corpGreen, AppColors.corpDarkGray],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.corpGold.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Name
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.corpDarkGray,
            ),
          ),
          if (isAdmin)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.corpGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.corpGold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          if (allRoutes.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Compact route stats
            _StatusChip(
              icon: Icons.play_circle_filled,
              iconColor: AppColors.statusInProgress,
              count: activeCount,
              label: 'act',
            ),
            const SizedBox(height: 2),
            _StatusChip(
              icon: Icons.check_circle,
              iconColor: AppColors.statusCompletedLight,
              count: completedCount,
              label: 'comp',
            ),
          ],
        ],
      ),
    );
  }
}

/// ── Rail bottom area: admin items + theme toggle + logout ──
class _RailTrailing extends StatelessWidget {
  final AuthProvider auth;
  final bool isAdmin;

  const _RailTrailing({
    required this.auth,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Admin tools popup
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              iconSize: 20,
              color: AppColors.gray500,
              tooltip: 'Panel de administración — monitorea conductores, gestiona usuarios y configura el sistema',
              onPressed: () => _showAdminMenu(context),
            ),
          // Dark mode toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            iconSize: 20,
            color: AppColors.gray500,
            tooltip: isDark
                ? 'Cambiar a modo claro — interfaz con fondo claro'
                : 'Cambiar a modo oscuro — interfaz con fondo oscuro',
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            iconSize: 20,
            color: AppColors.gray500,
            tooltip: 'Cerrar sesión — salir de la aplicación y volver a la pantalla de inicio',
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  void _showAdminMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Administración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: AppColors.primary),
              title: const Text('Monitor'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/admin/monitor');
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervisor_account,
                  color: AppColors.primary),
              title: const Text('Usuarios'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/admin/users');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/admin/config');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// ── Badge wrapper for BottomNav / Rail icons ──
class _BadgeWrapper extends StatelessWidget {
  final int count;
  final Widget child;

  const _BadgeWrapper({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
