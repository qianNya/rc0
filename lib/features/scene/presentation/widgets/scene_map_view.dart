import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/location/location_snackbar.dart';
import '../../../../core/location/map_city_catalog.dart';
import '../../../../core/location/map_place_service.dart';
import '../../../../core/location/map_nearby_place.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../studio/presentation/widgets/script_studio_glass_widgets.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import 'scene_map_city_picker.dart';
import 'scene_map_place_list.dart';
import 'scene_map_pick.dart';
import 'scene_map_zoom_controls.dart';

class SceneMapView extends StatefulWidget {
  const SceneMapView({
    super.key,
    required this.repo,
    this.isLoggedIn = false,
    this.onCreateSceneAt,
    this.onSceneTap,
  });

  final SceneRepository repo;
  final bool isLoggedIn;
  final SceneMapCreateCallback? onCreateSceneAt;
  final void Function(SceneEntry entry)? onSceneTap;

  @override
  State<SceneMapView> createState() => _SceneMapViewState();
}

class _SceneMapViewState extends State<SceneMapView> {
  final _mapController = MapController();
  Timer? _debounce;
  String _mapCity = MapCityCatalog.defaultCityName;
  String? _lastCategory;
  String? _lastSearchQuery;
  LatLng? _selectedPoint;
  MapNearbyPlace? _selectedPlace;
  List<MapNearbyPlace> _nearbyPlaces = const [];
  bool _placesLoading = false;
  String? _placesError;
  LatLng? _userLocation;
  bool _locating = false;
  double _zoom = MapCityCatalog.defaultZoom;

  @override
  void initState() {
    super.initState();
    _lastCategory = widget.repo.category;
    _lastSearchQuery = widget.repo.searchQuery;
    widget.repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.repo.removeListener(_onRepoChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (!mounted) return;

    final category = widget.repo.category;
    final searchQuery = widget.repo.searchQuery;
    if (category != _lastCategory || searchQuery != _lastSearchQuery) {
      _lastCategory = category;
      _lastSearchQuery = searchQuery;
      _loadVisibleScenes();
    }

    _safeSetState(() {});
  }

  /// Avoid setState during map gesture / layout (semantics parentDataDirty).
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  void _onMapMoved() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadVisibleScenes);
  }

  Future<void> _loadVisibleScenes() async {
    final bounds = _mapController.camera.visibleBounds;
    await widget.repo.loadMapScenes(
      minLat: bounds.south,
      maxLat: bounds.north,
      minLng: bounds.west,
      maxLng: bounds.east,
      city: _mapCity,
    );
  }

  void _selectPoint(LatLng point) {
    if (!widget.isLoggedIn) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('请先登录后再添加场景'),
            action: SnackBarAction(
              label: '去登录',
              onPressed: () => context.push(AppRoutes.login),
            ),
          ),
        );
      return;
    }
    _safeSetState(() => _selectedPoint = point);
    _loadNearbyPlaces(point);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _selectPoint(point);
  }

  void _onMapLongPress(TapPosition tapPosition, LatLng point) {
    _selectPoint(point);
  }

  void _clearSelection() {
    _safeSetState(() {
      _selectedPoint = null;
      _selectedPlace = null;
      _nearbyPlaces = const [];
      _placesLoading = false;
      _placesError = null;
    });
  }

  Future<void> _loadNearbyPlaces(LatLng point) async {
    _safeSetState(() {
      _placesLoading = true;
      _placesError = null;
      _nearbyPlaces = const [];
      _selectedPlace = null;
    });

    final result = await MapPlaceService.nearbyPlaces(point);
    if (!mounted || _selectedPoint != point) return;

    _safeSetState(() {
      _placesLoading = false;
      _nearbyPlaces = result.places;
      _placesError = result.error;
      final fallbackOnly = result.places.length == 1 &&
          result.places.first.isCoordinateFallback;
      _selectedPlace = fallbackOnly ? result.places.first : null;
    });
  }

  void _zoomBy(double delta) {
    final zoom = (_zoom + delta).clamp(
      MapCityCatalog.minZoom,
      MapCityCatalog.maxZoom,
    );
    _safeSetState(() => _zoom = zoom.toDouble());
    _mapController.move(_mapController.camera.center, _zoom);
    _onMapMoved();
  }

  Future<void> _openCityPicker() async {
    final picked = await showSceneMapCityPicker(
      context,
      selectedCity: _mapCity,
    );
    if (picked == null || !mounted) return;

    _safeSetState(() {
      _mapCity = picked.name;
      _selectedPoint = null;
      _selectedPlace = null;
      _nearbyPlaces = const [];
      _placesLoading = false;
      _placesError = null;
      _zoom = picked.zoom;
    });
    _mapController.move(picked.center, picked.zoom);
    await _loadVisibleScenes();
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    _safeSetState(() => _locating = true);

    final result = await DeviceLocationService.currentPosition();
    if (!mounted) return;

    _safeSetState(() => _locating = false);
    if (!result.isSuccess) {
      showDeviceLocationSnackBar(context, result);
      return;
    }

    final position = result.position!;
    _safeSetState(() {
      _userLocation = position;
      if (widget.isLoggedIn) {
        _selectedPoint = position;
      }
    });
    if (widget.isLoggedIn) {
      await _loadNearbyPlaces(position);
    }
    _mapController.move(position, 14);
    _onMapMoved();
  }

  Future<void> _createSceneAtSelected() async {
    final point = _selectedPoint;
    final place = _selectedPlace ??
        (point == null
            ? null
            : MapNearbyPlace(
                name: '地图选点',
                subtitle:
                    '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                point: point,
                distanceMeters: 0,
                isCoordinateFallback: true,
              ));
    final onCreate = widget.onCreateSceneAt;
    if (place == null || onCreate == null) return;

    await onCreate(
      SceneMapPick(
        point: place.point,
        city: _mapCity,
        placeName: place.isCoordinateFallback ? '' : place.name,
        address: place.subtitle,
      ),
    );
    if (!mounted) return;
    _clearSelection();
    await _loadVisibleScenes();
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repo;
    final items = repo.mapItems.where((e) => e.hasLocation).toList();
    final theme = Theme.of(context);
    final zoom = _zoom;
    final canZoomIn = zoom < MapCityCatalog.maxZoom;
    final canZoomOut = zoom > MapCityCatalog.minZoom;
    final selectionPoint = _selectedPlace?.point ?? _selectedPoint;

    if (repo.mapError != null && items.isEmpty && !repo.mapLoading) {
      return EmptyStateView(
        icon: Icons.map_outlined,
        title: '地图加载失败',
        subtitle: repo.mapError,
        actionLabel: '重试',
        onAction: _loadVisibleScenes,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: MapCityCatalog.defaultCenter,
                initialZoom: MapCityCatalog.defaultZoom,
                minZoom: MapCityCatalog.minZoom,
                maxZoom: MapCityCatalog.maxZoom,
                onTap: _onMapTap,
                onLongPress: _onMapLongPress,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    _safeSetState(() => _zoom = _mapController.camera.zoom);
                    _onMapMoved();
                  }
                },
                onMapReady: () {
                  _safeSetState(() => _zoom = _mapController.camera.zoom);
                  _loadVisibleScenes();
                },
              ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rc0.app',
              ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 28,
                      height: 28,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (selectionPoint != null)
                    Marker(
                      point: selectionPoint,
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.add_location_alt,
                        color: theme.colorScheme.tertiary,
                        size: 40,
                      ),
                    ),
                  for (final entry in items)
                    Marker(
                      point: LatLng(entry.latitude!, entry.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!context.mounted) return;
                            widget.onSceneTap?.call(entry);
                            context.push(AppRoutes.sceneDetailPath(entry.id));
                          });
                        },
                        child: Tooltip(
                          message: entry.title,
                          child: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.primary,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: AppDimensions.spacingMd,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (repo.mapLoading) ...[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
              ],
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.floatingBarRadius),
                  onTap: _openCityPicker,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.92),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.floatingBarRadius),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _mapCity,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.expand_more,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedPoint == null)
          Positioned(
            left: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingMd + 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '${items.length} 个场景',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ),
          ),
        Positioned(
          right: AppDimensions.spacingMd,
          bottom: AppDimensions.spacingMd,
          child: _locating
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : StudioGlassIconButton(
                  tooltip: '定位到当前位置',
                  icon: Icons.my_location,
                  onPressed: _locateMe,
                ),
        ),
        Positioned(
          right: AppDimensions.spacingMd,
          bottom: AppDimensions.spacingMd + 48,
          child: SceneMapZoomControls(
            canZoomIn: canZoomIn,
            canZoomOut: canZoomOut,
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
          ),
        ),
        Positioned(
          left: AppDimensions.spacingMd,
          right: AppDimensions.spacingMd,
          bottom: AppDimensions.spacingMd + 108,
          child: IgnorePointer(
            ignoring: _selectedPoint == null,
            child: AnimatedSlide(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              offset: _selectedPoint == null
                  ? const Offset(0, 0.35)
                  : Offset.zero,
              child: AnimatedOpacity(
                duration: AppMotion.fast,
                opacity: _selectedPoint == null ? 0 : 1,
                child: GlassCard(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.floatingBarRadius),
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('在此添加场景', style: AppTextStyles.label),
                      const SizedBox(height: AppDimensions.spacingXs),
                      SceneMapPlaceList(
                        places: _nearbyPlaces,
                        selected: _selectedPlace,
                        loading: _placesLoading,
                        error: _placesError,
                        onRetry: _selectedPoint == null
                            ? null
                            : () => _loadNearbyPlaces(_selectedPoint!),
                        onSelected: (place) =>
                            _safeSetState(() => _selectedPlace = place),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Row(
                        children: [
                          GlassButton(
                            label: '取消',
                            onPressed: _clearSelection,
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: GlassButton(
                              label: '添加场景',
                              icon: Icons.add_location_alt_outlined,
                              filled: true,
                              expand: true,
                              onPressed: widget.onCreateSceneAt == null ||
                                      _placesLoading ||
                                      (_selectedPlace == null &&
                                          _selectedPoint == null)
                                  ? null
                                  : _createSceneAtSelected,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_selectedPoint == null)
          Positioned(
            left: AppDimensions.spacingMd,
            right: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingMd,
            child: Center(
              child: GlassButton(
                label: widget.isLoggedIn ? '点击地图选择位置' : '登录后添加场景',
                icon: Icons.add_location_alt_outlined,
                filled: widget.isLoggedIn,
                onPressed: widget.isLoggedIn
                    ? () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('点击或长按地图选择位置'),
                            ),
                          );
                      }
                    : () => context.push(AppRoutes.login),
              ),
            ),
          ),
        if (widget.isLoggedIn && _selectedPoint == null)
          Positioned(
            top: 12,
            left: AppDimensions.spacingMd,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '点击或长按地图选点',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
