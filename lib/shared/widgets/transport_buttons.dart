import 'package:flutter/material.dart';
import '../../features/home/domain/lugar.dart';
import '../../core/theme/app_theme.dart';

class TransportButtons extends StatelessWidget {
  final Lugar lugar;
  final VoidCallback? onComoLlegar;
  final VoidCallback? onUber;
  final VoidCallback? onDidi;

  const TransportButtons({
    super.key,
    required this.lugar,
    this.onComoLlegar,
    this.onUber,
    this.onDidi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo llegar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TransportButton(
                icon: Icons.directions,
                label: 'Maps',
                color: AppTheme.primary,
                onTap: onComoLlegar,
              ),
            ),
            if (lugar.planTipo != PlanTipo.basico) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _TransportButton(
                  icon: Icons.local_taxi,
                  label: 'Uber',
                  color: Colors.white,
                  onTap: onUber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TransportButton(
                  icon: Icons.directions_car,
                  label: 'DiDi',
                  color: const Color(0xFFFF6600),
                  onTap: onDidi,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TransportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _TransportButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
