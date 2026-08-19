import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../utils/pair.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import '../../widgets/attachment_tile.dart';
import '../../widgets/theme_toggle_button.dart';
import './widgets/supplier_info_dialog.dart';
import './widgets/photo_capture_dialog.dart';
import './widgets/incomplete_reason_dialog.dart';

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

    // Search in today's synced routes first
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

    // Then search in historical routes lines
    for (final historyItem in odoo.routesHistory) {
      if (historyItem.lines != null) {
        for (final line in historyItem.lines!) {
          if (line.id == widget.lineId) {
            setState(() {
              _lineData = line;
              _isLoading = false;
            });
            return;
          }
        }
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final odoo = context.watch<OdooProvider>();
    RouteLineData? currentLine;

    // Search in today's synced routes first
    for (final route in odoo.odooRoutes) {
      for (final line in route.routeLines) {
        if (line.id == widget.lineId) {
          currentLine = line;
          break;
        }
      }
      if (currentLine != null) break;
    }

    // Then search in historical routes lines
    if (currentLine == null) {
      for (final historyItem in odoo.routesHistory) {
        if (historyItem.lines != null) {
          for (final line in historyItem.lines!) {
            if (line.id == widget.lineId) {
              currentLine = line;
              break;
            }
          }
        }
        if (currentLine != null) break;
      }
    }

    final displayLine = currentLine ?? _lineData;

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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: AnimatedThemeToggle(),
          ),
        ],
      ),
      body: _isLoading && displayLine == null
          ? const Center(child: CircularProgressIndicator())
          : displayLine == null
              ? _buildNotFound()
              : _buildDetailWithLine(displayLine),
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

  Widget _buildDetailWithLine(RouteLineData line) {
    final stateColor = _getStateColor(line.state);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status & Supplier card
          InkWell(
            onTap: () => SupplierInfoDialog.show(context, line),
            borderRadius: BorderRadius.circular(20),
            child: Container(
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                line.partnerId.name.isNotEmpty ? line.partnerId.name : 'Contacto sin nombre',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.25),
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
          ),
          const SizedBox(height: 16),

          // ── Desde / Hasta (Origen / Destino) ──
          _InfoCard(
            icon: Icons.alt_route,
            title: 'Ruta',
            children: [
              // Desde: dirección de origen
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trip_origin, size: 16, color: AppColors.statusInProgress),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Desde: ${line.originAddress != null && line.originAddress!.isNotEmpty ? line.originAddress! : 'Mi ubicación'}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.subtextColor),
                        ),
                        if (line.originAddress == null || line.originAddress!.isEmpty)
                          const SizedBox(height: 2),
                        if (line.originAddress == null || line.originAddress!.isEmpty)
                          Text(
                            'Tu posición actual (GPS)',
                            style: TextStyle(fontSize: 13, color: context.onSurfaceColor),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 6, bottom: 6),
                child: Icon(Icons.arrow_downward, size: 14, color: AppColors.gray400),
              ),
              // Hasta: dirección de destino
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.statusCompleted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.destinationAddress != null && line.destinationAddress!.isNotEmpty
                              ? 'Hasta: ${line.destinationAddress}'
                              : 'Hasta: ${line.partnerId.name.isNotEmpty ? line.partnerId.name : 'Destino'}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.subtextColor),
                        ),
                        if (line.street != null && line.street!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(line.street!, style: const TextStyle(fontSize: 15)),
                        ],
                        if (line.city != null && line.city!.isNotEmpty)
                          Text(line.city!, style: TextStyle(fontSize: 13, color: context.subtextColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Obra
          if (line.obra != null && line.obra!.isNotEmpty)
            _InfoCard(
              icon: Icons.build,
              title: 'Obra',
              children: [Text(line.obra!, style: TextStyle(fontSize: 15, color: context.onSurfaceColor))],
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
                  style: TextStyle(fontSize: 14, color: context.onSurfaceColor),
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

          // Attachments/Documents
          if (line.attachments != null && line.attachments!.isNotEmpty)
            _InfoCard(
              icon: Icons.description,
              title: 'Documentos (${line.attachments!.length})',
              children: [
                AttachmentsGrouped(attachments: line.attachments!),
              ],
            ),
          if (line.attachments != null && line.attachments!.isNotEmpty)
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

          // Actions
          _buildActionSection(context, line),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, RouteLineData line) {
    final odoo = context.read<OdooProvider>();

    return Column(
      children: [
        // Navigate button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _navigate(context, line),
            icon: const Icon(Icons.navigation, size: 20),
            label: const Text('Abrir en Google Maps', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // State Action Buttons
        if (line.state == 'pending') ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _startLine(odoo, line),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Iniciar Entrega', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusInProgress,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ] else if (line.state == 'in_progress') ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickUpLine(odoo, line),
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text('Recoger', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusPickedUp,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showPhotoDialog(odoo, line),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Finalizar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusCompleted,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showIncompleteDialog(odoo, line),
              icon: const Icon(Icons.warning_amber_rounded, size: 18),
              label: const Text('Marcar Incompleta / Parcial'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.statusIncomplete,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else if (line.state == 'picked_up') ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => _showPhotoDialog(odoo, line),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Finalizar Entrega', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusCompleted,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _showIncompleteDialog(odoo, line),
                  icon: const Icon(Icons.warning_amber_rounded, size: 18),
                  label: const Text('Incompleta', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusIncomplete,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ] else if (line.state == 'done') ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.statusCompleted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 20),
                SizedBox(width: 8),
                Text(
                  'Entrega completada',
                  style: TextStyle(
                    color: AppColors.statusCompleted,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<Pair<double?, double?>> _getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return Pair(null, null);
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        return Pair(null, null);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 4)),
      );
      return Pair(position.latitude, position.longitude);
    } catch (_) {
      return Pair(null, null);
    }
  }

  Future<void> _startLine(OdooProvider odoo, RouteLineData line) async {
    final loc = await _getLocation();
    odoo.notifyLineStarted(line.id, loc.first, loc.second);
  }

  Future<void> _pickUpLine(OdooProvider odoo, RouteLineData line) async {
    final loc = await _getLocation();
    odoo.notifyLinePickedUp(line.id, loc.first, loc.second);
  }

  Future<void> _showPhotoDialog(OdooProvider odoo, RouteLineData line) async {
    final loc = await _getLocation();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => PhotoCaptureDialog(
        partnerName: line.partnerId.name,
        odoo: odoo,
        lineId: line.id,
        currentLocation: loc,
      ),
    );
  }

  Future<void> _showIncompleteDialog(OdooProvider odoo, RouteLineData line) async {
    final loc = await _getLocation();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => IncompleteReasonDialog(
        partnerName: line.partnerId.name,
        odoo: odoo,
        lineId: line.id,
        currentLocation: loc,
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
      case 'done': return 'Entregado';
      case 'picked_up': return 'Recogido';
      case 'in_progress': return 'En camino';
      case 'incomplete': return 'Incompleta';
      case 'partial': return 'Parcial';
      case 'cancelled': return 'Cancelado';
      default: return 'Pendiente';
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
          Text('$label: ', style: TextStyle(fontSize: 13, color: context.subtextColor)),
          Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
