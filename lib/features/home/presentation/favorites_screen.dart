import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/favorites_provider.dart';
import 'providers/home_providers.dart';
import './widgets/pulse_card.dart';
import '../domain/lugar.dart';
import '../../../shared/widgets/qsh_empty_state.dart';
import '../../../shared/widgets/qsh_scaffold_background.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/auth_brand_logo.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final lugares = ref.watch(lugaresListProvider);
    final source = lugares.isEmpty ? mockLugares : lugares;
    final favoriteLugares = source
        .where((l) => favorites.contains(l.id))
        .toList();

    return QshScaffoldBackground(
      appBar: AppBar(
        title: const GradientText('Mis Planes'),
        actions: const [
          AuthBrandLogo(maxWidth: 40, glowOpacity: 0, padding: EdgeInsets.zero),
          SizedBox(width: 8),
        ],
      ),
      child: favoriteLugares.isEmpty
          ? const QshEmptyState(
              icon: Icons.favorite_outline,
              title: 'Aún no tienes planes guardados',
              subtitle: 'Explora y guarda los parches que más te gusten.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteLugares.length,
              itemBuilder: (context, index) {
                final lugar = favoriteLugares[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PulseCard(
                    lugar: lugar,
                    onTap: () =>
                        context.push('/detail/${lugar.id}', extra: lugar),
                  ),
                );
              },
            ),
    );
  }
}
