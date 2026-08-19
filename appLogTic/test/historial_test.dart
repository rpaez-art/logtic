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
import 'package:logtic/widgets/dynamic_search_bar.dart';
import 'helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    await initFirebaseForTest();
  });

  Widget createHistoryScreen() {
    final auth = AuthProvider();
    return MultiProvider(
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
    );
  }

  group('Historial de Rutas Screen Tests', () {
    testWidgets('Ver el resumen general y barra de búsqueda en el historial', (tester) async {
      await tester.pumpWidget(createHistoryScreen());
      await tester.pumpAndSettle();

      expect(find.text('Historial de Rutas'), findsOneWidget);
      expect(find.text('Resumen General (Todo el tiempo)'), findsOneWidget);
      expect(find.byType(DynamicSearchBar), findsOneWidget);
      expect(find.text('Buscar por ruta, cliente, dirección o fecha...'), findsOneWidget);
    });

    testWidgets('Ver chips de filtros rápidos en historial', (tester) async {
      await tester.pumpWidget(createHistoryScreen());
      await tester.pumpAndSettle();

      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Esta semana'), findsOneWidget);
      expect(find.text('Este mes'), findsOneWidget);
      expect(find.text('100% Completas'), findsOneWidget);
      expect(find.text('Con Documentos'), findsOneWidget);
      expect(find.text('Rango fecha'), findsOneWidget);
    });

    testWidgets('Ver estado vacío y mensaje de no rutas', (tester) async {
      await tester.pumpWidget(createHistoryScreen());
      await tester.pumpAndSettle();

      expect(find.text('No hay rutas completadas en el historial'), findsOneWidget);
    });

    testWidgets('Interacción con la barra de búsqueda dinámica', (tester) async {
      await tester.pumpWidget(createHistoryScreen());
      await tester.pumpAndSettle();

      // Ingresar término de búsqueda
      await tester.enterText(find.byType(TextField), 'Ruta Inexistente 999');
      await tester.pumpAndSettle();

      expect(find.text('No se encontraron rutas con los filtros aplicados'), findsOneWidget);
      expect(find.text('Restablecer búsqueda'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Limpiar búsqueda
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('No hay rutas completadas en el historial'), findsOneWidget);
    });
  });
}