import '../../../../core/errors/result.dart';
import '../evento.dart';

abstract class EventoRepository {
  Future<Result<List<Evento>>> getEventos();
  Future<Result<Evento>> getEventoById(String id);
  Future<Result<List<Evento>>> getEventosByCategoria(String categoria);
  Future<Result<List<Evento>>> getEventosByFecha(DateTime fecha);
}
