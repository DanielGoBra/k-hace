import '../../home/domain/lugar.dart';
import '../../events/domain/evento.dart';

enum SearchResultType { lugar, evento }

class SearchResult {
  final SearchResultType tipo;
  final Lugar? lugar;
  final Evento? evento;

  const SearchResult.fromLugar(this.lugar)
      : tipo = SearchResultType.lugar,
        evento = null;

  const SearchResult.fromEvento(this.evento)
      : tipo = SearchResultType.evento,
        lugar = null;

  String get nombre =>
      tipo == SearchResultType.lugar ? lugar!.nombre : evento!.nombre;
}
