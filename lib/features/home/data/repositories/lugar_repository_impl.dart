import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/lugar.dart';
import '../../domain/repositories/lugar_repository.dart';
import '../datasources/lugar_local_datasource.dart';

class LugarRepositoryImpl implements LugarRepository {
  final LugarLocalDatasource _local;
  final SupabaseClient? _supabase;

  LugarRepositoryImpl({
    required LugarLocalDatasource local,
    SupabaseClient? supabase,
  })  : _local = local,
        _supabase = supabase;

  @override
  Future<Result<List<Lugar>>> getLugares() async {
    if (_supabase == null) return Success(_local.getLugares());

    try {
      final data = await _supabase
          .from('lugares')
          .select()
          .not('lat', 'is', null)
          .not('lng', 'is', null)
          .limit(200);

      if (data.isEmpty) return Success(_local.getLugares());

      final lugares = data
          .map<Lugar>(Lugar.fromSupabase)
          .where((l) => l.latitud != 0 || l.longitud != 0)
          .toList();

      return Success(lugares);
    } catch (e) {
      debugPrint('Error fetching lugares: $e');
      return Success(_local.getLugares());
    }
  }

  @override
  Future<Result<Lugar>> getLugarById(String id) async {
    final local = _local.getLugarById(id);
    if (local != null) return Success(local);

    if (_supabase == null) {
      return const Fail(NotFoundFailure('Lugar no encontrado'));
    }

    try {
      final data = await _supabase
          .from('lugares')
          .select()
          .eq('id', int.parse(id))
          .maybeSingle();

      if (data != null) return Success(Lugar.fromSupabase(data));
      return const Fail(NotFoundFailure('Lugar no encontrado'));
    } catch (e) {
      debugPrint('Error fetching lugar $id: $e');
      return Fail(ServerFailure('Error al obtener lugar', e));
    }
  }

  @override
  Future<Result<List<Lugar>>> searchLugares(String query) async {
    return Success(_local.searchLugares(query));
  }

  @override
  Future<Result<List<Lugar>>> getLugaresByCategoria(String categoria) async {
    final result = await getLugares();
    return result.map(
      (lugares) => lugares.where((l) => l.categoria == categoria).toList(),
    );
  }
}
