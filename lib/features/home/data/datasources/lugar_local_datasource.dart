import '../../domain/lugar.dart';

class LugarLocalDatasource {
  List<Lugar> getLugares() => mockLugares;

  Lugar? getLugarById(String id) {
    return mockLugares.where((l) => l.id == id).firstOrNull;
  }

  List<Lugar> searchLugares(String query) {
    final q = query.toLowerCase();
    return mockLugares
        .where(
          (l) =>
              l.nombre.toLowerCase().contains(q) ||
              l.categoria.toLowerCase().contains(q) ||
              l.descripcion.toLowerCase().contains(q) ||
              l.tags.any((t) => t.toLowerCase().contains(q)),
        )
        .toList();
  }

  List<Lugar> getLugaresByCategoria(String categoria) {
    return mockLugares.where((l) => l.categoria == categoria).toList();
  }
}
