import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/brand_assets.dart';
import '../../core/theme/app_theme.dart';

enum BrandSurfaceTone { light, dark }

class BrandLogo extends StatelessWidget {
  final double maxWidth;
  final BrandSurfaceTone tone;
  final double shadowOpacity;
  final EdgeInsetsGeometry padding;

  const BrandLogo({
    super.key,
    this.maxWidth = 280,
    this.tone = BrandSurfaceTone.dark,
    this.shadowOpacity = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  });

  String get _assetPath {
    return tone == BrandSurfaceTone.dark
        ? BrandAssets.logoOnDark
        : BrandAssets.logoOnLight;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: shadowOpacity <= 0
              ? const []
              : [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: shadowOpacity),
                    blurRadius: 26,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppTheme.secondary.withValues(
                      alpha: shadowOpacity * 0.7,
                    ),
                    blurRadius: 36,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: SvgPicture.asset(
          _assetPath,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Image.asset(
            BrandAssets.logoFallbackRaster,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
