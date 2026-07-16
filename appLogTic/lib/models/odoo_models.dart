class OdooConfig {
  final String baseUrl;
  final String apiKey;
  final String database;

  OdooConfig({
    this.baseUrl = 'https://etc-corpocrea.odoo.com',
    this.apiKey = '',
    this.database = 'etc-corpocrea',
  });
}

// Auth models
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class FcmTokenRequest {
  final int driverId;
  final String token;
  final String platform;
  final String? username;

  FcmTokenRequest({
    required this.driverId,
    required this.token,
    this.platform = 'android',
    this.username,
  });

  Map<String, dynamic> toJson() => {
    'driver_id': driverId,
    'token': token,
    'platform': platform,
    'username': username,
  };
}

class LoginResponse {
  final bool success;
  final String? message;
  final AuthData? data;

  LoginResponse({required this.success, this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

class AuthData {
  final String username;
  final int? uid;
  final String? sessionId;
  final String fullName;
  final String role;
  final String driverCode;
  final int driverId;
  final String driverName;

  AuthData({
    this.username = '',
    this.uid,
    this.sessionId,
    this.fullName = '',
    this.role = 'driver',
    this.driverCode = '',
    this.driverId = 0,
    this.driverName = '',
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      username: json['username'] ?? '',
      uid: json['uid'],
      sessionId: json['session_id'],
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'driver',
      driverCode: json['driver_code'] ?? '',
      driverId: json['driver_id'] ?? 0,
      driverName: json['driver_name'] ?? '',
    );
  }
}

// Route models
class RouteData {
  final int id;
  final String name;
  final DriverInfo? driverId;
  final String state;
  final String? maxPriority;
  final String date;
  final String? startDate;
  final String? endDate;
  final List<RouteLineData> routeLines;

  RouteData({
    required this.id,
    this.name = '',
    this.driverId,
    this.state = '',
    this.maxPriority,
    this.date = '',
    this.startDate,
    this.endDate,
    this.routeLines = const [],
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      driverId: json['driver_id'] != null ? DriverInfo.fromJson(json['driver_id']) : null,
      state: json['state'] ?? '',
      maxPriority: json['max_priority'],
      date: json['date'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      routeLines: (json['route_lines'] as List<dynamic>?)
              ?.map((e) => RouteLineData.fromJson(e))
              .toList() ??
          [],
    );
  }

  RouteData copyWith({
    int? id,
    String? name,
    DriverInfo? Function()? driverId,
    String? state,
    String? maxPriority,
    String? date,
    String? startDate,
    String? endDate,
    List<RouteLineData>? routeLines,
  }) {
    return RouteData(
      id: id ?? this.id,
      name: name ?? this.name,
      driverId: driverId != null ? driverId() : this.driverId,
      state: state ?? this.state,
      maxPriority: maxPriority ?? this.maxPriority,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      routeLines: routeLines ?? this.routeLines,
    );
  }
}

class DriverInfo {
  final int id;
  final String name;

  DriverInfo({required this.id, this.name = ''});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class RouteLineData {
  final int id;
  final PartnerInfo partnerId;
  final String? street;
  final String? city;
  final double? latitude;
  final double? longitude;
  final int sequence;
  final String? notes;
  final String? obra;
  final String? priority;
  final String state;
  final String? scheduledTime;
  final String? startTime;
  final String? pickupTime;
  final String? endTime;
  final String? orderType;
  final String? orderName;
  final List<OrderLineData>? orderLines;
  final List<AttachmentData>? attachments;
  final String? incompleteReason;
  final String? incompleteNotes;

  RouteLineData({
    required this.id,
    required this.partnerId,
    this.street,
    this.city,
    this.latitude,
    this.longitude,
    this.sequence = 0,
    this.notes,
    this.obra,
    this.priority,
    this.state = 'pending',
    this.scheduledTime,
    this.startTime,
    this.pickupTime,
    this.endTime,
    this.orderType,
    this.orderName,
    this.orderLines,
    this.attachments,
    this.incompleteReason,
    this.incompleteNotes,
  });

  factory RouteLineData.fromJson(Map<String, dynamic> json) {
    return RouteLineData(
      id: json['id'] ?? 0,
      partnerId: PartnerInfo.fromJson(json['partner_id'] ?? {}),
      street: json['street'],
      city: json['city'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      sequence: json['sequence'] ?? 0,
      notes: json['notes'],
      obra: json['obra'],
      priority: json['priority'],
      state: json['state'] ?? 'pending',
      scheduledTime: json['scheduled_time'],
      startTime: json['start_time'],
      pickupTime: json['pickup_time'],
      endTime: json['end_time'],
      orderType: json['order_type'],
      orderName: json['order_name'],
      orderLines: (json['order_lines'] as List<dynamic>?)
          ?.map((e) => OrderLineData.fromJson(e))
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentData.fromJson(e))
          .toList(),
      incompleteReason: json['incomplete_reason'],
      incompleteNotes: json['incomplete_notes'],
    );
  }

  RouteLineData copyWith({
    int? id,
    PartnerInfo? partnerId,
    String? street,
    String? city,
    double? latitude,
    double? longitude,
    int? sequence,
    String? notes,
    String? obra,
    String? priority,
    String? state,
    String? scheduledTime,
    String? startTime,
    String? pickupTime,
    String? endTime,
    String? orderType,
    String? orderName,
    List<OrderLineData>? orderLines,
    List<AttachmentData>? attachments,
    String? incompleteReason,
    String? incompleteNotes,
  }) {
    return RouteLineData(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      street: street ?? this.street,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
      notes: notes ?? this.notes,
      obra: obra ?? this.obra,
      priority: priority ?? this.priority,
      state: state ?? this.state,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      pickupTime: pickupTime ?? this.pickupTime,
      endTime: endTime ?? this.endTime,
      orderType: orderType ?? this.orderType,
      orderName: orderName ?? this.orderName,
      orderLines: orderLines ?? this.orderLines,
      attachments: attachments ?? this.attachments,
      incompleteReason: incompleteReason ?? this.incompleteReason,
      incompleteNotes: incompleteNotes ?? this.incompleteNotes,
    );
  }
}

class PartnerInfo {
  final int id;
  final String name;

  PartnerInfo({required this.id, this.name = ''});

  factory PartnerInfo.fromJson(Map<String, dynamic> json) {
    return PartnerInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class OrderLineData {
  final String productName;
  final double quantity;
  final String uom;
  final double priceUnit;

  OrderLineData({
    this.productName = '',
    this.quantity = 0,
    this.uom = '',
    this.priceUnit = 0,
  });

  factory OrderLineData.fromJson(Map<String, dynamic> json) {
    return OrderLineData(
      productName: json['product_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      uom: json['uom'] ?? '',
      priceUnit: (json['price_unit'] ?? 0).toDouble(),
    );
  }
}

// Attachments
class AttachmentData {
  final int id;
  final String name;
  final String? filename;
  final String? mimetype;
  final int? fileSize;
  final String? createDate;
  final String? downloadUrl;

  AttachmentData({
    required this.id,
    this.name = '',
    this.filename,
    this.mimetype,
    this.fileSize,
    this.createDate,
    this.downloadUrl,
  });

  factory AttachmentData.fromJson(Map<String, dynamic> json) {
    return AttachmentData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      filename: json['filename'],
      mimetype: json['mimetype'],
      fileSize: json['file_size'],
      createDate: json['create_date'],
      downloadUrl: json['download_url'],
    );
  }

  bool isImage() => mimetype?.startsWith('image/') == true;
  bool isPdf() => mimetype == 'application/pdf';
  bool isDocument() {
    const docMimes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'text/plain',
    ];
    return docMimes.contains(mimetype);
  }

  String formattedFileSize() {
    final size = fileSize ?? 0;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${size ~/ 1024} KB';
    return '${(size / (1024.0 * 1024.0)).toStringAsFixed(1)} MB';
  }

  String getExtension() => name.split('.').last.toUpperCase();
}

class LineAttachmentsResponse {
  final bool success;
  final String? message;
  final LineAttachmentsData? data;

  LineAttachmentsResponse({required this.success, this.message, this.data});

  factory LineAttachmentsResponse.fromJson(Map<String, dynamic> json) {
    return LineAttachmentsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? LineAttachmentsData.fromJson(json['data']) : null,
    );
  }
}

class LineAttachmentsData {
  final int lineId;
  final List<AttachmentData> attachments;
  final int count;

  LineAttachmentsData({
    required this.lineId,
    this.attachments = const [],
    this.count = 0,
  });

  factory LineAttachmentsData.fromJson(Map<String, dynamic> json) {
    return LineAttachmentsData(
      lineId: json['line_id'] ?? 0,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentData.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

// Request/Response models
class UpdateStateRequest {
  final int lineId;
  final String state;
  final double? latitude;
  final double? longitude;
  final String? timestamp;

  UpdateStateRequest({
    required this.lineId,
    required this.state,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp,
  };
}

class IncompleteLineRequest {
  final int lineId;
  final String state;
  final String? reason;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? timestamp;

  IncompleteLineRequest({
    required this.lineId,
    required this.state,
    this.reason,
    this.notes,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'state': state,
    'reason': reason,
    'notes': notes,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp,
  };
}

class UpdateStateResponse {
  final bool success;
  final String? message;

  UpdateStateResponse({required this.success, this.message});

  factory UpdateStateResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStateResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.message, this.data});
}

class UploadImageRequest {
  final int lineId;
  final String image;
  final String filename;
  final String? notes;
  final String? timestamp;

  UploadImageRequest({
    required this.lineId,
    required this.image,
    this.filename = 'photo.jpg',
    this.notes,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'image': image,
    'filename': filename,
    'notes': notes,
    'timestamp': timestamp,
  };
}

class UploadImageResponse {
  final bool success;
  final String? message;
  final UploadImageData? data;

  UploadImageResponse({required this.success, this.message, this.data});

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? UploadImageData.fromJson(json['data']) : null,
    );
  }
}

class UploadImageData {
  final int lineId;
  final String filename;
  final String? timestamp;

  UploadImageData({required this.lineId, this.filename = '', this.timestamp});

  factory UploadImageData.fromJson(Map<String, dynamic> json) {
    return UploadImageData(
      lineId: json['line_id'] ?? 0,
      filename: json['filename'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}

// Driver Stats
class DriverStatsResponse {
  final bool success;
  final String? message;
  final DriverStatsData? data;

  DriverStatsResponse({required this.success, this.message, this.data});

  factory DriverStatsResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? DriverStatsData.fromJson(json['data']) : null,
    );
  }
}

class DriverStatsData {
  final DriverProfile driver;
  final String period;
  final StatsSummary summary;
  final PerformanceStats performance;
  final TodayStats today;

  DriverStatsData({
    required this.driver,
    this.period = 'today',
    required this.summary,
    required this.performance,
    required this.today,
  });

  factory DriverStatsData.fromJson(Map<String, dynamic> json) {
    return DriverStatsData(
      driver: DriverProfile.fromJson(json['driver'] ?? {}),
      period: json['period'] ?? 'today',
      summary: StatsSummary.fromJson(json['summary'] ?? {}),
      performance: PerformanceStats.fromJson(json['performance'] ?? {}),
      today: TodayStats.fromJson(json['today'] ?? {}),
    );
  }
}

class DriverProfile {
  final int id;
  final String name;
  final String? image;

  DriverProfile({required this.id, this.name = '', this.image});

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
    );
  }
}

class StatsSummary {
  final int totalRoutes;
  final int completedRoutes;
  final int inProgressRoutes;
  final int pendingRoutes;
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final int inProgressDeliveries;
  final double completionRate;

  StatsSummary({
    this.totalRoutes = 0,
    this.completedRoutes = 0,
    this.inProgressRoutes = 0,
    this.pendingRoutes = 0,
    this.totalDeliveries = 0,
    this.completedDeliveries = 0,
    this.pendingDeliveries = 0,
    this.inProgressDeliveries = 0,
    this.completionRate = 0,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    return StatsSummary(
      totalRoutes: json['total_routes'] ?? 0,
      completedRoutes: json['completed_routes'] ?? 0,
      inProgressRoutes: json['in_progress_routes'] ?? 0,
      pendingRoutes: json['pending_routes'] ?? 0,
      totalDeliveries: json['total_deliveries'] ?? 0,
      completedDeliveries: json['completed_deliveries'] ?? 0,
      pendingDeliveries: json['pending_deliveries'] ?? 0,
      inProgressDeliveries: json['in_progress_deliveries'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
    );
  }
}

class PerformanceStats {
  final double avgDeliveryTimeMinutes;
  final double avgRouteTimeMinutes;
  final String avgDeliveryTimeFormatted;
  final String avgRouteTimeFormatted;

  PerformanceStats({
    this.avgDeliveryTimeMinutes = 0,
    this.avgRouteTimeMinutes = 0,
    this.avgDeliveryTimeFormatted = '',
    this.avgRouteTimeFormatted = '',
  });

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      avgDeliveryTimeMinutes: (json['avg_delivery_time_minutes'] ?? 0).toDouble(),
      avgRouteTimeMinutes: (json['avg_route_time_minutes'] ?? 0).toDouble(),
      avgDeliveryTimeFormatted: json['avg_delivery_time_formatted'] ?? '',
      avgRouteTimeFormatted: json['avg_route_time_formatted'] ?? '',
    );
  }
}

class TodayStats {
  final int total;
  final int completed;
  final int pending;
  final int inProgress;

  TodayStats({
    this.total = 0,
    this.completed = 0,
    this.pending = 0,
    this.inProgress = 0,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      pending: json['pending'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
    );
  }
}

// Routes History
class RoutesHistoryResponse {
  final bool success;
  final String? message;
  final List<RouteHistoryItem>? data;
  final PaginationInfo? pagination;

  RoutesHistoryResponse({required this.success, this.message, this.data, this.pagination});

  factory RoutesHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RoutesHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RouteHistoryItem.fromJson(e))
          .toList(),
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
    );
  }
}

class RouteHistoryItem {
  final int id;
  final String name;
  final String date;
  final String? startDate;
  final String? endDate;
  final double durationMinutes;
  final String durationFormatted;
  final int totalDeliveries;
  final int completedDeliveries;
  final List<RouteLineData>? lines;

  RouteHistoryItem({
    required this.id,
    this.name = '',
    this.date = '',
    this.startDate,
    this.endDate,
    this.durationMinutes = 0,
    this.durationFormatted = '',
    this.totalDeliveries = 0,
    this.completedDeliveries = 0,
    this.lines,
  });

  factory RouteHistoryItem.fromJson(Map<String, dynamic> json) {
    return RouteHistoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      durationMinutes: (json['duration_minutes'] ?? 0).toDouble(),
      durationFormatted: json['duration_formatted'] ?? '',
      totalDeliveries: json['total_deliveries'] ?? 0,
      completedDeliveries: json['completed_deliveries'] ?? 0,
      lines: (json['lines'] as List<dynamic>?)
          ?.map((e) => RouteLineData.fromJson(e))
          .toList(),
    );
  }

  RouteHistoryItem copyWith({
    int? id,
    String? name,
    String? date,
    String? startDate,
    String? endDate,
    double? durationMinutes,
    String? durationFormatted,
    int? totalDeliveries,
    int? completedDeliveries,
    List<RouteLineData>? lines,
  }) {
    return RouteHistoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationFormatted: durationFormatted ?? this.durationFormatted,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      lines: lines ?? this.lines,
    );
  }
}

/// Response from `api/routes/history/{id}/lines`
class RouteHistoryLinesResponse {
  final bool success;
  final String? message;
  final List<RouteLineData>? lines;

  RouteHistoryLinesResponse({required this.success, this.message, this.lines});

  factory RouteHistoryLinesResponse.fromJson(Map<String, dynamic> json) {
    return RouteHistoryLinesResponse(
      success: json['success'] ?? false,
      message: json['message'],
      lines: (json['data']?['lines'] as List<dynamic>?)
          ?.map((e) => RouteLineData.fromJson(e))
          .toList(),
    );
  }
}

class PaginationInfo {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  PaginationInfo({
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
    this.hasMore = false,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 0,
      offset: json['offset'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}

// Check new routes
class CheckNewRoutesResponse {
  final bool success;
  final String? message;
  final CheckNewRoutesData? data;

  CheckNewRoutesResponse({required this.success, this.message, this.data});

  factory CheckNewRoutesResponse.fromJson(Map<String, dynamic> json) {
    return CheckNewRoutesResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? CheckNewRoutesData.fromJson(json['data']) : null,
    );
  }
}

class CheckNewRoutesData {
  final bool hasNew;
  final int newCount;
  final int totalPending;
  final List<String> routeNames;
  final String? checkedAt;

  CheckNewRoutesData({
    this.hasNew = false,
    this.newCount = 0,
    this.totalPending = 0,
    this.routeNames = const [],
    this.checkedAt,
  });

  factory CheckNewRoutesData.fromJson(Map<String, dynamic> json) {
    return CheckNewRoutesData(
      hasNew: json['has_new'] ?? false,
      newCount: json['new_count'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      routeNames: (json['route_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      checkedAt: json['checked_at'],
    );
  }
}

class LocalStats {
  final int totalRoutes;
  final int completedRoutes;
  final int inProgressRoutes;
  final int pendingRoutes;
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final int inProgressDeliveries;
  final double completionRate;
  final int avgDeliveryTimeMinutes;
  final int avgRouteTimeMinutes;
  final String avgDeliveryTimeFormatted;
  final String avgRouteTimeFormatted;

  LocalStats({
    this.totalRoutes = 0,
    this.completedRoutes = 0,
    this.inProgressRoutes = 0,
    this.pendingRoutes = 0,
    this.totalDeliveries = 0,
    this.completedDeliveries = 0,
    this.pendingDeliveries = 0,
    this.inProgressDeliveries = 0,
    this.completionRate = 0,
    this.avgDeliveryTimeMinutes = 0,
    this.avgRouteTimeMinutes = 0,
    this.avgDeliveryTimeFormatted = '--',
    this.avgRouteTimeFormatted = '--',
  });
}