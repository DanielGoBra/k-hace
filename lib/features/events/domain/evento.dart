class Evento {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final String lugarId;
  final String lugarNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String categoria;
  final double? precio;
  final bool esDestacado;

  const Evento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.lugarId,
    required this.lugarNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.categoria,
    this.precio,
    this.esDestacado = false,
  });

  bool get esGratis => precio == null || precio == 0;
}

final List<Evento> mockEventos = [
  Evento(
    id: 'e1',
    nombre: 'Noche de Rock Alternativo',
    descripcion:
        'Las mejores bandas locales de rock alternativo en una noche inolvidable. Tres bandas en escenario con sonido de primera.',
    imagenUrl: 'lib/assets/images/altavoz.png',
    lugarId: '1',
    lugarNombre: 'Festival Altavoz',
    fechaInicio: DateTime.now().add(const Duration(days: 3, hours: 18)),
    fechaFin: DateTime.now().add(const Duration(days: 3, hours: 23)),
    categoria: 'Música',
    precio: 25000,
    esDestacado: true,
  ),
  Evento(
    id: 'e2',
    nombre: 'Festival de Comida Asiática',
    descripcion:
        'Degustación de cocina asiática fusión con chefs invitados. Ramen, sushi, pad thai y mucho más en un solo lugar.',
    imagenUrl: 'lib/assets/images/mercadoDelRio.png',
    lugarId: '2',
    lugarNombre: 'Mercado del Río',
    fechaInicio: DateTime.now().add(const Duration(days: 1, hours: 11)),
    fechaFin: DateTime.now().add(const Duration(days: 1, hours: 20)),
    categoria: 'Gastronomía',
    esDestacado: false,
  ),
  Evento(
    id: 'e3',
    nombre: 'Caminata Ecológica Amanecer',
    descripcion:
        'Recorrido guiado por los senderos del Cerro El Volador al amanecer. Incluye avistamiento de aves y yoga al aire libre.',
    imagenUrl: 'lib/assets/images/cerroVolador.png',
    lugarId: '4',
    lugarNombre: 'Cerro El Volador',
    fechaInicio: DateTime.now().add(const Duration(days: 2, hours: 5)),
    fechaFin: DateTime.now().add(const Duration(days: 2, hours: 9)),
    categoria: 'Aventura',
  ),
  Evento(
    id: 'e4',
    nombre: 'Cata de Café de Origen',
    descripcion:
        'Descubre los sabores del café colombiano en una cata guiada por baristas expertos. Aprende sobre métodos de preparación y perfiles de sabor.',
    imagenUrl: 'lib/assets/images/cafePergamino.png',
    lugarId: '5',
    lugarNombre: 'Café Pergamino',
    fechaInicio: DateTime.now().add(const Duration(days: 5, hours: 15)),
    fechaFin: DateTime.now().add(const Duration(days: 5, hours: 17)),
    categoria: 'Gastronomía',
    precio: 35000,
  ),
  Evento(
    id: 'e5',
    nombre: 'Fiesta Neón',
    descripcion:
        'La fiesta más colorida de Medellín. DJ internacionales, pintura neón y la mejor energía del Parque Lleras.',
    imagenUrl: 'lib/assets/images/dulceJesusMio.png',
    lugarId: '7',
    lugarNombre: 'Dulce Jesús Mío',
    fechaInicio: DateTime.now().add(const Duration(days: 6, hours: 21)),
    fechaFin: DateTime.now().add(const Duration(days: 7, hours: 4)),
    categoria: 'Fiesta',
    precio: 40000,
    esDestacado: true,
  ),
  Evento(
    id: 'e6',
    nombre: 'Menú Degustación 7 Tiempos',
    descripcion:
        'Experiencia culinaria exclusiva de 7 tiempos maridada con vinos seleccionados. Solo 20 cupos disponibles.',
    imagenUrl: 'lib/assets/images/elCielo.png',
    lugarId: '8',
    lugarNombre: 'El Cielo Restaurante',
    fechaInicio: DateTime.now().add(const Duration(days: 4, hours: 19)),
    fechaFin: DateTime.now().add(const Duration(days: 4, hours: 23)),
    categoria: 'Gastronomía',
    precio: 180000,
    esDestacado: true,
  ),
  Evento(
    id: 'e7',
    nombre: 'Mercado Campesino Arví',
    descripcion:
        'Productos orgánicos, artesanías y gastronomía local directamente de los productores de la región.',
    imagenUrl: 'lib/assets/images/parqueArvi.png',
    lugarId: '6',
    lugarNombre: 'Parque Arví',
    fechaInicio: DateTime.now().add(const Duration(days: 7, hours: 8)),
    fechaFin: DateTime.now().add(const Duration(days: 7, hours: 16)),
    categoria: 'Gastronomía',
  ),
  Evento(
    id: 'e8',
    nombre: 'Salsa al Parque',
    descripcion:
        'Festival de salsa al aire libre con orquestas en vivo. Clases gratuitas de salsa para principiantes desde las 4pm.',
    imagenUrl: 'lib/assets/images/altavoz.png',
    lugarId: '1',
    lugarNombre: 'Festival Altavoz',
    fechaInicio: DateTime.now().add(const Duration(days: 8, hours: 16)),
    fechaFin: DateTime.now().add(const Duration(days: 8, hours: 23)),
    categoria: 'Música',
    precio: 15000,
  ),
];
