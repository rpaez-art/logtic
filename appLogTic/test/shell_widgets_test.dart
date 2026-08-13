import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/config/theme.dart';
import 'package:logtic/models/route.dart';
import 'package:logtic/providers/route_provider.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'package:logtic/screens/shell/widgets/badge_wrapper.dart';
import 'package:logtic/screens/shell/widgets/drawer_navigation_widgets.dart';
import 'step/bdd_steps.dart';

void main() {
  group('Navegación Principal (Shell)', () {
    testWidgets('Ver el resumen de estado de rutas', (tester) async {
      // Given tengo rutas activas y completadas
      final routeProvider = RouteProvider();
      routeProvider.setRoutesFromOdoo([
        RouteModel(id: 1, clientName: 'Cliente A', status: RouteStatus.pending),
        RouteModel(id: 2, clientName: 'Cliente B', status: RouteStatus.inProgress),
        RouteModel(id: 3, clientName: 'Cliente C', status: RouteStatus.completed),
      ]);

      // When veo el resumen de estado de rutas
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: ChangeNotifierProvider.value(
            value: routeProvider,
            child: const MaterialApp(
              home: Scaffold(
                body: RouteStatusSummary(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Activas"
      await BddSteps.veoElTexto(tester, 'Activas');
      // And veo el texto "Completadas"
      await BddSteps.veoElTexto(tester, 'Completadas');
      // And veo el texto "3 total"
      await BddSteps.veoElTexto(tester, '3 total');
    });

    testWidgets('Ver el item de navegación del drawer', (tester) async {
      // Given tengo el drawer abierto
      // When veo el item de navegación
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            home: Scaffold(
              body: DrawerItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                selected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Dashboard"
      await BddSteps.veoElTexto(tester, 'Dashboard');
    });

    testWidgets('Ver el badge de notificaciones en la navegación', (tester) async {
      // Given tengo notificaciones sin leer
      // When veo el ícono con badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BadgeWrapper(
                count: 5,
                child: Icon(Icons.route_outlined),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el número "5"
      await BddSteps.veoElTexto(tester, '5');
    });

    testWidgets('Ver el chip de estado de ruta', (tester) async {
      // Given tengo estadísticas de rutas
      // When veo el chip de estado
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatusChip(
                icon: Icons.play_circle_filled,
                iconColor: AppColors.statusInProgress,
                count: 2,
                label: 'Activas',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Activas"
      await BddSteps.veoElTexto(tester, 'Activas');
    });
  });
}