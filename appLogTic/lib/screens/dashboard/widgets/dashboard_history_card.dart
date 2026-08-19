import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/odoo_models.dart';
import '../../../providers/odoo_provider.dart';
import '../../../services/api/retrofit_client.dart';
import '../../../widgets/attachment_tile.dart';
import '../../routes/widgets/supplier_info_dialog.dart';

/// Tarjeta expandible de historial en el dashboard
class DashboardHistoryCard extends StatefulWidget {
  final RouteHistoryItem item;

  const DashboardHistoryCard({super.key, required this.item});

  @override
  State<DashboardHistoryCard> createState() => _DashboardHistoryCardState();
}

class _DashboardHistoryCardState extends State<DashboardHistoryCard> {
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
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: completionRate >= 100
                              ? AppColors.statusCompleted.withValues(alpha: 0.1)
                              : AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          completionRate >= 100 ? Icons.check_circle : Icons.remove_circle_outlined,
                          color: completionRate >= 100 ? AppColors.statusCompleted : AppColors.secondary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: AppColors.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  item.date,
                                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                                ),
                              ],
                            ),
                          ],
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
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      Row(
                        children: [
                          Text(
                            hasLines
                                ? '${item.lines!.length} entregas'
                                : 'Ver entregas',
                            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                          ),
                          const SizedBox(width: 4),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: context.containerColor.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
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
                              .map((line) => DashboardLineCard(line: line))
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

/// Línea de entrega dentro del historial del dashboard
class DashboardLineCard extends StatefulWidget {
  final RouteLineData line;

  const DashboardLineCard({super.key, required this.line});

  @override
  State<DashboardLineCard> createState() => _DashboardLineCardState();
}

class _DashboardLineCardState extends State<DashboardLineCard> {
  bool _showProducts = false;
  String? _originAddress;
  String? _destinationAddress;

  @override
  void initState() {
    super.initState();
    _fetchMapInfo();
  }

  Future<void> _fetchMapInfo() async {
    try {
      final info = await RetrofitClient().getMapInfo(widget.line.id);
      if (info['success'] == true && info['data'] != null) {
        final allAddresses = info['data']['all_addresses'];
        if (allAddresses != null && mounted) {
          setState(() {
            _originAddress = allAddresses['origin_address'];
            _destinationAddress = allAddresses['destination_address'];
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final stateColor = _getStateColor(line.state);
    final hasAttachments = line.attachments != null && line.attachments!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => SupplierInfoDialog.show(context, line),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: stateColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  line.partnerId.name.isNotEmpty
                                      ? line.partnerId.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: stateColor),
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
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                  if (line.obra != null && line.obra!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.place_outlined, size: 12, color: AppColors.gray600),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              line.obra!,
                                              style: const TextStyle(fontSize: 11, color: AppColors.gray600),
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stateColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStateLabel(line.state),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: stateColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.containerColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.trip_origin, size: 14, color: AppColors.statusInProgress),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_originAddress != null && _originAddress!.isNotEmpty)
                                Text(
                                  _originAddress!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                                )
                              else ...[
                                Text(
                                  'Desde: Mi ubicación',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.subtextColor),
                                ),
                                const Text(
                                  'Tu posición actual (GPS)',
                                  style: TextStyle(fontSize: 11, color: AppColors.gray500),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 7, top: 4, bottom: 4),
                      child: Icon(Icons.arrow_downward, size: 12, color: AppColors.gray400),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.statusCompleted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _destinationAddress != null && _destinationAddress!.isNotEmpty
                                    ? 'Hasta: $_destinationAddress'
                                    : 'Hasta: ${line.partnerId.name.isNotEmpty ? line.partnerId.name : 'Destino'}',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.subtextColor),
                              ),
                              if (line.street != null && line.street!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(line.street!, style: const TextStyle(fontSize: 12)),
                              ],
                              if (line.city != null && line.city!.isNotEmpty)
                                Text(line.city!, style: const TextStyle(fontSize: 10, color: AppColors.gray500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (line.notes != null && line.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: context.containerColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(_parseHtml(line.notes!), style: TextStyle(fontSize: 12, color: context.onSurfaceColor)),
                ),
              ],
              if (line.incompleteReason != null && line.incompleteReason!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.statusIncomplete.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.report_problem_outlined, size: 14, color: AppColors.statusIncomplete),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Motivo: ${line.incompleteNotes ?? line.incompleteReason!}',
                          style: const TextStyle(fontSize: 11, color: AppColors.statusIncomplete),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (line.startTime != null || line.pickupTime != null || line.endTime != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (line.startTime != null)
                      DTimeChip(icon: Icons.play_arrow, time: _formatTime(line.startTime!), color: AppColors.statusInProgress),
                    if (line.pickupTime != null)
                      DTimeChip(icon: Icons.local_shipping, time: _formatTime(line.pickupTime!), color: AppColors.statusPickedUp),
                    if (line.endTime != null)
                      DTimeChip(icon: Icons.check_circle, time: _formatTime(line.endTime!), color: AppColors.statusCompleted),
                  ],
                ),
              ],
              if (line.orderLines != null && line.orderLines!.isNotEmpty) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => setState(() => _showProducts = !_showProducts),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${line.orderLines!.length} productos',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                            ),
                            if (line.orderName != null)
                              Text(' • ${line.orderName}', style: const TextStyle(fontSize: 10, color: AppColors.gray500)),
                          ],
                        ),
                        Icon(_showProducts ? Icons.expand_less : Icons.expand_more, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
                if (_showProducts)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Column(
                      children: line.orderLines!
                          .map((orderLine) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(orderLine.productName, style: const TextStyle(fontSize: 11))),
                                    Text(
                                      '${orderLine.quantity.toInt()} ${orderLine.uom}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
              if (hasAttachments) ...[
                const SizedBox(height: 10),
                AttachmentsGrouped(attachments: line.attachments!),
              ],
            ],
          ),
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

class DTimeChip extends StatelessWidget {
  final IconData icon;
  final String time;
  final Color color;

  const DTimeChip({super.key, required this.icon, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
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