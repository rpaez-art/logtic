import 'dart:async';
import 'package:flutter/foundation.dart';

/// Periodically syncs routes from Odoo in the background (every 5 minutes)
/// to keep the local cache up-to-date without disrupting the UI.
class BackgroundSyncService {
  static const Duration _interval = Duration(minutes: 5);

  Timer? _timer;
  bool _isRunning = false;

  /// Returns `true` while a sync tick is in progress.
  bool _isSyncing = false;

  /// Callback invoked on each tick. Receives the current [driverId].
  /// Should return the number of synced routes, or 0 on failure.
  final Future<int> Function(int driverId) onSync;

  /// Callback invoked each tick to check if the user is still logged in.
  /// Return `null` to skip / stop syncing.
  final int? Function() getDriverId;

  BackgroundSyncService({
    required this.onSync,
    required this.getDriverId,
  });

  bool get isRunning => _isRunning;

  /// Start the periodic timer. Safe to call multiple times.
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    debugPrint('🔄 BackgroundSyncService started (every $_interval)');

    // Trigger an immediate first sync, then periodic
    _tick();
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  /// Stop the timer. Safe to call multiple times.
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    debugPrint('🔄 BackgroundSyncService stopped');
  }

  Future<void> _tick() async {
    if (_isSyncing) return; // don't overlap ticks

    final driverId = getDriverId();
    if (driverId == null || driverId <= 0) {
      // User logged out → stop the service
      debugPrint('🔄 BackgroundSync: no driver, stopping…');
      stop();
      return;
    }

    _isSyncing = true;
    try {
      debugPrint('🔄 BackgroundSync: starting tick for driver $driverId');
      final count = await onSync(driverId);
      debugPrint('🔄 BackgroundSync: tick complete — $count routes synced');
    } catch (e) {
      debugPrint('🔄 BackgroundSync: tick error — $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Release all resources.
  void dispose() {
    stop();
  }
}
