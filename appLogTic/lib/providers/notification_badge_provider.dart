import 'package:flutter/foundation.dart';

/// Tracks the count of unread push notifications for the badge indicator
/// on the BottomNavigationBar.
class NotificationBadgeProvider extends ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  /// Increment the unread badge when a new FCM notification arrives.
  void increment() {
    _unreadCount++;
    notifyListeners();
  }

  /// Reset the badge to zero — call when user opens the notifications screen
  /// or taps a notification.
  void markAllAsRead() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }

  /// Decrement by one (e.g. when user taps a single notification banner).
  void markOneAsRead() {
    if (_unreadCount <= 0) return;
    _unreadCount--;
    notifyListeners();
  }
}
