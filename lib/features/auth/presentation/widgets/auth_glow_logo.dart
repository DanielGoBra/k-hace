import 'package:flutter/material.dart';

import '../../../../core/constants/brand_assets.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated logo with pulsing glow effect.
/// Self-contained: manages its own [AnimationController].
class AuthGlowLogo extends StatefulWidget {
  const AuthGlowLogo({super.key});

  @override
  State<AuthGlowLogo> createState() => _AuthGlowLogoState();
}

class _AuthGlowLogoState extends State<AuthGlowLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.12, end: 0.30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Logo de ¿K hace!',
        child: ListenableBuilder(
          listenable: _glow,
          builder: (context, child) => Container(
            width: 220,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: _glow.value),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppTheme.secondary
                      .withValues(alpha: _glow.value * 0.65),
                  blurRadius: 36,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              BrandAssets.logoCompact,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
