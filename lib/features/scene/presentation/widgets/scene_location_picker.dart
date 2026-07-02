import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/location/location_snackbar.dart';
import '../../../../core/location/map_city_catalog.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../studio/presentation/widgets/script_studio_glass_widgets.dart';

class SceneLocationPicker extends StatefulWidget {
  const SceneLocationPicker({
    super.key,
    this.initial,
    this.initialZoom = 12,
  });

  final LatLng? initial;
  final double initialZoom;

  @override
  State<SceneLocationPicker> createState() => _SceneLocationPickerState();
}

class _SceneLocationPickerState extends State<SceneLocationPicker> {
  final _mapController = MapController();
  LatLng? _selected;
  LatLng? _userLocation;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selected = point);
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);

    final result = await DeviceLocationService.currentPosition();
    if (!mounted) return;

    setState(() => _locating = false);
    if (!result.isSuccess) {
      showDeviceLocationSnackBar(context, result);
      return;
    }

    final position = result.position!;
    setState(() {
      _userLocation = position;
      _selected = position;
    });
    _mapController.move(position, widget.initialZoom);
  }

  @override
  Widget build(BuildContext context) {
    final center =
        _selected ?? widget.initial ?? MapCityCatalog.defaultCenter;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('地图选点', style: AppTextStyles.label),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: widget.initialZoom,
                    onTap: _onTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rc0.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 24,
                            height: 24,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        if (_selected != null)
                          Marker(
                            point: _selected!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: theme.colorScheme.primary,
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _locating
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : StudioGlassIconButton(
                          size: 36,
                          iconSize: 20,
                          tooltip: '定位到当前位置',
                          icon: Icons.my_location,
                          onPressed: _locateMe,
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selected == null
              ? '点击地图或定位按钮选择坐标'
              : '纬度 ${_selected!.latitude.toStringAsFixed(5)}，经度 ${_selected!.longitude.toStringAsFixed(5)}',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Row(
          children: [
            TextButton(
              onPressed: _selected == null
                  ? null
                  : () => setState(() => _selected = null),
              child: const Text('清除坐标'),
            ),
            const Spacer(),
            PrimaryButton(
              label: '确认位置',
              isExpanded: false,
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
            ),
          ],
        ),
      ],
    );
  }
}

Future<LatLng?> showSceneLocationPicker(
  BuildContext context, {
  LatLng? initial,
}) {
  return showModalBottomSheet<LatLng>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        0,
        AppDimensions.spacingMd,
        MediaQuery.paddingOf(context).bottom + AppDimensions.spacingMd,
      ),
      child: SceneLocationPicker(initial: initial),
    ),
  );
}
