import 'user.dart';

class RouteModel {
  final int id;
  final String clientName;
  final String address;
  final String city;
  final String scheduledTime;
  final RouteStatus status;
  final double latitude;
  final double longitude;
  final String description;
  final String? startTime;
  final String? endTime;
  final double? endLatitude;
  final double? endLongitude;
  final String assignedDriver;
  final int? odooRouteId;
  final int? odooLineId;
  final int sequence;

  RouteModel({
    required this.id,
    this.clientName = '',
    this.address = '',
    this.city = '',
    this.scheduledTime = '',
    this.status = RouteStatus.pending,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.description = '',
    this.startTime,
    this.endTime,
    this.endLatitude,
    this.endLongitude,
    this.assignedDriver = '',
    this.odooRouteId,
    this.odooLineId,
    this.sequence = 0,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? json['partnerId']?['name'] ?? '',
      address: json['address'] ?? json['street'] ?? '',
      city: json['city'] ?? '',
      scheduledTime: json['scheduled_time'] ?? json['scheduledTime'] ?? '',
      status: _parseStatus(json['status'] ?? json['state'] ?? 'pending'),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      description: json['description'] ?? json['notes'] ?? '',
      startTime: json['start_time'] ?? json['startTime'],
      endTime: json['end_time'] ?? json['endTime'],
      endLatitude: json['end_latitude']?.toDouble() ?? json['endLatitude']?.toDouble(),
      endLongitude: json['end_longitude']?.toDouble() ?? json['endLongitude']?.toDouble(),
      assignedDriver: json['assigned_driver'] ?? json['assignedDriver'] ?? '',
      odooRouteId: json['odoo_route_id'] ?? json['odooRouteId'],
      odooLineId: json['odoo_line_id'] ?? json['odooLineId'],
      sequence: json['sequence'] ?? 0,
    );
  }

  static RouteStatus _parseStatus(String status) {
    switch (status) {
      case 'completed':
      case 'done':
        return RouteStatus.completed;
      case 'in_progress':
      case 'inProgress':
        return RouteStatus.inProgress;
      default:
        return RouteStatus.pending;
    }
  }

  RouteModel copyWith({
    int? id,
    String? clientName,
    String? address,
    String? city,
    String? scheduledTime,
    RouteStatus? status,
    double? latitude,
    double? longitude,
    String? description,
    String? startTime,
    String? endTime,
    double? endLatitude,
    double? endLongitude,
    String? assignedDriver,
    int? odooRouteId,
    int? odooLineId,
    int? sequence,
  }) {
    return RouteModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      city: city ?? this.city,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      odooRouteId: odooRouteId ?? this.odooRouteId,
      odooLineId: odooLineId ?? this.odooLineId,
      sequence: sequence ?? this.sequence,
    );
  }
}

enum RouteStatus { pending, inProgress, completed }

class DriverWithRoutes {
  final User driver;
  final List<RouteModel> routes;

  DriverWithRoutes({required this.driver, required this.routes});

  int get totalRoutes => routes.length;
  int get completedRoutes => routes.where((r) => r.status == RouteStatus.completed).length;
  int get inProgressRoutes => routes.where((r) => r.status == RouteStatus.inProgress).length;
  int get pendingRoutes => routes.where((r) => r.status == RouteStatus.pending).length;
  int get completionPercentage => totalRoutes > 0 ? (completedRoutes * 100 / totalRoutes).round() : 0;
}