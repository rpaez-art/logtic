import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/odoo_models.dart';

/// Tarjeta de rendimiento del conductor
class PerformanceCard extends StatelessWidget {
  final DriverStatsData? stats;
  const PerformanceCard({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    final performance = stats?.performance;
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.greenTextColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.speed, color: context.greenTextColor, size: 22),
                ),
                const SizedBox(width: 10),
                const Text('Rendimiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PerformanceMetric(
                  icon: Icons.timer_outlined,
                  value: performance?.avgDeliveryTimeFormatted.isNotEmpty == true ? performance!.avgDeliveryTimeFormatted : '--',
                  label: 'Prom. Entrega',
                ),
                Container(height: 50, width: 1, color: context.borderColor),
                PerformanceMetric(
                  icon: Icons.route_outlined,
                  value: performance?.avgRouteTimeFormatted.isNotEmpty == true ? performance!.avgRouteTimeFormatted : '--',
                  label: 'Prom. Ruta',
                ),
                Container(height: 50, width: 1, color: context.borderColor),
                PerformanceMetric(
                  icon: Icons.trending_up,
                  value: '${(stats?.summary.completionRate ?? 0).toInt()}%',
                  label: 'Eficiencia',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const PerformanceMetric({super.key, required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: context.greenTextColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.primaryTextColor)),
        Text(label, style: TextStyle(fontSize: 11, color: context.subtextColor)),
      ],
    );
  }
}