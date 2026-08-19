import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/theme_toggle_button.dart';
import '../../../widgets/settings_dropdown_menu.dart';

/// Encabezado de la pantalla de rutas
class RoutesHeader extends StatelessWidget {
  final String userName;
  final bool isAdmin;
  final String errorMessage;
  final bool isLoading;
  final VoidCallback onSync;
  final VoidCallback onLogout;
  final VoidCallback onMonitor;
  final VoidCallback onUsers;

  const RoutesHeader({
    super.key,
    required this.userName,
    required this.isAdmin,
    required this.errorMessage,
    required this.isLoading,
    required this.onSync,
    required this.onLogout,
    required this.onMonitor,
    required this.onUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mis Rutas',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 14, color: AppColors.white70),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(onPressed: onMonitor, icon: const Icon(Icons.visibility, color: AppColors.white)),
                  IconButton(onPressed: onUsers, icon: const Icon(Icons.supervisor_account, color: AppColors.white)),
                ] else
                  IconButton(
                    onPressed: isLoading ? null : onSync,
                    icon: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                        : const Icon(Icons.sync, color: AppColors.white),
                  ),
                const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: AnimatedThemeToggle(),
                ),
                SettingsDropdownMenu(
                  isAdmin: isAdmin,
                  onLogout: onLogout,
                ),
              ],
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.white),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(fontSize: 11, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}