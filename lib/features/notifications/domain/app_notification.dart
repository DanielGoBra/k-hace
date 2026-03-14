enum NotificationType { eventoCercano, nuevoLugar, promo, sistema }

class AppNotification {
  final String id;
  final String titulo;
  final String cuerpo;
  final NotificationType tipo;
  final DateTime fechaCreacion;
  final bool leida;
  final Map<String, dynamic> datosExtra;

  const AppNotification({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.tipo,
    required this.fechaCreacion,
    this.leida = false,
    this.datosExtra = const {},
  });

  AppNotification copyWith({bool? leida}) {
    return AppNotification(
      id: id,
      titulo: titulo,
      cuerpo: cuerpo,
      tipo: tipo,
      fechaCreacion: fechaCreacion,
      leida: leida ?? this.leida,
      datosExtra: datosExtra,
    );
  }
}

final List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n1',
    titulo: 'Fiesta Neón este sábado',
    cuerpo: 'Dulce Jesús Mío tiene un evento destacado cerca de ti. ¡No te lo pierdas!',
    tipo: NotificationType.eventoCercano,
    fechaCreacion: DateTime.now().subtract(const Duration(hours: 2)),
    datosExtra: {'eventId': 'e5'},
  ),
  AppNotification(
    id: 'n2',
    titulo: 'Nuevo lugar: El Cielo Restaurante',
    cuerpo: 'Un restaurante con estrella Michelin acaba de unirse a KeHace en El Poblado.',
    tipo: NotificationType.nuevoLugar,
    fechaCreacion: DateTime.now().subtract(const Duration(hours: 8)),
    datosExtra: {'lugarId': '8'},
  ),
  AppNotification(
    id: 'n3',
    titulo: '20% de descuento en Café Pergamino',
    cuerpo: 'Presenta tu app y obtén un 20% en cualquier bebida de especialidad este fin de semana.',
    tipo: NotificationType.promo,
    fechaCreacion: DateTime.now().subtract(const Duration(days: 1)),
    leida: true,
    datosExtra: {'lugarId': '5'},
  ),
  AppNotification(
    id: 'n4',
    titulo: 'Caminata Ecológica mañana',
    cuerpo: 'Recuerda: mañana a las 5am arranca la caminata en el Cerro El Volador. ¡Lleva agua!',
    tipo: NotificationType.eventoCercano,
    fechaCreacion: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    datosExtra: {'eventId': 'e3'},
  ),
  AppNotification(
    id: 'n5',
    titulo: 'Bienvenido a KeHace',
    cuerpo: '¡Gracias por unirte! Explora los mejores parches de Medellín y guarda tus favoritos.',
    tipo: NotificationType.sistema,
    fechaCreacion: DateTime.now().subtract(const Duration(days: 3)),
    leida: true,
  ),
  AppNotification(
    id: 'n6',
    titulo: 'Mercado Campesino este domingo',
    cuerpo: 'Parque Arví te espera con productos orgánicos y artesanías. Entrada libre.',
    tipo: NotificationType.eventoCercano,
    fechaCreacion: DateTime.now().subtract(const Duration(hours: 12)),
    datosExtra: {'eventId': 'e7'},
  ),
];
