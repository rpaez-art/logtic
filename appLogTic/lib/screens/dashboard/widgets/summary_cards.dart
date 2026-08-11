import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/odoo_models.dart';

/// Tarjetas de resumen de estadísticas del conductor
class SummaryCards extends StatelessWidget {
  final DriverStatsData? stats;
  const SummaryCards({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    final summary = stats?.summary;
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          MiniStatCard(
            icon: Icons.list_alt_rounded,
            value: '${summary?.totalDeliveries ?? 0}',
            label: 'Total Entregas',
            gradient: const [AppColors.accent, AppColors.accentDark],
          ),
          const SizedBox(width: 12),
          MiniStatCard(
            icon: Icons.check_circle_rounded,
            value: '${summary?.completedDeliveries ?? 0}',
            label: 'Completadas',
            gradient: const [AppColors.statusCompleted, Color(0xFF0F2A22)],
          ),
          const SizedBox(width: 12),
          MiniStatCard(
            icon: Icons.local_shipping_rounded,
            value: '${summary?.inProgressDeliveries ?? 0}',
            label: 'En Curso',
            gradient: const [AppColors.primaryLight, AppColors.secondaryDark],
          ),
          const SizedBox(width: 12),
          MiniStatCard(
            icon: Icons.schedule_rounded,
            value: '${summary?.pendingDeliveries ?? 0}',
            label: 'Pendientes',
            gradient: const [AppColors.gray600, AppColors.gray800],
          ),
        ],
      ),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.white, size: 18),
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.8), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}