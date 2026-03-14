import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/evento.dart';
import '../../domain/repositories/evento_repository.dart';
import '../datasources/evento_local_datasource.dart';

class EventoRepositoryImpl implements EventoRepository {
  final EventoLocalDatasource _local;

  EventoRepositoryImpl({required EventoLocalDatasource local}) : _local = local;

  @override
  Future<Result<List<Evento>>> getEventos() async {
    return Success(_local.getEventos());
  }

  @override
  Future<Result<Evento>> getEventoById(String id) async {
    final evento = _local.getEventoById(id);
    if (evento != null) return Success(evento);
    return const Fail(NotFoundFailure('Evento no encontrado'));
  }

  @override
  Future<Result<List<Evento>>> getEventosByCategoria(String categoria) async {
    return Success(_local.getEventosByCategoria(categoria));
  }

  @override
  Future<Result<List<Evento>>> getEventosByFecha(DateTime fecha) async {
    return Success(_local.getEventosByFecha(fecha));
  }
}
