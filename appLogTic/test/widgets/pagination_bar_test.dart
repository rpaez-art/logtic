import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logtic/widgets/pagination_bar.dart';

void main() {
  group('PaginationBar Widget Tests', () {
    testWidgets('Muestra información de página actual y total', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationBar(
              currentPage: 2,
              totalPages: 5,
              totalItems: 48,
              pageSize: 10,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
              itemLabel: 'rutas',
            ),
          ),
        ),
      );

      expect(find.text('Pág. 2 de 5 (48 rutas)'), findsOneWidget);
      expect(find.text('Anterior'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('Llama a onPageChanged al presionar Siguiente y Anterior', (tester) async {
      int selectedPage = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PaginationBar(
                  currentPage: selectedPage,
                  totalPages: 5,
                  totalItems: 50,
                  pageSize: 10,
                  onPageChanged: (newPage) {
                    setState(() => selectedPage = newPage);
                  },
                  onPageSizeChanged: (_) {},
                );
              },
            ),
          ),
        ),
      );

      // Presionar Siguiente
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(selectedPage, 3);

      // Presionar Anterior
      await tester.tap(find.text('Anterior'));
      await tester.pumpAndSettle();
      expect(selectedPage, 2);
    });

    testWidgets('Llama a onPageChanged al presionar un número de página directo', (tester) async {
      int selectedPage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PaginationBar(
                  currentPage: selectedPage,
                  totalPages: 4,
                  totalItems: 40,
                  pageSize: 10,
                  onPageChanged: (newPage) {
                    setState(() => selectedPage = newPage);
                  },
                  onPageSizeChanged: (_) {},
                );
              },
            ),
          ),
        ),
      );

      // Presionar el botón de la página 3
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(selectedPage, 3);
    });

    testWidgets('Deshabilita botón Anterior en la primera página y Siguiente en la última', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationBar(
              currentPage: 1,
              totalPages: 3,
              totalItems: 30,
              pageSize: 10,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      final prevButton = tester.widget<OutlinedButton>(
        find.ancestor(of: find.text('Anterior'), matching: find.byType(OutlinedButton)),
      );
      expect(prevButton.onPressed, isNull);

      // Renderizar en última página
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationBar(
              currentPage: 3,
              totalPages: 3,
              totalItems: 30,
              pageSize: 10,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      final nextButton = tester.widget<OutlinedButton>(
        find.ancestor(of: find.text('Siguiente'), matching: find.byType(OutlinedButton)),
      );
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('No renderiza contenido si solo hay 1 página con pocos elementos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationBar(
              currentPage: 1,
              totalPages: 1,
              totalItems: 3,
              pageSize: 5,
              onPageChanged: (_) {},
              onPageSizeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Anterior'), findsNothing);
      expect(find.text('Siguiente'), findsNothing);
    });
  });
}
