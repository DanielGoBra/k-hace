import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QshRatingBadge extends StatelessWidget {
  final double rating;
  final double iconSize;
  final double fontSize;
  final Color? textColor;

  const QshRatingBadge({
    super.key,
    required this.rating,
    this.iconSize = 16,
    this.fontSize = 14,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: AppTheme.highlight, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor ?? context.textPrimary,
          ),
        ),
      ],
    );
  }
}
