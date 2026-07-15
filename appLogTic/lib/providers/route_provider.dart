import 'package:flutter/foundation.dart';
import '../models/route.dart';

enum RouteFilter { pending, all }

class RouteProvider extends ChangeNotifier {
  List<RouteModel> _allRoutes = [];
  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  RouteFilter _currentFilter = RouteFilter.pending;

  List<RouteModel> get routes => _routes;
  RouteModel? get selectedRoute => _selectedRoute;
  RouteFilter get currentFilter => _currentFilter;

  void setRoutesFromOdoo(List<RouteModel> odooRoutes) {
    _allRoutes = odooRoutes;
    _applyFilter();
    notifyListeners();
  }

  void setFilter(RouteFilter filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _routes = _currentFilter == RouteFilter.pending
        ? _allRoutes.where((r) => r.status != RouteStatus.completed).toList()
        : _allRoutes;
  }

  void selectRoute(RouteModel route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void clearSelectedRoute() {
    _selectedRoute = null;
    notifyListeners();
  }

  void startRoute(int routeId) {
    final now = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
    _allRoutes = _allRoutes.map((route) {
      if (route.id == routeId) {
        return route.copyWith(status: RouteStatus.inProgress, startTime: now);
      }
      return route;
    }).toList();
    _applyFilter();
    notifyListeners();
  }

  void completeRoute(int routeId, {double? latitude, double? longitude}) {
    final now = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
    _allRoutes = _allRoutes.map((route) {
      if (route.id == routeId) {
        return route.copyWith(
          status: RouteStatus.completed,
          endTime: now,
          endLatitude: latitude,
          endLongitude: longitude,
        );
      }
      return route;
    }).toList();
    _applyFilter();
    notifyListeners();
  }
}