import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class QshChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const QshChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedBorder = context.dividerStrong;
    final unselectedText = context.textSecondary;

    return Material(
      color: isSelected ? AppTheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: isSelected
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: unselectedBorder),
                ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black87 : unselectedText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
