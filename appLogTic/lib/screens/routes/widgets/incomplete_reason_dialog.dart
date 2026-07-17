import 'package:flutter/material.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusIncomplete.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.statusIncomplete, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marcar como incompleta',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.partnerName,
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // State type selection
            const Text('Tipo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StateChip(
                    label: 'Incompleta',
                    isSelected: _selectedState == 'incomplete',
                    onTap: () => setState(() => _selectedState = 'incomplete'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StateChip(
                    label: 'Parcial',
                    isSelected: _selectedState == 'partial',
                    onTap: () => setState(() => _selectedState = 'partial'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reason selection
            const Text('Motivo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason.isEmpty ? null : _selectedReason,
              hint: const Text('Seleccione un motivo'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: const Icon(Icons.report_problem_outlined, color: AppColors.statusIncomplete),
                filled: true,
                fillColor: AppColors.gray50,
              ),
              isExpanded: true,
              items: _reasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason['value'],
                  child: Text(reason['label']!, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedReason = value ?? ''),
            ),
            const SizedBox(height: 16),

            // Notes
            const Text('Detalle adicional (opcional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Explique el motivo...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.note_outlined, color: AppColors.gray500),
                ),
                filled: true,
                fillColor: AppColors.gray50,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: AppColors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Estado actualizado'),
                                  ],
                                ),
                                backgroundColor: AppColors.statusIncomplete,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirmar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusIncomplete,
                      disabledBackgroundColor: AppColors.statusIncomplete.withValues(alpha: 0.4),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StateChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.statusIncomplete : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.statusIncomplete : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.corpDarkGray,
            ),
          ),
        ),
      ),
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