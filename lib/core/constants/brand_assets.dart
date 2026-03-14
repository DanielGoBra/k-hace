class BrandAssets {
  static const String logoPrimarySvg = 'lib/assets/logos/logo_svg.svg';
  static const String logoCompact = 'lib/assets/logos/logo_200x200.png';

  // Temporalmente ambas variantes apuntan al SVG principal hasta cerrar
  // con el equipo cuál archivo corresponde a cada contexto visual.
  static const String logoOnDark = logoPrimarySvg;
  static const String logoOnLight = logoPrimarySvg;
  static const String logoFallbackRaster = 'lib/assets/logos/logo_940x788.png';

  const BrandAssets._();
}
