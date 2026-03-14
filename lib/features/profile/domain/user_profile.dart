class UserProfile {
  final String id;
  final String nombre;
  final String email;
  final String? avatarUrl;
  final String ciudad;
  final List<String> intereses;
  final DateTime fechaRegistro;

  const UserProfile({
    required this.id,
    required this.nombre,
    required this.email,
    this.avatarUrl,
    required this.ciudad,
    this.intereses = const [],
    required this.fechaRegistro,
  });

  String get iniciales {
    final parts = nombre.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  UserProfile copyWith({
    String? id,
    String? nombre,
    String? email,
    String? avatarUrl,
    String? ciudad,
    List<String>? intereses,
    DateTime? fechaRegistro,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ciudad: ciudad ?? this.ciudad,
      intereses: intereses ?? this.intereses,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}

final mockUser = UserProfile(
  id: 'u1',
  nombre: 'Santiago Ríos',
  email: 'santiago.rios@gmail.com',
  ciudad: 'Medellín',
  intereses: ['Rumba', 'Gastronomía', 'Café', 'Aventura'],
  fechaRegistro: DateTime(2024, 6, 15),
);
