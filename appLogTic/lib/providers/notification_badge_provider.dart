import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the count of unread push notifications for the badge indicator
/// on the BottomNavigationBar.
class NotificationBadgeProvider extends ChangeNotifier {
  static const String _prefsKey = 'unread_badge_count';

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  /// Carga el contador persistido al iniciar la app.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _unreadCount = prefs.getInt(_prefsKey) ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading badge count: $e');
    }
  }

  /// Increment the unread badge when a new FCM notification arrives.
  void increment() {
    _unreadCount++;
    _persist();
    notifyListeners();
  }

  /// Reset the badge to zero — call when user opens the notifications screen
  /// or taps a notification.
  void markAllAsRead() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    _persist();
    notifyListeners();
  }

  /// Decrement by one (e.g. when user taps a single notification banner).
  void markOneAsRead() {
    if (_unreadCount <= 0) return;
    _unreadCount--;
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, _unreadCount);
    } catch (e) {
      debugPrint('Error persisting badge count: $e');
    }
  }
}