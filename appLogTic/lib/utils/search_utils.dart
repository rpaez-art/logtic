/// Utilidades para búsquedas inteligentes insensibles a mayúsculas,
/// minúsculas, espacios y tildes/acentos diacríticos.
class SearchUtils {
  /// Normaliza una cadena convirtiendo a minúsculas y eliminando acentos/tildes.
  static String normalize(String? text) {
    if (text == null || text.isEmpty) return '';
    var result = text.toLowerCase().trim();
    const replacements = {
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
    };
    replacements.forEach((accent, replacement) {
      result = result.replaceAll(accent, replacement);
    });
    return result;
  }

  /// Retorna true si [source] contiene [query] de forma insensible a mayúsculas y acentos.
  static bool matches(String? source, String query) {
    if (query.trim().isEmpty) return true;
    if (source == null || source.isEmpty) return false;
    final normalizedQuery = normalize(query);
    final normalizedSource = normalize(source);
    return normalizedSource.contains(normalizedQuery);
  }

  /// Retorna true si todos los términos de [query] coinciden con alguno de los campos en [sources].
  /// Permite búsqueda multi-término (ej. "Ruta 1 Ferreteria").
  static bool matchesAny(List<String?> sources, String query) {
    final cleanQuery = normalize(query);
    if (cleanQuery.isEmpty) return true;

    final terms = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return true;

    final combinedSources = sources
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => normalize(s!))
        .join(' ');

    return terms.every((term) => combinedSources.contains(term));
  }
}
