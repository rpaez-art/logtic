import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/route.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/route_provider.dart';

/// Perfil del encabezado del drawer
class ShellDrawerHeader extends StatelessWidget {
  final User? user;
  final bool isAdmin;

  const ShellDrawerHeader({super.key, required this.user, required this.isAdmin});

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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

/// Elemento de navegación del drawer
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;

  const DrawerItem({
    super.key,
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

/// Resumen de estado de rutas activas/completadas
class RouteStatusSummary extends StatelessWidget {
  const RouteStatusSummary({super.key});

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
          StatusChip(
            icon: Icons.play_circle_filled,
            iconColor: AppColors.statusInProgress,
            count: activeCount,
            label: 'Activas',
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: AppColors.gray200,
          ),
          const SizedBox(width: 8),
          StatusChip(
            icon: Icons.check_circle,
            iconColor: AppColors.statusCompletedLight,
            count: completedCount,
            label: 'Completadas',
          ),
          const Spacer(),
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

class StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const StatusChip({
    super.key,
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

/// Encabezado compacto del rail
class RailHeader extends StatelessWidget {
  final User? user;
  final bool isAdmin;

  const RailHeader({super.key, required this.user, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : user?.username ?? 'Conductor';
    final initial = name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?';
    final routeProvider = context.watch<RouteProvider>();
    final allRoutes = routeProvider.allRoutes;
    final activeCount = allRoutes
        .where((r) => r.status == RouteStatus.pending || r.status == RouteStatus.inProgress)
        .length;
    final completedCount = allRoutes
        .where((r) => r.status == RouteStatus.completed)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
            StatusChip(
              icon: Icons.play_circle_filled,
              iconColor: AppColors.statusInProgress,
              count: activeCount,
              label: 'act',
            ),
            const SizedBox(height: 2),
            StatusChip(
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

/// Área inferior del rail con logout y acceso admin
class RailTrailing extends StatelessWidget {
  final AuthProvider auth;
  final bool isAdmin;

  const RailTrailing({super.key, required this.auth, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              iconSize: 20,
              color: AppColors.gray500,
              tooltip: 'Panel de administración',
              onPressed: () => _showAdminMenu(context),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            iconSize: 20,
            color: AppColors.gray500,
            tooltip: 'Cerrar sesión',
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
              leading: const Icon(Icons.supervisor_account, color: AppColors.primary),
              title: const Text('Usuarios'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/admin/users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
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

/// Elemento expandible de "Rutas" con sub-rutas activas
class ExpandableRutasItem extends StatefulWidget {
  final int current;
  final int badgeCount;
  final VoidCallback onNavigateToRoutes;

  const ExpandableRutasItem({
    super.key,
    required this.current,
    required this.badgeCount,
    required this.onNavigateToRoutes,
  });

  @override
  State<ExpandableRutasItem> createState() => _ExpandableRutasItemState();
}

class _ExpandableRutasItemState extends State<ExpandableRutasItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DrawerItem(
          icon: Icons.route_outlined,
          activeIcon: Icons.route,
          label: 'Rutas',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded ? _buildSubItems() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubItems() {
    final routeProvider = context.watch<RouteProvider>();
    final activeRoutes = routeProvider.allRoutes
        .where((r) => r.status == RouteStatus.pending || r.status == RouteStatus.inProgress)
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isInProgress ? AppColors.statusInProgress : AppColors.gray400,
                    boxShadow: isInProgress
                        ? [
                            BoxShadow(
                              color: AppColors.statusInProgress.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.clientName.isNotEmpty ? route.clientName : 'Ruta #${route.id}',
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
                        route.address.isNotEmpty ? route.address : 'Sin dirección',
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
                Text(
                  route.scheduledTime.length >= 5 ? route.scheduledTime.substring(0, 5) : '',
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