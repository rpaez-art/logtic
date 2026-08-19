import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/odoo_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/odoo_provider.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/attachment_tile.dart';
import '../../widgets/dynamic_search_bar.dart';
import '../../widgets/pagination_bar.dart';
import '../../utils/search_utils.dart';
import '../routes/widgets/supplier_info_dialog.dart';
import '../../services/api/retrofit_client.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'today', 'week', 'month', 'completed_100', 'has_docs', 'custom_range'
  DateTimeRange? _dateRange;
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'duration_desc', 'deliveries_desc'
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final odoo = context.read<OdooProvider>();
      if (auth.currentUser != null) {
        odoo.fetchRoutesHistory(auth.currentUser!.driverId, limit: 100);
        odoo.fetchHistoryStats(auth.currentUser!.driverId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _currentPage = 1;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialRange = _dateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.corpGreen,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _selectedFilter = 'custom_range';
        _currentPage = 1;
      });
    }
  }

  void _resetAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilter = 'all';
      _dateRange = null;
      _sortBy = 'date_desc';
      _currentPage = 1;
    });
  }

  String _formatDateSpanish(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
      const days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} de $monthName ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  List<RouteHistoryItem> _filterAndSortRoutes(List<RouteHistoryItem> allRoutes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final filtered = allRoutes.where((route) {
      // 1. Text search query (case & accent insensitive multi-term search)
      if (_searchQuery.trim().isNotEmpty) {
        final List<String?> routeFields = [
          route.name,
          route.date,
          _formatDateSpanish(route.date),
        ];

        if (route.lines != null) {
          for (final line in route.lines!) {
            routeFields.addAll([
              line.partnerId.name,
              line.street,
              line.originAddress,
              line.destinationAddress,
              line.obra,
              line.orderName,
              line.notes,
            ]);
          }
        }

        if (!SearchUtils.matchesAny(routeFields, _searchQuery)) {
          return false;
        }
      }

      // 2. Filter category
      DateTime? routeDate;
      try {
        routeDate = DateTime.parse(route.date);
      } catch (_) {}

      switch (_selectedFilter) {
        case 'today':
          if (routeDate == null) return false;
          final rDate = DateTime(routeDate.year, routeDate.month, routeDate.day);
          if (rDate != today) return false;
          break;
        case 'week':
          if (routeDate == null) return false;
          final rDate = DateTime(routeDate.year, routeDate.month, routeDate.day);
          if (rDate.isBefore(weekStart)) return false;
          break;
        case 'month':
          if (routeDate == null) return false;
          final rDate = DateTime(routeDate.year, routeDate.month, routeDate.day);
          if (rDate.isBefore(monthStart)) return false;
          break;
        case 'completed_100':
          if (route.totalDeliveries == 0 || route.completedDeliveries < route.totalDeliveries) {
            return false;
          }
          break;
        case 'has_docs':
          final hasDocs = route.lines != null &&
              route.lines!.any((l) => l.attachments != null && l.attachments!.isNotEmpty);
          if (!hasDocs) return false;
          break;
        case 'custom_range':
          if (_dateRange != null && routeDate != null) {
            final rDate = DateTime(routeDate.year, routeDate.month, routeDate.day);
            final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
            final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
            if (rDate.isBefore(start) || rDate.isAfter(end)) return false;
          }
          break;
        default:
          break;
      }

      return true;
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date_asc':
          return a.date.compareTo(b.date);
        case 'duration_desc':
          return b.durationMinutes.compareTo(a.durationMinutes);
        case 'deliveries_desc':
          return b.totalDeliveries.compareTo(a.totalDeliveries);
        case 'date_desc':
        default:
          return b.date.compareTo(a.date);
      }
    });

    return filtered;
  }

  void _goToPage(int page, int totalPages) {
    if (page < 1 || page > totalPages) return;
    setState(() => _currentPage = page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        220, // scroll past header stats
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final odoo = context.watch<OdooProvider>();

    final allRoutes = odoo.routesHistory;
    final stats = odoo.historyStats?.summary;
    final performance = odoo.historyStats?.performance;

    final totalRoutes = stats?.totalRoutes ?? allRoutes.length;
    final totalDeliveries = stats?.totalDeliveries ?? 0;
    final totalCompleted = stats?.completedDeliveries ?? 0;
    final avgDuration = performance?.avgRouteTimeFormatted ?? '--';

    final filteredRoutes = _filterAndSortRoutes(allRoutes);
    final totalPages = (filteredRoutes.isEmpty || _pageSize <= 0)
        ? 1
        : (filteredRoutes.length / _pageSize).ceil();

    // Ensure valid page
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    }

    final startIndex = (_currentPage - 1) * _pageSize;
    final paginatedRoutes = filteredRoutes.skip(startIndex).take(_pageSize).toList();
    final isFiltering = _searchQuery.isNotEmpty || _selectedFilter != 'all' || _sortBy != 'date_desc';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Rutas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.corpGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () {
              if (auth.currentUser != null) {
                odoo.fetchRoutesHistory(auth.currentUser!.driverId, limit: 100);
                odoo.fetchHistoryStats(auth.currentUser!.driverId);
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: AnimatedThemeToggle(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.gray100,
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Stats summary card
            SliverToBoxAdapter(
              child: _HistorySummarySection(
                totalRoutes: totalRoutes,
                totalDeliveries: totalDeliveries,
                totalCompleted: totalCompleted,
                avgDuration: avgDuration,
              ),
            ),

            // Search & Filter controls
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Smart search bar
                    DynamicSearchBar(
                      controller: _searchController,
                      hintText: 'Buscar por ruta, cliente, dirección o fecha...',
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                      accentColor: AppColors.corpGreen,
                    ),
                    const SizedBox(height: 12),

                    // Quick filter chips horizontal list
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Todas', Icons.all_inclusive),
                          const SizedBox(width: 8),
                          _buildFilterChip('today', 'Hoy', Icons.today),
                          const SizedBox(width: 8),
                          _buildFilterChip('week', 'Esta semana', Icons.calendar_view_week),
                          const SizedBox(width: 8),
                          _buildFilterChip('month', 'Este mes', Icons.calendar_month),
                          const SizedBox(width: 8),
                          _buildFilterChip('completed_100', '100% Completas', Icons.check_circle_outline),
                          const SizedBox(width: 8),
                          _buildFilterChip('has_docs', 'Con Documentos', Icons.attach_file),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _pickDateRange,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'custom_range'
                                    ? AppColors.primary
                                    : (isDark ? AppColors.surfaceDark : AppColors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedFilter == 'custom_range'
                                      ? AppColors.primary
                                      : (isDark ? AppColors.gray700 : AppColors.gray300),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.date_range,
                                    size: 14,
                                    color: _selectedFilter == 'custom_range'
                                        ? AppColors.white
                                        : (isDark ? AppColors.gray300 : AppColors.gray700),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dateRange != null
                                        ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'
                                        : 'Rango fecha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedFilter == 'custom_range'
                                          ? AppColors.white
                                          : (isDark ? AppColors.gray300 : AppColors.gray700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Results count and sorting bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${filteredRoutes.length} rutas encontradas',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.gray300 : AppColors.gray700,
                              ),
                            ),
                            if (isFiltering) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _resetAllFilters,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Limpiar filtros',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Sort dropdown
                        PopupMenuButton<String>(
                          initialValue: _sortBy,
                          tooltip: 'Ordenar por',
                          onSelected: (val) => setState(() {
                            _sortBy = val;
                            _currentPage = 1;
                          }),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'date_desc',
                              child: Text('Fecha: Más recientes primero'),
                            ),
                            const PopupMenuItem(
                              value: 'date_asc',
                              child: Text('Fecha: Más antiguas primero'),
                            ),
                            const PopupMenuItem(
                              value: 'duration_desc',
                              child: Text('Duración: Mayor a menor'),
                            ),
                            const PopupMenuItem(
                              value: 'deliveries_desc',
                              child: Text('Entregas: Mayor a menor'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.gray700 : AppColors.gray300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _sortBy == 'date_desc'
                                      ? 'Recientes'
                                      : _sortBy == 'date_asc'
                                          ? 'Antiguas'
                                          : _sortBy == 'duration_desc'
                                              ? 'Duración'
                                              : 'Entregas',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                const Icon(Icons.arrow_drop_down, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            if (odoo.isLoadingHistory)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (filteredRoutes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          isFiltering ? Icons.search_off_rounded : Icons.history,
                          size: 64,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isFiltering
                              ? 'No se encontraron rutas con los filtros aplicados'
                              : 'No hay rutas completadas en el historial',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.gray300 : AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isFiltering) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _resetAllFilters,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Restablecer búsqueda'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Paginated Route List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _HistoryRouteCard(item: paginatedRoutes[index]),
                  childCount: paginatedRoutes.length,
                ),
              ),

              // Pagination Controls Bar
              SliverToBoxAdapter(
                child: PaginationBar(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  totalItems: filteredRoutes.length,
                  pageSize: _pageSize,
                  pageSizeOptions: const [5, 10, 20, 50],
                  onPageChanged: (p) => _goToPage(p, totalPages),
                  onPageSizeChanged: (s) {
                    setState(() {
                      _pageSize = s;
                      _currentPage = 1;
                    });
                  },
                  activeColor: AppColors.corpGreen,
                  itemLabel: 'rutas',
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _selectFilter(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkGreen : AppColors.primary)
              : (isDark ? AppColors.surfaceDark : AppColors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.darkGreen : AppColors.primary)
                : (isDark ? AppColors.gray700 : AppColors.gray300),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.darkGreen : AppColors.primary).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? (isDark ? AppColors.black : AppColors.white)
                  : (isDark ? AppColors.darkGreen : AppColors.primary),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.black : AppColors.white)
                    : (isDark ? AppColors.darkTextWhite : AppColors.gray700),
              ),
            ),
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
  final String avgDuration;

  const _HistorySummarySection({
    required this.totalRoutes,
    required this.totalDeliveries,
    required this.totalCompleted,
    required this.avgDuration,
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
            'Resumen General (Todo el tiempo)',
            style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HistoryStat(value: '$totalRoutes', label: 'Rutas', icon: Icons.route_outlined),
              _HistoryStat(value: '$totalDeliveries', label: 'Entregas', icon: Icons.local_shipping_outlined),
              _HistoryStat(value: '$totalCompleted', label: 'Completadas', icon: Icons.check_circle_outlined),
              _HistoryStat(value: avgDuration.isEmpty ? '--' : avgDuration, label: 'Prom. Dur.', icon: Icons.timer_outlined),
            ],
          ),
        ],
      ),
    );
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

/// Route-level card matching the style of _ExpandableRouteCard from routes_screen.dart
class _HistoryRouteCard extends StatefulWidget {
  final RouteHistoryItem item;

  const _HistoryRouteCard({required this.item});

  @override
  State<_HistoryRouteCard> createState() => _HistoryRouteCardState();
}

class _HistoryRouteCardState extends State<_HistoryRouteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final odoo = context.watch<OdooProvider>();
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: icon + name + duration + completed/total
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.route, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  ]),
                  const SizedBox(height: 6),
                  // Date row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.date,
                          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        ),
                      ),
                      // Expand icon
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
                  const SizedBox(height: 8),
                  // Progress bar
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
                  // Bottom row: docs badge / loading / deliveries count
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
                      Text(
                        hasLines
                            ? '${item.lines!.length} entregas'
                            : 'Ver entregas',
                        style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded delivery lines
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(12),
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
                              .map((line) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _HistoryLineCard(line: line),
                                  ))
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

/// Delivery line card matching the style of _RouteActivityCard from routes_screen.dart
class _HistoryLineCard extends StatefulWidget {
  final RouteLineData line;

  const _HistoryLineCard({required this.line});

  @override
  State<_HistoryLineCard> createState() => _HistoryLineCardState();
}

class _HistoryLineCardState extends State<_HistoryLineCard> {
  bool _showProducts = false;
  bool _isLoadingAttachments = false;
  List<AttachmentData> _attachments = [];
  String? _originAddress;
  String? _destinationAddress;

  @override
  void initState() {
    super.initState();
    _fetchMapInfo();
    _attachments = widget.line.attachments ?? [];
    if (_attachments.isEmpty) {
      _fetchAttachments();
    }
  }

  Future<void> _fetchMapInfo() async {
    try {
      final info = await RetrofitClient().getMapInfo(widget.line.id);
      if (info['success'] == true && info['data'] != null) {
        final allAddresses = info['data']['all_addresses'];
        if (allAddresses != null && mounted) {
          setState(() {
            _originAddress = allAddresses['origin_address'];
            _destinationAddress = allAddresses['destination_address'];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchAttachments() async {
    setState(() => _isLoadingAttachments = true);
    try {
      final odoo = Provider.of<OdooProvider>(context, listen: false);
      final attachments = await odoo.getLineAttachments(widget.line.id);
      if (mounted) {
        setState(() {
          _attachments = attachments;
          _isLoadingAttachments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAttachments = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final stateColor = _getStateColor(line.state);
    final hasAttachments = _attachments.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner & state badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => SupplierInfoDialog.show(context, line),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: stateColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                line.partnerId.name.isNotEmpty ? line.partnerId.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: stateColor,
                                ),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          height: 1.25,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: context.greenTextColor,
                                    ),
                                  ],
                                ),
                                if (line.obra != null && line.obra!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.place_outlined, size: 13, color: context.subtextColor),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            line.obra!,
                                            style: TextStyle(fontSize: 12, color: context.subtextColor),
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStateLabel(line.state),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: stateColor,
                    ),
                  ),
                ),
              ],
            ),
            // ── Desde / Hasta (Origen / Destino) ──
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.containerColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desde: ubicación actual del conductor
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.trip_origin, size: 16, color: AppColors.statusInProgress),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_originAddress != null && _originAddress!.isNotEmpty)
                            Text(
                              _originAddress!,
                              style: const TextStyle(fontSize: 13),
                            )
                          else ...[
                            Text(
                              'Desde: Mi ubicación',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.subtextColor),
                            ),
                            Text(
                              'Tu posición actual (GPS)',
                              style: TextStyle(fontSize: 12, color: context.subtextColor),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  // Hasta: dirección de destino
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.statusCompleted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _destinationAddress != null && _destinationAddress!.isNotEmpty
                                ? 'Hasta: $_destinationAddress'
                                : 'Hasta: ${line.partnerId.name.isNotEmpty ? line.partnerId.name : 'Destino'}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.subtextColor),
                          ),
                          if (line.street != null && line.street!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(line.street!, style: const TextStyle(fontSize: 13)),
                          ],
                          if (line.city != null && line.city!.isNotEmpty)
                            Text(line.city!, style: TextStyle(fontSize: 11, color: context.subtextColor)),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            // Notes
            if (line.notes != null && line.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: context.containerColor, borderRadius: BorderRadius.circular(10)),
                child: Text(_parseHtml(line.notes!), style: const TextStyle(fontSize: 13)),
              ),
            ],
            // Incomplete reason
            if (line.incompleteReason != null && line.incompleteReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.statusIncomplete.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_outlined, size: 16, color: AppColors.statusIncomplete),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Motivo: ${line.incompleteNotes ?? line.incompleteReason!}',
                        style: const TextStyle(fontSize: 12, color: AppColors.statusIncomplete),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Time chips
            if (line.startTime != null || line.pickupTime != null || line.endTime != null) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: [
                if (line.startTime != null) _TimeChip(icon: Icons.play_arrow, time: _formatTime(line.startTime!), color: AppColors.statusInProgress),
                if (line.pickupTime != null) _TimeChip(icon: Icons.local_shipping, time: _formatTime(line.pickupTime!), color: AppColors.statusPickedUp),
                if (line.endTime != null) _TimeChip(icon: Icons.check_circle, time: _formatTime(line.endTime!), color: AppColors.statusCompleted),
              ]),
            ],
            // Products (order lines)
            if (line.orderLines != null && line.orderLines!.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => setState(() => _showProducts = !_showProducts),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: context.greenTextColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Icon(Icons.inventory, size: 18, color: context.greenTextColor),
                      const SizedBox(width: 8),
                      Text('${line.orderLines!.length} productos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.greenTextColor)),
                      if (line.orderName != null) Text(' • ${line.orderName}', style: TextStyle(fontSize: 11, color: context.subtextColor)),
                    ]),
                    Icon(_showProducts ? Icons.expand_less : Icons.expand_more, color: context.greenTextColor, size: 20),
                  ]),
                ),
              ),
              if (_showProducts)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: line.orderLines!.map((orderLine) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(orderLine.productName, style: const TextStyle(fontSize: 12))),
                        Text('${orderLine.quantity.toInt()} ${orderLine.uom}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ]),
                    )).toList(),
                  ),
                ),
            ],
            // Documents (attachments)
            if (_isLoadingAttachments) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ] else if (hasAttachments) ...[
              const SizedBox(height: 10),
              AttachmentsGrouped(attachments: _attachments),
            ],
            // Navigate button (like routes_screen _RouteActivityCard)
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigate(line),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navegar', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _navigate(RouteLineData line) async {
    final destination = line.street != null && line.street!.isNotEmpty
        ? Uri.encodeComponent(line.street!)
        : '${line.latitude ?? 0.0},${line.longitude ?? 0.0}';
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
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
      case 'done': return 'Entregado';
      case 'picked_up': return 'Recogido';
      case 'in_progress': return 'En camino';
      case 'incomplete': return 'Incompleta';
      case 'partial': return 'Parcial';
      case 'cancelled': return 'Cancelado';
      default: return 'Pendiente';
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

/// Same time chip widget used in routes_screen _RouteActivityCard
class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String time;
  final Color color;

  const _TimeChip({required this.icon, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
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