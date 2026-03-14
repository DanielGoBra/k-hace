import 'package:flutter/material.dart';

enum AmbientGifPreset {
  standard,
  onboarding,
  authLanding,
  authFormRight,
  authFormLeft,
}

class AmbientGifBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final String backgroundAsset;
  final AmbientGifPreset preset;
  final Alignment imageAlignment;
  final double imageOpacity;
  final double imageScale;
  final BoxFit imageFit;
  final double verticalOverlayOpacity;
  final double horizontalOverlayOpacity;
  final double baseOverlayOpacity;

  const AmbientGifBackground({
    super.key,
    required this.child,
    this.padding,
    this.backgroundAsset = _defaultBackgroundAsset,
    this.preset = AmbientGifPreset.standard,
    this.imageAlignment = Alignment.centerRight,
    this.imageOpacity = 1,
    this.imageScale = 1,
    this.imageFit = BoxFit.cover,
    this.verticalOverlayOpacity = 1,
    this.horizontalOverlayOpacity = 1,
    this.baseOverlayOpacity = 1,
  });

  static const _defaultBackgroundAsset = 'lib/assets/background.gif';

  double get _resolvedImageOpacity {
    if (imageOpacity != 1) return imageOpacity;
    switch (preset) {
      case AmbientGifPreset.onboarding:
        return 1;
      case AmbientGifPreset.authLanding:
      case AmbientGifPreset.authFormRight:
      case AmbientGifPreset.authFormLeft:
        return 1;
      case AmbientGifPreset.standard:
        return 0.98;
    }
  }

  double get _resolvedImageScale {
    if (imageScale != 1) return imageScale;
    switch (preset) {
      case AmbientGifPreset.onboarding:
        return 1.06;
      case AmbientGifPreset.authLanding:
        return 1.12;
      case AmbientGifPreset.authFormRight:
        return 1.16;
      case AmbientGifPreset.authFormLeft:
        return 1.18;
      case AmbientGifPreset.standard:
        return 1;
    }
  }

  double get _resolvedVerticalOverlayOpacity {
    if (verticalOverlayOpacity != 1) return verticalOverlayOpacity;
    switch (preset) {
      case AmbientGifPreset.onboarding:
        return 0.62;
      case AmbientGifPreset.authLanding:
        return 0.7;
      case AmbientGifPreset.authFormRight:
      case AmbientGifPreset.authFormLeft:
        return 0.66;
      case AmbientGifPreset.standard:
        return 0.84;
    }
  }

  double get _resolvedHorizontalOverlayOpacity {
    if (horizontalOverlayOpacity != 1) return horizontalOverlayOpacity;
    switch (preset) {
      case AmbientGifPreset.onboarding:
        return 0.56;
      case AmbientGifPreset.authLanding:
        return 0.64;
      case AmbientGifPreset.authFormRight:
      case AmbientGifPreset.authFormLeft:
        return 0.6;
      case AmbientGifPreset.standard:
        return 0.8;
    }
  }

  double get _resolvedBaseOverlayOpacity {
    if (baseOverlayOpacity != 1) return baseOverlayOpacity;
    switch (preset) {
      case AmbientGifPreset.onboarding:
        return 0.52;
      case AmbientGifPreset.authLanding:
        return 0.62;
      case AmbientGifPreset.authFormRight:
      case AmbientGifPreset.authFormLeft:
        return 0.58;
      case AmbientGifPreset.standard:
        return 0.8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isLight = Theme.of(context).brightness == Brightness.light;
    // In light mode, boost overlay opacity so GIF blends with light UI
    final lightBoost = isLight ? 1.25 : 1.0;

    final baseOp = (_resolvedBaseOverlayOpacity * lightBoost).clamp(0.0, 1.0);
    final vertOp =
        (_resolvedVerticalOverlayOpacity * lightBoost).clamp(0.0, 1.0);
    final horizOp =
        (_resolvedHorizontalOverlayOpacity * lightBoost).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF060816).withValues(alpha: baseOp),
            bg.withValues(alpha: baseOp * 0.84),
            const Color(0xFF060816).withValues(alpha: baseOp),
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: _resolvedImageOpacity,
            child: Transform.scale(
              scale: _resolvedImageScale,
              alignment: imageAlignment,
              child: Image.asset(
                backgroundAsset,
                fit: imageFit,
                alignment: imageAlignment,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bg.withValues(alpha: 0.92 * vertOp),
                  bg.withValues(alpha: 0.68 * vertOp),
                  bg.withValues(alpha: 0.78 * vertOp),
                  bg.withValues(alpha: 0.96 * vertOp),
                ],
                stops: const [0, 0.22, 0.68, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  bg.withValues(alpha: 0.88 * horizOp),
                  bg.withValues(alpha: 0.4 * horizOp),
                  bg.withValues(alpha: 0.72 * horizOp),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
