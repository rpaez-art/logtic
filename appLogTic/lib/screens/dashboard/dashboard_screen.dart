import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import '../routes/routes_screen.dart';
import '../history/route_history_screen.dart';
import '../admin/driver_monitor_screen.dart';
import '../admin/user_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final odoo = context.read<OdooProvider>();
      if (auth.currentUser != null) {
        odoo.syncRoutesFromOdoo(auth.currentUser!.driverId);
        odoo.fetchDriverStats(auth.currentUser!.driverId, period: _selectedPeriod);
        odoo.fetchRoutesHistory(auth.currentUser!.driverId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final odoo = context.watch<OdooProvider>();
    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.username == 'admin';

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _DashboardHeader(
                  userName: currentUser?.fullName.isNotEmpty == true
                      ? currentUser!.fullName
                      : currentUser?.username ?? 'Conductor',
                  driverImage: odoo.driverStats?.driver.image,
                  onLogout: () {
                    auth.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const _LoginRedirect()),
                      (route) => false,
                    );
                  },
                ),
              ),

              // Period Selector
              SliverToBoxAdapter(
                child: _PeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  onPeriodSelected: (period) {
                    setState(() => _selectedPeriod = period);
                    if (auth.currentUser != null) {
                      odoo.fetchDriverStats(auth.currentUser!.driverId, period: period);
                    }
                  },
                ),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: odoo.isLoadingStats
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _SummaryCards(
                        stats: odoo.driverStats,
                      ),
              ),

              // Performance Card
              SliverToBoxAdapter(
                child: _PerformanceCard(stats: odoo.driverStats),
              ),

              // Today Progress
              SliverToBoxAdapter(
                child: _TodayProgressCard(
                  stats: odoo.driverStats,
                  onViewRoutes: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoutesScreen()),
                    );
                  },
                ),
              ),

              // History Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📜 Historial Reciente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RouteHistoryScreen()),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ver todo', style: TextStyle(color: AppColors.corpGreen)),
                            Icon(Icons.chevron_right, color: AppColors.corpGreen, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // History Items
              if (odoo.isLoadingHistory)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (odoo.routesHistory.isEmpty)
                const SliverToBoxAdapter(
                  child: _EmptyHistoryCard(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = odoo.routesHistory[index];
                      return _HistoryItemCard(item: item);
                    },
                    childCount: odoo.routesHistory.length > 5
                        ? 5
                        : odoo.routesHistory.length,
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // FAB
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoutesScreen()),
                );
              },
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.local_shipping, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget to redirect to login
class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const _EmptyWidget()),
        (route) => false,
      );
    });
    return const SizedBox.shrink();
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// Header Widget
class _DashboardHeader extends StatelessWidget {
  final String userName;
  final String? driverImage;
  final VoidCallback onLogout;

  const _DashboardHeader({
    required this.userName,
    this.driverImage,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.corpGreen,
                  AppColors.corpDarkGray,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: MediaQuery.of(context).padding.top + 8,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola!',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout, color: AppColors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile photo
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                          ),
                          child: _buildProfileImage(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Conductor Activo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.statusCompleted,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'En servicio',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.statusCompleted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.gray400,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (driverImage != null) {
      try {
        final bytes = base64Decode(driverImage!);
        return ClipOval(
          child: Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultIcon(),
          ),
        );
      } catch (_) {
        return _defaultIcon();
      }
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return const Icon(Icons.person, color: AppColors.white, size: 40);
  }
}

// Period Selector
class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final periods = [
      ('today', 'Hoy'),
      ('week', 'Semana'),
      ('month', 'Mes'),
      ('all', 'Todo'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onPeriodSelected(period.$1),
              label: Text(
                period.$2,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.white : AppColors.corpDarkGray,
                ),
              ),
              selectedColor: AppColors.corpGreen,
              checkmarkColor: AppColors.white,
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: isSelected ? AppColors.corpGreen : AppColors.corpDarkGray.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Summary Cards
class _SummaryCards extends StatelessWidget {
  final DriverStatsData? stats;

  const _SummaryCards({this.stats});

  @override
  Widget build(BuildContext context) {
    final summary = stats?.summary;

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _MiniStatCard(
            icon: Icons.list_alt_outlined,
            value: '${summary?.totalDeliveries ?? 0}',
            label: 'Total',
            gradient: const [AppColors.accent, AppColors.accentDark],
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            icon: Icons.check_circle_outline,
            value: '${summary?.completedDeliveries ?? 0}',
            label: 'Completadas',
            gradient: const [AppColors.statusCompleted, Color(0xFF0F2A22)],
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            icon: Icons.local_shipping_outlined,
            value: '${summary?.inProgressDeliveries ?? 0}',
            label: 'En Curso',
            gradient: const [AppColors.primary, Color(0xFFB08A3E)],
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            icon: Icons.schedule_outlined,
            value: '${summary?.pendingDeliveries ?? 0}',
            label: 'Pendientes',
            gradient: const [AppColors.gray600, AppColors.gray800],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.white.withValues(alpha: 0.9), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Performance Card
class _PerformanceCard extends StatelessWidget {
  final DriverStatsData? stats;

  const _PerformanceCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final performance = stats?.performance;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'Rendimiento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PerformanceMetric(
                  icon: Icons.timer_outlined,
                  value: performance?.avgDeliveryTimeFormatted.isNotEmpty == true
                      ? performance!.avgDeliveryTimeFormatted
                      : '--',
                  label: 'Prom. Entrega',
                ),
                Container(
                  height: 60,
                  width: 1,
                  color: AppColors.gray200,
                ),
                _PerformanceMetric(
                  icon: Icons.route_outlined,
                  value: performance?.avgRouteTimeFormatted.isNotEmpty == true
                      ? performance!.avgRouteTimeFormatted
                      : '--',
                  label: 'Prom. Ruta',
                ),
                Container(
                  height: 60,
                  width: 1,
                  color: AppColors.gray200,
                ),
                _PerformanceMetric(
                  icon: Icons.trending_up,
                  value: '${stats?.summary?.completionRate.toInt() ?? 0}%',
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

class _PerformanceMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PerformanceMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.corpGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.corpDarkGray,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.corpDarkGray.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// Today Progress Card
class _TodayProgressCard extends StatelessWidget {
  final DriverStatsData? stats;
  final VoidCallback onViewRoutes;

  const _TodayProgressCard({
    this.stats,
    required this.onViewRoutes,
  });

  @override
  Widget build(BuildContext context) {
    final today = stats?.today;
    final completed = today?.completed ?? 0;
    final total = today?.total ?? 0;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.today, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Progreso de Hoy',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onViewRoutes,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ver rutas', style: TextStyle(color: AppColors.primary)),
                      Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Circular Progress
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
                          strokeWidth: 12,
                          color: AppColors.gray200,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '$completed de $total',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TodayStatItem(
                      color: AppColors.statusCompleted,
                      label: 'Completadas',
                      value: completed,
                    ),
                    const SizedBox(height: 8),
                    _TodayStatItem(
                      color: AppColors.statusInProgress,
                      label: 'En curso',
                      value: today?.inProgress ?? 0,
                    ),
                    const SizedBox(height: 8),
                    _TodayStatItem(
                      color: AppColors.statusPending,
                      label: 'Pendientes',
                      value: today?.pending ?? 0,
                    ),
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

class _TodayStatItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _TodayStatItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value $label',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray700,
          ),
        ),
      ],
    );
  }
}

// History Item Card
class _HistoryItemCard extends StatelessWidget {
  final RouteHistoryItem item;

  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.statusCompleted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.statusCompleted,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.durationFormatted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${item.completedDeliveries}/${item.totalDeliveries} entregas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
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

// Empty History Card
class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.gray50,
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.history, color: AppColors.gray400, size: 48),
            SizedBox(height: 12),
            Text(
              'Sin historial aún',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Completa tus primeras rutas para ver tu historial aquí',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

