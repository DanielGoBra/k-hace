import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/qsh_image_header.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/evento.dart';
import '../../home/domain/lugar.dart';
import '../../home/presentation/providers/home_providers.dart';
import 'providers/events_providers.dart';
import '../../../shared/widgets/gradient_text.dart';

class EventDetailScreen extends ConsumerWidget {
  final Evento evento;

  const EventDetailScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedEventsProvider).contains(evento.id);
    final lugares = ref.watch(lugaresListProvider);
    final source = lugares.isEmpty ? mockLugares : lugares;
    final lugar = source.where((l) => l.id == evento.lugarId).firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          QshImageHeader(
            imageUrl: evento.imagenUrl,
            heroTag: 'event-image-${evento.id}',
            actions: [
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppTheme.primary : null,
                ),
                onPressed: () => ref
                    .read(savedEventsProvider.notifier)
                    .toggleEvent(evento.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & price
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
                          evento.categoria.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (evento.esDestacado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.highlight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: AppTheme.highlight,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'DESTACADO',
                                style: TextStyle(
                                  color: AppTheme.highlight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  GradientText(
                    evento.nombre,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 20),

                  // Date & time
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: _formatDate(evento.fechaInicio),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time,
                    label:
                        '${_formatTime(evento.fechaInicio)} - ${_formatTime(evento.fechaFin)}',
                  ),
                  const SizedBox(height: 12),

                  // Venue
                  if (lugar != null)
                    GestureDetector(
                      onTap: () => context.push('/detail/${lugar.id}'),
                      child: _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: evento.lugarNombre,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: context.textSubtle,
                          size: 20,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Price
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: evento.esGratis
                        ? 'Entrada libre'
                        : '\$${evento.precio!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')} COP',
                    labelColor: evento.esGratis
                        ? AppTheme.success
                        : AppTheme.primary,
                  ),

                  const SizedBox(height: 32),

                  // Description
                  GradientText(
                    'Sobre el evento',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    evento.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: context.textTertiary,
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.background.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: context.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_month),
                label: const Text('ME INTERESA'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${days[date.weekday - 1]} ${date.day} de ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'pm' : 'am';
    final min = date.minute.toString().padLeft(2, '0');
    return '${hour == 0 ? 12 : hour}:$min $amPm';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.textSubtle),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor ?? context.textTertiary,
              fontSize: 15,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
