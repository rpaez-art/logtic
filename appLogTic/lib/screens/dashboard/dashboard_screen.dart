import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/attachment_tile.dart';
import '../routes/widgets/supplier_info_dialog.dart';

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
      extendBodyBehindAppBar: true,
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
                  isAdmin: isAdmin,
                  onLogout: () {
                    auth.logout();
                    context.go('/login');
                  },
                ),
              ),

              // Period Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                    : _SummaryCards(stats: odoo.driverStats),
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
                    context.go('/routes');
                  },
                ),
              ),

              // Admin Section
              if (isAdmin) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.admin_panel_settings, color: AppColors.secondary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Panel de Administración',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AdminActionCard(
                            icon: Icons.visibility,
                            label: 'Monitor',
                            color: AppColors.primary,
                            onTap: () => context.push('/admin/monitor'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AdminActionCard(
                            icon: Icons.supervisor_account,
                            label: 'Usuarios',
                            color: AppColors.secondary,
                            onTap: () => context.push('/admin/users'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AdminActionCard(
                            icon: Icons.settings,
                            label: 'Config',
                            color: AppColors.accent,
                            onTap: () => context.push('/admin/config'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // History Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
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
                            child: const Icon(Icons.history, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Historial Reciente',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/history');
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ver todo', style: TextStyle(color: AppColors.corpGreen, fontWeight: FontWeight.w600)),
                            Icon(Icons.chevron_right, color: AppColors.corpGreen, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // History Items (expandable with lines & documents)
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
                      return _DashboardHistoryCard(item: item);
                    },
                    childCount: odoo.routesHistory.length > 5 ? 5 : odoo.routesHistory.length,
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
            child: FloatingActionButton.extended(
              onPressed: () {
                context.go('/routes');
              },
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.local_shipping, size: 22),
              label: const Text('Mis Rutas', style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}

// Header Widget
class _DashboardHeader extends StatelessWidget {
  final String userName;
  final String? driverImage;
  final bool isAdmin;
  final VoidCallback onLogout;

  const _DashboardHeader({
    required this.userName,
    this.driverImage,
    this.isAdmin = false,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.corpGreen,
            AppColors.corpDarkGray,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: [
              // Top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: AnimatedThemeToggle(),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout, color: AppColors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Profile card
              Card(
                elevation: 8,
                shadowColor: AppColors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
                              style: TextStyle(fontSize: 11, color: AppColors.gray500, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.gray900),
                            ),
                            const SizedBox(height: 6),
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
                                  style: TextStyle(fontSize: 12, color: AppColors.statusCompleted, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.gray300),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _defaultIcon() => const Icon(Icons.person, color: AppColors.white, size: 32);
}

// Period Selector
class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const _PeriodSelector({required this.selectedPeriod, required this.onPeriodSelected});

  @override
  Widget build(BuildContext context) {
    final periods = [
      ('today', 'Hoy', Icons.today),
      ('week', 'Semana', Icons.date_range),
      ('month', 'Mes', Icons.calendar_month),
      ('all', 'Todo', Icons.inbox),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onPeriodSelected(period.$1),
              avatar: Icon(period.$3, size: 16, color: isSelected ? AppColors.white : AppColors.corpDarkGray),
              label: Text(
                period.$2,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.corpDarkGray,
                  fontSize: 13,
                ),
              ),
              selectedColor: AppColors.corpGreen,
              checkmarkColor: AppColors.white,
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: isSelected ? AppColors.corpGreen : AppColors.gray300,
                width: isSelected ? 1.5 : 1,
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
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _MiniStatCard(
            icon: Icons.list_alt_rounded,
            value: '${summary?.totalDeliveries ?? 0}',
            label: 'Total Entregas',
            gradient: const [AppColors.accent, AppColors.accentDark],
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            icon: Icons.check_circle_rounded,
            value: '${summary?.completedDeliveries ?? 0}',
            label: 'Completadas',
            gradient: const [AppColors.statusCompleted, Color(0xFF0F2A22)],
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            icon: Icons.local_shipping_rounded,
            value: '${summary?.inProgressDeliveries ?? 0}',
            label: 'En Curso',
            gradient: const [AppColors.primaryLight, AppColors.secondaryDark],
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
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

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;

  const _MiniStatCard({required this.icon, required this.value, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.8), fontSize: 11),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.speed, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                const Text('Rendimiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PerformanceMetric(
                  icon: Icons.timer_outlined,
                  value: performance?.avgDeliveryTimeFormatted.isNotEmpty == true ? performance!.avgDeliveryTimeFormatted : '--',
                  label: 'Prom. Entrega',
                ),
                Container(height: 50, width: 1, color: AppColors.gray200),
                _PerformanceMetric(
                  icon: Icons.route_outlined,
                  value: performance?.avgRouteTimeFormatted.isNotEmpty == true ? performance!.avgRouteTimeFormatted : '--',
                  label: 'Prom. Ruta',
                ),
                Container(height: 50, width: 1, color: AppColors.gray200),
                _PerformanceMetric(
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

class _PerformanceMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _PerformanceMetric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.corpGreen, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.corpDarkGray)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.corpDarkGray.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray700)),
            ],
          ),
        ),
      ),
    );
  }
}

// Today Progress Card
class _TodayProgressCard extends StatelessWidget {
  final DriverStatsData? stats;
  final VoidCallback onViewRoutes;
  const _TodayProgressCard({this.stats, required this.onViewRoutes});

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
                // Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TodayStatItem(color: AppColors.statusCompleted, label: 'Completadas', value: completed),
                    const SizedBox(height: 10),
                    _TodayStatItem(color: AppColors.statusInProgress, label: 'En curso', value: today?.inProgress ?? 0),
                    const SizedBox(height: 10),
                    _TodayStatItem(color: AppColors.statusPending, label: 'Pendientes', value: today?.pending ?? 0),
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
  const _TodayStatItem({required this.color, required this.label, required this.value});

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
          style: const TextStyle(fontSize: 14, color: AppColors.gray700),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dashboard history card — expandable with lines & documents
// ─────────────────────────────────────────────────────────────
class _DashboardHistoryCard extends StatefulWidget {
  final RouteHistoryItem item;

  const _DashboardHistoryCard({required this.item});

  @override
  State<_DashboardHistoryCard> createState() => _DashboardHistoryCardState();
}

class _DashboardHistoryCardState extends State<_DashboardHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final odoo = context.watch<OdooProvider>();
    // Get fresh item from provider so it updates when lines are fetched
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
                  // Main row
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

                  // Expand indicator & status row
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

          // Expanded delivery lines or loading state
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.gray50.withValues(alpha: 0.7),
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
                              .map((line) => _DashboardLineCard(line: line))
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

/// Dashboard line card — same as history line card but adapted for dashboard
class _DashboardLineCard extends StatefulWidget {
  final RouteLineData line;

  const _DashboardLineCard({required this.line});

  @override
  State<_DashboardLineCard> createState() => _DashboardLineCardState();
}

class _DashboardLineCardState extends State<_DashboardLineCard> {
  bool _showProducts = false;

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
              // Partner & state
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
                                      child: Text(
                                        '📍 ${line.obra}',
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
              if (line.street != null && line.street!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.street!, style: const TextStyle(fontSize: 12)),
                          if (line.city != null && line.city!.isNotEmpty)
                            Text(line.city!, style: const TextStyle(fontSize: 10, color: AppColors.gray500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Notes/comments
              if (line.notes != null && line.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: context.containerColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(_parseHtml(line.notes!), style: TextStyle(fontSize: 12, color: context.onSurfaceColor)),
                ),
              ],

              // Incomplete reason
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

              // Delivery times (Chips)
              if (line.startTime != null || line.pickupTime != null || line.endTime != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (line.startTime != null)
                      _DTimeChip(icon: Icons.play_arrow, time: _formatTime(line.startTime!), color: AppColors.statusInProgress),
                    if (line.pickupTime != null)
                      _DTimeChip(icon: Icons.local_shipping, time: _formatTime(line.pickupTime!), color: AppColors.statusPickedUp),
                    if (line.endTime != null)
                      _DTimeChip(icon: Icons.check_circle, time: _formatTime(line.endTime!), color: AppColors.statusCompleted),
                  ],
                ),
              ],

              // Products summary and list
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

              // Documents (grouped by type)
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
      case 'done': return '✓ Entregado';
      case 'picked_up': return '📦 Recogido';
      case 'in_progress': return '🚛 En camino';
      case 'incomplete': return '⚠ Incompleta';
      case 'partial': return '⚠ Parcial';
      case 'cancelled': return '✗ Cancelado';
      default: return '⏳ Pendiente';
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

class _DTimeChip extends StatelessWidget {
  final IconData icon;
  final String time;
  final Color color;

  const _DTimeChip({required this.icon, required this.time, required this.color});

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

// Empty History Card
class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: AppColors.gray50,
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