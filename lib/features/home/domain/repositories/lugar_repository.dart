import '../../../../core/errors/result.dart';
import '../lugar.dart';

abstract class LugarRepository {
  Future<Result<List<Lugar>>> getLugares();
  Future<Result<Lugar>> getLugarById(String id);
  Future<Result<List<Lugar>>> searchLugares(String query);
  Future<Result<List<Lugar>>> getLugaresByCategoria(String categoria);
}
