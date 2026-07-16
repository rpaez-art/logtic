import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles displaying FCM push notifications as local system notifications
/// when the app is in foreground (since FCM doesn't show system alerts in foreground).
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._();
  static LocalNotificationService get instance => _instance;
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Callback invoked when the user taps on a notification.
  /// The [payload] is a JSON-encoded Map containing route info.
  void Function(Map<String, dynamic> payload)? onNotificationTap;

  bool _initialized = false;

  /// Initialize the plugin and create notification channels.
  Future<void> init() async {
    if (_initialized) return;

    // Android initialization (default icon from AndroidManifest)
    const androidSettings = AndroidInitializationSettings('@drawable/app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the notification channel for Android 8+
    await _createNotificationChannel();

    _initialized = true;
  }

  /// Create the primary notification channel.
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      'logtic_push_channel',
      'Notificaciones LogTic',
      description: 'Notificaciones de rutas y entregas',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// Called when the user taps on a local notification.
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      onNotificationTap?.call(data);
    } catch (_) {
      // Invalid payload - ignore
    }
  }

  /// Show a local notification for an FCM message received in foreground.
  ///
  /// [id] should be unique per notification (use messageId hash or timestamp).
  /// [title], [body] come from the FCM RemoteMessage.
  /// [data] is the FCM data payload (contains 'route' key for deep links).
  Future<void> showFcmNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // Encode relevant data as payload for tap handling
    final payloadData = <String, dynamic>{
      'route': data['route'],
      'title': title,
      'body': body,
    };
    final payload = jsonEncode(payloadData);

    // Android notification details with the custom channel
    const androidDetails = AndroidNotificationDetails(
      'logtic_push_channel',
      'Notificaciones LogTic',
      channelDescription: 'Notificaciones de rutas y entregas',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/app_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Cancel a specific notification by ID.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Generate a stable notification ID from a string (e.g. messageId).
  static int generateId(String messageId) {
    return messageId.hashCode & 0x7FFFFFFF; // ensure positive
  }
}
