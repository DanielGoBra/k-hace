import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/widgets/qsh_chip.dart';
import '../../../shared/widgets/qsh_rating_badge.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/domain/lugar.dart';
import '../../home/presentation/providers/home_providers.dart';

final mapCategoryProvider = StateProvider<String>((ref) => 'Todos');
final selectedMapLugarProvider = StateProvider<Lugar?>((ref) => null);
final selectedPoiProvider = StateProvider<_PoiInfo?>((ref) => null);

class _PoiInfo {
  final String name;
  final String? group;
  final String? category;

  const _PoiInfo({required this.name, this.group, this.category});
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _lugaresSourceId = 'qsh-lugares-source';
  static const _lugaresLayerId = 'qsh-lugares-layer';
  static const _lugaresSelectedGlowLayerId = 'qsh-lugares-selected-glow-layer';
  static const _lugaresSelectedLayerId = 'qsh-lugares-selected-layer';

  MapboxMap? _mapboxMap;
  GeoJsonSource? _lugaresSource;
  List<Lugar> _currentLugares = [];

  Position get _fallbackCenter => Position(-75.5812, 6.2442);

  @override
  void dispose() => super.dispose();

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _enableLocationPuck();
    _setupInteractions();
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.style.setStyleImportConfigProperties('basemap', {
      'lightPreset': _resolveLightPreset(DateTime.now()),
      'theme': 'default',
    });

    await _ensureLugarLayer();
    await _syncLugarSource();
  }

  // ── Location ──────────────────────────────────────────────

  Future<void> _enableLocationPuck() async {
    if (kIsWeb) return;

    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted || _mapboxMap == null) return;

    _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: AppTheme.primary.toARGB32(),
        pulsingMaxRadius: 24.0,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
      ),
    );
  }

  Future<void> _ensureLugarLayer() async {
    if (_mapboxMap == null) return;

    _lugaresSource = GeoJsonSource(
      id: _lugaresSourceId,
      data: _buildGeoJson([]),
    );

    await _mapboxMap!.style.addSource(_lugaresSource!);
    await _mapboxMap!.style.addLayer(
      CircleLayer(
        id: _lugaresLayerId,
        sourceId: _lugaresSourceId,
        slot: 'middle',
        circleRadius: 9.5,
        circleBlur: 0.08,
        circleOpacity: 0.96,
        circleStrokeWidth: 2.5,
        circleStrokeColor: Colors.white.toARGB32(),
        circleEmissiveStrength: 0.65,
        circleColorExpression: const [
          'match',
          ['get', 'categoria'],
          'Rumba',
          '#F471B5',
          'Gastronomía',
          '#FBBF24',
          'Aventura',
          '#34D399',
          'Parques',
          '#4ADE80',
          'Café',
          '#A78BFA',
          'Cultura',
          '#F472B6',
          'Hospedaje',
          '#38BDF8',
          'Comercio',
          '#FBBF24',
          'Servicios',
          '#94A3B8',
          'Educación',
          '#2DD4BF',
          '#38BDF8',
        ],
      ),
    );

    await _mapboxMap!.style.addLayer(
      CircleLayer(
        id: _lugaresSelectedGlowLayerId,
        sourceId: _lugaresSourceId,
        slot: 'middle',
        filter: const [
          '==',
          ['get', 'selected'],
          true,
        ],
        circleRadius: 20.0,
        circleBlur: 0.75,
        circleOpacity: 0.34,
        circleColor: AppTheme.primary.toARGB32(),
        circleEmissiveStrength: 1.0,
      ),
    );

    await _mapboxMap!.style.addLayer(
      CircleLayer(
        id: _lugaresSelectedLayerId,
        sourceId: _lugaresSourceId,
        slot: 'middle',
        filter: const [
          '==',
          ['get', 'selected'],
          true,
        ],
        circleRadius: 12.5,
        circleOpacity: 1.0,
        circleStrokeWidth: 3.0,
        circleStrokeColor: Colors.white.toARGB32(),
        circleColor: AppTheme.primary.toARGB32(),
        circleEmissiveStrength: 1.0,
      ),
    );
  }

  Future<void> _syncLugarSource() async {
    if (_lugaresSource == null) return;

    final selectedCategory = ref.read(mapCategoryProvider);
    final selectedLugar = ref.read(selectedMapLugarProvider);
    final lugares = ref.read(lugaresListProvider);
    final source = lugares.isEmpty ? mockLugares : lugares;
    _currentLugares = selectedCategory == 'Todos'
        ? source
        : source.where((l) => l.categoria == selectedCategory).toList();

    if (selectedLugar != null &&
        !_currentLugares.any((lugar) => lugar.id == selectedLugar.id)) {
      ref.read(selectedMapLugarProvider.notifier).state = null;
    }

    await _lugaresSource!.updateGeoJSON(_buildGeoJson(_currentLugares));
  }

  // ── Interactions API (Standard style featuresets) ──────────

  void _setupInteractions() {
    if (_mapboxMap == null) return;

    // POI tap → show POI info chip
    _mapboxMap!.addInteraction(
      TapInteraction(StandardPOIs(), (poi, _) {
        ref.read(selectedMapLugarProvider.notifier).state = null;
        ref.read(selectedPoiProvider.notifier).state = _PoiInfo(
          name: poi.name ?? 'Sin nombre',
          group: poi.group,
          category: poi.category,
        );
      }, stopPropagation: false),
      interactionID: 'poi_tap',
    );

    // Building tap → highlight building
    _mapboxMap!.addInteraction(
      TapInteraction(StandardBuildings(), (building, _) {
        _mapboxMap!.setFeatureStateForFeaturesetFeature(
          building,
          StandardBuildingsState(highlight: true),
        );
      }),
      interactionID: 'building_tap',
    );

    // Place label tap → select label
    _mapboxMap!.addInteraction(
      TapInteraction(StandardPlaceLabels(), (label, _) {
        _mapboxMap!.setFeatureStateForFeaturesetFeature(
          label,
          StandardPlaceLabelsState(select: true),
        );
      }),
      interactionID: 'place_label_tap',
    );

    // Long press → reset all feature states
    _mapboxMap!.addInteraction(
      LongTapInteraction.onMap((_) {
        _mapboxMap!.resetFeatureStatesForFeatureset(StandardPOIs());
        _mapboxMap!.resetFeatureStatesForFeatureset(StandardBuildings());
        _mapboxMap!.resetFeatureStatesForFeatureset(StandardPlaceLabels());
        ref.read(selectedPoiProvider.notifier).state = null;
        ref.read(selectedMapLugarProvider.notifier).state = null;
      }),
      interactionID: 'map_long_tap',
    );
  }

  // ── Camera helpers ────────────────────────────────────────

  void _flyToLugar(Lugar lugar) {
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lugar.longitud, lugar.latitud)),
        zoom: 14.0,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _handleMapTap(MapContentGestureContext context) async {
    if (_mapboxMap == null || kIsWeb) return;

    final results = await _mapboxMap!.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(
        ScreenCoordinate(
          x: context.touchPosition.x,
          y: context.touchPosition.y,
        ),
      ),
      RenderedQueryOptions(layerIds: const [_lugaresLayerId]),
    );

    for (final result in results) {
      final queried = result?.queriedFeature.feature;
      final lugarId = _extractLugarId(queried);
      if (lugarId == null) continue;

      final lugar = _findLugarById(lugarId);
      if (lugar == null) continue;

      ref.read(selectedMapLugarProvider.notifier).state = lugar;
      ref.read(selectedPoiProvider.notifier).state = null;
      _flyToLugar(lugar);
      return;
    }

    ref.read(selectedMapLugarProvider.notifier).state = null;
  }

  Future<void> _flyToUserLocation() async {
    ref.read(selectedMapLugarProvider.notifier).state = null;
    ref.read(selectedPoiProvider.notifier).state = null;

    if (_mapboxMap == null) return;

    try {
      final permission = await geo.Geolocator.checkPermission();
      var effectivePermission = permission;

      if (effectivePermission == geo.LocationPermission.denied) {
        effectivePermission = await geo.Geolocator.requestPermission();
      }

      if (effectivePermission == geo.LocationPermission.always ||
          effectivePermission == geo.LocationPermission.whileInUse) {
        final current = await geo.Geolocator.getCurrentPosition(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.high,
          ),
        );

        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(current.longitude, current.latitude),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 800),
        );
        return;
      }

      final lastKnown = await geo.Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(lastKnown.longitude, lastKnown.latitude),
            ),
            zoom: 14.5,
          ),
          MapAnimationOptions(duration: 800),
        );
        return;
      }
    } catch (_) {
      await _enableLocationPuck();
    }

    _mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: _fallbackCenter), zoom: 14.0),
      MapAnimationOptions(duration: 800),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  String _poiGroupIcon(String? group) {
    switch (group) {
      case 'food_and_drink':
      case 'food and drink':
        return 'Gastronomía';
      case 'transit':
        return 'Transporte';
      case 'lodging':
        return 'Hospedaje';
      case 'shopping':
        return 'Compras';
      case 'education':
        return 'Educación';
      case 'commercial_services':
      case 'commercial services':
        return 'Servicios';
      case 'motorist':
        return 'Automotriz';
      case 'arts_and_entertainment':
      case 'arts and entertainment':
        return 'Entretenimiento';
      default:
        return group ?? 'Punto de interés';
    }
  }

  String _resolveLightPreset(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 8) return 'dawn';
    if (hour >= 8 && hour < 18) return 'day';
    if (hour >= 18 && hour < 20) return 'dusk';
    return 'night';
  }

  String _buildGeoJson(List<Lugar> lugares) {
    final selectedLugarId = ref.read(selectedMapLugarProvider)?.id;

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': lugares
          .map(
            (lugar) => {
              'type': 'Feature',
              'id': lugar.id,
              'properties': {
                'id': lugar.id,
                'nombre': lugar.nombre,
                'categoria': lugar.categoria,
                'selected': lugar.id == selectedLugarId,
              },
              'geometry': {
                'type': 'Point',
                'coordinates': [lugar.longitud, lugar.latitud],
              },
            },
          )
          .toList(),
    });
  }

  String? _extractLugarId(Map<String?, Object?>? feature) {
    if (feature == null) return null;

    final directId = feature['id'];
    if (directId != null) return directId.toString();

    final properties = feature['properties'];
    if (properties is Map) {
      final nestedId = properties['id'];
      if (nestedId != null) return nestedId.toString();
    }

    return null;
  }

  Lugar? _findLugarById(String id) {
    for (final lugar in _currentLugares) {
      if (lugar.id == id) return lugar;
    }
    return null;
  }

  Widget _buildWebFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08111F), Color(0xFF14263C), Color(0xFF0C1728)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.travel_explore, color: AppTheme.primary, size: 42),
              SizedBox(height: 16),
              Text(
                'Vista web del mapa en preparación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'La experiencia final del mapa sigue optimizada para Android e iOS. En Chrome dejamos esta ruta estable para revisar el resto de la interfaz sin un crash del renderer nativo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(mapCategoryProvider);
    final selectedLugar = ref.watch(selectedMapLugarProvider);
    final selectedPoi = ref.watch(selectedPoiProvider);

    ref.listen<String>(mapCategoryProvider, (prev, next) {
      _syncLugarSource();
    });

    ref.listen<Lugar?>(selectedMapLugarProvider, (prev, next) {
      _syncLugarSource();
    });

    // Refresh annotations when Supabase data finishes loading
    ref.listen(lugaresProvider, (prev, next) {
      if (next.hasValue) _syncLugarSource();
    });

    final hasBottomCard = selectedLugar != null || selectedPoi != null;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ── Mapbox Map (Standard style) ─────────────────
            if (kIsWeb)
              _buildWebFallback()
            else
              MapWidget(
                cameraOptions: CameraOptions(
                  center: Point(coordinates: _fallbackCenter),
                  zoom: 12.0,
                  pitch: 45.0,
                ),
                styleUri: MapboxStyles.STANDARD,
                onMapCreated: _onMapCreated,
                onStyleLoadedListener: _onStyleLoaded,
                onTapListener: _handleMapTap,
              ),

            // ── Category chips overlay ──────────────────────
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children:
                      [
                            'Todos',
                            'Rumba',
                            'Gastronomía',
                            'Aventura',
                            'Parques',
                            'Café',
                            'Cultura',
                            'Hospedaje',
                            'Comercio',
                            'Servicios',
                            'Educación',
                          ]
                          .map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: QshChip(
                                label: cat,
                                isSelected: selectedCategory == cat,
                                onTap: () =>
                                    ref
                                            .read(mapCategoryProvider.notifier)
                                            .state =
                                        cat,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),

            // ── My location button ──────────────────────────
            if (!kIsWeb)
              Positioned(
                bottom: hasBottomCard ? 200 : 24,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'my_location',
                  onPressed: _flyToUserLocation,
                  backgroundColor: AppTheme.surface,
                  child: const Icon(Icons.my_location, color: AppTheme.primary),
                ),
              ),

            // ── Bottom card: selected Lugar ─────────────────
            if (selectedLugar != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push(
                    '/detail/${selectedLugar.id}',
                    extra: selectedLugar,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: selectedLugar.imagenUrl.startsWith('http')
                              ? Image.network(
                                  selectedLugar.imagenUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  selectedLugar.imagenUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedLugar.nombre,
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedLugar.ubicacion,
                                style: TextStyle(
                                  color: context.textSubtle,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (selectedLugar.rating > 0)
                                    QshRatingBadge(
                                      rating: selectedLugar.rating,
                                      iconSize: 14,
                                      fontSize: 13,
                                    ),
                                  const Spacer(),
                                  Text(
                                    'Ver detalle',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: AppTheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Bottom chip: selected Mapbox POI ────────────
            if (selectedPoi != null && selectedLugar == null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedPoi.name,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _poiGroupIcon(selectedPoi.group),
                              style: TextStyle(
                                color: context.textSubtle,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(selectedPoiProvider.notifier).state = null,
                        child: Icon(
                          Icons.close,
                          color: context.textSubtle,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
