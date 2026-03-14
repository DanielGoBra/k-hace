import 'package:flutter/material.dart';
import '../../features/events/domain/evento.dart';
import '../../core/theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.evento, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: evento.esDestacado
              ? Border.all(color: AppTheme.highlight, width: 1.5)
              : Border.all(color: context.dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppTheme.secondary.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: evento.esDestacado
                    ? AppTheme.highlight.withValues(alpha: 0.15)
                    : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayAbbr(evento.fechaInicio),
                    style: TextStyle(
                      color: evento.esDestacado
                          ? AppTheme.highlight
                          : AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${evento.fechaInicio.day}',
                    style: TextStyle(
                      color: evento.esDestacado
                          ? AppTheme.highlight
                          : AppTheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _monthAbbr(evento.fechaInicio),
                    style: TextStyle(
                      color: evento.esDestacado
                          ? AppTheme.highlight.withValues(alpha: 0.7)
                          : AppTheme.primary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (evento.esDestacado)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.highlight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DESTACADO',
                            style: TextStyle(
                              color: AppTheme.highlight,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      evento.nombre,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.lugarNombre,
                      style: TextStyle(color: context.textSubtle, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: context.textSubtle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(evento.fechaInicio)} - ${_formatTime(evento.fechaFin)}',
                          style: TextStyle(
                            color: context.textSubtle,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          evento.esGratis
                              ? 'Gratis'
                              : '\$${evento.precio!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}',
                          style: TextStyle(
                            color: evento.esGratis
                                ? AppTheme.success
                                : AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayAbbr(DateTime date) {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return days[date.weekday - 1];
  }

  String _monthAbbr(DateTime date) {
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    return months[date.month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'pm' : 'am';
    return '${hour == 0 ? 12 : hour}$amPm';
  }
}
