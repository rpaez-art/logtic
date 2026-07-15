package com.example.logtic.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// ===========================================
// LOGTIC - Tema Material 3 Moderno con Gradientes
// ===========================================

private val LightColorScheme = lightColorScheme(
    // Colores principales - Verde corporativo
    primary = CorpGreen,
    onPrimary = LogticWhite,
    primaryContainer = CorpGreen.copy(alpha = 0.1f),
    onPrimaryContainer = CorpGreen,
    
    // Colores secundarios - Dorado
    secondary = CorpGold,
    onSecondary = LogticWhite,
    secondaryContainer = CorpGold.copy(alpha = 0.1f),
    onSecondaryContainer = CorpGold,
    
    // Colores terciarios (acento) - Azul grisáceo
    tertiary = CorpLightBlue,
    onTertiary = CorpDarkGray,
    tertiaryContainer = CorpLightBlue.copy(alpha = 0.2f),
    onTertiaryContainer = CorpDarkGray,
    
    // Superficies
    background = BackgroundLight,
    onBackground = CorpDarkGray,
    surface = SurfaceLight,
    onSurface = CorpDarkGray,
    surfaceVariant = SurfaceVariantLight,
    onSurfaceVariant = LogticMediumGray,
    
    // Contornos
    outline = LogticLightGray,
    outlineVariant = LogticLightGray.copy(alpha = 0.5f),
    
    // Estados de error
    error = LogticError,
    onError = LogticWhite,
    errorContainer = LogticError.copy(alpha = 0.1f),
    onErrorContainer = LogticError,
    
    // Inversiones
    inverseSurface = LogticDarkGray,
    inverseOnSurface = LogticWhite,
    inversePrimary = LogticOrangeLight,
    
    // Scrim
    scrim = LogticBlack.copy(alpha = 0.5f)
)

private val DarkColorScheme = darkColorScheme(
    // Colores principales
    primary = LogticOrangeLight,
    onPrimary = LogticDarkGray,
    primaryContainer = LogticOrange.copy(alpha = 0.3f),
    onPrimaryContainer = LogticOrangeLight,
    
    // Colores secundarios
    secondary = LogticPurpleLight,
    onSecondary = LogticDarkGray,
    secondaryContainer = LogticPurple.copy(alpha = 0.3f),
    onSecondaryContainer = LogticPurpleLight,
    
    // Colores terciarios (acento)
    tertiary = LogticGreenLight,
    onTertiary = LogticDarkGray,
    tertiaryContainer = LogticGreen.copy(alpha = 0.3f),
    onTertiaryContainer = LogticGreenLight,
    
    // Superficies
    background = BackgroundDark,
    onBackground = LogticWhite,
    surface = SurfaceDark,
    onSurface = LogticWhite,
    surfaceVariant = SurfaceVariantDark,
    onSurfaceVariant = LogticLightGray,
    
    // Contornos
    outline = LogticMediumGray,
    outlineVariant = LogticMediumGray.copy(alpha = 0.5f),
    
    // Estados de error
    error = LogticErrorLight,
    onError = LogticBlack,
    errorContainer = LogticError.copy(alpha = 0.3f),
    onErrorContainer = LogticErrorLight,
    
    // Inversiones
    inverseSurface = LogticWhite,
    inverseOnSurface = LogticDarkGray,
    inversePrimary = LogticOrange,
    
    // Scrim
    scrim = LogticBlack.copy(alpha = 0.7f)
)

@Composable
fun LogticTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Dynamic color is available on Android 12+
    dynamicColor: Boolean = false,  // Desactivado para usar nuestra paleta personalizada
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }
    
    // Actualizar barra de estado con color corporativo
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = CorpGreen.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}