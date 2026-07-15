import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../utils/pair.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import '../../providers/route_provider.dart';
import '../admin/driver_monitor_screen.dart';
import '../admin/user_management_screen.dart';
import '../dashboard/dashboard_screen.dart';
import './widgets/photo_capture_dialog.dart';
import './widgets/incomplete_reason_dialog.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final odoo = context.read<OdooProvider>();
      final routeProvider = context.read<RouteProvider>();
      
      final driverId = auth.currentUser?.driverId;
      if (driverId != null && driverId > 0) {
        odoo.syncRoutesFromOdoo(driverId).then((routes) {
          if (routes.isNotEmpty) {
            routeProvider.setRoutesFromOdoo(routes);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final odoo = context.watch<OdooProvider>();
    final isAdmin = auth.currentUser?.username == 'admin';

    return Scaffold(
      body: Column(
        children: [
          _RoutesHeader(
            userName: auth.currentUser?.fullName ?? 'Conductor',
            isAdmin: isAdmin,
            isConnected: odoo.isConnected,
            lastSync: odoo.lastSyncTime,
            errorMessage: odoo.errorMessage,
            isLoading: odoo.isLoading,
            onSync: () {
              final driverId = auth.currentUser?.driverId;
              if (driverId != null) {
                odoo.syncRoutesFromOdoo(driverId).then((routes) {
                  if (routes.isNotEmpty) {
                    context.read<RouteProvider>().setRoutesFromOdoo(routes);
                  }
                });
              }
            },
            onLogout: () {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            },
            onMonitor: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DriverMonitorScreen()),
              );
            },
            onUsers: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              );
            },
          ),
          _StatsCardsRow(odoo: odoo),
          Expanded(
            child: _RoutesList(odoo: odoo),
          ),
        ],
      ),
    );
  }
}

class _RoutesHeader extends StatelessWidget {
  final String userName;
  final bool isAdmin;
  final bool isConnected;
  final String lastSync;
  final String errorMessage;
  final bool isLoading;
  final VoidCallback onSync;
  final VoidCallback onLogout;
  final VoidCallback onMonitor;
  final VoidCallback onUsers;

  const _RoutesHeader({
    required this.userName,
    required this.isAdmin,
    required this.isConnected,
    required this.lastSync,
    required this.errorMessage,
    required this.isLoading,
    required this.onSync,
    required this.onLogout,
    required this.onMonitor,
    required this.onUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis Rutas',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 14, color: AppColors.white70),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(onPressed: onMonitor, icon: const Icon(Icons.visibility, color: AppColors.white)),
                  IconButton(onPressed: onUsers, icon: const Icon(Icons.supervisor_account, color: AppColors.white)),
                ] else
                  IconButton(
                    onPressed: isLoading ? null : onSync,
                    icon: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Icon(Icons.sync, color: AppColors.white),
                  ),
                IconButton(onPressed: onLogout, icon: const Icon(Icons.exit_to_app, color: AppColors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ConnectionBadge(isConnected: isConnected, lastSync: lastSync),
                if (errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                    child: const Text('⚠️ Error', style: TextStyle(fontSize: 10, color: AppColors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool isConnected;
  final String lastSync;
  const _ConnectionBadge({required this.isConnected, required this.lastSync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.statusCompleted.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: isConnected ? AppColors.statusCompletedLight : AppColors.error)),
          const SizedBox(width: 6),
          Text(
            isConnected ? (lastSync.isNotEmpty ? 'Sync: $lastSync' : 'Conectado') : 'Desconectado',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _StatsCardsRow extends StatelessWidget {
  final OdooProvider odoo;
  const _StatsCardsRow({required this.odoo});

  @override
  Widget build(BuildContext context) {
    final routes = odoo.odooRoutes.where((r) => r.state != 'finished').toList();
    final lines = routes.expand((r) => r.routeLines).toList();
    final total = lines.length;
    final inProgress = lines.where((l) => l.state == 'in_progress' || l.state == 'picked_up').length;
    final completed = lines.where((l) => ['done', 'incomplete', 'partial'].contains(l.state)).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.corpDarkGray,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCardItem(icon: Icons.list_alt, value: '$total', label: 'Pendientes', iconColor: AppColors.corpLightBlue),
            Container(height: 50, width: 1, color: AppColors.white24),
            _StatCardItem(icon: Icons.local_shipping, value: '$inProgress', label: 'En Curso', iconColor: AppColors.corpGold),
            Container(height: 50, width: 1, color: AppColors.white24),
            _StatCardItem(icon: Icons.check_circle, value: '$completed', label: 'Completadas', iconColor: AppColors.statusCompleted),
          ],
        ),
      ),
    );
  }
}

class _StatCardItem extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color iconColor;
  const _StatCardItem({required this.icon, required this.value, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: iconColor, size: 24),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.white70)),
    ]);
  }
}

class _RoutesList extends StatelessWidget {
  final OdooProvider odoo;
  const _RoutesList({required this.odoo});

  @override
  Widget build(BuildContext context) {
    final groupedRoutes = odoo.odooRoutes.where((r) => r.state != 'finished').toList();
    if (groupedRoutes.isEmpty) return _EmptyStateCard(errorMessage: odoo.errorMessage);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: groupedRoutes.length,
      itemBuilder: (context, index) {
        final route = groupedRoutes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ExpandableRouteCard(routeName: route.name, routeLines: route.routeLines, routeData: route, odoo: odoo),
        );
      },
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String errorMessage;
  const _EmptyStateCard({this.errorMessage = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_shipping, size: 64, color: AppColors.gray400),
              const SizedBox(height: 16),
              if (errorMessage.isNotEmpty) ...[
                const Text('⚠️ Error de sincronización', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.error)),
                const SizedBox(height: 8),
                Text(errorMessage, style: const TextStyle(fontSize: 14, color: AppColors.gray600), textAlign: TextAlign.center),
              ] else ...[
                const Text('Sin rutas pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                const Text('No hay entregas asignadas para hoy', style: TextStyle(fontSize: 14, color: AppColors.gray600), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableRouteCard extends StatefulWidget {
  final String routeName;
  final List<RouteLineData> routeLines;
  final RouteData routeData;
  final OdooProvider odoo;

  const _ExpandableRouteCard({
    required this.routeName,
    required this.routeLines,
    required this.routeData,
    required this.odoo,
  });

  @override
  State<_ExpandableRouteCard> createState() => _ExpandableRouteCardState();
}

class _ExpandableRouteCardState extends State<_ExpandableRouteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.routeLines.where((l) => ['done', 'incomplete', 'partial'].contains(l.state)).length;
    final totalCount = widget.routeLines.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final hasUrgent = widget.routeLines.any((l) => l.priority == 'urgent' && !['done', 'cancelled', 'incomplete', 'partial'].contains(l.state));
    final isUrgent = hasUrgent || (widget.routeData.maxPriority == 'urgent' && widget.routeData.state != 'finished');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isUrgent ? BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 2) : BorderSide.none,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isUrgent ? AppColors.error.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(isUrgent ? Icons.warning : Icons.route, color: isUrgent ? AppColors.error : AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.routeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('⚠ URGENTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error)),
                      ),
                    const SizedBox(width: 8),
                    Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Theme.of(context).primaryColor),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('$completedCount de $totalCount entregas', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.statusCompletedLight)),
                  ]),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusCompletedLight),
                    minHeight: 6,
                  ),
                  if (widget.routeData.startDate != null && widget.routeData.startDate!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.play_arrow, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(_formatDateTime(widget.routeData.startDate!), style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                    ]),
                  ],
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                children: widget.routeLines.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RouteActivityCard(line: line, odoo: widget.odoo),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final parts = dateTime.split(' ');
      if (parts.length == 2) {
        final date = parts[0].split('-');
        final time = parts[1].split(':');
        return '${date[2]}/${date[1]} ${time[0]}:${time[1]}';
      }
      return dateTime;
    } catch (_) { return dateTime; }
  }
}

class _RouteActivityCard extends StatefulWidget {
  final RouteLineData line;
  final OdooProvider odoo;
  const _RouteActivityCard({required this.line, required this.odoo});

  @override
  State<_RouteActivityCard> createState() => _RouteActivityCardState();
}

class _RouteActivityCardState extends State<_RouteActivityCard> {
  Pair<double?, double?> _currentLocation = Pair(null, null);
  bool _showProducts = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) await Geolocator.requestPermission();
      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentLocation = Pair(position.latitude, position.longitude));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor(widget.line.state);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: stateColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Center(child: Text(
                  widget.line.partnerId.name.isNotEmpty ? widget.line.partnerId.name[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: stateColor),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.line.partnerId.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (widget.line.obra != null && widget.line.obra!.isNotEmpty)
                    Text('📍 ${widget.line.obra}', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: stateColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(_getStateLabel(widget.line.state), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: stateColor)),
              ),
            ]),
            if (widget.line.street != null && widget.line.street!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.place, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.line.street!, style: const TextStyle(fontSize: 13)),
                    if (widget.line.city != null) Text(widget.line.city!, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                  ],
                )),
              ]),
            ],
            if (widget.line.notes != null && widget.line.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
                child: Text(_parseHtml(widget.line.notes!), style: const TextStyle(fontSize: 13)),
              ),
            ],
            if (widget.line.startTime != null || widget.line.pickupTime != null || widget.line.endTime != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                if (widget.line.startTime != null) _TimeChip(icon: Icons.play_arrow, time: _formatTime(widget.line.startTime!), color: AppColors.statusInProgress),
                if (widget.line.pickupTime != null) _TimeChip(icon: Icons.local_shipping, time: _formatTime(widget.line.pickupTime!), color: AppColors.statusPickedUp),
                if (widget.line.endTime != null) _TimeChip(icon: Icons.check_circle, time: _formatTime(widget.line.endTime!), color: AppColors.statusCompleted),
              ]),
            ],
            if (widget.line.orderLines != null && widget.line.orderLines!.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => setState(() => _showProducts = !_showProducts),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      const Icon(Icons.inventory, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('${widget.line.orderLines!.length} productos', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      if (widget.line.orderName != null) Text(' • ${widget.line.orderName}', style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                    ]),
                    Icon(_showProducts ? Icons.expand_less : Icons.expand_more, color: AppColors.primary, size: 20),
                  ]),
                ),
              ),
              if (_showProducts)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: widget.line.orderLines!.map((orderLine) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(orderLine.productName, style: const TextStyle(fontSize: 12))),
                        Text('${orderLine.quantity.toInt()} ${orderLine.uom}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ]),
                    )).toList(),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _navigate,
          icon: const Icon(Icons.navigation, size: 18),
          label: const Text('Navegar', style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
      const SizedBox(width: 8),
      ..._buildStateButtons(context),
    ]);
  }

  List<Widget> _buildStateButtons(BuildContext context) {
    switch (widget.line.state) {
      case 'pending':
        return [Expanded(child: OutlinedButton.icon(
          onPressed: () => widget.odoo.notifyLineStarted(widget.line.id, _currentLocation.first, _currentLocation.second),
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Iniciar', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ))];
      case 'in_progress':
        return [
          Expanded(child: ElevatedButton.icon(
            onPressed: () => widget.odoo.notifyLinePickedUp(widget.line.id, _currentLocation.first, _currentLocation.second),
            icon: const Icon(Icons.local_shipping, size: 16),
            label: const Text('Recoger', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusPickedUp, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => _showPhotoDialog(context),
            icon: const Icon(Icons.camera_alt, size: 16),
            label: const Text('Finalizar', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _showIncompleteDialog(context),
            icon: const Icon(Icons.warning, size: 16),
            label: const Text('Incompleta', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.statusIncomplete, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ];
      case 'picked_up':
        return [
          Expanded(child: ElevatedButton.icon(
            onPressed: () => _showPhotoDialog(context),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Finalizar con Foto', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _showIncompleteDialog(context),
            icon: const Icon(Icons.warning, size: 16),
            label: const Text('Incompleta', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.statusIncomplete, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ];
      case 'done':
      case 'incomplete':
      case 'partial':
        return [Expanded(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (widget.line.state == 'done' ? AppColors.statusCompleted : AppColors.statusIncomplete).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.line.state == 'done' ? Icons.check_circle : Icons.warning, size: 18,
              color: widget.line.state == 'done' ? AppColors.statusCompleted : AppColors.statusIncomplete),
            const SizedBox(width: 6),
            Text(widget.line.state == 'done' ? 'Completada' : 'Incompleta',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: widget.line.state == 'done' ? AppColors.statusCompleted : AppColors.statusIncomplete)),
          ]),
        ))];
      default:
        return [Expanded(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: AppColors.statusCancelled.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('Cancelada', style: TextStyle(fontSize: 13, color: AppColors.statusCancelled))),
        ))];
    }
  }

  void _navigate() async {
    final destination = widget.line.street != null && widget.line.street!.isNotEmpty
        ? Uri.encodeComponent(widget.line.street!)
        : '${widget.line.latitude ?? 0.0},${widget.line.longitude ?? 0.0}';
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  void _showPhotoDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => PhotoCaptureDialog(
      partnerName: widget.line.partnerId.name, odoo: widget.odoo, lineId: widget.line.id, currentLocation: _currentLocation,
    ));
  }

  void _showIncompleteDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => IncompleteReasonDialog(
      partnerName: widget.line.partnerId.name, odoo: widget.odoo, lineId: widget.line.id, currentLocation: _currentLocation,
    ));
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'done': return AppColors.statusCompleted;
      case 'picked_up': return AppColors.statusPickedUp;
      case 'in_progress': return AppColors.statusInProgress;
      case 'incomplete': case 'partial': return AppColors.statusIncomplete;
      case 'cancelled': return AppColors.statusCancelled;
      default: return AppColors.statusPending;
    }
  }

  String _getStateLabel(String state) {
    switch (state) {
      case 'done': return '✓ Entregado';
      case 'picked_up': return '📦 Recogido';
      case 'in_progress': return '🚛 En camino';
      case 'incomplete': return '⚠ Incompleta';
      case 'partial': return '⚠ Parcial';
      case 'cancelled': return '✗ Cancelado';
      default: return '⏳ Pendiente';
    }
  }

  String _formatTime(String dateTime) {
    try { final parts = dateTime.split(' '); if (parts.length == 2) { final time = parts[1].split(':'); return '${time[0]}:${time[1]}'; } return dateTime; } catch (_) { return dateTime; }
  }

  String _parseHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ').replaceAll('&', '&')
        .replaceAll('<', '<').replaceAll('>', '>')
        .replaceAll('"', '"').trim();
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon; final String time; final Color color;
  const _TimeChip({required this.icon, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(time, style: TextStyle(fontSize: 10, color: color)),
      ]),
    );
  }
}