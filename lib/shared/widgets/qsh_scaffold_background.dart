import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Scaffold wrapper that adds a subtle Night Metalist gradient background.
///
/// In dark mode:  deep radial glow of purple/indigo over the dark surface.
/// In light mode: soft diagonal gradient from lavender to white.
class QshScaffoldBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const QshScaffoldBackground({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  static const _backgroundAsset = 'lib/assets/background.gif';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gifOpacity = isDark ? 0.15 : 0.09;

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: isDark ? _darkGradient : _lightGradient,
            ),
            child: const SizedBox.expand(),
          ),
          // Subtle GIF layer
          Opacity(
            opacity: gifOpacity,
            child: Image.asset(
              _backgroundAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }

  // Dark: diagonal glow with purple/indigo tint
  static final Gradient _darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.background,
      Color.lerp(AppTheme.background, AppTheme.primary, 0.18)!,
      Color.lerp(AppTheme.background, AppTheme.secondary, 0.14)!,
      AppTheme.background,
    ],
    stops: const [0.0, 0.35, 0.65, 1.0],
  );

  // Light: diagonal flow with visible lavender/indigo tint
  static final Gradient _lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.backgroundLight,
      Color.lerp(AppTheme.backgroundLight, AppTheme.primary, 0.15)!,
      Color.lerp(AppTheme.backgroundLight, AppTheme.secondary, 0.10)!,
      AppTheme.backgroundLight,
    ],
    stops: const [0.0, 0.3, 0.6, 1.0],
  );
}
