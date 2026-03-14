import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  void _showComingSoon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inicio con $provider disponible próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 18),
        // Divider row
        Row(
          children: [
            Expanded(child: Divider(color: context.dividerStrong)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'o continuar con',
                style: TextStyle(color: context.textTertiary, fontSize: 13),
              ),
            ),
            Expanded(child: Divider(color: context.dividerStrong)),
          ],
        ),
        const SizedBox(height: 16),
        // Social buttons
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                iconPath: 'lib/assets/icons/google_icon.svg',
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderColor: context.dividerStrong,
                iconColor: null, // multicolor SVG
                onTap: () => _showComingSoon(context, 'Google'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                label: 'Facebook',
                iconPath: 'lib/assets/icons/facebook_icon.svg',
                backgroundColor: const Color(0xFF1877F2),
                borderColor: const Color(0xFF1877F2),
                iconColor: Colors.white,
                textColor: Colors.white,
                onTap: () => _showComingSoon(context, 'Facebook'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                iconPath: 'lib/assets/icons/apple_icon.svg',
                backgroundColor: isDark ? Colors.white : Colors.black,
                borderColor: isDark ? Colors.white : Colors.black,
                iconColor: isDark ? Colors.black : Colors.white,
                textColor: isDark ? Colors.black : Colors.white,
                onTap: () => _showComingSoon(context, 'Apple'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color backgroundColor;
  final Color borderColor;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.iconPath,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? context.textPrimary;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 22,
                height: 22,
                colorFilter: iconColor != null
                    ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                    : null,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: defaultTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
