import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/odoo_models.dart';
import '../../../providers/odoo_provider.dart';
import '../../../widgets/attachment_tile.dart';
import '../../routes/widgets/supplier_info_dialog.dart';

/// Resumen general de estadísticas de historial
class HistorySummarySection extends StatelessWidget {
  final int totalRoutes;
  final int totalDeliveries;
  final int totalCompleted;
  final String avgDuration;

  const HistorySummarySection({
    super.key,
    required this.totalRoutes,
    required this.totalDeliveries,
    required this.totalCompleted,
    required this.avgDuration,
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
            'Resumen General (Todo el tiempo)',
            style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HistoryStat(value: '$totalRoutes', label: 'Rutas', icon: Icons.route_outlined),
              HistoryStat(value: '$totalDeliveries', label: 'Entregas', icon: Icons.local_shipping_outlined),
              HistoryStat(value: '$totalCompleted', label: 'Completadas', icon: Icons.check_circle_outlined),
              HistoryStat(value: avgDuration.isEmpty ? '--' : avgDuration, label: 'Prom. Dur.', icon: Icons.timer_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const HistoryStat({super.key, required this.value, required this.label, required this.icon});

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

/// Tarjeta expandible de ruta completada en historial
class HistoryRouteCard extends StatefulWidget {
  final RouteHistoryItem item;

  const HistoryRouteCard({super.key, required this.item});

  @override
  State<HistoryRouteCard> createState() => _HistoryRouteCardState();
}

class _HistoryRouteCardState extends State<HistoryRouteCard> {
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
                                    child: HistoryLineCard(line: line),
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

/// Tarjeta de línea de entrega en historial
class HistoryLineCard extends StatefulWidget {
  final RouteLineData line;

  const HistoryLineCard({super.key, required this.line});

  @override
  State<HistoryLineCard> createState() => _HistoryLineCardState();
}

class _HistoryLineCardState extends State<HistoryLineCard> {
  bool _showProducts = false;
  List<AttachmentData> _attachments = [];

  @override
  void initState() {
    super.initState();
    _attachments = widget.line.attachments ?? [];
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: stateColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.partnerId.name.isNotEmpty
                                      ? line.partnerId.name
                                      : 'Contacto sin nombre',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.25),
                                  softWrap: true,
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: stateColor),
                  ),
                ),
              ],
            ),
            if (line.notes != null && line.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: context.containerColor, borderRadius: BorderRadius.circular(10)),
                child: Text(_parseHtml(line.notes!), style: const TextStyle(fontSize: 13)),
              ),
            ],
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
            if (hasAttachments) ...[
              const SizedBox(height: 10),
              AttachmentsGrouped(attachments: _attachments),
            ],
          ],
        ),
      ),
    );
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

/// Estado vacío del historial
class EmptyHistorySection extends StatelessWidget {
  const EmptyHistorySection({super.key});

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