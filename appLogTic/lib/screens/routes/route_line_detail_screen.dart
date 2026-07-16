import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';

class RouteLineDetailScreen extends StatefulWidget {
  final int lineId;
  final String routeName;

  const RouteLineDetailScreen({
    super.key,
    required this.lineId,
    this.routeName = '',
  });

  @override
  State<RouteLineDetailScreen> createState() => _RouteLineDetailScreenState();
}

class _RouteLineDetailScreenState extends State<RouteLineDetailScreen> {
  RouteLineData? _lineData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _findLineData();
  }

  void _findLineData() {
    final odoo = context.read<OdooProvider>();
    for (final route in odoo.odooRoutes) {
      for (final line in route.routeLines) {
        if (line.id == widget.lineId) {
          setState(() {
            _lineData = line;
            _isLoading = false;
          });
          return;
        }
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routeName.isNotEmpty ? widget.routeName : 'Detalle de Entrega',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.corpGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lineData == null
              ? _buildNotFound()
              : _buildDetail(),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: AppColors.gray300),
          const SizedBox(height: 16),
          const Text(
            'Entrega no encontrada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.gray600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los datos pueden estar desactualizados.\nSincroniza tus rutas e intenta de nuevo.',
            style: TextStyle(fontSize: 14, color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final auth = context.read<AuthProvider>();
              final odoo = context.read<OdooProvider>();
              if (auth.currentUser != null) {
                odoo.syncRoutesFromOdoo(auth.currentUser!.driverId).then((_) {
                  _findLineData();
                });
              }
            },
            icon: const Icon(Icons.sync),
            label: const Text('Sincronizar rutas'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail() {
    final line = _lineData!;
    final stateColor = _getStateColor(line.state);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [stateColor.withValues(alpha: 0.1), stateColor.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stateColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_getStateIcon(line.state), color: stateColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.partnerId.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: stateColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStateLabel(line.state),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: stateColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Address card
          if (line.street != null && line.street!.isNotEmpty)
            _InfoCard(
              icon: Icons.place,
              title: 'Dirección',
              children: [
                Text(line.street!, style: const TextStyle(fontSize: 15)),
                if (line.city != null && line.city!.isNotEmpty)
                  Text(line.city!, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
              ],
            ),
          if (line.street != null && line.street!.isNotEmpty)
            const SizedBox(height: 12),

          // Obra
          if (line.obra != null && line.obra!.isNotEmpty)
            _InfoCard(
              icon: Icons.build,
              title: 'Obra',
              children: [Text(line.obra!, style: const TextStyle(fontSize: 15))],
            ),
          if (line.obra != null && line.obra!.isNotEmpty)
            const SizedBox(height: 12),

          // Notes
          if (line.notes != null && line.notes!.isNotEmpty)
            _InfoCard(
              icon: Icons.note,
              title: 'Notas',
              children: [
                Text(
                  line.notes!.replaceAll(RegExp(r'<[^>]*>'), ''),
                  style: const TextStyle(fontSize: 14, color: AppColors.gray700),
                ),
              ],
            ),
          if (line.notes != null && line.notes!.isNotEmpty)
            const SizedBox(height: 12),

          // Products
          if (line.orderLines != null && line.orderLines!.isNotEmpty)
            _InfoCard(
              icon: Icons.inventory,
              title: 'Productos (${line.orderLines!.length})',
              children: line.orderLines!.map((orderLine) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(orderLine.productName, style: const TextStyle(fontSize: 13))),
                    Text(
                      '${orderLine.quantity.toInt()} ${orderLine.uom}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              )).toList(),
            ),
          if (line.orderLines != null && line.orderLines!.isNotEmpty)
            const SizedBox(height: 12),

          // Times
          if (line.startTime != null || line.pickupTime != null || line.endTime != null)
            _InfoCard(
              icon: Icons.access_time,
              title: 'Tiempos',
              children: [
                if (line.startTime != null)
                  _TimeRow(label: 'Inicio', time: _formatTime(line.startTime!), icon: Icons.play_arrow, color: AppColors.statusInProgress),
                if (line.pickupTime != null)
                  _TimeRow(label: 'Recogida', time: _formatTime(line.pickupTime!), icon: Icons.local_shipping, color: AppColors.statusPickedUp),
                if (line.endTime != null)
                  _TimeRow(label: 'Final', time: _formatTime(line.endTime!), icon: Icons.check_circle, color: AppColors.statusCompleted),
              ],
            ),
          if (line.startTime != null || line.pickupTime != null || line.endTime != null)
            const SizedBox(height: 12),

          // Navigate button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _navigate(context, line),
              icon: const Icon(Icons.navigation),
              label: const Text('Abrir en Google Maps', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigate(BuildContext context, RouteLineData line) async {
    final destination = line.street != null && line.street!.isNotEmpty
        ? Uri.encodeComponent(line.street!)
        : '${line.latitude ?? 0.0},${line.longitude ?? 0.0}';
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
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

  IconData _getStateIcon(String state) {
    switch (state) {
      case 'done': return Icons.check_circle;
      case 'picked_up': return Icons.local_shipping;
      case 'in_progress': return Icons.directions_car;
      case 'incomplete': case 'partial': return Icons.warning_amber_rounded;
      case 'cancelled': return Icons.cancel;
      default: return Icons.schedule;
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
    try {
      final parts = dateTime.split(' ');
      if (parts.length == 2) {
        final time = parts[1].split(':');
        return '${time[0]}:${time[1]}';
      }
      return dateTime;
    } catch (_) {
      return dateTime;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeRow({required this.label, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
          Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
