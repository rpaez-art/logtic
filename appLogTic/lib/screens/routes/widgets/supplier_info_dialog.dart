import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/odoo_models.dart';
import '../../../widgets/attachment_tile.dart';
import '../../../providers/odoo_provider.dart';

class SupplierInfoDialog extends StatefulWidget {
  final RouteLineData line;

  const SupplierInfoDialog({
    super.key,
    required this.line,
  });

  static void show(BuildContext context, RouteLineData line) {
    showDialog(
      context: context,
      builder: (context) => SupplierInfoDialog(line: line),
    );
  }

  @override
  State<SupplierInfoDialog> createState() => _SupplierInfoDialogState();
}

class _SupplierInfoDialogState extends State<SupplierInfoDialog> {
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
    final size = MediaQuery.of(context).size;
    final containerColor = context.containerColor;
    final borderColor = context.borderColor;
    final textColor = context.onSurfaceColor;
    final subtextColor = context.subtextColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: context.surfaceColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient and Close Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.corpGreen,
                    AppColors.corpGreen.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle Avatar with initials
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        line.partnerId.name.isNotEmpty
                            ? line.partnerId.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name and Order Type badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getOrderTypeLabel(line.orderType),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            if (line.partnerId.id > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                'ID: #${line.partnerId.id}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Supplier Name - Complete without truncation
                        SelectableText(
                          line.partnerId.name.isNotEmpty
                              ? line.partnerId.name
                              : 'Contacto no especificado',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.white),
                    tooltip: 'Cerrar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content Body (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Priority Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: stateColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(_getStateIcon(line.state), color: stateColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _getStateLabel(line.state),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: stateColor,
                                ),
                              ),
                            ],
                          ),
                          if (line.priority != null && line.priority!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(line.priority).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Prioridad: ${_getPriorityLabel(line.priority!)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getPriorityColor(line.priority),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Location & Obra
                    _SectionTitle(icon: Icons.location_on_rounded, title: 'Ubicación y Dirección'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (line.obra != null && line.obra!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.business_rounded, size: 16, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    line.obra!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 16, color: borderColor),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.place_outlined, size: 16, color: subtextColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(
                                      (line.street != null && line.street!.isNotEmpty)
                                          ? line.street!
                                          : 'Sin dirección registrada',
                                      style: TextStyle(fontSize: 13, color: textColor),
                                    ),
                                    if (line.city != null && line.city!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      SelectableText(
                                        line.city!,
                                        style: TextStyle(fontSize: 12, color: subtextColor),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Order Reference & Products
                    if (line.orderName != null || (line.orderLines != null && line.orderLines!.isNotEmpty)) ...[
                      _SectionTitle(icon: Icons.inventory_2_rounded, title: 'Orden de Pedido y Productos'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (line.orderName != null && line.orderName!.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text('Código de Orden: ', style: TextStyle(fontSize: 12, color: subtextColor)),
                                  SelectableText(
                                    line.orderName!,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                              if (line.orderLines != null && line.orderLines!.isNotEmpty)
                                Divider(height: 16, color: borderColor),
                            ],
                            if (line.orderLines != null && line.orderLines!.isNotEmpty)
                              ...line.orderLines!.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            item.productName,
                                            style: TextStyle(fontSize: 13, color: textColor),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.uom}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Section 3: Notes & Instructions
                    if (line.notes != null && line.notes!.isNotEmpty) ...[
                      _SectionTitle(icon: Icons.notes_rounded, title: 'Notas e Instrucciones'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: SelectableText(
                          line.notes!.replaceAll(RegExp(r'<[^>]*>'), ''),
                          style: TextStyle(fontSize: 13, color: textColor, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Section 4: Attachments / Documents
                    _SectionTitle(
                      icon: Icons.attachment_rounded,
                      title: _attachments.isNotEmpty
                          ? 'Documentos y Archivos Adjuntos (${_attachments.length})'
                          : 'Documentos y Archivos Adjuntos',
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingAttachments)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_attachments.isNotEmpty)
                      AttachmentsGrouped(attachments: _attachments)
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.folder_off_outlined, size: 20, color: subtextColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Sin documentos ni archivos adjuntos asociados a esta entrega.',
                                style: TextStyle(fontSize: 12, color: subtextColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Section 5: Timeline / Registered Times
                    if (line.startTime != null || line.pickupTime != null || line.endTime != null) ...[
                      _SectionTitle(icon: Icons.schedule_rounded, title: 'Registro de Tiempos'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            if (line.startTime != null)
                              _TimeRow(label: 'Hora de Inicio', time: line.startTime!, icon: Icons.play_arrow_rounded, color: AppColors.statusInProgress),
                            if (line.pickupTime != null)
                              _TimeRow(label: 'Hora de Recogida', time: line.pickupTime!, icon: Icons.local_shipping_rounded, color: AppColors.statusPickedUp),
                            if (line.endTime != null)
                              _TimeRow(label: 'Hora de Finalización', time: line.endTime!, icon: Icons.check_circle_rounded, color: AppColors.statusCompletedLight),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text('Cerrar', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (line.street != null && line.street!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _openMaps(context, line),
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: const Text('Navegar en Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(BuildContext context, RouteLineData line) async {
    final destination = line.street != null && line.street!.isNotEmpty
        ? Uri.encodeComponent(line.street!)
        : '${line.latitude ?? 0.0},${line.longitude ?? 0.0}';
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  String _getOrderTypeLabel(String? orderType) {
    if (orderType == 'purchase') return '🛒 COMPRA / PROVEEDOR';
    if (orderType == 'sale') return '📦 VENTA / CLIENTE';
    return '🚚 DESPACHO';
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'done': return AppColors.statusCompletedLight;
      case 'picked_up': return AppColors.statusPickedUp;
      case 'in_progress': return AppColors.statusInProgress;
      case 'incomplete': case 'partial': return AppColors.statusIncomplete;
      case 'cancelled': return AppColors.statusCancelled;
      default: return AppColors.statusPending;
    }
  }

  IconData _getStateIcon(String state) {
    switch (state) {
      case 'done': return Icons.check_circle_rounded;
      case 'picked_up': return Icons.local_shipping_rounded;
      case 'in_progress': return Icons.directions_car_rounded;
      case 'incomplete': case 'partial': return Icons.warning_amber_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default: return Icons.schedule_rounded;
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

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      default: return AppColors.info;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return 'Alta';
      case 'medium': return 'Media';
      default: return 'Baja';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: context.onSurfaceColor,
          ),
        ),
      ],
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
          Text('$label: ', style: TextStyle(fontSize: 12, color: context.subtextColor)),
          const Spacer(),
          Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
