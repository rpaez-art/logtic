import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/odoo_models.dart';

/// Tarjeta de progreso del día con indicador circular
class TodayProgressCard extends StatelessWidget {
  final DriverStatsData? stats;
  final VoidCallback onViewRoutes;
  const TodayProgressCard({super.key, this.stats, required this.onViewRoutes});

  @override
  Widget build(BuildContext context) {
    final today = stats?.today;
    final completed = today?.completed ?? 0;
    final total = today?.total ?? 0;
    final progress = total > 0 ? completed / total : 0.0;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.today, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text('Progreso de Hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(
                  onPressed: onViewRoutes,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ver rutas', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 10,
                          color: AppColors.gray200,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 10,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: (progress * 100).toInt()),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return Text(
                                '$value%',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                              );
                            },
                          ),
                          Text(
                            '$completed de $total',
                            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TodayStatItem(color: AppColors.statusCompleted, label: 'Completadas', value: completed),
                    const SizedBox(height: 10),
                    TodayStatItem(color: AppColors.statusInProgress, label: 'En curso', value: today?.inProgress ?? 0),
                    const SizedBox(height: 10),
                    TodayStatItem(color: AppColors.statusPending, label: 'Pendientes', value: today?.pending ?? 0),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TodayStatItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const TodayStatItem({super.key, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$value $label',
          style: TextStyle(fontSize: 14, color: context.onSurfaceColor),
        ),
      ],
    );
  }
}