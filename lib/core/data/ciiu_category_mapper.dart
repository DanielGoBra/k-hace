import '../../features/home/domain/lugar.dart';

class CiiuCategoryMapper {
  // ── 4-digit exact overrides (highest priority) ───────────
  static const _exactOverrides = <String, String>{
    '5630': 'Rumba', // Expendio de bebidas alcohólicas (bares, discotecas)
    '5611': 'Gastronomía', // Expendio a la mesa de comidas preparadas
    '5613': 'Gastronomía', // Expendio de comidas en cafeterías
    '5619': 'Gastronomía', // Otros expendios de comidas preparadas
    '5621': 'Gastronomía', // Catering para eventos
    '5629': 'Gastronomía', // Otros servicios de comidas
    '9312': 'Aventura', // Actividades de clubes deportivos
    '9319': 'Aventura', // Otras actividades deportivas
    '9321': 'Parques', // Actividades de parques de atracciones
    '9329': 'Aventura', // Otras actividades recreativas
    '9103': 'Parques', // Jardines botánicos, zoológicos, parques
    '9101': 'Cultura', // Actividades de bibliotecas y archivos
    '9102': 'Cultura', // Actividades de museos
    '5510': 'Hospedaje', // Alojamiento en hoteles
    '5511': 'Hospedaje', // Alojamiento en apartahoteles
    '5519': 'Hospedaje', // Otros tipos de alojamiento
    '5520': 'Hospedaje', // Actividades de zonas de camping
  };

  // ── 2-digit prefix mapping ───────────────────────────────
  static const _prefixToCategory = <String, String>{
    '56': 'Gastronomía', // Actividades de servicio de comidas y bebidas
    '55': 'Hospedaje', // Alojamiento
    '93': 'Aventura', // Actividades deportivas y recreativas
    '91': 'Cultura', // Bibliotecas, archivos, museos
    '90': 'Cultura', // Actividades creativas, artísticas y de entretenimiento
    '92': 'Rumba', // Actividades de juegos de azar
    '79':
        'Aventura', // Actividades de agencias de viajes y operadores turísticos
    '47': 'Comercio', // Comercio al por menor
    '46': 'Comercio', // Comercio al por mayor
    '86': 'Servicios', // Actividades de atención de la salud
    '85': 'Educación', // Educación
  };

  // ── Keyword detection (lowest priority fallback) ─────────
  static const _keywordToCategory = <String, String>{
    'café': 'Café',
    'cafe': 'Café',
    'coffee': 'Café',
    'restaura': 'Gastronomía',
    'comida': 'Gastronomía',
    'alimento': 'Gastronomía',
    'panaderi': 'Gastronomía',
    'bar ': 'Rumba',
    'discoteca': 'Rumba',
    'licor': 'Rumba',
    'bebida alcoh': 'Rumba',
    'rumba': 'Rumba',
    'deport': 'Aventura',
    'aventura': 'Aventura',
    'senderis': 'Aventura',
    'turism': 'Aventura',
    'parque': 'Parques',
    'jardin botan': 'Parques',
    'zoolog': 'Parques',
    'museo': 'Cultura',
    'bibliotec': 'Cultura',
    'cultural': 'Cultura',
    'teatro': 'Cultura',
    'hotel': 'Hospedaje',
    'hostal': 'Hospedaje',
    'alojam': 'Hospedaje',
  };

  /// Derives the app category from CIIU codes and descriptions.
  static String categoriaFromCiiu({
    String? ciiu1,
    String? ciiu2,
    String? ciiu3,
    String? ciiu4,
    String? descCiiu1,
    String? descCiiu2,
  }) {
    // 1. Try exact 4-digit match (highest specificity)
    for (final code in [ciiu1, ciiu2, ciiu3, ciiu4]) {
      if (code != null && _exactOverrides.containsKey(code)) {
        return _exactOverrides[code]!;
      }
    }

    // 2. Try 2-digit prefix match
    for (final code in [ciiu1, ciiu2, ciiu3, ciiu4]) {
      if (code != null && code.length >= 2) {
        final prefix = code.substring(0, 2);
        if (_prefixToCategory.containsKey(prefix)) {
          return _prefixToCategory[prefix]!;
        }
      }
    }

    // 3. Keyword search in descriptions
    final text = '${descCiiu1 ?? ''} ${descCiiu2 ?? ''}'.toLowerCase();
    for (final entry in _keywordToCategory.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    // 4. Default
    return 'Comercio';
  }

  /// Generates tags from CIIU description fields.
  static List<String> tagsFromDescriptions({
    String? desc1,
    String? desc2,
    String? desc3,
    String? desc4,
  }) {
    return [
      desc1,
      desc2,
      desc3,
      desc4,
    ].whereType<String>().where((d) => d.isNotEmpty).take(4).toList();
  }

  /// Maps `tamano_empresa` to PlanTipo.
  static PlanTipo planTipoFromTamano(String? tamano) {
    if (tamano == null) return PlanTipo.basico;
    final lower = tamano.toLowerCase();
    if (lower.contains('grande')) return PlanTipo.pro;
    if (lower.contains('mediana')) return PlanTipo.parche;
    return PlanTipo.basico;
  }
}
