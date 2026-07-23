import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/attachment_tile.dart';
import '../routes/widgets/supplier_info_dialog.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final odoo = context.read<OdooProvider>();
      if (auth.currentUser != null) {
        odoo.fetchRoutesHistory(auth.currentUser!.driverId, limit: 50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final odoo = context.watch<OdooProvider>();

    final routes = odoo.routesHistory;
    final totalRoutes = routes.length;
    final totalDeliveries = routes.fold(0, (sum, item) => sum + item.totalDeliveries);
    final totalCompleted = routes.fold(0, (sum, item) => sum + item.completedDeliveries);
    final routesWithDuration = routes.where((item) => item.durationMinutes > 0).toList();
    final avgDuration = routesWithDuration.isNotEmpty
        ? routesWithDuration.fold(0.0, (sum, item) => sum + item.durationMinutes) / routesWithDuration.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Rutas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.corpGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () {
              if (auth.currentUser != null) {
                odoo.fetchRoutesHistory(auth.currentUser!.driverId, limit: 50);
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: AnimatedThemeToggle(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gray100, AppColors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HistorySummarySection(
                totalRoutes: totalRoutes,
                totalDeliveries: totalDeliveries,
                totalCompleted: totalCompleted,
                avgDurationMinutes: avgDuration,
              ),
            ),
            if (odoo.isLoadingHistory)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (routes.isEmpty)
              const SliverToBoxAdapter(
                child: _EmptyHistorySection(),
              )
            else ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'Rutas Completadas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _HistoryRouteCard(item: routes[index]),
                  childCount: routes.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HistorySummarySection extends StatelessWidget {
  final int totalRoutes;
  final int totalDeliveries;
  final int totalCompleted;
  final double avgDurationMinutes;

  const _HistorySummarySection({
    required this.totalRoutes,
    required this.totalDeliveries,
    required this.totalCompleted,
    required this.avgDurationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.corpGreen, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HistoryStat(value: '$totalRoutes', label: 'Rutas', icon: Icons.route_outlined),
              _HistoryStat(value: '$totalDeliveries', label: 'Entregas', icon: Icons.local_shipping_outlined),
              _HistoryStat(value: '$totalCompleted', label: 'Completadas', icon: Icons.check_circle_outlined),
              _HistoryStat(value: _formatDuration(avgDurationMinutes), label: 'Prom. Dur.', icon: Icons.timer_outlined),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(double minutes) {
    if (minutes <= 0) return '--';
    if (minutes < 60) return '${minutes.toInt()}m';
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).toInt();
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

class _HistoryStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _HistoryStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Route-level card matching the style of _ExpandableRouteCard from routes_screen.dart
class _HistoryRouteCard extends StatefulWidget {
  final RouteHistoryItem item;

  const _HistoryRouteCard({required this.item});

  @override
  State<_HistoryRouteCard> createState() => _HistoryRouteCardState();
}

class _HistoryRouteCardState extends State<_HistoryRouteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final odoo = context.watch<OdooProvider>();
    final historyList = odoo.routesHistory;
    final index = historyList.indexWhere((h) => h.id == widget.item.id);
    final item = index >= 0 ? historyList[index] : widget.item;

    final completionRate = item.totalDeliveries > 0
        ? (item.completedDeliveries * 100 / item.totalDeliveries)
        : 0.0;
    final hasLines = item.lines != null && item.lines!.isNotEmpty;
    final isLoading = odoo.isHistoryLineLoading(item.id);
    final canFetch = item.lines == null && item.totalDeliveries > 0;
    final hasDocs = hasLines && item.lines!.any((l) => l.attachments != null && l.attachments!.isNotEmpty);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: hasDocs ? BorderSide(color: AppColors.accent.withValues(alpha: 0.3), width: 1) : BorderSide.none,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (hasLines) {
                setState(() => _isExpanded = !_isExpanded);
              } else if (canFetch && !isLoading) {
                odoo.fetchHistoryRouteLines(item.id);
                setState(() => _isExpanded = true);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: icon + name + duration + completed/total
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.route, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.durationFormatted,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.corpGreen),
                        ),
                        Text(
                          '${item.completedDeliveries}/${item.totalDeliveries}',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 6),
                  // Date row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.date,
                          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        ),
                      ),
                      // Expand icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: completionRate / 100,
                          backgroundColor: AppColors.gray200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionRate >= 100 ? AppColors.statusCompleted : AppColors.secondary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${completionRate.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: completionRate >= 100 ? AppColors.statusCompleted : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  // Bottom row: docs badge / loading / deliveries count
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasDocs)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description, size: 12, color: AppColors.accentDark),
                              SizedBox(width: 4),
                              Text(
                                'Con documentos',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accentDark),
                              ),
                            ],
                          ),
                        )
                      else if (isLoading)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentDark),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Cargando entregas...',
                              style: TextStyle(fontSize: 10, color: AppColors.gray500),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        hasLines
                            ? '${item.lines!.length} entregas'
                            : 'Ver entregas',
                        style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded delivery lines
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Cargando entregas...',
                              style: TextStyle(fontSize: 12, color: AppColors.gray500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : hasLines
                      ? Column(
                          children: item.lines!
                              .map((line) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _HistoryLineCard(line: line),
                                  ))
                              .toList(),
                        )
                      : item.lines != null
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'No hay entregas disponibles',
                                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

/// Delivery line card matching the style of _RouteActivityCard from routes_screen.dart
class _HistoryLineCard extends StatefulWidget {
  final RouteLineData line;

  const _HistoryLineCard({required this.line});

  @override
  State<_HistoryLineCard> createState() => _HistoryLineCardState();
}

class _HistoryLineCardState extends State<_HistoryLineCard> {
  bool _showProducts = false;
  bool _isLoadingAttachments = false;
  List<AttachmentData> _attachments = [];

  @override
  void initState() {
    super.initState();
    _attachments = widget.line.attachments ?? [];
    if (_attachments.isEmpty) {
      _fetchAttachments();
    }
  }

  Future<void> _fetchAttachments() async {
    setState(() => _isLoadingAttachments = true);
    try {
      final odoo = Provider.of<OdooProvider>(context, listen: false);
      final attachments = await odoo.getLineAttachments(widget.line.id);
      if (mounted) {
        setState(() {
          _attachments = attachments;
          _isLoadingAttachments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAttachments = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final stateColor = _getStateColor(line.state);
    final hasAttachments = _attachments.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner & state badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => SupplierInfoDialog.show(context, line),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: stateColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                line.partnerId.name.isNotEmpty ? line.partnerId.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: stateColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        line.partnerId.name.isNotEmpty
                                            ? line.partnerId.name
                                            : 'Contacto sin nombre',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          height: 1.25,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                                if (line.obra != null && line.obra!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '📍 ${line.obra}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                                      softWrap: true,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStateLabel(line.state),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: stateColor,
                    ),
                  ),
                ),
              ],
            ),
            // Address
            if (line.street != null && line.street!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.place, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.street!, style: const TextStyle(fontSize: 13)),
                    if (line.city != null && line.city!.isNotEmpty)
                      Text(line.city!, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                  ],
                )),
              ]),
            ],
            // Notes
            if (line.notes != null && line.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: context.containerColor, borderRadius: BorderRadius.circular(10)),
                child: Text(_parseHtml(line.notes!), style: const TextStyle(fontSize: 13)),
              ),
            ],
            // Incomplete reason
            if (line.incompleteReason != null && line.incompleteReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.statusIncomplete.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_outlined, size: 16, color: AppColors.statusIncomplete),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Motivo: ${line.incompleteNotes ?? line.incompleteReason!}',
                        style: const TextStyle(fontSize: 12, color: AppColors.statusIncomplete),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Time chips
            if (line.startTime != null || line.pickupTime != null || line.endTime != null) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: [
                if (line.startTime != null) _TimeChip(icon: Icons.play_arrow, time: _formatTime(line.startTime!), color: AppColors.statusInProgress),
                if (line.pickupTime != null) _TimeChip(icon: Icons.local_shipping, time: _formatTime(line.pickupTime!), color: AppColors.statusPickedUp),
                if (line.endTime != null) _TimeChip(icon: Icons.check_circle, time: _formatTime(line.endTime!), color: AppColors.statusCompleted),
              ]),
            ],
            // Products (order lines)
            if (line.orderLines != null && line.orderLines!.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => setState(() => _showProducts = !_showProducts),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      const Icon(Icons.inventory, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('${line.orderLines!.length} productos', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      if (line.orderName != null) Text(' • ${line.orderName}', style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                    ]),
                    Icon(_showProducts ? Icons.expand_less : Icons.expand_more, color: AppColors.primary, size: 20),
                  ]),
                ),
              ),
              if (_showProducts)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: line.orderLines!.map((orderLine) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(orderLine.productName, style: const TextStyle(fontSize: 12))),
                        Text('${orderLine.quantity.toInt()} ${orderLine.uom}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ]),
                    )).toList(),
                  ),
                ),
            ],
            // Documents (attachments)
            if (_isLoadingAttachments) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ] else if (hasAttachments) ...[
              const SizedBox(height: 10),
              AttachmentsGrouped(attachments: _attachments),
            ],
            // Navigate button (like routes_screen _RouteActivityCard)
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigate(line),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navegar', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _navigate(RouteLineData line) async {
    final destination = line.street != null && line.street!.isNotEmpty
        ? Uri.encodeComponent(line.street!)
        : '${line.latitude ?? 0.0},${line.longitude ?? 0.0}';
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
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

  String _parseHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&', '&')
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .replaceAll('"', '"')
        .trim();
  }
}

/// Same time chip widget used in routes_screen _RouteActivityCard
class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String time;
  final Color color;

  const _TimeChip({required this.icon, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(time, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _EmptyHistorySection extends StatelessWidget {
  const _EmptyHistorySection();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      color: AppColors.gray50,
      child: const Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: AppColors.gray400),
            SizedBox(height: 16),
            Text(
              'Sin historial de rutas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray600),
            ),
            SizedBox(height: 8),
            Text(
              'Aquí aparecerán las rutas que hayas completado',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}