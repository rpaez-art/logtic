import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/period_selector.dart';
import 'widgets/summary_cards.dart';
import 'widgets/performance_card.dart';
import 'widgets/admin_action_card.dart';
import 'widgets/today_progress_card.dart';
import 'widgets/dashboard_history_card.dart';
import 'widgets/empty_history_card.dart';

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
              SliverToBoxAdapter(
                child: DashboardHeader(
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: PeriodSelector(
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
              SliverToBoxAdapter(
                child: odoo.isLoadingStats
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SummaryCards(stats: odoo.driverStats),
              ),
              SliverToBoxAdapter(
                child: PerformanceCard(stats: odoo.driverStats),
              ),
              SliverToBoxAdapter(
                child: TodayProgressCard(
                  stats: odoo.driverStats,
                  onViewRoutes: () {
                    context.go('/routes');
                  },
                ),
              ),
              if (isAdmin) ...[
                SliverToBoxAdapter(
                  child: _AdminSection(onMonitor: () => context.push('/admin/monitor')),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: AdminActionCard(
                            icon: Icons.visibility,
                            label: 'Monitor',
                            color: AppColors.primary,
                            onTap: () => context.push('/admin/monitor'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminActionCard(
                            icon: Icons.supervisor_account,
                            label: 'Usuarios',
                            color: AppColors.secondary,
                            onTap: () => context.push('/admin/users'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AdminActionCard(
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
              SliverToBoxAdapter(
                child: _HistoryHeader(onViewAll: () => context.go('/history')),
              ),
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
                  child: EmptyHistoryCard(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = odoo.routesHistory[index];
                      return DashboardHistoryCard(item: item);
                    },
                    childCount: odoo.routesHistory.length > 5 ? 5 : odoo.routesHistory.length,
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
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

class _AdminSection extends StatelessWidget {
  final VoidCallback onMonitor;
  const _AdminSection({required this.onMonitor});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  final VoidCallback onViewAll;
  const _HistoryHeader({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: onViewAll,
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
    );
  }
}