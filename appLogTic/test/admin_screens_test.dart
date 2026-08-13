import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/screens/admin/driver_monitor_screen.dart';
import 'package:logtic/screens/admin/user_management_screen.dart';
import 'package:logtic/providers/auth_provider.dart';
import 'package:logtic/providers/driver_monitor_provider.dart';
import 'package:logtic/providers/odoo_provider.dart';
import 'package:logtic/providers/route_provider.dart';
import 'package:logtic/providers/user_management_provider.dart';
import 'package:logtic/providers/notification_badge_provider.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'helpers/firebase_test_helper.dart';
import 'step/bdd_steps.dart';

void main() {
  setUpAll(() async {
    await initFirebaseForTest();
  });

  group('Monitor de Choferes', () {
    testWidgets('Ver la pantalla de monitor con lista de choferes', (tester) async {
      // Given soy un usuario administrador con choferes cargados
      final auth = AuthProvider();
      // When veo la pantalla de monitor
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: DriverMonitorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Monitor de Choferes"
      await BddSteps.veoElTexto(tester, 'Monitor de Choferes');
      // And veo el texto "Juan Pérez"
      await BddSteps.veoElTexto(tester, 'Juan Pérez');
      // And veo el texto "María González"
      await BddSteps.veoElTexto(tester, 'María González');
    });

    testWidgets('Ver las estadísticas de progreso de un chofer', (tester) async {
      // Given tengo choferes con estadísticas
      final auth = AuthProvider();
      // When veo la tarjeta de progreso
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: DriverMonitorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Progreso"
      await BddSteps.veoElTexto(tester, 'Progreso');
      // And veo el texto "Total"
      await BddSteps.veoElTexto(tester, 'Total');
      // And veo el texto "En Curso"
      await BddSteps.veoElTexto(tester, 'En Curso');
      // And veo el texto "Completadas"
      await BddSteps.veoElTexto(tester, 'Completadas');
      // And veo el texto "Pendientes"
      await BddSteps.veoElTexto(tester, 'Pendientes');
    });
  });

  group('Gestión de Usuarios', () {
    testWidgets('Ver la pantalla de gestión de usuarios', (tester) async {
      // Given soy un usuario administrador
      final auth = AuthProvider();
      // When veo la pantalla de gestión de usuarios
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Gestión de Usuarios"
      await BddSteps.veoElTexto(tester, 'Gestión de Usuarios');
      // And veo el texto "3 Usuarios"
      await BddSteps.veoElTexto(tester, '3 Usuarios');
    });

    testWidgets('Ver la lista de usuarios con sus roles', (tester) async {
      // Given tengo usuarios registrados
      final auth = AuthProvider();
      // When veo la lista de usuarios
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Administrador Sistema"
      await BddSteps.veoElTexto(tester, 'Administrador Sistema');
      // And veo el texto "Juan Pérez"
      await BddSteps.veoElTexto(tester, 'Juan Pérez');
      // And veo el texto "María González"
      await BddSteps.veoElTexto(tester, 'María González');
      // And veo el texto "ADMIN"
      await BddSteps.veoElTexto(tester, 'ADMIN');
    });

    testWidgets('Ver el botón para crear un nuevo usuario', (tester) async {
      // Given tengo la pantalla de usuarios abierta
      final auth = AuthProvider();
      // When veo la barra de acciones
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => UserManagementProvider()),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => DriverMonitorProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Nuevo"
      await BddSteps.veoElTexto(tester, 'Nuevo');
    });
  });
}