import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/theme.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/odoo_provider.dart';
import '../providers/notification_badge_provider.dart';
import '../services/local_notification_service.dart';
import '../services/api/retrofit_client.dart';
import '../models/odoo_models.dart';

/// Modal dialog that comprehensively tests and displays:
/// 1. Odoo Server REST API connection & latency
/// 2. Firebase Cloud Messaging (FCM) push token & permission status
/// 3. Device notification channel & badge status
/// Includes a live action to send a local test notification.
class ConnectionStatusDialog extends StatefulWidget {
  const ConnectionStatusDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const ConnectionStatusDialog(),
    );
  }

  @override
  State<ConnectionStatusDialog> createState() => _ConnectionStatusDialogState();
}

enum CheckState { testing, success, warning, error }

class _ConnectionStatusDialogState extends State<ConnectionStatusDialog> {
  // Server Status
  CheckState _serverState = CheckState.testing;
  String _serverMessage = 'Comprobando conexión con el servidor...';
  int? _serverLatencyMs;

  // FCM Status
  CheckState _fcmState = CheckState.testing;
  String _fcmMessage = 'Obteniendo estado de Firebase...';
  String? _fcmToken;
  String _fcmPermission = 'Verificando permisos...';
  bool _fcmRegisteredInBackend = false;

  // Test Notification Status
  bool _isSendingTestNotification = false;
  String? _testNotificationFeedback;

  @override
  void initState() {
    super.initState();
    _runAllDiagnostics();
  }

  Future<void> _runAllDiagnostics() async {
    setState(() {
      _serverState = CheckState.testing;
      _serverMessage = 'Comprobando endpoint del servidor...';
      _serverLatencyMs = null;

      _fcmState = CheckState.testing;
      _fcmMessage = 'Verificando token y permisos FCM...';
      _fcmToken = null;
      _fcmRegisteredInBackend = false;
      _testNotificationFeedback = null;
    });

    await Future.wait([
      _checkServerConnection(),
      _checkFcmConnection(),
    ]);
  }

  Future<void> _checkServerConnection() async {
    final stopwatch = Stopwatch()..start();
    try {
      final client = RetrofitClient();
      final auth = context.read<AuthProvider>();
      final driverId = auth.currentUser?.driverId;

      if (driverId != null && driverId > 0) {
        final response = await client.checkNewRoutes(driverId.toString());
        stopwatch.stop();
        if (mounted) {
          setState(() {
            _serverLatencyMs = stopwatch.elapsedMilliseconds;
            if (response.success) {
              _serverState = CheckState.success;
              _serverMessage = 'Conectado al servidor Odoo (${stopwatch.elapsedMilliseconds} ms)';
            } else {
              _serverState = CheckState.warning;
              _serverMessage = response.message ?? 'Respuesta con advertencia del servidor';
            }
          });
        }
      } else {
        // Driver not available, test via routes sync or fallback ping
        await client.syncTodayRoutes();
        stopwatch.stop();
        if (mounted) {
          setState(() {
            _serverLatencyMs = stopwatch.elapsedMilliseconds;
            _serverState = CheckState.success;
            _serverMessage = 'Conectado al servidor Odoo (${stopwatch.elapsedMilliseconds} ms)';
          });
        }
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _serverLatencyMs = stopwatch.elapsedMilliseconds;
          _serverState = CheckState.error;
          _serverMessage = 'Error de conexión: ${e.toString().replaceAll('HttpException: ', '')}';
        });
      }
    }
  }

  Future<void> _checkFcmConnection() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();

      String permText = 'Desconocido';
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          permText = 'Autorizado (Permitido)';
          break;
        case AuthorizationStatus.provisional:
          permText = 'Provisional';
          break;
        case AuthorizationStatus.denied:
          permText = 'Denegado (Actívalos en Ajustes)';
          break;
        case AuthorizationStatus.notDetermined:
          permText = 'No determinado';
          break;
      }

      final token = await messaging.getToken();

      bool backendRegistered = false;
      if (token != null && mounted) {
        final auth = context.read<AuthProvider>();
        final driverId = auth.currentUser?.driverId;
        if (driverId != null && driverId > 0) {
          try {
            final client = RetrofitClient();
            await client.registerFcmToken(
              FcmTokenRequest(
                driverId: driverId,
                token: token,
                platform: Platform.isIOS ? 'ios' : 'android',
                username: auth.currentUser?.username,
              ),
            );
            backendRegistered = true;
          } catch (_) {
            backendRegistered = false;
          }
        }
      }

      if (mounted) {
        setState(() {
          _fcmPermission = permText;
          _fcmToken = token;
          _fcmRegisteredInBackend = backendRegistered;

          if (settings.authorizationStatus == AuthorizationStatus.denied) {
            _fcmState = CheckState.warning;
            _fcmMessage = 'Permisos de notificación bloqueados';
          } else if (token == null) {
            _fcmState = CheckState.error;
            _fcmMessage = 'No se pudo obtener el token de Firebase';
          } else {
            _fcmState = CheckState.success;
            _fcmMessage = 'FCM activo y sincronizado correctamente';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Error en servicio FCM: $e';
        final errStr = e.toString();
        if (errStr.contains('FCM Registration failed') || errStr.contains('SERVICE_NOT_AVAILABLE')) {
          msg = 'FCM requiere Google Play Services activo y conexión a internet en el dispositivo/emulador.';
        }
        setState(() {
          _fcmState = CheckState.error;
          _fcmMessage = msg;
        });
      }
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() {
      _isSendingTestNotification = true;
      _testNotificationFeedback = null;
    });

    try {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      await LocalNotificationService.instance.showFcmNotification(
        id: now.millisecondsSinceEpoch ~/ 1000,
        title: 'Prueba de Notificación LogTic',
        body: 'El canal de notificaciones y sonido funcionan correctamente ($timeStr).',
        data: {
          'type': 'test_notification',
          'route': '/routes',
        },
      );

      if (mounted) {
        setState(() {
          _isSendingTestNotification = false;
          _testNotificationFeedback = 'Notificación enviada al dispositivo.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingTestNotification = false;
          _testNotificationFeedback = 'Error al emitir notificación: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final odoo = context.watch<OdooProvider>();
    final badge = context.watch<NotificationBadgeProvider>();
    final user = auth.currentUser;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.greenTextColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sensors_rounded,
                        color: context.greenTextColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado de Conexiones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.primaryTextColor,
                            ),
                          ),
                          Text(
                            'Diagnóstico de Servidor y FCM',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: context.subtextColor,
                      ),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Overall Health Banner
                _buildOverallBanner(isDark),
                const SizedBox(height: 16),

                // Section 1: Servidor Odoo
                _buildSectionHeader(
                  icon: Icons.cloud_outlined,
                  title: 'Servidor Odoo',
                  state: _serverState,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildCard(
                  isDark: isDark,
                  children: [
                    if (_serverLatencyMs != null)
                      _buildInfoRow('Tiempo de Respuesta:', '$_serverLatencyMs ms', isDark, isHighlighted: true),
                    _buildInfoRow(
                      'Usuario en Sesión:',
                      user != null ? user.fullName : 'No autenticado',
                      isDark,
                    ),
                    _buildInfoRow('Última Sincronización:', odoo.lastSyncTime.isNotEmpty ? odoo.lastSyncTime : 'No realizada', isDark),
                    const SizedBox(height: 4),
                    _buildStatusMessage(_serverMessage, _serverState, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 2: Firebase Cloud Messaging
                _buildSectionHeader(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notificaciones Push',
                  state: _fcmState,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildCard(
                  isDark: isDark,
                  children: [
                    _buildInfoRow('Permisos en Dispositivo:', _fcmPermission, isDark),
                    _buildInfoRow(
                      'Recepción en Segundo Plano:',
                      _fcmToken != null ? 'Habilitado' : 'No disponible',
                      isDark,
                    ),
                    _buildInfoRow(
                      'Sincronización con Servidor:',
                      _fcmRegisteredInBackend ? 'Conectado' : (_fcmToken != null ? 'Listo' : 'Pendiente'),
                      isDark,
                    ),
                    const SizedBox(height: 4),
                    _buildStatusMessage(_fcmMessage, _fcmState, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 3: Sistema de Notificaciones Local y Segundo Plano
                _buildSectionHeader(
                  icon: Icons.tune_rounded,
                  title: 'Canal y Segundo Plano',
                  state: CheckState.success,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildCard(
                  isDark: isDark,
                  children: [
                    _buildInfoRow('Canal de Notificaciones:', 'Activo y prioritario', isDark),
                    _buildInfoRow('Sincronización en Segundo Plano:', 'Activa (cada 5 min)', isDark),
                    _buildInfoRow('Notificaciones Pendientes:', '${badge.unreadCount}', isDark),
                    if (_testNotificationFeedback != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _testNotificationFeedback!.contains('Error')
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14,
                            color: _testNotificationFeedback!.contains('Error')
                                ? AppColors.error
                                : (isDark ? AppColors.darkGreen : AppColors.statusCompleted),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _testNotificationFeedback!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _testNotificationFeedback!.contains('Error')
                                    ? AppColors.error
                                    : (isDark ? AppColors.darkGreen : AppColors.statusCompleted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _runAllDiagnostics,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reverificar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkGreen : AppColors.primary,
                          side: BorderSide(color: isDark ? AppColors.darkGreen : AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSendingTestNotification ? null : _sendTestNotification,
                        icon: _isSendingTestNotification
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? AppColors.black : AppColors.white),
                              )
                            : const Icon(Icons.notifications_active, size: 18),
                        label: const Text('Probar Push'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkGreen : AppColors.primary,
                          foregroundColor: isDark ? AppColors.black : AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallBanner(bool isDark) {
    final bool allOk = _serverState == CheckState.success && _fcmState == CheckState.success;
    final bool hasError = _serverState == CheckState.error || _fcmState == CheckState.error;
    final bool isTesting = _serverState == CheckState.testing || _fcmState == CheckState.testing;

    Color bg;
    Color fg;
    IconData icon;
    String text;

    if (isTesting) {
      bg = (isDark ? AppColors.darkGreen : AppColors.primary).withValues(alpha: 0.15);
      fg = isDark ? AppColors.darkGreen : AppColors.primary;
      icon = Icons.sync;
      text = 'Ejecutando diagnóstico en tiempo real...';
    } else if (allOk) {
      bg = (isDark ? AppColors.darkGreen : AppColors.statusCompleted).withValues(alpha: 0.15);
      fg = isDark ? AppColors.darkGreen : AppColors.statusCompleted;
      icon = Icons.check_circle_rounded;
      text = 'Todos los servicios conectados y operativos';
    } else if (hasError) {
      bg = AppColors.error.withValues(alpha: 0.15);
      fg = AppColors.error;
      icon = Icons.error_rounded;
      text = 'Se detectaron problemas en las conexiones';
    } else {
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      text = 'Conexión parcial / Permisos con advertencia';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required CheckState state,
    required bool isDark,
  }) {
    final greenCol = isDark ? AppColors.darkGreen : AppColors.primary;
    Widget stateWidget;
    switch (state) {
      case CheckState.testing:
        stateWidget = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: greenCol),
        );
        break;
      case CheckState.success:
        stateWidget = Icon(Icons.check_circle, color: isDark ? AppColors.darkGreen : AppColors.statusCompleted, size: 18);
        break;
      case CheckState.warning:
        stateWidget = const Icon(Icons.warning, color: AppColors.warning, size: 18);
        break;
      case CheckState.error:
        stateWidget = const Icon(Icons.cancel, color: AppColors.error, size: 18);
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: greenCol),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.gray800,
          ),
        ),
        const Spacer(),
        stateWidget,
      ],
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkMedium : AppColors.gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.corpDarkGray : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.gray600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted
                    ? (isDark ? AppColors.darkGreen : AppColors.primary)
                    : (isDark ? AppColors.white : AppColors.gray900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String message, CheckState state, bool isDark) {
    Color textColor;
    switch (state) {
      case CheckState.testing:
        textColor = isDark ? AppColors.darkTextMuted : AppColors.gray600;
        break;
      case CheckState.success:
        textColor = isDark ? AppColors.darkGreen : AppColors.statusCompleted;
        break;
      case CheckState.warning:
        textColor = AppColors.warning;
        break;
      case CheckState.error:
        textColor = AppColors.error;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
