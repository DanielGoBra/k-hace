import '../../domain/evento.dart';

class EventoLocalDatasource {
  List<Evento> getEventos() => mockEventos;

  Evento? getEventoById(String id) {
    return mockEventos.where((e) => e.id == id).firstOrNull;
  }

  List<Evento> getEventosByCategoria(String categoria) {
    return mockEventos.where((e) => e.categoria == categoria).toList();
  }

  List<Evento> getEventosByFecha(DateTime fecha) {
    return mockEventos.where((e) {
      return e.fechaInicio.year == fecha.year &&
          e.fechaInicio.month == fecha.month &&
          e.fechaInicio.day == fecha.day;
    }).toList();
  }
}
