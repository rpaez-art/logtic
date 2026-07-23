import 'package:flutter/material.dart';

class AppColors {
  // Corporativos Principales
  static const Color corpDarkGray = Color(0xFF25282A);
  static const Color corpGreen = Color(0xFF1D3C34);
  static const Color corpGold = Color(0xFFCBA052);
  static const Color corpLightBlue = Color(0xFFA2B2C8);

  // Gradientes
  static const Color gradientStart = Color(0xFFCBA052);
  static const Color gradientEnd = Color(0xFF1D3C34);

  // Primarios
  static const Color primary = Color(0xFF1D3C34);
  static const Color primaryDark = Color(0xFF152A25);
  static const Color primaryLight = Color(0xFF2A5246);

  // Secundarios (Dorado)
  static const Color secondary = Color(0xFFCBA052);
  static const Color secondaryLight = Color(0xFFD9B76A);
  static const Color secondaryDark = Color(0xFFB08A3E);

  // Acento
  static const Color accent = Color(0xFFA2B2C8);
  static const Color accentLight = Color(0xFFB8C5D6);
  static const Color accentDark = Color(0xFF8A9BB0);

  // Estados
  static const Color statusPending = Color(0xFFA2B2C8);
  static const Color statusInProgress = Color(0xFFCBA052);
  static const Color statusPickedUp = Color(0xFFD9B76A);
  static const Color statusCompleted = Color(0xFF1D3C34);
  static const Color statusCompletedLight = Color(0xFF2A7D5C);
  static const Color statusIncomplete = Color(0xFFE67E22);
  static const Color statusCancelled = Color(0xFFB91C1C);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color black = Color(0xFF25282A);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Error y Alerta
  static const Color error = Color(0xFFB91C1C);
  static const Color errorLight = Color(0xFFDC2626);
  static const Color warning = Color(0xFFCBA052);
  static const Color info = Color(0xFFA2B2C8);
  static const Color success = Color(0xFF1D3C34);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryLight.withValues(alpha: 0.2),
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondaryLight.withValues(alpha: 0.2),
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.white,
      onSurface: AppColors.corpDarkGray,
      onSurfaceVariant: AppColors.gray600,
      outline: AppColors.gray300,
    ),
    scaffoldBackgroundColor: AppColors.gray100,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.corpGreen,
      foregroundColor: AppColors.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      elevation: 8,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray500,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primary.withValues(alpha: 0.3),
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.3),
      tertiary: AppColors.accentLight,
      error: AppColors.errorLight,
      surface: const Color(0xFF25282A),
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.gray400,
      outline: AppColors.gray600,
    ),
    scaffoldBackgroundColor: const Color(0xFF141617),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF1D3C34),
      foregroundColor: AppColors.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF25282A),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF25282A),
      surfaceTintColor: Colors.transparent,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E2022),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF25282A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E2022),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF383C3E),
      thickness: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryLight,
      foregroundColor: AppColors.black,
      elevation: 8,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E2022),
      selectedItemColor: AppColors.secondaryLight,
      unselectedItemColor: AppColors.gray400,
    ),
  );
}

/// Extension helpers to easily query theme-aware colors in widgets
extension ThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get containerColor => isDarkMode ? const Color(0xFF1E2022) : AppColors.gray50;
  Color get borderColor => isDarkMode ? const Color(0xFF383C3E) : AppColors.gray200;
  Color get subtextColor => isDarkMode ? AppColors.gray400 : AppColors.gray600;
}