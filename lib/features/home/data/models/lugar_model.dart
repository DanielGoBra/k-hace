import 'package:json_annotation/json_annotation.dart';

import '../../domain/lugar.dart';

part 'lugar_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: true)
class LugarModel {
  final String id;
  final String nombre;
  final String? descripcion;
  @JsonKey(name: 'imagen_url')
  final String? imagenUrl;
  final String categoria;
  final double? rating;
  final double? latitud;
  final double? longitud;
  final String? direccion;
  final String? telefono;
  final Map<String, dynamic>? horario;
  @JsonKey(name: 'precio_rango')
  final String? precioRango;
  final List<String>? tags;
  final bool activo;

  const LugarModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    required this.categoria,
    this.rating,
    this.latitud,
    this.longitud,
    this.direccion,
    this.telefono,
    this.horario,
    this.precioRango,
    this.tags,
    this.activo = true,
  });

  factory LugarModel.fromJson(Map<String, dynamic> json) =>
      _$LugarModelFromJson(json);

  Map<String, dynamic> toJson() => _$LugarModelToJson(this);

  Lugar toLugar() {
    return Lugar(
      id: id,
      nombre: nombre,
      categoria: categoria,
      imagenUrl: imagenUrl ?? _placeholderForCategory(categoria),
      rating: rating ?? 0,
      descripcion: descripcion ?? '',
      ubicacion: direccion ?? '',
      latitud: latitud ?? 0,
      longitud: longitud ?? 0,
      telefono: telefono,
      tags: tags ?? [],
      horario: _formatHorario(),
    );
  }

  String? _formatHorario() {
    if (horario == null || horario!.isEmpty) return null;
    return horario!.entries.map((e) => '${e.key}: ${e.value}').join(' · ');
  }

  static String _placeholderForCategory(String categoria) {
    const placeholders = <String, String>{
      'restaurante': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
      'parque': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600',
      'museo': 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=600',
      'bar': 'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=600',
      'cafe': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
    };
    return placeholders[categoria.toLowerCase()] ??
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=600';
  }
}
