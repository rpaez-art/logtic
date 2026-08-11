import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// Tarjeta de estado vacío para el historial del dashboard
class EmptyHistoryCard extends StatelessWidget {
  const EmptyHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: context.containerColor,
      elevation: 0,
      child: const Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.history, color: AppColors.gray400, size: 56),
            SizedBox(height: 16),
            Text('Sin historial aún', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray600)),
            SizedBox(height: 8),
            Text(
              'Completa tus primeras rutas para ver tu historial aquí',
              style: TextStyle(fontSize: 13, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}