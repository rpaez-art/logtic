import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/config/theme.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'package:logtic/screens/config/odoo_config_screen.dart';
import 'package:logtic/services/log_service.dart';
import 'package:logtic/screens/tools/log_viewer_screen.dart';
import 'step/bdd_steps.dart';

void main() {
  group('Configuración Odoo API', () {
    testWidgets('Ver la pantalla de configuración Odoo', (tester) async {
      // Given quiero configurar la API de Odoo
      // When veo la pantalla de configuración
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => OdooConfigScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Configuración Odoo API"
      await BddSteps.veoElTexto(tester, 'Configuración Odoo API');
      // And veo el texto "🌐 Servidor Odoo"
      await BddSteps.veoElTexto(tester, '🌐 Servidor Odoo');
      // And veo el campo de base de datos
      await BddSteps.veoElCampo(tester, 'Base de Datos');
    });

    testWidgets('Ver los campos de credenciales de Odoo', (tester) async {
      // Given quiero acceder a mis rutas
      // When veo la pantalla de configuración
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => OdooConfigScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Usuario Odoo"
      await BddSteps.veoElTexto(tester, 'Usuario Odoo');
      // And veo el texto "Contraseña Odoo"
      await BddSteps.veoElTexto(tester, 'Contraseña Odoo');
      // And veo el texto "Guardar y Probar Conexión"
      await BddSteps.veoElTexto(tester, 'Guardar y Probar Conexión');
    });
  });

  group('Registro de Logs', () {
    testWidgets('Ver el visor de logs con estado vacío', (tester) async {
      // Given no hay logs registrados
      LogService.instance.clear();
      // When veo la pantalla de logs
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogViewerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Registro de Logs"
      await BddSteps.veoElTexto(tester, 'Registro de Logs');
      // And veo el texto "Sin registros"
      await BddSteps.veoElTexto(tester, 'Sin registros');
      // And veo el texto "Exportar"
      await BddSteps.veoElTexto(tester, 'Exportar');
    });

    testWidgets('Ver los filtros de nivel de log', (tester) async {
      // Given tengo varios niveles de log
      LogService.instance.clear();
      // When veo la pantalla de logs
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogViewerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "DEBUG"
      await BddSteps.veoElTexto(tester, 'DEBUG');
      // And veo el texto "INFO"
      await BddSteps.veoElTexto(tester, 'INFO');
      // And veo el texto "WARN"
      await BddSteps.veoElTexto(tester, 'WARN');
      // And veo el texto "ERROR"
      await BddSteps.veoElTexto(tester, 'ERROR');
    });
  });
}