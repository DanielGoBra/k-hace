import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_providers.dart';

final greetingProvider = Provider<String>((ref) {
  final user = ref.watch(userProfileProvider);
  final hour = DateTime.now().hour;

  final saludo = switch (hour) {
    >= 5 && < 12 => 'Buenos días',
    >= 12 && < 18 => 'Buenas tardes',
    _ => 'Buenas noches',
  };

  final nombre = user?.nombre.split(' ').first ?? 'Explorador';
  return 'Hola, $saludo $nombre';
});
