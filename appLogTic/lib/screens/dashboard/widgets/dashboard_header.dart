import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/theme_toggle_button.dart';

/// Header del dashboard con gradiente, perfil y acciones
class DashboardHeader extends StatelessWidget {
  final String userName;
  final String? driverImage;
  final bool isAdmin;
  final VoidCallback onLogout;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.driverImage,
    this.isAdmin = false,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.corpGreen,
            AppColors.corpDarkGray,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: AnimatedThemeToggle(),
                      ),
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout, color: AppColors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Card(
                elevation: 8,
                shadowColor: AppColors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _buildProfileImage(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Conductor Activo',
                              style: TextStyle(fontSize: 11, color: AppColors.gray500, letterSpacing: 0.8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.gray900),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.statusCompleted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'En servicio',
                                  style: TextStyle(fontSize: 12, color: AppColors.statusCompleted, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.gray300),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (driverImage != null) {
      try {
        final bytes = base64Decode(driverImage!);
        return ClipOval(
          child: Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _defaultIcon(),
          ),
        );
      } catch (_) {
        return _defaultIcon();
      }
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() => const Icon(Icons.person, color: AppColors.white, size: 32);
}