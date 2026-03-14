import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Text widget with a purple→indigo gradient matching the Night Metalist brand.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final List<Color>? colors;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: colors ?? const [AppTheme.primary, AppTheme.secondary],
    );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
