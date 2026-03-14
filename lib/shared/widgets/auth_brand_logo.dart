import 'package:flutter/material.dart';

import 'brand_logo.dart';

class AuthBrandLogo extends StatelessWidget {
  final double maxWidth;
  final double glowOpacity;
  final EdgeInsetsGeometry padding;

  const AuthBrandLogo({
    super.key,
    this.maxWidth = 280,
    this.glowOpacity = 0.22,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final tone = Theme.of(context).brightness == Brightness.dark
        ? BrandSurfaceTone.dark
        : BrandSurfaceTone.light;

    return BrandLogo(
      maxWidth: maxWidth,
      tone: tone,
      shadowOpacity: glowOpacity,
      padding: padding,
    );
  }
}
