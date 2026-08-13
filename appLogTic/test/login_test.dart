import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:logtic/config/theme.dart';
import 'package:logtic/providers/auth_provider.dart';
import 'package:logtic/providers/theme_provider.dart';
import 'package:logtic/screens/login/login_screen.dart';
import 'helpers/firebase_test_helper.dart';
import 'step/bdd_steps.dart';

void main() {
  setUpAll(() async {
    await initFirebaseForTest();
  });

  group('Login de Usuario', () {
    testWidgets('Ver la pantalla de login', (tester) async {
      // Given no estoy autenticado
      final auth = AuthProvider();
      // When veo la pantalla de login
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "LOGTIC"
      await BddSteps.veoElTexto(tester, 'LOGTIC');
      // And veo el texto "Iniciar Sesión"
      await BddSteps.veoElTexto(tester, 'Iniciar Sesión');
      // And veo el texto "INICIAR SESIÓN"
      await BddSteps.veoElTexto(tester, 'INICIAR SESIÓN');
      // And veo el campo de usuario
      await BddSteps.veoElCampo(tester, '');
    });

    testWidgets('Ver error de credenciales inválidas', (tester) async {
      // Given ingreso credenciales incorrectas
      final auth = AuthProvider();
      auth.updateUsername('usuario');
      auth.updatePassword('incorrecta');
      // When veo la pantalla de login
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el campo de usuario
      await BddSteps.veoElCampo(tester, '');
    });
  });
}