import 'package:json_annotation/json_annotation.dart';

import '../../domain/evento.dart';

part 'evento_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: true)
class EventoModel {
  final String id;
  final String titulo;
  final String? descripcion;
  @JsonKey(name: 'imagen_url')
  final String? imagenUrl;
  @JsonKey(name: 'lugar_id')
  final String? lugarId;
  @JsonKey(name: 'fecha_inicio')
  final DateTime fechaInicio;
  @JsonKey(name: 'fecha_fin')
  final DateTime? fechaFin;
  final double? precio;
  final String categoria;
  final int? capacidad;
  final bool activo;

  const EventoModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.imagenUrl,
    this.lugarId,
    required this.fechaInicio,
    this.fechaFin,
    this.precio,
    required this.categoria,
    this.capacidad,
    this.activo = true,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) =>
      _$EventoModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventoModelToJson(this);

  Evento toEvento({String lugarNombre = ''}) {
    return Evento(
      id: id,
      nombre: titulo,
      descripcion: descripcion ?? '',
      imagenUrl: imagenUrl ?? '',
      lugarId: lugarId ?? '',
      lugarNombre: lugarNombre,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin ?? fechaInicio.add(const Duration(hours: 3)),
      categoria: categoria,
      precio: precio,
    );
  }
}
