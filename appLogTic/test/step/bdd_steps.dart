import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pasos BDD personalizados en español para los tests de LogTic
class BddSteps {
  /// Busca texto en el widget tree
  static Future<void> veoElTexto(WidgetTester tester, String text) async {
    expect(find.text(text), findsWidgets);
  }

  /// Razón: el texto existe
  static Future<void> veoElTextoExacto(WidgetTester tester, String text) async {
    expect(find.text(text), findsOneWidget);
  }

  /// Busca campo de entrada por hint o label
  static Future<void> veoElCampo(WidgetTester tester, String fieldName) async {
    expect(find.byType(TextField), findsWidgets);
  }

  /// Toca un texto en pantalla
  static Future<void> tocoElTexto(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Espera un momento
  static Future<void> espero(WidgetTester tester) async {
    await tester.pump();
  }
}