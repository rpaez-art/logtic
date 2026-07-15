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
  static const Color statusIncomplete = Color(0xFFE67E22);
  static const Color statusCancelled = Color(0xFFB91C1C);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
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
    ),
    cardTheme: CardTheme(
      elevation: 2,
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
      surface: AppColors.corpDarkGray,
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.gray400,
      outline: AppColors.gray600,
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1C1D),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF2F3234),
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
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2F3234),
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
  );
}