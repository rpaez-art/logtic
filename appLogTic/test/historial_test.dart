import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/screens/history/route_history_screen.dart';
import 'package:logtic/providers/auth_provider.dart';
import 'package:logtic/providers/odoo_provider.dart';
import 'package:logtic/providers/route_provider.dart';
import 'package:logtic/providers/driver_monitor_provider.dart';
import 'package:logtic/providers/user_management_provider.dart';
import 'package:logtic/providers/notification_badge_provider.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'helpers/firebase_test_helper.dart';
import 'step/bdd_steps.dart';

void main() {
  setUpAll(() async {
    await initFirebaseForTest();
  });

  group('Historial de Rutas', () {
    testWidgets('Ver el resumen general del historial', (tester) async {
      // Given tengo estadísticas de historial
      final auth = AuthProvider();
      // When veo la pantalla de historial
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: RouteHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Historial de Rutas"
      await BddSteps.veoElTexto(tester, 'Historial de Rutas');
      // And veo el texto "Resumen General (Todo el tiempo)"
      await BddSteps.veoElTexto(tester, 'Resumen General (Todo el tiempo)');
    });

    testWidgets('Ver estado vacío del historial', (tester) async {
      // Given no tengo rutas completadas
      final auth = AuthProvider();
      // When veo la pantalla de historial
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: RouteHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Sin historial de rutas"
      await BddSteps.veoElTexto(tester, 'Sin historial de rutas');
    });

    testWidgets('Ver el mensaje de historial vacío', (tester) async {
      // Given no tengo rutas completadas
      final auth = AuthProvider();
      // When veo la pantalla de historial
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: RouteHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Aquí aparecerán las rutas que hayas completado"
      await BddSteps.veoElTexto(tester, 'Aquí aparecerán las rutas que hayas completado');
    });
  });
}