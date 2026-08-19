import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import 'connection_status_dialog.dart';

/// Dropdown menu with a settings gear icon located in the top-right corner of main headers.
/// Provides access to:
/// - Connection & FCM Notification diagnostics dialog
/// - System logs viewer
/// - Admin Odoo configuration (for admin users)
/// - Logout action
class SettingsDropdownMenu extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback onLogout;
  final Color iconColor;
  final Color backgroundColor;

  const SettingsDropdownMenu({
    super.key,
    required this.isAdmin,
    required this.onLogout,
    this.iconColor = AppColors.white,
    this.backgroundColor = const Color(0x26FFFFFF), // white with 15% opacity
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.corpDarkGray : AppColors.gray200,
            ),
          ),
          elevation: 8,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Ajustes y Diagnóstico',
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.settings_outlined,
            color: iconColor,
            size: 20,
          ),
        ),
        offset: const Offset(0, 48),
        onSelected: (value) {
          switch (value) {
            case 'check_connections':
              ConnectionStatusDialog.show(context);
              break;
            case 'view_logs':
              context.push('/tools/logs');
              break;
            case 'admin_config':
              context.push('/admin/config');
              break;
            case 'logout':
              onLogout();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'check_connections',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sensors_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Verificar Conexiones',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      Text(
                        'Servidor y FCM push',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.gray400 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'view_logs',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ver Logs del Sistema',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.white : AppColors.gray800,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            PopupMenuItem<String>(
              value: 'admin_config',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.corpGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.corpGold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Configuración Odoo',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.gray800,
                    ),
                  ),
                ],
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
