import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/lugar.dart';
import 'providers/favorites_provider.dart';
import '../../../shared/widgets/qsh_image_header.dart';
import '../../../shared/widgets/qsh_rating_badge.dart';

import '../../../shared/widgets/transport_buttons.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../events/domain/evento.dart';
import '../../../shared/widgets/gradient_text.dart';

class LugarDetailScreen extends ConsumerWidget {
  final Lugar lugar;

  const LugarDetailScreen({super.key, required this.lugar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(lugar.id);
    final lugarEventos = mockEventos
        .where((e) => e.lugarId == lugar.id)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          QshImageHeader(
            imageUrl: lugar.imagenUrl,
            heroTag: 'lugar-image-${lugar.id}',
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                onPressed: () => ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(lugar.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.secondary),
                        ),
                        child: Text(
                          lugar.categoria.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (lugar.rating > 0)
                        QshRatingBadge(
                          rating: lugar.rating,
                          iconSize: 20,
                          fontSize: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  GradientText(
                    lugar.nombre,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: context.textSubtle,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lugar.ubicacion,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  // Schedule
                  if (lugar.horario != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: context.textSubtle,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lugar.horario!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Phone
                  if (lugar.telefono != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          color: context.textSubtle,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lugar.telefono!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],

                  // Tags
                  if (lugar.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: lugar.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: context.dividerColor),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: context.textSubtle,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  // Photo gallery (Parche/Pro only)
                  if (lugar.fotos.length > 1) ...[
                    const SizedBox(height: 28),
                    const SectionHeader(title: 'Fotos'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: lugar.fotos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: lugar.fotos[index].startsWith('http')
                                  ? Image.network(
                                      lugar.fotos[index],
                                      width: 160,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 160,
                                        height: 120,
                                        color: AppTheme.surface,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.white24,
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      lugar.fotos[index],
                                      width: 160,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 160,
                                        height: 120,
                                        color: AppTheme.surface,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.white24,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Description
                  GradientText(
                    'Sobre el parche',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lugar.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: context.textTertiary,
                    ),
                  ),

                  // Menu PDF button (Parche/Pro only)
                  if (lugar.menuPdfUrl != null) ...[
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Ver menú'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],

                  // Transport buttons
                  const SizedBox(height: 28),
                  TransportButtons(lugar: lugar),

                  // Events at this place
                  if (lugarEventos.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Eventos aquí'),
                    const SizedBox(height: 12),
                    ...lugarEventos.map(
                      (evento) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: EventCard(
                          evento: evento,
                          onTap: () => context.push('/event/${evento.id}'),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
