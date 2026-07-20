import 'package:flutter/foundation.dart';
import '../models/odoo_models.dart';
import '../models/route.dart';
import '../services/api/retrofit_client.dart';
import '../services/route_cache_service.dart';

class OdooProvider extends ChangeNotifier {
  final RetrofitClient _client = RetrofitClient();

  bool _isConnected = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastSyncTime = '';
  String _debugInfo = '';

  List<RouteData> _odooRoutes = [];
  bool _isUploadingImage = false;
  String _uploadImageError = '';
  bool _uploadImageSuccess = false;

  DriverStatsData? _driverStats;
  bool _isLoadingStats = false;
  String _statsError = '';

  List<RouteHistoryItem> _routesHistory = [];
  bool _isLoadingHistory = false;

  /// IDs of history routes currently fetching their lines
  final Set<int> _loadingHistoryLineIds = {};

  bool _isDownloadingAttachment = false;
  String _downloadError = '';

  /// Cached attachment contents by attachment ID (base64 data)
  final Map<int, AttachmentData> _attachmentCache = {};

  // Getters
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get lastSyncTime => _lastSyncTime;
  String get debugInfo => _debugInfo;
  List<RouteData> get odooRoutes => _odooRoutes;

  /// Whether the current data was loaded from the local cache (offline mode).
  bool get isShowingCachedData => !_isConnected && _lastSyncTime == '📦 Offline' && _odooRoutes.isNotEmpty;
  bool get isUploadingImage => _isUploadingImage;
  String get uploadImageError => _uploadImageError;
  bool get uploadImageSuccess => _uploadImageSuccess;
  DriverStatsData? get driverStats => _driverStats;
  bool get isLoadingStats => _isLoadingStats;
  String get statsError => _statsError;
  List<RouteHistoryItem> get routesHistory => _routesHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  bool isHistoryLineLoading(int routeId) => _loadingHistoryLineIds.contains(routeId);
  bool get isDownloadingAttachment => _isDownloadingAttachment;
  String get downloadError => _downloadError;
  AttachmentData? getCachedAttachment(int id) => _attachmentCache[id];

  /// Shared helper: convert a `List<RouteData>` (from API or cache) into
  /// `List<RouteModel>` for the UI layer.
  List<RouteModel> _buildRouteModels(List<RouteData> routes) {
    final result = <RouteModel>[];
    for (final routeData in routes) {
      for (final line in routeData.routeLines) {
        result.add(RouteModel(
          id: line.id,
          clientName: line.partnerId.name,
          address: line.street ?? '',
          city: line.city ?? '',
          scheduledTime: line.scheduledTime ?? '${line.sequence}° Parada',
          status: _parseStatus(line.state),
          latitude: line.latitude ?? 0.0,
          longitude: line.longitude ?? 0.0,
          description: line.notes ?? '',
          startTime: line.startTime,
          endTime: line.endTime,
          assignedDriver: routeData.driverId?.name ?? '',
          odooRouteId: routeData.id,
          odooLineId: line.id,
          sequence: line.sequence,
        ));
      }
    }
    return result;
  }

  Future<List<RouteModel>> syncRoutesFromOdoo(int? driverId, {bool silent = false}) async {
    debugPrint('=== ${silent ? "BACKGROUND" : "MANUAL"} SINCRONIZACIÓN ===');
    debugPrint('Driver ID: $driverId');

    if (driverId == null || driverId <= 0) {
      _errorMessage = 'Usuario sin conductor asignado (driver_id: $driverId)';
      _isConnected = false;
      if (!silent) _isLoading = false;
      notifyListeners();
      return [];
    }

    if (!silent) {
      _isLoading = true;
      _errorMessage = '';
      _debugInfo = 'Enviando request...';
      notifyListeners();
    }

    try {
      final routeDataList = await _client.syncTodayRoutes(driver: driverId.toString());
      debugPrint('Rutas recibidas: ${routeDataList.length}');

      _odooRoutes = routeDataList;
      _errorMessage = '';
      _isConnected = true;

      final sortedRouteDataList = <RouteData>[];
      for (final routeData in routeDataList) {
        final sortedLines = List<RouteLineData>.from(routeData.routeLines);
        sortedLines.sort((a, b) => a.sequence.compareTo(b.sequence));
        sortedRouteDataList.add(routeData.copyWith(routeLines: sortedLines));
      }
      
      // Cache the fresh data locally for offline access
      await RouteCacheService.instance.cacheRoutes(driverId, sortedRouteDataList);

      final routes = _buildRouteModels(sortedRouteDataList);
      _lastSyncTime = DateTime.now().toString().substring(11, 19);
      _isLoading = false;
      _debugInfo = '✅ ${routes.length} rutas cargadas';
      notifyListeners();

      return routes;
    } catch (e) {
      debugPrint('❌ Sync failed, trying cache: $e');
      _isConnected = false;

      // Attempt to load from local cache
      final cachedRoutes = await RouteCacheService.instance.getCachedRoutes(driverId);
      if (cachedRoutes.isNotEmpty) {
        _odooRoutes = cachedRoutes;
        final routes = _buildRouteModels(cachedRoutes);

        _lastSyncTime = '📦 Offline';
        _isLoading = false;
        _errorMessage = '';
        _debugInfo = '📦 ${routes.length} rutas desde caché offline';
        notifyListeners();

        routes.sort((a, b) => a.sequence.compareTo(b.sequence));
        return routes;
      }

      // No cache available either
      _errorMessage = 'Sin conexión y sin datos en caché';
      _isLoading = false;
      _debugInfo = '❌ ERROR: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  RouteStatus _parseStatus(String state) {
    switch (state) {
      case 'done':
        return RouteStatus.completed;
      case 'in_progress':
      case 'picked_up':
        return RouteStatus.inProgress;
      default:
        return RouteStatus.pending;
    }
  }

  void notifyLineStarted(int lineId, double? latitude, double? longitude) {
    _performAction(() async {
      final timestamp = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
      final request = UpdateStateRequest(
        lineId: lineId,
        state: 'in_progress',
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );
      final response = await _client.startRouteLine(request);
      if (response.success) {
        _updateLineStateLocally(lineId, 'in_progress', timestamp);
      }
      return response.success;
    }, 'iniciando línea');
  }

  void notifyLinePickedUp(int lineId, double? latitude, double? longitude) {
    _performAction(() async {
      final timestamp = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
      final request = UpdateStateRequest(
        lineId: lineId,
        state: 'picked_up',
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );
      final response = await _client.pickupRouteLine(request);
      if (response.success) {
        _updateLineStateLocally(lineId, 'picked_up', timestamp, isPickup: true);
      }
      return response.success;
    }, 'marcando recogida');
  }

  void notifyLineCompleted(int lineId, double? latitude, double? longitude) {
    _performAction(() async {
      final timestamp = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
      final request = UpdateStateRequest(
        lineId: lineId,
        state: 'done',
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );
      final response = await _client.completeRouteLine(request);
      if (response.success) {
        _updateLineStateLocally(lineId, 'done', timestamp);
      }
      return response.success;
    }, 'completando línea');
  }

  void notifyLineIncomplete(
    int lineId,
    String incompleteState,
    String reason,
    String notes, {
    double? latitude,
    double? longitude,
  }) {
    _performAction(() async {
      final timestamp = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
      final request = IncompleteLineRequest(
        lineId: lineId,
        state: incompleteState,
        reason: reason,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );
      final response = await _client.markLineIncomplete(request);
      if (response.success) {
        _updateLineStateLocally(lineId, incompleteState, timestamp,
            incompleteReason: reason, incompleteNotes: notes);
      }
      return response.success;
    }, 'marcando línea incompleta');
  }

  void _performAction(Future<bool> Function() action, String description) async {
    try {
      debugPrint('$description...');
      await action();
    } catch (e) {
      debugPrint('Error $description: $e');
    }
  }

  void _updateLineStateLocally(
    int lineId,
    String newState,
    String timestamp, {
    bool isPickup = false,
    String? incompleteReason,
    String? incompleteNotes,
  }) {
    final updatedRoutes = _odooRoutes.map((route) {
      var routeUpdated = false;
      final updatedLines = route.routeLines.map((line) {
        if (line.id == lineId) {
          routeUpdated = true;
          switch (newState) {
            case 'in_progress':
              return line.copyWith(state: newState, startTime: timestamp);
            case 'picked_up':
              return line.copyWith(state: newState, pickupTime: timestamp);
            case 'done':
              return line.copyWith(state: newState, endTime: timestamp);
            case 'incomplete':
            case 'partial':
              return line.copyWith(
                state: newState,
                endTime: timestamp,
                incompleteReason: incompleteReason,
                incompleteNotes: incompleteNotes,
              );
            default:
              return line.copyWith(state: newState);
          }
        }
        return line;
      }).toList();

      if (routeUpdated) {
        switch (newState) {
          case 'in_progress':
            final hasOtherStarted = updatedLines.any((l) => l.id != lineId && l.state == 'in_progress');
            if (!hasOtherStarted && (route.startDate == null || route.startDate!.isEmpty)) {
              return route.copyWith(routeLines: updatedLines, startDate: timestamp, state: 'started');
            }
            return route.copyWith(routeLines: updatedLines, state: 'started');
          case 'done':
          case 'incomplete':
          case 'partial':
            final allDone = updatedLines.every((l) => l.state == 'done' || l.state == 'cancelled' || l.state == 'incomplete' || l.state == 'partial');
            if (allDone) {
              return route.copyWith(routeLines: updatedLines, endDate: timestamp, state: 'finished');
            }
            return route.copyWith(routeLines: updatedLines);
          default:
            return route.copyWith(routeLines: updatedLines);
        }
      }
      return route.copyWith(routeLines: updatedLines);
    }).toList();

    _odooRoutes = updatedRoutes;
    notifyListeners();
  }

  void completeLineWithImage({
    required int lineId,
    required String imageBase64,
    double? latitude,
    double? longitude,
    String? notes,
    required Function(bool success) onComplete,
  }) async {
    try {
      _isUploadingImage = true;
      _uploadImageError = '';
      _uploadImageSuccess = false;
      notifyListeners();

      final timestamp = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' ');
      final filename = 'delivery_${lineId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload image first
      final uploadRequest = UploadImageRequest(
        lineId: lineId,
        image: imageBase64,
        filename: filename,
        notes: notes,
        timestamp: timestamp,
      );

      final uploadResponse = await _client.uploadLineImage(uploadRequest);
      if (!uploadResponse.success) {
        _uploadImageError = uploadResponse.message ?? 'Error al subir imagen';
        _isUploadingImage = false;
        notifyListeners();
        onComplete(false);
        return;
      }

      // Then complete the line
      final completeRequest = UpdateStateRequest(
        lineId: lineId,
        state: 'done',
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
      );

      final completeResponse = await _client.completeRouteLine(completeRequest);
      if (completeResponse.success) {
        _updateLineStateLocally(lineId, 'done', timestamp);
        _uploadImageSuccess = true;
        _isUploadingImage = false;
        notifyListeners();
        onComplete(true);
      } else {
        _uploadImageError = 'Imagen subida pero error al completar línea';
        _isUploadingImage = false;
        notifyListeners();
        onComplete(false);
      }
    } catch (e) {
      _uploadImageError = e.toString();
      _isUploadingImage = false;
      notifyListeners();
      onComplete(false);
    }
  }

  void clearUploadState() {
    _uploadImageError = '';
    _uploadImageSuccess = false;
    _isUploadingImage = false;
    notifyListeners();
  }

  Future<void> fetchDriverStats(int driverId, {String period = 'today'}) async {
    try {
      _isLoadingStats = true;
      _statsError = '';
      notifyListeners();

      final response = await _client.getDriverStats(driverId.toString(), period: period);
      if (response.success) {
        _driverStats = response.data;
      } else {
        _statsError = response.message ?? 'Error obteniendo estadísticas';
      }
    } catch (e) {
      _statsError = e.toString();
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoutesHistory(int driverId, {int limit = 20, int offset = 0}) async {
    try {
      _isLoadingHistory = true;
      notifyListeners();

      final response = await _client.getRoutesHistory(driverId.toString(), limit: limit, offset: offset);
      if (response.success && response.data != null) {
        _routesHistory = response.data!;
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Fetches route lines for a specific history route and updates the item in place.
  Future<void> fetchHistoryRouteLines(int routeId) async {
    if (_loadingHistoryLineIds.contains(routeId)) return;
    try {
      _loadingHistoryLineIds.add(routeId);
      notifyListeners();

      final response = await _client.getRouteHistoryLines(routeId);
      if (response.success) {
        final index = _routesHistory.indexWhere((item) => item.id == routeId);
        if (index >= 0) {
          // Always update after fetch — even an empty list prevents re-fetching
          _routesHistory[index] = _routesHistory[index].copyWith(lines: response.lines ?? []);
        }
      }
    } catch (e) {
      debugPrint('Error fetching history lines for route $routeId: $e');
    } finally {
      _loadingHistoryLineIds.remove(routeId);
      notifyListeners();
    }
  }

  void clearAttachmentCache() {
    _attachmentCache.clear();
    notifyListeners();
  }

  LocalStats getLocalStats() {
    return LocalStats(); // Simplified - will calculate in UI
  }

  void fetchAttachmentContent(
    int attachmentId, {
    required Function(AttachmentData data) onSuccess,
    required Function(String error) onError,
  }) async {
    if (_attachmentCache.containsKey(attachmentId)) {
      onSuccess(_attachmentCache[attachmentId]!);
      return;
    }
    try {
      _isDownloadingAttachment = true;
      _downloadError = '';
      notifyListeners();

      final attachment = await _client.getAttachmentContent(attachmentId);
      if (attachment != null) {
        _attachmentCache[attachmentId] = attachment;
        _isDownloadingAttachment = false;
        notifyListeners();
        onSuccess(attachment);
      } else {
        _downloadError = 'Attachment not found';
        _isDownloadingAttachment = false;
        onError('Attachment not found');
        notifyListeners();
      }
    } catch (e) {
      _downloadError = e.toString();
      _isDownloadingAttachment = false;
      onError(e.toString());
      notifyListeners();
    }
  }
}