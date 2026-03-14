import '../../../core/data/ciiu_category_mapper.dart';

enum PlanTipo { basico, parche, pro }

class Lugar {
  final String id;
  final String nombre;
  final String categoria;
  final String imagenUrl;
  final double rating;
  final String descripcion;
  final String ubicacion;
  final PlanTipo planTipo;
  final double latitud;
  final double longitud;
  final String? telefono;
  final List<String> tags;
  final List<String> fotos;
  final String? menuPdfUrl;
  final String? horario;

  const Lugar({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.imagenUrl,
    required this.rating,
    required this.descripcion,
    required this.ubicacion,
    this.planTipo = PlanTipo.basico,
    required this.latitud,
    required this.longitud,
    this.telefono,
    this.tags = const [],
    this.fotos = const [],
    this.menuPdfUrl,
    this.horario,
  });

  // ── Placeholder images by category ──────────────────────
  static const _categoryPlaceholders = <String, String>{
    'Gastronomía':
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
    'Rumba':
        'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=600',
    'Aventura':
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600',
    'Parques':
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600',
    'Café':
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
    'Cultura':
        'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=600',
    'Hospedaje':
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600',
    'Comercio':
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=600',
    'Servicios':
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600',
    'Educación':
        'https://images.unsplash.com/photo-1523050854058-8df90110c476?w=600',
  };

  factory Lugar.fromSupabase(Map<String, dynamic> json) {
    final categoria = CiiuCategoryMapper.categoriaFromCiiu(
      ciiu1: json['ciiu_1'] as String?,
      ciiu2: json['ciiu_2'] as String?,
      ciiu3: json['ciiu_3'] as String?,
      ciiu4: json['ciiu_4'] as String?,
      descCiiu1: json['descripcion_ciiu_1'] as String?,
      descCiiu2: json['descripcion_ciiu_2'] as String?,
    );

    final nombre = _titleCase(
      json['nombre_razon_social'] as String? ?? 'Sin nombre',
    );
    final direccion = json['direccion'] as String? ?? '';
    final municipio = json['municipio'] as String? ?? '';

    return Lugar(
      id: json['id'].toString(),
      nombre: nombre,
      categoria: categoria,
      imagenUrl:
          _categoryPlaceholders[categoria] ??
          _categoryPlaceholders['Comercio']!,
      rating: 0.0,
      descripcion: _buildDescripcion(json, municipio),
      ubicacion: [direccion, municipio].where((s) => s.isNotEmpty).join(', '),
      planTipo: CiiuCategoryMapper.planTipoFromTamano(
        json['tamano_empresa'] as String?,
      ),
      latitud: (json['lat'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['lng'] as num?)?.toDouble() ?? 0.0,
      telefono: json['telefonos'] as String?,
      tags: CiiuCategoryMapper.tagsFromDescriptions(
        desc1: json['descripcion_ciiu_1'] as String?,
        desc2: json['descripcion_ciiu_2'] as String?,
        desc3: json['descripcion_ciiu_3'] as String?,
        desc4: json['descripcion_ciiu_4'] as String?,
      ),
    );
  }

  static String _buildDescripcion(Map<String, dynamic> json, String municipio) {
    final desc = json['descripcion_ciiu_1'] as String?;
    if (desc != null && desc.isNotEmpty) {
      return municipio.isNotEmpty ? '$desc. Ubicado en $municipio.' : desc;
    }
    return municipio.isNotEmpty
        ? 'Establecimiento en $municipio.'
        : 'Establecimiento comercial.';
  }

  static String _titleCase(String input) {
    if (input.isEmpty) return input;
    const lowercase = {'de', 'del', 'la', 'el', 'y', 'en', 'los', 'las', 'por'};
    const keepLower = {'s.a.s', 'sas', 'ltda', 's.a', 'e.u'};
    return input
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((word) {
          if (keepLower.contains(word)) return word;
          if (lowercase.contains(word)) return word;
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}

final List<Lugar> mockLugares = [
  const Lugar(
    id: '1',
    nombre: 'Festival Altavoz',
    categoria: 'Rumba',
    imagenUrl: 'lib/assets/images/altavoz.png',
    rating: 4.9,
    descripcion:
        'El festival de rock y sonidos alternativos más grande de Medellín. Energía pura en el Estadio Cincuentenario con las mejores bandas locales e internacionales.',
    ubicacion: 'Estadio Cincuentenario, Medellín',
    planTipo: PlanTipo.pro,
    latitud: 6.2518,
    longitud: -75.5636,
    telefono: '+57 604 385 5555',
    tags: ['Rock', 'Festival', 'Música en vivo', 'Al aire libre'],
    fotos: ['lib/assets/images/altavoz.png'],
    horario: 'Según programación del evento',
  ),
  const Lugar(
    id: '2',
    nombre: 'Mercado del Río',
    categoria: 'Gastronomía',
    imagenUrl: 'lib/assets/images/mercadoDelRio.png',
    rating: 4.7,
    descripcion:
        'Un parche gastronómico imperdible. Más de 50 propuestas culinarias en un ambiente industrial y moderno. Perfecto para unos tragos y buena comida con amigos.',
    ubicacion: 'Ciudad del Río, Medellín',
    planTipo: PlanTipo.parche,
    latitud: 6.2306,
    longitud: -75.5745,
    telefono: '+57 604 444 2233',
    tags: ['Comida', 'Mercado', 'Tragos', 'Industrial'],
    fotos: ['lib/assets/images/mercadoDelRio.png'],
    menuPdfUrl: 'https://example.com/menu-mercado-rio.pdf',
    horario: 'Lun-Jue 11am-10pm · Vie-Sáb 11am-12am · Dom 11am-8pm',
  ),
  const Lugar(
    id: '3',
    nombre: 'Salto del Buey',
    categoria: 'Aventura',
    imagenUrl: 'lib/assets/images/saltoDelBuey.png',
    rating: 4.8,
    descripcion:
        '¿Buscas adrenalina? Una de las cascadas más imponentes de Antioquia. Canopy, senderismo y la mejor vista de las montañas de La Ceja.',
    ubicacion: 'La Ceja, Antioquia',
    planTipo: PlanTipo.basico,
    latitud: 6.0291,
    longitud: -75.4260,
    tags: ['Naturaleza', 'Senderismo', 'Cascada'],
    horario: 'Todos los días 7am-5pm',
  ),
  const Lugar(
    id: '4',
    nombre: 'Cerro El Volador',
    categoria: 'Parques',
    imagenUrl: 'lib/assets/images/cerroVolador.png',
    rating: 4.5,
    descripcion:
        'El parque natural más grande dentro del área urbana. Ideal para un picnic al atardecer, elevar cometa o simplemente ver Medellín desde lo alto.',
    ubicacion: 'Comuna 7, Medellín',
    planTipo: PlanTipo.basico,
    latitud: 6.2690,
    longitud: -75.5875,
    tags: ['Parque', 'Mirador', 'Picnic', 'Naturaleza'],
    horario: 'Todos los días 6am-6pm',
  ),
  const Lugar(
    id: '5',
    nombre: 'Café Pergamino',
    categoria: 'Café',
    imagenUrl: 'lib/assets/images/cafePergamino.png',
    rating: 4.9,
    descripcion:
        'Referente del café de especialidad en El Poblado. Un espacio minimalista donde el protagonista es el grano colombiano procesado con perfección.',
    ubicacion: 'Vía Primavera, El Poblado',
    planTipo: PlanTipo.parche,
    latitud: 6.2086,
    longitud: -75.5659,
    telefono: '+57 604 311 7989',
    tags: ['Café', 'Especialidad', 'Minimalista'],
    fotos: ['lib/assets/images/cafePergamino.png'],
    menuPdfUrl: 'https://example.com/menu-pergamino.pdf',
    horario: 'Lun-Sáb 8am-8pm · Dom 9am-6pm',
  ),
  const Lugar(
    id: '6',
    nombre: 'Parque Arví',
    categoria: 'Aventura',
    imagenUrl: 'lib/assets/images/parqueArvi.png',
    rating: 4.6,
    descripcion:
        'Reserva natural a las afueras de Medellín. Senderos ecológicos, avistamiento de aves y mercado campesino los fines de semana.',
    ubicacion: 'Santa Elena, Medellín',
    planTipo: PlanTipo.parche,
    latitud: 6.2833,
    longitud: -75.4944,
    tags: ['Ecoturismo', 'Senderismo', 'Metrocable'],
    fotos: ['lib/assets/images/parqueArvi.png'],
    horario: 'Mar-Dom 9am-5pm',
  ),
  const Lugar(
    id: '7',
    nombre: 'Dulce Jesús Mío',
    categoria: 'Rumba',
    imagenUrl: 'lib/assets/images/dulceJesusMio.png',
    rating: 4.4,
    descripcion:
        'La discoteca de crossover más icónica de Medellín. Tres pisos de pura rumba con los clásicos de siempre y los éxitos del momento.',
    ubicacion: 'Parque Lleras, El Poblado',
    planTipo: PlanTipo.pro,
    latitud: 6.2088,
    longitud: -75.5672,
    telefono: '+57 604 268 0990',
    tags: ['Discoteca', 'Crossover', 'Rumba', 'Parque Lleras'],
    fotos: ['lib/assets/images/dulceJesusMio.png'],
    horario: 'Jue-Sáb 9pm-4am',
  ),
  const Lugar(
    id: '8',
    nombre: 'El Cielo Restaurante',
    categoria: 'Gastronomía',
    imagenUrl: 'lib/assets/images/elCielo.png',
    rating: 4.8,
    descripcion:
        'Experiencia gastronómica de autor con estrella Michelin. Cocina colombiana de vanguardia que desafía los sentidos en cada plato.',
    ubicacion: 'El Poblado, Medellín',
    planTipo: PlanTipo.pro,
    latitud: 6.2100,
    longitud: -75.5680,
    telefono: '+57 604 268 3080',
    tags: ['Fine dining', 'Michelin', 'Autor', 'Experiencia'],
    fotos: ['lib/assets/images/elCielo.png'],
    menuPdfUrl: 'https://example.com/menu-el-cielo.pdf',
    horario: 'Mar-Sáb 12pm-3pm, 7pm-11pm',
  ),
];
