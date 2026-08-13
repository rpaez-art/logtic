import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/screens/routes/route_line_detail_screen.dart';
import 'package:logtic/providers/auth_provider.dart';
import 'package:logtic/providers/odoo_provider.dart';
import 'package:logtic/providers/route_provider.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'package:logtic/providers/notification_badge_provider.dart';
import 'helpers/firebase_test_helper.dart';
import 'step/bdd_steps.dart';

void main() {
  setUpAll(() async {
    await initFirebaseForTest();
  });

  group('Detalle de Entrega', () {
    testWidgets('Ver estado de entrega no encontrada', (tester) async {
      // Given no hay datos sincronizados para esa entrega
      final auth = AuthProvider();
      // When veo el detalle de una entrega inexistente
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => OdooProvider()),
            ChangeNotifierProvider(create: (_) => RouteProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NotificationBadgeProvider()),
          ],
          child: const MaterialApp(
            home: RouteLineDetailScreen(lineId: 999, routeName: 'Ruta Test'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Entrega no encontrada"
      await BddSteps.veoElTexto(tester, 'Entrega no encontrada');
      // And veo el texto "Sincronizar rutas"
      await BddSteps.veoElTexto(tester, 'Sincronizar rutas');
    });
  });
}