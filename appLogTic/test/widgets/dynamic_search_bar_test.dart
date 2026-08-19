import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logtic/widgets/dynamic_search_bar.dart';

void main() {
  group('DynamicSearchBar Widget Tests', () {
    testWidgets('Muestra hintText e icono de búsqueda', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicSearchBar(
              controller: controller,
              hintText: 'Buscar ruta o cliente...',
              onChanged: (_) {},
              onClear: () {},
            ),
          ),
        ),
      );

      expect(find.text('Buscar ruta o cliente...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('Ejecuta onChanged al ingresar texto', (tester) async {
      final controller = TextEditingController();
      String changedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicSearchBar(
              controller: controller,
              hintText: 'Buscar...',
              onChanged: (val) => changedText = val,
              onClear: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Cliente ABC');
      await tester.pump();

      expect(changedText, 'Cliente ABC');
    });

    testWidgets('Muestra botón de limpiar cuando hay texto y ejecuta onClear al presionarlo', (tester) async {
      final controller = TextEditingController(text: 'Ruta 101');
      bool clearCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicSearchBar(
              controller: controller,
              hintText: 'Buscar...',
              onChanged: (_) {},
              onClear: () {
                clearCalled = true;
                controller.clear();
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(clearCalled, isTrue);
    });
  });
}
