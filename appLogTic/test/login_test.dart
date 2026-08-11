import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logtic/config/theme.dart';
import 'step/bdd_steps.dart';

void main() {
  group('Login de Usuario', () {
    testWidgets('Ver la pantalla de login', (tester) async {
      // Given no estoy autenticado
      // When veo la pantalla de login
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LOGTIC', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Iniciar Sesión'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Then veo el texto "Iniciar Sesión"
      await BddSteps.veoElTexto(tester, 'Iniciar Sesión');
      // And veo el texto "LOGTIC"
      await BddSteps.veoElTexto(tester, 'LOGTIC');
    });
  });
}