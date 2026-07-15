import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../utils/pair.dart';
import '../../../providers/odoo_provider.dart';

class IncompleteReasonDialog extends StatefulWidget {
  final String partnerName;
  final OdooProvider odoo;
  final int lineId;
  final Pair<double?, double?> currentLocation;

  const IncompleteReasonDialog({
    super.key,
    required this.partnerName,
    required this.odoo,
    required this.lineId,
    required this.currentLocation,
  });

  @override
  State<IncompleteReasonDialog> createState() => _IncompleteReasonDialogState();
}

class _IncompleteReasonDialogState extends State<IncompleteReasonDialog> {
  String _selectedState = 'incomplete';
  String _selectedReason = '';
  final _notesController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {'value': 'no_material', 'label': 'Proveedor sin material'},
    {'value': 'not_needed', 'label': 'Ya no se necesita'},
    {'value': 'order_error', 'label': 'Error en la orden'},
    {'value': 'wrong_address', 'label': 'Dirección incorrecta'},
    {'value': 'closed', 'label': 'Establecimiento cerrado'},
    {'value': 'no_access', 'label': 'Sin acceso al lugar'},
    {'value': 'damaged', 'label': 'Material dañado'},
    {'value': 'other', 'label': 'Otro motivo'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Marcar como incompleta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            widget.partnerName,
            style: const TextStyle(fontSize: 13, color: AppColors.gray600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    selected: _selectedState == 'incomplete',
                    onSelected: (_) => setState(() => _selectedState = 'incomplete'),
                    label: const Text('Incompleta', style: TextStyle(fontSize: 12)),
                    selectedColor: AppColors.statusIncomplete,
                    labelStyle: TextStyle(
                      color: _selectedState == 'incomplete' ? AppColors.white : AppColors.corpDarkGray,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    selected: _selectedState == 'partial',
                    onSelected: (_) => setState(() => _selectedState = 'partial'),
                    label: const Text('Parcial', style: TextStyle(fontSize: 12)),
                    selectedColor: AppColors.statusIncomplete,
                    labelStyle: TextStyle(
                      color: _selectedState == 'partial' ? AppColors.white : AppColors.corpDarkGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Motivo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReason.isEmpty ? null : _selectedReason,
              hint: const Text('Seleccione un motivo'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isExpanded: true,
              items: _reasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason['value'],
                  child: Text(reason['label']!),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedReason = value ?? ''),
            ),
            const SizedBox(height: 16),
            const Text('Detalle adicional (opcional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Explique el motivo...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedReason.isEmpty
              ? null
              : () {
                  widget.odoo.notifyLineIncomplete(
                    widget.lineId,
                    _selectedState,
                    _selectedReason,
                    _notesController.text,
                    latitude: widget.currentLocation.first,
                    longitude: widget.currentLocation.second,
                  );
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusIncomplete),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

String getReasonLabel(String reason) {
  switch (reason) {
    case 'no_material': return 'Proveedor sin material';
    case 'not_needed': return 'Ya no se necesita';
    case 'order_error': return 'Error en la orden';
    case 'wrong_address': return 'Dirección incorrecta';
    case 'closed': return 'Establecimiento cerrado';
    case 'no_access': return 'Sin acceso al lugar';
    case 'damaged': return 'Material dañado';
    case 'other': return 'Otro motivo';
    default: return reason;
  }
}