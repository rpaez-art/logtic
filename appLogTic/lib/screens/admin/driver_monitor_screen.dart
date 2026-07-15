import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/route.dart';
import '../../providers/driver_monitor_provider.dart';

class DriverMonitorScreen extends StatefulWidget {
  const DriverMonitorScreen({super.key});

  @override
  State<DriverMonitorScreen> createState() => _DriverMonitorScreenState();
}

class _DriverMonitorScreenState extends State<DriverMonitorScreen> {
  DriverWithRoutes? _selectedDriver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverMonitorProvider>().loadDriversWithRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverMonitorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedDriver == null
            ? 'Monitor de Choferes'
            : 'Rutas de ${_selectedDriver!.driver.fullName}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          onPressed: () {
            if (_selectedDriver != null) {
              setState(() => _selectedDriver = null);
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.refreshData(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _selectedDriver == null
          ? _DriversListView(
              drivers: provider.driversWithRoutes,
              onDriverClick: (driver) => setState(() => _selectedDriver = driver),
            )
          : _DriverRoutesDetailView(driverWithRoutes: _selectedDriver!),
    );
  }
}

class _DriversListView extends StatelessWidget {
  final List<DriverWithRoutes> drivers;
  final ValueChanged<DriverWithRoutes> onDriverClick;

  const _DriversListView({required this.drivers, required this.onDriverClick});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driverWithRoutes = drivers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _DriverCard(
            driverWithRoutes: driverWithRoutes,
            onClick: () => onDriverClick(driverWithRoutes),
          ),
        );
      },
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverWithRoutes driverWithRoutes;
  final VoidCallback onClick;

  const _DriverCard({required this.driverWithRoutes, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 40, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverWithRoutes.driver.fullName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rol: ${driverWithRoutes.driver.role}',
                          style: const TextStyle(fontSize: 14, color: AppColors.gray600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progreso', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(
                        '${driverWithRoutes.completionPercentage}%',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: driverWithRoutes.completionPercentage / 100,
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    minHeight: 8,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Total', value: '${driverWithRoutes.totalRoutes}', color: Theme.of(context).colorScheme.primary),
                  _StatItem(label: 'En Curso', value: '${driverWithRoutes.inProgressRoutes}', color: Theme.of(context).colorScheme.secondary),
                  _StatItem(label: 'Completadas', value: '${driverWithRoutes.completedRoutes}', color: Theme.of(context).colorScheme.tertiary),
                  _StatItem(label: 'Pendientes', value: '${driverWithRoutes.pendingRoutes}', color: Theme.of(context).colorScheme.error),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
      ],
    );
  }
}

class _DriverRoutesDetailView extends StatelessWidget {
  final DriverWithRoutes driverWithRoutes;

  const _DriverRoutesDetailView({required this.driverWithRoutes});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${driverWithRoutes.completedRoutes}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    const Text('Completadas', style: TextStyle(fontSize: 12, color: AppColors.gray700)),
                  ],
                ),
                Container(height: 50, width: 1, color: AppColors.gray400),
                Column(
                  children: [
                    Text(
                      '${driverWithRoutes.pendingRoutes}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    const Text('Pendientes', style: TextStyle(fontSize: 12, color: AppColors.gray700)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: driverWithRoutes.routes.length,
            itemBuilder: (context, index) {
              final route = driverWithRoutes.routes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  color: route.status == RouteStatus.completed
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : route.status == RouteStatus.inProgress
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                route.clientName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: route.status == RouteStatus.completed
                                    ? Theme.of(context).colorScheme.tertiary
                                    : route.status == RouteStatus.inProgress
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                route.status == RouteStatus.completed
                                    ? '✓ Completada'
                                    : route.status == RouteStatus.inProgress
                                        ? '→ En Curso'
                                        : '○ Pendiente',
                                style: const TextStyle(fontSize: 12, color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${route.address}, ${route.city}',
                          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                        ),
                        if (route.startTime != null) ...[
                          const SizedBox(height: 8),
                          Text('⏰ Inicio: ${route.startTime}', style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}