import 'package:flutter_test/flutter_test.dart';
import 'package:logtic/utils/search_utils.dart';

void main() {
  group('SearchUtils Tests (Case & Accent Insensitive)', () {
    test('normalize convierte a minúsculas y remueve tildes/acentos', () {
      expect(SearchUtils.normalize('HOLA MUNDO'), 'hola mundo');
      expect(SearchUtils.normalize('Canción y Álbum'), 'cancion y album');
      expect(SearchUtils.normalize('Miércoles 19 de Agosto'), 'miercoles 19 de agosto');
      expect(SearchUtils.normalize('CONSTRUCCIÓN'), 'construccion');
    });

    test('matches busca sin importar mayúsculas ni minúsculas', () {
      expect(SearchUtils.matches('Ruta Principal 01', 'ruta'), isTrue);
      expect(SearchUtils.matches('ruta principal 01', 'RUTA'), isTrue);
      expect(SearchUtils.matches('Ruta Principal 01', 'PRINCIPAL'), isTrue);
      expect(SearchUtils.matches('Ruta Principal 01', '01'), isTrue);
      expect(SearchUtils.matches('Ruta Principal 01', 'secundaria'), isFalse);
    });

    test('matches busca sin importar acentos o tildes', () {
      expect(SearchUtils.matches('Ferretería El Tornillo', 'ferreteria'), isTrue);
      expect(SearchUtils.matches('Ferreteria El Tornillo', 'ferretería'), isTrue);
      expect(SearchUtils.matches('Dirección Colón 123', 'colon'), isTrue);
      expect(SearchUtils.matches('Dirección Colón 123', 'DIRECCION'), isTrue);
    });

    test('matchesAny busca múltiples términos combinados entre campos', () {
      final fields = ['Ruta 05', 'Ferretería La Unión', 'Calle Mayor 45'];

      // Coincide con términos distribuidos en diferentes campos
      expect(SearchUtils.matchesAny(fields, 'ruta ferreteria'), isTrue);
      expect(SearchUtils.matchesAny(fields, 'RUTA UNION'), isTrue);
      expect(SearchUtils.matchesAny(fields, 'mayor 05'), isTrue);

      // Falla si alguno de los términos no existe
      expect(SearchUtils.matchesAny(fields, 'ruta inexistente'), isFalse);
    });
  });
}
