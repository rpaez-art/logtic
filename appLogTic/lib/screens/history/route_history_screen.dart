import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';

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
                  (context, index) => _HistoryDetailCard(item: routes[index]),
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

class _HistoryDetailCard extends StatelessWidget {
  final RouteHistoryItem item;

  const _HistoryDetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final completionRate = item.totalDeliveries > 0
        ? (item.completedDeliveries * 100 / item.totalDeliveries)
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
          ],
        ),
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