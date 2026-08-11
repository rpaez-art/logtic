import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/screens/routes/routes_screen.dart';
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

  group('Gestión de Rutas', () {
    testWidgets('Ver el encabezado de rutas', (tester) async {
      // Given soy un conductor autenticado
      final auth = AuthProvider();
      // When veo la pantalla de rutas
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
            home: RoutesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Mis Rutas"
      await BddSteps.veoElTexto(tester, 'Mis Rutas');
    });

    testWidgets('Ver estado vacío de rutas', (tester) async {
      // Given no tengo rutas asignadas
      final auth = AuthProvider();
      // When veo la pantalla de rutas
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
            home: RoutesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Sin rutas pendientes"
      await BddSteps.veoElTexto(tester, 'Sin rutas pendientes');
    });

    testWidgets('Ver tarjetas de estadísticas', (tester) async {
      // Given tengo rutas activas
      final auth = AuthProvider();
      // When veo la sección de estadísticas
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
            home: RoutesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Pendientes"
      await BddSteps.veoElTexto(tester, 'Pendientes');
      // And veo el texto "En Curso"
      await BddSteps.veoElTexto(tester, 'En Curso');
      // And veo el texto "Completadas"
      await BddSteps.veoElTexto(tester, 'Completadas');
    });
  });
}