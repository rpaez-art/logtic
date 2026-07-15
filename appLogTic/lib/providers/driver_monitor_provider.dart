import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/route.dart';

class DriverMonitorProvider extends ChangeNotifier {
  List<DriverWithRoutes> _driversWithRoutes = [];

  List<DriverWithRoutes> get driversWithRoutes => _driversWithRoutes;

  void loadDriversWithRoutes() {
    // In production, this would come from an API
    _driversWithRoutes = [
      DriverWithRoutes(
        driver: User(username: 'driver1', fullName: 'Juan Pérez', driverCode: 'DRV001', driverId: 1),
        routes: [],
      ),
      DriverWithRoutes(
        driver: User(username: 'driver2', fullName: 'María González', driverCode: 'DRV002', driverId: 2),
        routes: [],
      ),
    ];
    notifyListeners();
  }

  void refreshData() {
    loadDriversWithRoutes();
  }
}