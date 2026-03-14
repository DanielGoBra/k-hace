import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QshSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool autofocus;
  final TextEditingController? controller;

  const QshSearchBar({
    super.key,
    this.hintText = '¿A dónde quieres ir hoy?',
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.dividerColor),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: context.textSecondary),
          hintText: hintText,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: TextStyle(color: context.textSubtle),
          fillColor: Colors.transparent,
          filled: true,
        ),
      ),
    );
  }
}
