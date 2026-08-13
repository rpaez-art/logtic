import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logtic/config/theme.dart';
import 'package:logtic/providers/auth_provider.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'package:logtic/screens/splash/splash_screen.dart';
import 'helpers/firebase_test_helper.dart';
import 'step/bdd_steps.dart';

void main() {
  setUpAll(() async {
    await initFirebaseForTest();
  });

  group('Pantalla de Splash', () {
    testWidgets('Ver la pantalla de splash con el logo y título', (tester) async {
      // Given la aplicación inicia
      final auth = AuthProvider();
      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Login'))),
          ),
        ],
      );
      // When veo la pantalla de splash
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      // Permitir que la animación avance
      await tester.pump(const Duration(milliseconds: 500));

      // Then veo el texto "LOGTIC"
      await BddSteps.veoElTexto(tester, 'LOGTIC');
      // And veo el texto "Gestión de Rutas Inteligente"
      await BddSteps.veoElTexto(tester, 'Gestión de Rutas Inteligente');
      // And veo el texto "Preparando tu experiencia..."
      await BddSteps.veoElTexto(tester, 'Preparando tu experiencia...');

      // Avanzar el reloj para completar el Future.delayed de 2600ms
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();
    });
  });
}